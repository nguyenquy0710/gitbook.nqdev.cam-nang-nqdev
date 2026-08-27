#!/usr/bin/env python3
"""Query TiniX Repo Trending server actions and print clean JSON.

No third-party dependencies — uses only the Python standard library.

The site https://repo.tinix.ai loads its trending tables via Next.js "server
actions": a POST to the page URL carrying a `Next-Action` header whose value is
the action ID. Responses use the React Flight format, one `N:<json>` per line;
this script returns the JSON of the final data line (the one with the payload).

Usage examples:
  python3 tinix_api.py stats
  python3 tinix_api.py filters
  python3 tinix_api.py search "rag"
  python3 tinix_api.py rankings --type trending --days 7 --limit 10
  python3 tinix_api.py rankings --type all --sort stars --limit 5 --category "LLM"
  python3 tinix_api.py rankings --source huggingface --type trending --days 3
  python3 tinix_api.py rankings --type new --days 1 --limit 20 --sort updated
  python3 tinix_api.py rankings --search "vector" --days 30 --type all --limit 10
"""
import argparse
import json
import sys
import urllib.request

BASE_URL = "https://repo.tinix.ai/vi"

# Action ID -> (display name, help). Action IDs are Next.js server action IDs;
# they are stable per deploy but can change if the site is redeployed.
ACTIONS = {
    "rankings": "7f559d229b0244b6c901ead15dde1c17df810f253e",
    "stats": "7f8183294f4e4d7a1ab0764aa7fafe547f25737c8c",
    "filters": "7fca30e220e95f00f264a7415245d86811faee8cfa",
    "search": "40026f6a73aed05048b638684f1f77857e183f2a0f",
}

FILTER_TYPES = ["trending", "all", "new"]
SORTS = ["trend", "stars", "likes", "views", "recent", "updated"]
SOURCES = ["github", "huggingface"]


def post(action_id: str, args: list) -> object:
    body = json.dumps(args).encode("utf-8")
    req = urllib.request.Request(
        BASE_URL,
        data=body,
        method="POST",
        headers={
            "Next-Action": action_id,
            "Content-Type": "text/plain;charset=UTF-8",
            "Accept": "text/x-component",
            "User-Agent": "Mozilla/5.0 (skill tinix-repo-trending)",
        },
    )
    with urllib.request.urlopen(req, timeout=60) as resp:
        raw = resp.read().decode("utf-8", errors="replace")

    payload = None
    for line in raw.splitlines():
        line = line.strip()
        if not line or not line[0].isdigit():
            continue
        idx = line.find(":")
        if idx < 0:
            continue
        try:
            obj = json.loads(line[idx + 1:])
        except json.JSONDecodeError:
            continue
        # Prefer the object carrying the real data.
        if isinstance(obj, dict) and ("projects" in obj or "total" in obj):
            return obj
        payload = obj
    return payload


def cmd_stats() -> None:
    print(json.dumps(post(ACTIONS["stats"], []), ensure_ascii=False, indent=2))


def cmd_filters() -> None:
    print(json.dumps(post(ACTIONS["filters"], []), ensure_ascii=False, indent=2))


def cmd_search(query: str) -> None:
    if not query:
        sys.exit("error: search requires a query string")
    print(json.dumps(post(ACTIONS["search"], [query]), ensure_ascii=False, indent=2))


def cmd_rankings(args: argparse.Namespace) -> None:
    payload = {
        "days": args.days,
        "limit": args.limit,
        "offset": args.offset,
        "filterType": args.type,
    }
    for opt, key in (
        ("source", "source"),
        ("category", "category"),
        ("tag", "tag"),
        ("language", "language"),
        ("search", "searchQuery"),
        ("sort", "sortBy"),
        ("order", "sortOrder"),
        ("license", "license"),
    ):
        val = getattr(args, opt)
        if val is not None:
            payload[key] = val
    if args.min_stars is not None:
        payload["minStars"] = args.min_stars
    if args.min_downloads is not None:
        payload["minDownloads"] = args.min_downloads

    result = post(ACTIONS["rankings"], [payload])

    if args.list and isinstance(result, dict) and "projects" in result:
        for p in result["projects"]:
            score = p.get("momentumScore") or 0
            print(f"{p.get('rank', ''):>4} {p.get('fullName',''):<50} "
                  f"{p.get('source',''):<12} {p.get('primaryLanguage',''):<12} "
                  f"stars={p.get('stars',0):>9} gained={p.get('starsGained',0):>8} "
                  f"score={score:.1f}")
        print(f"\ntotal: {result.get('total', 0)}")
        return
    print(json.dumps(result, ensure_ascii=False, indent=2))


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Query TiniX Repo Trending data")
    sub = parser.add_subparsers(dest="cmd", required=True)

    sub.add_parser("stats", help="platform stats (total/trending/new projects)")
    sub.add_parser("filters", help="popular languages, hashtags, categories")
    s = sub.add_parser("search", help="project name suggestions for a query")
    s.add_argument("query", help="search text, e.g. rag, vector, docker")

    r = sub.add_parser("rankings", help="fetch trending/new/all projects")
    r.add_argument("--type", choices=FILTER_TYPES, default="trending",
                   help="filterType: trending (default), all, new")
    r.add_argument("--days", type=int, default=7,
                   help="look-back window in days (site presets: 1, 7, 30)")
    r.add_argument("--limit", type=int, default=20, help="number of results")
    r.add_argument("--offset", type=int, default=0, help="pagination offset")
    r.add_argument("--source", choices=SOURCES, help="github (default) or huggingface")
    r.add_argument("--category", help="category display name, e.g. 'LLM', 'AI Agent'")
    r.add_argument("--tag", help="hashtag filter, e.g. MCP, RAG, AI Agent")
    r.add_argument("--language", help="primary language, e.g. Rust, Python, Go")
    r.add_argument("--search", help="free-text search query")
    r.add_argument("--sort", choices=SORTS,
                   help="sortBy: trend, stars, likes, views, recent, updated")
    r.add_argument("--order", choices=["asc", "desc"], help="sortOrder")
    r.add_argument("--license", help="license, e.g. MIT")
    r.add_argument("--min-stars", type=int, help="min GitHub stars")
    r.add_argument("--min-downloads", type=int, help="min HuggingFace downloads")
    r.add_argument("--list", action="store_true",
                   help="print a compact table instead of full JSON")
    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()
    if args.cmd == "rankings":
        cmd_rankings(args)
    elif args.cmd == "stats":
        cmd_stats()
    elif args.cmd == "filters":
        cmd_filters()
    elif args.cmd == "search":
        cmd_search(args.query)


if __name__ == "__main__":
    main()
