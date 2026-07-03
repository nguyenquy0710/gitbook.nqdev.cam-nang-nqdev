# Cẩm nang NQDEV — Agent Guide

Vietnamese GitBook documentation site. **Not a code project** — no build/lint/test suite. Content is Markdown, deployed to GitHub Pages via `gitbook-cli`.

## Content

7 root "books" (`cheat-sheet/`, `cong-nghe/`, `cuoc-song/`, `devsecops/`, `hoi-dap/`, `lien-he/`, `prompts/`). Each has `SUMMARY.md` (nav TOC) and `README.md` (intro). No `book.json` — GitBook uses defaults.

**New articles always go in `opcode/<book>/`**, mirroring the source book's directory structure. Existing files in root books are never modified. `opcode/` does not yet exist — create it when adding the first article.

**Build artifact:** `_book/` (not committed; no root `.gitignore`; `.opencode/.gitignore` ignores `node_modules`, `package-lock.json`, `bun.lock`). `.gitbook/` dirs may appear after local `gitbook install` runs.

**CI gotcha:** Workflow runs `gitbook install && gitbook build` from repository root with no root `SUMMARY.md` or `book.json`. This likely produces an empty/broken site. Per-book build (`cd <book> && gitbook install && gitbook build`) is the reliable approach.

## Writing

Load the `viet-bai-gitbook` skill for full style guide, templates, and per-book content tables. Minimum per-article requirements:

- YAML `description:` front matter (<160 chars for SEO)
- GitBook syntax (`{% code %}`, `{% tabs %}`, `{% endcode %}`)
- Vietnamese text, English technical terms preserved
- Lowercase-kebab-case filenames with full Vietnamese diacritics
- After creating the `.md` file, add an entry in the source book's `SUMMARY.md` with path `opcode/<book>/file.md`

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
