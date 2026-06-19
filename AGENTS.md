# AGENTS.md

## Repository Overview

GitBook documentation site (`gitbook.nqdev.cam-nang-nqdev`). Vietnamese-language tech guides and cheat sheets. MIT licensed.

## Structure

7 independent books, each a top-level directory:

```
cheat-sheet/   # Bash, Git, HAProxy, Redis, Wireshark, Windows, Ubuntu commands
cong-nghe/     # .NET, Docker, SQL Server, Linux, Node.js, design patterns, tools
cuoc-song/     # Life content (books, health)
devsecops/     # DevSecOps (Ansible, Docker, VMware)
hoi-dap/       # Q&A, SQL help
lien-he/       # Contact, policies, sitemap
prompts/       # AI prompts (ChatGPT, Gemini, coding, writing, business)
```

Each book has its own `SUMMARY.md` (table of contents) and `README.md`. Images live in `.gitbook/assets/`.

## Key Files

- `.github/workflows/deploy_gitbook.yml` — CI/CD to GitHub Pages
- `LICENSE` — MIT
- `{book}/SUMMARY.md` — Navigation structure for each book

## Build & Deploy

```bash
# Local build (requires Node.js v14, gitbook-cli)
npm install -g gitbook-cli --legacy-peer-deps
cd <book-directory>
gitbook install
gitbook build    # Output: _book/
```

CI runs on `workflow_dispatch`: builds with GitBook CLI v14, deploys `_book/` to GitHub Pages.

## Content Conventions

- All documentation in Markdown
- Book titles and section names in Vietnamese
- GitBook uses `SUMMARY.md` for navigation (not file system order)
- Images stored in `.gitbook/assets/` per book
- No code to build, test, or lint — pure documentation

## Adding Content

1. Create `.md` file in the appropriate book directory
2. Add entry to that book's `SUMMARY.md` under the correct section
3. Place any images in `.gitbook/assets/` and reference with relative paths

## Notes

- Each book is self-contained — no shared configuration or dependencies
- `book.json` not present (GitBook cloud may auto-detect structure)
- Currently configured for root-level build (may require adjustment per book)
