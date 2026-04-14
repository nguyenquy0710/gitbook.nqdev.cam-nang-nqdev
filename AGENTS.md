# Repository-Specific Agent Instructions

## Project Overview
- This is a GitBook documentation project in Vietnamese covering various topics (DevSecOps, technology, life advice, prompts, cheat sheets)
- Content is organized in directories like `devsecops/`, `cong-nghe/`, `cuoc-song/`, `cheat-sheet/`, `prompts/`, `hoi-dap/`, etc.

## Build and Deployment
- Uses GitBook CLI for building the documentation site
- Deployment happens via GitHub Actions workflow (`.github/workflows/deploy_gitbook.yml`)
- Node.js v14 is required for compatibility with legacy peer dependencies
- Build command: `gitbook install && gitbook build`

## Directory Structure
- Content follows GitBook structure with SUMMARY.md files in each section
- Assets are stored in `.gitbook/assets/` directories within each section
- Main content directories: prompts, lien-he, hoi-dap, devsecops, cong-nghe, cuoc-song, cheat-sheet

## Development Workflow
- Run `npm install -g gitbook-cli --legacy-peer-deps` to install dependencies
- Use `gitbook serve` for local development server
- Content updates should maintain consistent Markdown formatting
- New sections should include appropriate SUMMARY.md files

## Working with Individual Sections
- **Critical**: When initializing or running GitBook commands for a specific section, always change to that section's directory first (e.g., `cd cong-nghe` before `gitbook install` or `gitbook init`)
- Each section (`cong-nghe/`, `devsecops/`, `cuoc-song/`, etc.) has its own `.gitbook/` configuration and should be treated as a standalone GitBook project
- Run `gitbook install && gitbook build` from within the specific section directory, not from root

## Important Notes
- All content is in Vietnamese
- Follow GitBook's standard directory structure and linking conventions
- Images and assets should be placed in local `.gitbook/assets/` directories
- Branch `obsidian` is the current active branch based on recent commits