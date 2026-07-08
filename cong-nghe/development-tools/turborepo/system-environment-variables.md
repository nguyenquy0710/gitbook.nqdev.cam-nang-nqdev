---
title: System Environment Variables
description: Learn about system environment variables that control Turborepo's behavior.
product: turborepo
type: reference
summary: Environment variables for configuring Turborepo's behavior, including remote caching, telemetry, and more.
related:
  - /docs/reference/configuration
---

# System Environment Variables

Turborepo's behavior can be modified using system environment variables. These variables can be used to control aspects like remote caching, telemetry, and more.

## Remote Caching

*   **`TURBO_TOKEN`**: Authentication token for remote caching. This is typically obtained after running `turbo login`.
*   **`TURBO_TEAM`**: The team associated with the remote cache. Used in conjunction with `TURBO_TOKEN`.
*   **`TURBO_API_URL`**: The URL for a self-hosted remote cache. If you are not using the managed Vercel remote cache, you can specify your own cache server URL here.
*   **`TURBO_REMOTE_CACHE_SIGNATURE_KEY`**: A secret key used for signing and verifying remote cache artifacts. This ensures the integrity and authenticity of cached data.

## Update Notifier

*   **`TURBO_NO_UPDATE_NOTIFIER`**: Disable the update notification that prompts you to update `turbo`. This is automatically disabled in CI environments but can be explicitly disabled via this variable.

## Telemetry

*   **`TURBO_TELEMETRY_DISABLED`**: Disable telemetry collection. By default, Turborepo sends anonymized usage data to help improve the tool.

## Other

*   **`TURBO_DRY`**: If set to `true`, Turborepo will only print the tasks it would run without actually executing them. Useful for debugging task graphs.
*   **`TURBO_FORCE`**: If set to `true`, Turborepo will ignore the cache and run all tasks. Useful for ensuring a clean build or troubleshooting cache issues.

---

[View full sitemap](/sitemap.md)