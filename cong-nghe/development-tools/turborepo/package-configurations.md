---
title: Package Configurations
description: Learn how to configure Turborepo tasks on a per-package basis.
product: turborepo
type: reference
summary: Configure Turborepo tasks within individual packages using the `turbo` property in `package.json`.
related:
  - /docs/reference/configuration
---

# Package Configurations

Turborepo allows for package-specific configurations that can override or extend the root `turbo.json` settings.

These configurations are defined within the `turbo` property of a package's `package.json` file.

## Example Package Configuration

```json
{
  "name": "@repo/ui",
  "dependencies": {
    "@repo/utils": "^1.0.0"
  },
  "scripts": {
    "build": "tsc",
    "lint": "eslint --ext .ts,.tsx ."
  },
  "turbo": {
    "dependencies": {
      "@repo/utils": "^1.0.0"
    },
    "pipeline": {
      "build": {
        "dependsOn": ["^build", "lint"]
      },
      "lint": {
        "outputs": []
      }
    }
  }
}
```

In this example:

*   `"@repo/utils": "^1.0.0"` under `"dependencies"` is a direct dependency that Turborepo's package graph will recognize.
*   `"build": { "dependsOn": ["^build", "lint"] }` overrides the root `turbo.json`'s `build` task to also depend on the `lint` task within this package.
*   `"lint": { "outputs": [] }` specifies that the `lint` task in this package produces no outputs to be cached.

## Overriding Root Configuration

Package configurations can override settings from the root `turbo.json`. For instance, if the root `turbo.json` defines a `build` task, a package's `turbo.pipeline.build` configuration will take precedence for that specific package.

This allows for granular control over how tasks are executed and cached across different parts of your monorepo.
