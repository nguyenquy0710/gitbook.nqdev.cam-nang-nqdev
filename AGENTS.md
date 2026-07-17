# Cẩm nang NQDEV — Agent Guide

Vietnamese GitBook documentation site. **Not a code project** — no build/lint/test suite. Content is Markdown, deployed to GitHub Pages via `gitbook-cli`.

## Content

7 root "books" (`cheat-sheet/`, `cong-nghe/`, `cuoc-song/`, `devsecops/`, `hoi-dap/`, `lien-he/`, `prompts/`). Each has `SUMMARY.md` (nav TOC) and `README.md` (intro). Root `SUMMARY.md` and `book.json` tie them together for a combined build.

**New articles go directly into the source book's directory** (e.g. `cong-nghe/<sub-dir>/bai-viet.md`), following the existing tree structure. Never create `opcode/`.

**Build artifact:** `_book/` (not committed; no root `.gitignore`; `.opencode/.gitignore` ignores `node_modules`, `package-lock.json`, `bun.lock`). `.gitbook/` dirs may appear after local `gitbook install` runs.

## Writing

Load the `viet-bai-gitbook` skill for full style guide, templates, and per-book content tables.

Minimum per-article requirements:

- YAML `description:` front matter (<160 chars for SEO)
- GitBook syntax (`{% code %}`, `{% tabs %}`, `{% endcode %}`)
- Vietnamese text, English technical terms preserved
- Lowercase-kebab-case filenames with full Vietnamese diacritics
- After creating the `.md` file, add an entry in the source book's `SUMMARY.md` with path relative to the book directory

## Deploy

Only manual trigger — no auto-deploy on push. **Requires Node.js v14** (gitbook-cli incompatible with newer versions).

```bash
npm install -g gitbook-cli --legacy-peer-deps
gitbook install && gitbook build   # output: _book/
```

Or trigger `deploy_gitbook.yml` workflow in `.github/workflows/`.

## Config

- `.opencode/` — OpenCode plugin (`@opencode-ai/plugin`) + `viet-bai-gitbook` skill
- `.github/workflows/deploy_gitbook.yml` — manual GH Pages deploy with Node 14
