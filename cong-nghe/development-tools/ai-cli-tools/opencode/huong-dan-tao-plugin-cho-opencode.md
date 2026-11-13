---
description: >-
  Hướng dẫn tạo plugin cho OpenCode V2: server part, đăng ký tool, hooks, cách
  load, publish npm, plugin TUI và xác minh kết quả.
---

# Hướng dẫn tạo plugin cho OpenCode V2

Plugin OpenCode là một package npm có thể gồm **server part**, **TUI part**, **GUI part** và **RPC part** tuỳ nhu cầu. Khác với V1, plugin viết cho OpenCode V1 **không chạy** trên V2 vì Server/Client API và Plugin API đã được tái thiết kế. Bài này hướng dẫn tạo plugin V2 từ đầu, bám theo docs chính thức.

{% hint style="warning" %}
Nếu bạn đang migrate plugin V1, hãy đọc thêm [Migrate từ OpenCode V1 sang OpenCode V2](migrate-opencode-v1-sang-v2.md) trước khi làm theo các bước dưới đây.
{% endhint %}

## Khái niệm cơ bản

Plugin là một package npm có thể có server part, TUI part, GUI part, RPC part hoặc bất kỳ kết hợp nào trong số đó. Mỗi part dùng SDK từ cùng dependency `@opencode/plugin`.

* **Server** (`.` hoặc `./server`): chạy trong OpenCode server, dùng `@opencode/plugin`. Thêm tool, hooks, integrations, commands, agents.
* **TUI** (`./tui`): chạy trong terminal UI, dùng `@opencode/plugin/tui`. Thêm commands, routes, slots, Markdown renderers.
* **GUI** (`./gui-experimental`): chạy trong OpenCode Desktop, dùng `@opencode/plugin/gui`.
* **RPC** (`./rpc`): contract typed mà server part implement và các part khác/clients gọi.

Server part dùng `@opencode/plugin` với default export `Plugin.define({ id, async setup(ctx) {...} })`. `setup` chạy khi plugin load và có thể trả về **cleanup function** chạy khi plugin unload. `id` phải ổn định, dùng cho storage và diagnostics.

## Yêu cầu

* **OpenCode V2** (binary mới, cài từ `https://opencode.ai/v2/install`).
* **Node.js + npm** để phát triển và publish package.
* **Kiến thức TypeScript cơ bản** (module, async/await, JSON Schema).

## Hướng dẫn thực hiện

### Bước 1: Plugin server tối thiểu

Tạo file tại `.opencode/plugins/hello/index.ts`:

{% code title="index.ts" overflow="wrap" lineNumbers="true" %}
```ts
import { Plugin } from "@opencode/plugin"

export default Plugin.define({
  id: "hello",
  async setup(ctx) {
    await ctx.storage.set("loaded", true)
    console.log(`loaded in OpenCode ${ctx.app.version}`)
    return () => console.log("unloaded")
  },
})
```
{% endcode %}

Plugin under `.opencode/plugins/` sẽ tự động load. `ctx.location` mô tả vị trí instance plugin được load (directory, workspaceID, project metadata).

### Bước 2: Đăng ký tool qua `ctx.tool.transform`

Transform là **đồng bộ**, **replayable** và mỗi transform xây trên các registration trước đó trong cùng domain. Vì vậy:

* Load dữ liệu ngoài **trước** callback transform.
* Không đặt side-effect "chạy một lần" bên trong callback (callback có thể được replay khi reload).
* Gọi `reload()` sau khi dữ liệu nguồn thay đổi.

Ví dụ thêm tool `greeting`:

{% code title="index.ts" overflow="wrap" lineNumbers="true" %}
```ts
import { Plugin } from "@opencode/plugin"

export default Plugin.define({
  id: "hello",
  async setup(ctx) {
    await ctx.tool.transform((editor) => {
      editor.namespace({ name: "acme", description: "Acme tools" })
      editor.add({
        name: "greeting",
        description: "Create a greeting",
        input: {
          type: "object",
          properties: { name: { type: "string" } },
          required: ["name"],
          additionalProperties: false,
        },
        execute: async (input) => {
          return { content: `Hello ${(input as { name: string }).name}!` }
        },
      })
    })
  },
})
```
{% endcode %}

Tool executor trả về `{ content: ... }`. Nếu cần huỷ khi session dừng, truyền `context.signal` vào các lệnh gọi có thể huỷ (ví dụ `fetch`).

### Bước 3: Hooks

Hooks chặn các thao tác live. Đăng ký hook trên domain tương ứng; nhiều plugin có thể đăng ký cùng hook và chạy theo thứ tự plugin.

{% code title="hooks.ts" overflow="wrap" lineNumbers="true" %}
```ts
// Sửa system/options trước khi model dispatch
await ctx.session.hook("context", (event) => {
  event.system.push({ type: "text", text: "Keep the review focused on correctness." })
  delete event.tools.write
  event.options.temperature = 0.2
  event.options.maxTokens = 8_000
})

// Chặn/kiểm tra trước khi tool thực thi
await ctx.tool.hook("execute.before", (event) => {
  // kiểm tra input trước khi tool chạy
})

// Can thiệp trước khi tạo shell
await ctx.shell.hook("create.before", (event) => {
  // ...
})

// Tự đánh giá permission
await ctx.permission.hook("evaluate", (event) => {
  // ...
})
```
{% endcode %}

{% hint style="info" %}
Transform và hook là hai cơ chế khác nhau: transform chỉnh sửa domain state (registry) theo kiểu replayable; hook chặn thao tác live đang diễn ra.
{% endhint %}

### Bước 4: Load plugin qua config `opencode.jsonc`

Plugin trong `.opencode/plugins/` tự load. Để load package đã publish hoặc thư mục plugin ở vị trí khác, thêm vào `plugins` trong `opencode.json(c)`:

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "plugins": [
    "opencode-acme-plugin",
    "opencode-acme-plugin@1.2.0",
    "@acme/opencode-plugin",
    "./plugins/local",
    "../shared/plugin",
    "/absolute/path/plugin",
    {
      "package": "@acme/opencode-plugin",
      "options": {
        "agent": "reviewer",
        "strict": true
      }
    }
  ]
}
```
{% endcode %}

* Đường dẫn tương đối resolve từ **file config chứa entry đó**.
* Local plugin path **phải là thư mục** (path trỏ file đơn bị bỏ qua).
* Plugin arrays từ nhiều config file được **áp dụng theo thứ tự precedence**, không thay thế nhau.
* Prefix ID hoặc wildcard bằng `-` để disable: `"-acme.reviewer"`, `"-opencode.fork-notice"`. Dùng `*` cho mọi plugin, `.*` để match prefix ID.
* `.opencode/plugins/` ở project và global (`~/.config/opencode/plugins/`) được auto-discover.

### Bước 5: Cấu trúc `package.json` để publish

{% code title="package.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "name": "opencode-acme-plugin",
  "version": "1.0.0",
  "type": "module",
  "exports": {
    ".": "./src/index.ts",
    "./tui": "./src/tui.tsx",
    "./gui-experimental": "./dist/gui-experimental.cjs",
    "./rpc": "./src/rpc.ts"
  },
  "files": ["src", "dist"],
  "dependencies": {
    "@opencode/plugin": "latest"
  },
  "peerDependencies": {
    "@opentui/core": ">=0.6.6",
    "@opentui/solid": ">=0.6.6",
    "solid-js": ">=1.9.0"
  }
}
```
{% endcode %}

* Export `./rpc` khi các plugin/clients khác cần import RPC contract mà không load implementation.
* Build GUI bundle trước khi publish và include qua `files`.
* Dùng versions tương thích với OpenCode release mục tiêu.

Publish:

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
npm publish
```
{% endcode %}

Quản lý package plugin bằng CLI:

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
opencode plugin add opencode-acme-plugin@1.2.0
opencode plugin list
opencode plugin list --builtin
opencode plugin check
opencode plugin update
opencode plugin update opencode-acme-plugin
opencode plugin remove opencode-acme-plugin@1.2.0
```
{% endcode %}

`plugin check` kiểm tra server, GUI-only và TUI-only package plugins. `plugin update` cập nhật mọi package cũ; truyền target để chỉ check/update package đó. Local plugin và exact revision bị skip.

### Bước 6 (tùy chọn): TUI plugin `./tui`

Tạo file `src/tui.tsx`:

{% code title="src/tui.tsx" overflow="wrap" lineNumbers="true" %}
```tsx
import { Plugin } from "@opencode/plugin/tui"

export default Plugin.define({
  id: "acme.tui",
  setup(context) {
    context.ui.toast.show({ message: "TUI plugin loaded", variant: "success" })

    context.keymap.layer(() => ({
      mode: "global",
      commands: [
        {
          id: "acme.status",
          title: "Show Acme status",
          group: "Acme",
          palette: true,
          run: async () => context.ui.toast.show({ message: "Ready" }),
        },
      ],
    }))

    return () => {}
  },
})
```
{% endcode %}

* Export `./tui` bên cạnh server part hoặc GUI part để tự load.
* Package **chỉ có TUI part** cấu hình trong `cli.json` để vẫn active khi kết nối remote server:

{% code title="cli.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "plugins": ["opencode-acme-plugin"]
}
```
{% endcode %}

* GUI part chỉ load từ global `opencode.jsonc` (mọi window Desktop).

## Xác minh kết quả

* Liệt kê plugin: `opencode plugin list` và `opencode plugin list --builtin`.
* Kiểm tra log server tại `~/.local/share/opencode/log/opencode.log`.
* Reload plugin: `touch .opencode/plugins/hello/index.ts` hoặc `opencode service restart`.

Kết quả mong đợi: log hiển thị `loaded in OpenCode <version>` khi plugin load, và cleanup `unloaded` khi unload/reload.

## Lưu ý quan trọng

{% hint style="danger" %}
Plugin V1 **không chạy** trên V2. Plugin API đã tái thiết kế; audit và cập nhật toàn bộ plugin trước khi chuyển. Xem [Migrate từ OpenCode V1 sang OpenCode V2](migrate-opencode-v1-sang-v2.md).
{% endhint %}

{% hint style="warning" %}
Transform là đồng bộ và replayable — **không** đặt side-effect one-time trong callback. Load dữ liệu trước callback, sau đó gọi `reload()` khi dữ liệu nguồn thay đổi.
{% endhint %}

* Local plugin path phải là **thư mục**, không phải file đơn.
* TUI-only plugin cấu hình trong `cli.json`.
* GUI part chỉ load từ global `opencode.jsonc`.
* ID plugin phải ổn định (dùng cho storage/diagnostics).

## Tài liệu tham khảo

* [OpenCode V2 — Plugins Overview](https://opencode.ai/v2/docs/build/plugins)
* [OpenCode V2 — Server Plugin](https://opencode.ai/v2/docs/build/plugins/server)
* [OpenCode V2 — TUI Plugin](https://opencode.ai/v2/docs/build/plugins/cli)
* [OpenCode V2 — Migrate V1](https://opencode.ai/v2/docs/build/plugins/migrate-v1)
* [OpenCode V2 — Configure Plugins](https://opencode.ai/v2/docs/plugins)
* {% content-ref url="migrate-opencode-v1-sang-v2.md" %}[Migrate từ OpenCode V1 sang OpenCode V2](migrate-opencode-v1-sang-v2.md){% endcontent-ref %}