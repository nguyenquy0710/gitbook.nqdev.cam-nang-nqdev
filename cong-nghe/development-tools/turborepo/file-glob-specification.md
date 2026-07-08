---
title: File Glob Specification
description: Learn about the glob patterns used in Turborepo for specifying files and directories.
product: turborepo
type: reference
summary: Glob pattern syntax used in turbo.json for task inputs, outputs, and more.
related:
  - /docs/reference/configuration
---

# File Glob Specification

Turborepo uses glob patterns to specify which files to include or exclude for tasks, caching, and environment variable invalidation.

The glob syntax aligns with the standard glob patterns used by [glob](https://github.com/isaacs/node-glob) and [minimatch](https://github.com/isaacs/minimatch) libraries.

## Glob Patterns

*   **`*`**: Matches any characters except path separators (`/`).
    *   Example: `*.ts` matches `a.ts` but not `src/a.ts`.
*   **`**`**: Matches any characters, including path separators.
    *   Example: `src/**/*.ts` matches `src/a.ts`, `src/sub/a.ts`, etc.
*   **`?`**: Matches any single character except path separators.
    *   Example: `?.ts` matches `a.ts` but not `ab.ts`.
*   **`[abc]`**: Matches any one of the characters inside the brackets.
    *   Example: `[ab].ts` matches `a.ts` and `b.ts`.
*   **`!(...)`**: Negates a pattern, excluding files that match.
    *   Example: `src/**/*.ts !src/**/*.test.ts` excludes test files.

## Usage in turbo.json

### Inputs

Specify which files Turborepo should track for cache invalidation:

```json
{
  "tasks": {
    "build": {
      "inputs": ["$TASKFILES", "!node_modules", "src/**/*.ts"]
    }
  }
}
```

### Outputs

Specify which files and directories are task artifacts and should be cached:

```json
{
  "tasks": {
    "build": {
      "outputs": ["dist/**", ".next/**"]
    }
  }
}
```

## Special Variables

*   **`$TASKFILES`**: A Turborepo-specific variable that refers to the default files relevant to the current task. This includes the `src/` directory, `package.json`, and other common configuration files.
*   **`!`**: The negation operator excludes files from a glob pattern.

## Common Patterns

| Pattern | Description |
|---|---|
| `dist/**` | All files in the `dist` directory |
| `**/*.ts` | All TypeScript files anywhere in the project |
| `src/**/*.ts !src/**/*.test.ts` | All TypeScript files except test files |
| `!node_modules` | Exclude the `node_modules` directory |
| `$TASKFILES` | Default files for the current task |

---

[View full sitemap](/sitemap.md)