# Cẩm nang NQDEV — Agent Guide

Vietnamese GitBook documentation site. **Not a code project** — no build/lint/test suite. Content is Markdown, deployed to GitHub Pages via `gitbook-cli`.

## Content

7 root "books" (`cheat-sheet/`, `cong-nghe/`, `cuoc-song/`, `devsecops/`, `hoi-dap/`, `lien-he/`, `prompts/`). Each has `SUMMARY.md` (nav TOC), `README.md` (intro), and optionally `.gitbook/assets/`.

**New articles always go in `opcode/<book>/`**, mirroring the source book's directory structure. Existing files in root books are never modified. The `opcode/` directory does not yet exist — create it when adding the first article.

## Writing

Load the `viet-bai-gitbook` skill for full style guide and templates. Minimum per-article requirements:

- YAML `description:` front matter (<160 chars for SEO)
- GitBook syntax (`{% code %}`, `{% tabs %}`, `{% endcode %}`)
- Vietnamese text, English technical terms preserved
- Lowercase-kebab-case filenames with full Vietnamese diacritics
- After creating the `.md` file, add an entry in the source book's `SUMMARY.md` with path `opcode/<book>/file.md`

## Deploy

```bash
npm install -g gitbook-cli --legacy-peer-deps   # Node.js v14 required
gitbook install && gitbook build                 # output: _book/
```

Or trigger the manual `deploy_gitbook.yml` workflow in `.github/workflows/`. No auto-deploy on push.
