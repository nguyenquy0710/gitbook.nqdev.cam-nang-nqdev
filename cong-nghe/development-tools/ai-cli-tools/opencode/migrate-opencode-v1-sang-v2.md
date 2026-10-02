---
description: >-
  Hướng dẫn migrate từ OpenCode V1 sang V2: breaking changes, lộ trình 5 bước,
  bảng đổi tên field, port plugin, MCP, compaction, skills.
---

# Migrate từ OpenCode V1 sang OpenCode V2

Bài này dành cho người **đang dùng OpenCode V1 ổn định** và cần lên V2 mà không phải viết lại cấu hình từ đầu. Tin tốt: phần lớn cấu hình V1 vẫn chạy được nguyên trạng trên V2, vì V2 đọc **cùng các vị trí file** và tự normalize trong memory.

Điểm cần lưu ý nhất, và cũng là điều dễ hiểu sai nhất: **OpenCode 1 và OpenCode 2 dùng chung lệnh `opencode`**, nên bạn **không thể cài song song hai bản như hai công cụ riêng biệt**.

{% hint style="info" %}
Nếu bạn chưa biết V2 có gì mới, đọc bài [OpenCode V2: Những thay đổi quan trọng](opencode-v2-nhung-thay-doi-quan-trong.md) trước. Bài này chỉ đi vào **chi tiết chuyển đổi thực tế**.
{% endhint %}

{% content-ref url="opencode-v2-nhung-thay-doi-quan-trong.md" %}
[OpenCode V2: Những thay đổi quan trọng](opencode-v2-nhung-thay-doi-quan-trong.md)
{% endcontent-ref %}

{% content-ref url="opencode-personal-ai-assistant.md" %}
[OpenCode - Personal AI Assistant](opencode-personal-ai-assistant.md)
{% endcontent-ref %}

***

## 1. Ba breaking change thật sự

Ngoài ba điểm dưới đây, chức năng V1 được hỗ trợ vẫn **tương thích** với V2. Một số field mà V1 schema chấp nhận nhưng không có bản V2 tương đương sẽ bị ignore — danh sách đầy đủ nằm ở mục **10. Accepted but unsupported fields**.

| # | Breaking change | Mức độ ảnh hưởng |
|:---|:---|:---|
| 1 | **Plugins** dùng plugin API mới | Cao — code V1 **không chạy** trên V2, phải port |
| 2 | **Server API và clients** có contract mới | Cao — integration gọi API phải viết lại |
| 3 | **Terminal client config** chuyển từ `tui.json(c)` phân lớp → một file global `cli.json` | Thấp — tự migrate |

{% hint style="info" %}
Nếu một hành vi V1 **được tài liệu mô tả là hỗ trợ** lại ngừng chạy trên V2, hãy coi đó là **compatibility bug** và báo issue, đừng mất công sửa cấu hình của mình.
{% endhint %}

### Lộ trình 5 bước

Bạn **không cần chuẩn bị gì cả** trước khi bắt đầu V2:

1. **Giữ nguyên** cấu hình và các định nghĩa file hiện có.
2. **Khởi động V2** và kiểm tra models, credentials, agents, permissions, MCP servers.
3. **Port plugins** — đây là phần bắt buộc, vì V1 plugin implementation không chạy trong V2.
4. **Port các integration** gọi server API.
5. **Chuyển cấu hình sang native V2 shape** khi bạn đã sẵn sàng. Bước này **tùy chọn**.

{% hint style="warning" %}
V1 và V2 dùng **chung** các vị trí cấu hình. Hãy giữ một bản copy của setup V1 trong lúc validate, và **đừng trỏ V1 vào các file đã chuyển sang native V2 shape**.
{% endhint %}

***

## 2. Cài V2

{% hint style="danger" %}
**Phải gỡ bản V1 do package manager quản lý trước khi cài V2.** V1 và V2 dùng chung lệnh `opencode`, và curl installer của V2 sẽ **thay thế** binary V1 chứ không cài cạnh nhau.
{% endhint %}

{% tabs %}
{% tab title="curl" %}

```bash
curl -fsSL https://opencode.ai/v2/install | bash
```

{% endtab %}
{% tab title="homebrew" %}

```bash
brew install anomalyco/tap/opencode-v2
```

{% endtab %}
{% tab title="npm" %}

```bash
npm install -g @opencode/cli
```

{% endtab %}
{% tab title="bun" %}

```bash
bun install -g --trust @opencode/cli
```

{% endtab %}
{% tab title="pnpm" %}

```bash
pnpm add -g --allow-build=@opencode/cli @opencode/cli
```

{% endtab %}
{% tab title="yarn" %}

```bash
yarn global add @opencode/cli
```

{% endtab %}
{% tab title="vite+" %}

```bash
vp install -g @opencode/cli
```

{% endtab %}
{% tab title="aur" %}

```bash
paru -S opencode-beta
```

{% endtab %}
{% endtabs %}

**Lưu ý khi cài:**

* **Postinstall:** npm package dùng postinstall script để chọn native binary `opencode` theo platform.
* **Quyền chạy script:** lệnh Bun và pnpm ở trên đã cho phép script cần thiết; Vite+ **không cần** flag bổ sung.
* **Windows:** các Windows package manager **không được hỗ trợ**.

### Binary tải tay

Nếu không dùng package manager, tải binary standalone theo version (docs đang ở `2.0.6`):

{% code title="Binary tải tay theo hệ điều hành" overflow="wrap" %}
```text
macOS       https://opencode.ai/files/bin/2.0.6/opencode-darwin-arm64.zip
            https://opencode.ai/files/bin/2.0.6/opencode-darwin-x64.zip
            https://opencode.ai/files/bin/2.0.6/opencode-darwin-x64-baseline.zip

Windows     https://opencode.ai/files/bin/2.0.6/opencode-windows-arm64.zip
            https://opencode.ai/files/bin/2.0.6/opencode-windows-x64.zip
            https://opencode.ai/files/bin/2.0.6/opencode-windows-x64-baseline.zip

Linux glibc https://opencode.ai/files/bin/2.0.6/opencode-linux-arm64.tar.gz
            https://opencode.ai/files/bin/2.0.6/opencode-linux-x64.tar.gz
            https://opencode.ai/files/bin/2.0.6/opencode-linux-x64-baseline.tar.gz

Linux musl  https://opencode.ai/files/bin/2.0.6/opencode-linux-arm64-musl.tar.gz
            https://opencode.ai/files/bin/2.0.6/opencode-linux-x64-musl.tar.gz
            https://opencode.ai/files/bin/2.0.6/opencode-linux-x64-baseline-musl.tar.gz
```
{% endcode %}

Bản `x64-baseline` dành cho CPU không hỗ trợ toàn bộ tập lệnh của `x64` thông thường.

### Docker và web

{% code title="Docker tag theo version" overflow="wrap" lineNumbers="true" %}
```bash
ghcr.io/anomalyco/opencode:2.0.0
```
{% endcode %}

{% code title="Mở giao diện web" overflow="wrap" lineNumbers="true" %}
```bash
$ opencode pair

  URLs      http://127.0.0.1:49374
  Username  opencode
  Password  ********
```
{% endcode %}

### Gỡ cài đặt

{% code title="Xem trước và gỡ OpenCode" overflow="wrap" lineNumbers="true" %}
```bash
opencode uninstall --dry-run   # xem trước những gì sẽ bị xoá
opencode uninstall             # gỡ, có xác nhận
opencode uninstall --keep-config --keep-data   # giữ config + session data
```
{% endcode %}

* **`--keep-config` (`-c`):** giữ file cấu hình.
* **`--keep-data` (`-d`):** giữ session data và snapshots; cache và state vẫn bị xoá.
* **`--force` (`-f`):** bỏ qua bước xác nhận, dùng cho noninteractive.
* **Cài bằng package manager:** dùng đúng package manager đã phát hiện. Cài bằng curl sẽ in ra lệnh cuối cùng để bạn tự xoá executable.
* OpenCode dừng registered background services và persistent terminals trước khi xoá global data, cache, config và state.

{% hint style="info" %}
Các thư mục global data, cache, config và state **dùng chung giữa các version và release channel**. Đó là lý do nên dùng `--keep-config --keep-data` khi muốn so sánh V1 với V2.
{% endhint %}

### Background service

Mặc định, OpenCode tìm hoặc khởi động **một shared background server** cho tài khoản của bạn; mọi client cục bộ đều kết nối vào server đó, và server nắm giữ sessions, configuration, integrations, permissions và tool execution.

{% code title="Chạy server riêng hoặc kết nối server cụ thể" overflow="wrap" lineNumbers="true" %}
```bash
opencode                                    # dùng shared server (mặc định)
opencode --standalone                       # server riêng, biệt lập
opencode --server http://localhost:4096     # kết nối server cụ thể
```
{% endcode %}

***

## 3. Cấu hình: V2 vẫn đọc cấu hình cũ

V2 đọc đúng những vị trí mà V1 đang dùng:

{% code title="Ba vị trí cấu hình" overflow="wrap" %}
```text
~/.config/opencode/opencode.json(c)
<project>/opencode.json(c)
<project>/.opencode/opencode.json(c)
```
{% endcode %}

* V2 **normalize** field V1 và native V2 trong memory, **không ghi lại file nguồn**.
* Cấu hình V1 hợp lệ vẫn được hỗ trợ, nên bạn **không cần convert gì** để thử hay dùng V2.

### Để OpenCode tự migrate

Format V1 vẫn được hỗ trợ, còn native V2 format là **tùy chọn** và giúp một số setting rõ hàng, dễ dùng hơn. Đường được khuyến nghị là **nhờ chính OpenCode** cập nhật giúp bạn — gửi prompt sau trong một session:

{% code title="Prompt migrate cấu hình" overflow="wrap" %}
```text
Migrate my OpenCode configuration, including file-based definitions, from the V1 format to the native V2 format.
Preserve its behavior and all unrelated settings.
```
{% endcode %}

OpenCode sẽ inspect toàn bộ file, áp dụng các thay đổi liên quan, và tránh viết lại những setting không cần đổi.

### Quy tắc khi trộn V1 và V2

* **Top level:** V1 và V2 có thể **coexist**. Khi cả hai cùng đặt một canonical value, **native V2 thắng**, bất kể thứ tự key trong JSON.
* **Không convert một lần là xong:** có thể làm dần.
* **Nested mixing có giới hạn:** OpenCode nhận ra mixed V1/V2 members bên trong `mcp`, `compaction` và `experimental`, nhưng **không** infer format đệ quy bên trong từng agent, provider, command hay model. Hãy giữ mỗi nested entry đó **hoàn toàn ở một format**.
* **Cảnh báo:** malformed values, unsupported legacy fields và giá trị V1/V2 xung đột sẽ sinh warning, còn các setting hợp lệ khác vẫn load bình thường.

{% hint style="success" %}
Vì normalize diễn ra trong memory, bạn có thể **thử native V2 shape** mà vẫn giữ file nguồn ở format V1. Đó là cách an toàn nhất để đánh giá trước khi commit thay đổi.
{% endhint %}

***

## 4. Bảng đổi tên field

Đây là phần lõi của việc chuyển sang native V2 shape. Mỗi mục cho bạn **cấu hình V1** và **cấu hình V2 tương đương**.

{% tabs %}
{% tab title="Sharing" %}

`autoshare` (deprecated) trở thành policy `share` tường minh:

{% code title="autoshare → share" overflow="wrap" lineNumbers="true" %}
```jsonc
// V1
{ "autoshare": true }

// V2
{ "share": "auto" }
```
{% endcode %}

Giá trị hợp lệ: `"manual"`, `"auto"`, `"disabled"`. Nếu file V1 đã dùng `share` thì không cần đổi gì.

{% endtab %}
{% tab title="Permissions & tools" %}

V1 gom permission effect **theo từng tool**. V2 dùng **một mảng `permissions` có thứ tự**, làm rõ precedence và các ngoại lệ.

{% code title="permission/tools → permissions" overflow="wrap" lineNumbers="true" %}
```jsonc
// V1
{
  "permission": {
    "bash": {
      "git push *": "ask"
    },
    "edit": "allow"
  },
  "tools": {
    "websearch": false
  }
}

// V2
{
  "permissions": [
    { "action": "shell", "resource": "git push *", "effect": "ask" },
    { "action": "edit", "resource": "*", "effect": "allow" },
    { "action": "websearch", "resource": "*", "effect": "deny" }
  ]
}
```
{% endcode %}

Permission action cũng đổi tên:

* **`bash` → `shell`**
* **`task` → `subagent`**
* **`write` và `patch` → `edit`**

Lưu ý `tools: { "websearch": false }` được diễn đạt lại thành một **deny rule** có resource `"*"`, thay vì một toggle bật/tắt riêng.

{% endtab %}
{% tab title="Agents" %}

Map `agent` (số ít) và map `mode` (deprecated) gộp thành **`agents`**. Entries đến từ map `mode` cũ trở thành **primary agents**.

{% code title="agent/mode → agents" overflow="wrap" lineNumbers="true" %}
```jsonc
// V1
{
  "agent": {
    "reviewer": {
      "prompt": "Review for correctness and missing tests.",
      "model": "anthropic/claude-sonnet-4-5",
      "variant": "high",
      "disable": false,
      "permission": {
        "edit": "deny"
      }
    }
  }
}

// V2
{
  "agents": {
    "reviewer": {
      "system": "Review for correctness and missing tests.",
      "model": "anthropic/claude-sonnet-4-5#high",
      "disabled": false,
      "permissions": [
        { "action": "edit", "resource": "*", "effect": "deny" }
      ]
    }
  }
}
```
{% endcode %}

Ánh xạ field:

* **`prompt` → `system`**
* **`disable` → `disabled`**
* **`variant` → gộp sau `#`** trong model reference
* **`temperature`, `top_p`, provider-specific `options` → `request.body`**
* **`maxSteps` → `steps`**
* **`permission` → `permissions`**

{% endtab %}
{% tab title="Commands" %}

Map `command` (số ít) thành **`commands`**, và `subtask` thành **`subagent`**. Variant riêng được gộp vào model.

{% code title="command → commands" overflow="wrap" lineNumbers="true" %}
```jsonc
// V1
{
  "command": {
    "review": {
      "template": "Review the current changes.",
      "model": "anthropic/claude-sonnet-4-5",
      "variant": "high",
      "subtask": true
    }
  }
}

// V2
{
  "commands": {
    "review": {
      "template": "Review the current changes.",
      "model": "anthropic/claude-sonnet-4-5#high",
      "subagent": true
    }
  }
}
```
{% endcode %}

* **`template`, `description`, `agent`** giữ nguyên tên.
* Legacy **`subtask`** vẫn được accept, nhưng **delegated commands nay chạy tự động trong background** và báo kết quả về parent session.

{% endtab %}
{% tab title="MCP servers" %}

V2 gom server dưới **`mcp.servers`**, đổi `enabled` thành phủ định **`disabled`**, và **tách mục đích timeout**.

{% code title="mcp → mcp.servers" overflow="wrap" lineNumbers="true" %}
```jsonc
// V1
{
  "mcp": {
    "playwright": {
      "type": "local",
      "command": ["npx", "@playwright/mcp"],
      "enabled": true,
      "timeout": 30000
    }
  }
}

// V2
{
  "mcp": {
    "servers": {
      "playwright": {
        "type": "local",
        "command": ["npx", "@playwright/mcp"],
        "disabled": false,
        "timeout": {
          "catalog": 30000,
          "execution": 30000
        }
      }
    }
  }
}
```
{% endcode %}

Các field OAuth của remote server dùng **snake_case**:

* **`clientId` → `client_id`**
* **`clientSecret` → `client_secret`**
* **`callbackPort` → `callback_port`**
* **`redirectUri` → `redirect_uri`**

Giá trị V1 `experimental.mcp_timeout` trở thành giá trị mặc định cho **cả** `mcp.timeout.catalog` và `mcp.timeout.execution`.

{% endtab %}
{% tab title="Compaction" %}

V2 gom budget token được giữ lại dưới **`keep`**, và đặt tên rõ hơn cho phần reserve.

{% code title="compaction → keep/buffer" overflow="wrap" lineNumbers="true" %}
```jsonc
// V1
{
  "compaction": {
    "preserve_recent_tokens": 8000,
    "reserved": 20000
  }
}

// V2
{
  "compaction": {
    "keep": {
      "tokens": 8000
    },
    "buffer": 20000
  }
}
```
{% endcode %}

* **`auto`** giữ nguyên tên.
* V2 **không có** native `tail_turns` hay `prune`; cả hai legacy field đều bị **ignore kèm warning**. Context gần đây được giữ theo **token budget** thay thế.

{% endtab %}
{% tab title="Skills" %}

V1 tách `paths` và `urls`; V2 gộp cả hai thành **một mảng có thứ tự**.

{% code title="skills → mảng thống nhất" overflow="wrap" lineNumbers="true" %}
```jsonc
// V1
{
  "skills": {
    "paths": ["./team-skills"],
    "urls": ["https://example.com/skills/"]
  }
}

// V2
{
  "skills": ["./team-skills", "https://example.com/skills/"]
}
```
{% endcode %}

Các file skill và việc tự động discover `.opencode/skills/` **không thay đổi**.

{% endtab %}
{% tab title="Providers" %}

Map `provider` (số ít) thành **`providers`**. V2 tách riêng package runtime, endpoint và request settings.

{% code title="provider → providers" overflow="wrap" lineNumbers="true" %}
```jsonc
// V1
{
  "provider": {
    "acme": {
      "npm": "@ai-sdk/openai-compatible",
      "api": "https://llm.example.com/v1",
      "options": {
        "apiKey": "{env:ACME_API_KEY}"
      }
    }
  }
}

// V2
{
  "providers": {
    "acme": {
      "package": "aisdk:@ai-sdk/openai-compatible",
      "settings": {
        "baseURL": "https://llm.example.com/v1",
        "apiKey": "{env:ACME_API_KEY}"
      }
    }
  }
}
```
{% endcode %}

* **`npm` → `package`**, và AI SDK package nhận tiền tố **`aisdk:`**.
* **`api` → `settings.baseURL`**.
* **`options`** được tách thành **`settings`, `headers`, `body`** theo vai trò của chúng với request.

**Hai namespace provider legacy đã được hợp nhất:**

| V1 provider ID | Canonical V2 provider ID |
|:---|:---|
| `azure-cognitive-services` | `azure` |
| `google-vertex-anthropic` | `google-vertex` |

Migration các field V1 không nhập nhằng (provider, agent, command, provider-filter) dùng các canonical ID này. Riêng top-level `model` **giữ nguyên provider ID** vì cú pháp đó vốn đã hợp lệ trong native V2 config — nhưng hãy cập nhật nó sang canonical ID khi migrate một legacy built-in provider.

{% endtab %}
{% tab title="Models & variants" %}

Model vẫn nested dưới provider, nhưng các field trở nên tường minh hơn:

* **`id` → `modelID`**
* **`tool_call` và `modalities` → `capabilities.tools`, `capabilities.input`, `capabilities.output`**
* **`status: "deprecated"` → `disabled: true`**
* **Cache cost: `cache_read`/`cache_write` → `cache.read`/`cache.write`**
* **Provider-specific `options` → `settings`**
* **V1 variants object → V2 array**, mỗi entry có `id`

{% code title="variants object → array" overflow="wrap" lineNumbers="true" %}
```jsonc
// V1
{
  "variants": {
    "high": {
      "reasoningEffort": "high"
    }
  }
}

// V2
{
  "variants": [
    {
      "id": "high",
      "settings": {
        "reasoningEffort": "high"
      }
    }
  ]
}
```
{% endcode %}

{% endtab %}
{% tab title="Snapshots & Media" %}

Hai thay đổi đơn giản, chỉ đổi tên khóa:

{% code title="snapshot/attachment → snapshots/media" overflow="wrap" lineNumbers="true" %}
```jsonc
// V1
{ "snapshot": false }
{ "attachment": { "image": { "auto_resize": true } } }

// V2
{ "snapshots": false }
{ "media": { "image": { "auto_resize": true } } }
```
{% endcode %}

* **`snapshot` → `snapshots`**, giá trị boolean không đổi.
* **`attachment` → `media`**, các nested image settings giữ nguyên tên.

{% endtab %}
{% tab title="References" %}

Map `reference` (số ít, deprecated) thành **`references`**:

{% code title="reference → references" overflow="wrap" lineNumbers="true" %}
```jsonc
// V1
{ "reference": { "docs": "../docs" } }

// V2
{ "references": { "docs": "../docs" } }
```
{% endcode %}

V1 vốn đã accept `references`, nên nếu file của bạn đã dùng tên này thì **không cần đổi**. Các entry giữ nguyên shape.

{% endtab %}
{% endtabs %}

***

## 5. Không cần migrate

Phần lớn field giữ nguyên shape, không cần chuyển đổi:

`shell`, `model`, `default_agent`, `watcher`, `formatter`, `instructions`, `enterprise`, `tool_output`.

### LSP: cấu hình còn, nhưng tính năng không còn

{% hint style="warning" %}
V2 **accept và giữ** cấu hình `lsp`, nhưng **không chạy language server, không expose LSP tools, và không sinh LSP diagnostics**. Hãy thay các workflow phụ thuộc những khả năng đó bằng **lint, typecheck hoặc compiler command** của project.
{% endhint %}

Đây là một trong những điểm dễ bỏ sót nhất, vì cấu hình vẫn còn trong file và parse không lỗi — bạn chỉ đơn giản là không còn diagnostics nào nữa.

### Provider filters → policies

Provider filters của V1 không có field native V2 tương ứng một-một, nhưng **hành vi vẫn được hỗ trợ** qua policies:

| V1 field | Cách V2 thực hiện |
|:---|:---|
| `enabled_providers` | Provider policy deny-by-default nội bộ, sau đó allow cho các provider được liệt kê |
| `disabled_providers` | Deny policy nội bộ cho các provider được liệt kê |
| `autoupdate` | `update`: `false` → `"disable"`, `"notify"` → `"notify"`, `true` → `"auto"` |
| `small_model` | Model selection cho built-in `title` agent — native V2 nên dùng `agents.title.model` |

{% hint style="info" %}
Bạn có thể **giữ nguyên** các field này ở V1 syntax. OpenCode normalize chúng mà không cảnh báo.
{% endhint %}

***

## 6. File-based definitions

### Agent files

V1 có thể dùng thư mục `agent/`, `agents/`, `mode/`, hoặc `modes/`; V2 vẫn discover **cả bốn**. Vị trí ưu tiên cho V2:

{% code title="Vị trí agent file ưu tiên" overflow="wrap" %}
```text
.opencode/agents/<name>.md
```
{% endcode %}

* File dưới `mode/` hoặc `modes/` biểu diễn **primary agents** — khi chuyển vào `agents/` phải thêm **`mode: primary`** vào frontmatter.
* File dưới `agent/` chuyển sang `agents/` **không cần đổi** path-derived ID.

Khi convert frontmatter sang native V2 fields:

* **Giữ Markdown body** làm system instructions của agent.
* **`prompt` → `system`** chỉ khi nó nằm trong JSON config — file body không cần field `system`.
* **`disable` → `disabled`** và **`permission` → `permissions`**.
* **Gộp `model` và `variant`** thành `provider/model#variant`.
* **`temperature`, `top_p`, provider-specific options → `request.body`**.

{% hint style="success" %}
V2 **tự translate** legacy agent frontmatter, nên toàn bộ các chỉnh sửa trên đều là **tùy chọn**.
{% endhint %}

### Command files

V1 dùng `command/` hoặc `commands/`; V2 discover cả hai. Vị trí ưu tiên:

{% code title="Vị trí command file ưu tiên" overflow="wrap" %}
```text
.opencode/commands/<name>.md
```
{% endcode %}

* Di chuyển file từ `command/` sang **cùng relative path** dưới `commands/` để giữ nguyên tên command.
* **Markdown body** vẫn là template của command; `description` và `agent` giữ nguyên tên.
* Đổi **`subtask` → `subagent`** để dùng tên native cho background delegation.
* Nếu frontmatter có `model` và `variant` tách riêng, nối variant vào model và bỏ field `variant`:

{% code title="Command frontmatter" overflow="wrap" lineNumbers="true" %}
```yaml
# V1
model: anthropic/claude-sonnet-4-5
variant: high
subtask: true

# V2
model: anthropic/claude-sonnet-4-5#high
subagent: true
```
{% endcode %}

### Skill files

V2 discover skills từ **cả** `.opencode/skill/` và `.opencode/skills/`. Layout ưu tiên:

{% code title="Layout skill ưu tiên" overflow="wrap" %}
```text
.opencode/skills/<skill-id>/SKILL.md
```
{% endcode %}

{% hint style="warning" %}
Hãy di chuyển **cả thư mục skill**, không chỉ file `SKILL.md`, để các script, reference và file hỗ trợ dùng đường dẫn relative vẫn hoạt động. Giữ nguyên **tên thư mục** để giữ skill ID.
{% endhint %}

Frontmatter và Markdown body hiện có **không cần rewrite** cho V2.

### Instruction files

* File **`AGENTS.md` hiện có giữ nguyên vị trí**.
* V2 discover file global `~/.config/opencode/AGENTS.md` và các `AGENTS.md` ambient **từ thư mục hiện tại ngược lên tới home**. Với project nằm ngoài home, việc discover **dừng ở project root**.

{% hint style="warning" %}
Nếu setup V1 của bạn dựa vào fallback **`CLAUDE.md`**, hãy chuyển hướng dẫn đó vào `AGENTS.md` phù hợp. V2 hiện chỉ discover `AGENTS.md`.

Vì hành vi V1 ngoài phạm vi API được kỳ vọng là tương thích, hãy **báo compatibility issue** kèm chi tiết project nếu bạn cần hỗ trợ.
{% endhint %}

***

## 7. Terminal client config

V2 thay các file **`tui.json(c)` phân lớp** của V1 bằng **một file global duy nhất**:

{% code title="Terminal client config" overflow="wrap" %}
```text
~/.config/opencode/cli.json
```
{% endcode %}

* **Terminal client sở hữu** file này; background service **không** load.
* Khi `cli.json` **chưa tồn tại**, lần khởi động terminal client V2 đầu tiên sẽ **tự migrate** các global `tui.json` setting được hỗ trợ cùng persisted preferences, và **giữ nguyên file V1**.
* **Project-local client config không được migrate**, vì cấu hình client của V2 là global.

{% hint style="info" %}
Đây là breaking change thứ 3, nhưng gần như không tốn công: quá trình tự động. Bạn chỉ cần biết rằng setting cũ nay nằm ở `cli.json` và project-level không còn tách riêng.
{% endhint %}

***

## 8. Plugins

Đổi tên `plugin` → `plugins`, và thay tuple package + options bằng một object:

{% code title="plugin → plugins" overflow="wrap" lineNumbers="true" %}
```jsonc
// V1
{
  "plugin": ["opencode-example-plugin", ["./plugin/local.ts", { "enabled": true }]]
}

// V2
{
  "plugins": [
    "opencode-example-plugin",
    {
      "package": "./plugin/local.ts",
      "options": { "enabled": true }
    }
  ]
}
```
{% endcode %}

V2 discover local plugin từ **cả** `.opencode/plugin/` và `.opencode/plugins/`; hãy dùng `.opencode/plugins/` cho file của V2.

{% hint style="danger" %}
**V1 plugin implementations KHÔNG chạy trong V2.** Chỉ di chuyển file hoặc đổi tên entry cấu hình là **không đủ** — bạn phải port entrypoints, hooks, tools, events và package exports.
{% endhint %}

### Cấu hình và discover

{% code title="Các dạng entry plugin trong V2" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "plugins": [
    "opencode-acme-plugin",
    "opencode-acme-plugin@1.2.0",
    "@acme/opencode-plugin",
    "./plugins/local",
    "../shared/plugin.ts",
    "/absolute/path/plugin.ts",
    "file:///home/me/plugins/local",
    {
      "package": "@acme/opencode-plugin",
      "options": { "agent": "reviewer", "strict": true }
    }
  ]
}
```
{% endcode %}

* **Đường dẫn tương đối** resolve từ config file chứa entry.
* **Plugin arrays** từ các config file áp dụng **từ precedence thấp đến cao**, thay vì replace lẫn nhau.
* **Discover:** file `.ts`/`.js` trực tiếp và các thư mục package nằm ngay cạnh trong mọi thư mục `.opencode/plugins/` đã discover.
* **Global plugin** dùng cùng layout dưới config directory: `~/.config/opencode/plugins/`.
* Thư mục `plugins/` nằm cạnh project-root `opencode.json(c)` **không** được discover tự động — hãy khai báo tường minh hoặc chuyển vào `.opencode/`.

{% code title="Layout discover" overflow="wrap" %}
```text
.opencode/
└── plugins/
    ├── concise.ts
    ├── reviewer.js
    └── acme-package/
```
{% endcode %}

### Bật/tắt plugin

Plugin entry được xử lý **theo thứ tự**. Tiền tố `-` với một ID hoặc wildcard để disable; `*` khớp mọi plugin; `.*` khớp **một tiền tố ID**. Một ID sau đó sẽ bật lại plugin đã bị tắt.

{% code title="Điều khiển plugin" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "plugins": ["*", "-opencode.provider.*", "opencode.provider.openai", "-acme.reviewer"]
}
```
{% endcode %}

Hai built-in plugin **bỏ qua** thao tác removal, để một repository không thể tắt enforcement:

* `opencode.config.policy`
* `opencode.provider.opencode` — kết nối Console cung cấp organization policy

### Quản lý bằng CLI

{% code title="Các lệnh quản lý plugin" overflow="wrap" lineNumbers="true" %}
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

* **`plugin check`** kiểm tra cập nhật cho server plugins và TUI-only package plugins.
* **`plugin update`** cập nhật mọi package lỗi thời; truyền một package target trong cấu hình để chỉ check/update package đó.
* **Bị bỏ qua:** local plugin và exact package revision.
* **Git package** hỗ trợ hosted shortcut, HTTPS và SSH, kể cả private repo dùng Git credentials hiện có:

{% code title="Cài plugin từ Git" overflow="wrap" lineNumbers="true" %}
```bash
opencode plugin add @acme/opencode-plugin@latest
opencode plugin add github:acme/opencode-plugin
opencode plugin add git+ssh://git@github.com/acme/opencode-plugin.git#main
opencode plugin add 'github:acme/plugins#main::path:packages/opencode-plugin'
```
{% endcode %}

Branch, tag, commit hash đầy đủ và selector `::path:` của npm đều được hỗ trợ. `plugin add` **không** nhận tarball và npm alias.

### Reload

{% code title="Reload plugin" overflow="wrap" lineNumbers="true" %}
```bash
touch .opencode/plugins/concise/index.ts
opencode service restart
```
{% endcode %}

Thay đổi trong các config directory được watch sẽ reload tự động. Lúc khởi động server, package plugin có cache được load ngay, package thiếu sẽ được cài ở background, và plugin npm/Git không pin sẽ được kiểm tra cập nhật mà không thay đổi bản đã cài. Exact npm version và full Git commit hash **giữ nguyên pin**. Thay đổi trong local dependency không được watch có thể vẫn cần restart OpenCode.

### CLI-only plugins

Plugin chỉ chạy ở CLI được cấu hình riêng và vẫn hoạt động khi bạn kết nối remote server:

{% code title="cli.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "plugins": ["opencode-acme-cli"]
}
```
{% endcode %}

***

## 9. Server API và clients

OpenCode 2 có server API **đã thiết kế lại**, dễ dùng hơn, cùng bộ client mới. Integration nào gọi V1 server API đều **phải** migrate sang V2 API.

{% code title="Package truy cập V2 API" overflow="wrap" lineNumbers="true" %}
```bash
npm install @opencode/client
```
{% endcode %}

Xem [API reference](https://opencode.ai/v2/docs/api/) được sinh tự động để biết endpoints, request types và responses.

{% hint style="warning" %}
Field `server` trong cấu hình JSON V1 là **accepted but unsupported** ở V2: hãy dùng V2 service và các server option tường minh.
{% endhint %}

***

## 10. Accepted but unsupported fields

V1 schema còn chấp nhận một số field **không có hành vi được hỗ trợ ở V2**. V2 sẽ **ignore** chúng và phát **warning**, để bạn không nhầm chúng là cấu hình đang hoạt động.

| Field V1 (không hỗ trợ) | Dùng thay bằng |
|:---|:---|
| `logLevel` | Biến môi trường `OPENCODE_LOG_LEVEL` khi khởi động OpenCode |
| `server` | V2 service và explicit server options; server API là intentional breaking change |
| `subagent_depth` (top-level) | `experimental.subagent_depth` |
| `compaction.tail_turns` | `compaction.keep.tokens` + checkpoint-based compaction |
| `compaction.prune` | `compaction.keep.tokens` + checkpoint-based compaction |
| Agent `name` (trong V1 JSON config) | Đặt tên qua đường dẫn file, hoặc key trong `agents` |
| MCP entry chỉ có `enabled`, thiếu `type` | Bắt buộc khai báo `type: "local"` hoặc `type: "remote"` |
| `experimental.batch_tool` | Không còn hỗ trợ |
| `experimental.openTelemetry` | Không còn hỗ trợ |
| `experimental.primary_tools` | Không còn hỗ trợ |
| `experimental.continue_loop_on_deny` | Không còn hỗ trợ |
| Provider `id` | Provider ID giờ là key trong map `providers` |
| Provider `whitelist` | Policies, hoặc model allow-list trong provider |
| Provider `blacklist` | Policies, hoặc model deny-list trong provider |
| Provider-model `release_date` | Không còn hỗ trợ |
| Provider-model `attachment` | `media` |
| Provider-model `reasoning` | Không còn hỗ trợ |
| Provider-model `temperature` | `settings` |
| Provider-model `experimental` | Không còn hỗ trợ |
| Provider-model `status` khác `"deprecated"` | Không còn hỗ trợ |
| Provider-model boolean `interleaved` | Không còn hỗ trợ |

{% hint style="info" %}
Việc ignore các field này là **có chủ đích**, không phải compatibility regression. Nếu V2 không giữ được một hành vi mà tài liệu mô tả là được hỗ trợ ở nơi khác trong hướng dẫn này, hãy báo issue theo hướng dẫn troubleshooting.
{% endhint %}

***

## 11. Checklist verify trước khi bỏ V1

{% hint style="success" %}
Verify model, provider credentials, agents, permissions, MCP servers và plugins trong **một project thực tế** trước khi dựa vào V2 cho công việc thường xuyên.
{% endhint %}

1. **Model và credentials** — đăng nhập lại bằng `/connect`, kiểm tra danh sách model hoạt động.
2. **Agents** — thử cả primary agent lẫn subagent, kiểm tra model được gán đúng.
3. **Permissions** — đối chiếu hành vi approval so với V1, đặc biệt các rule giới hạn `shell`.
4. **MCP servers** — xác nhận mọi server load được và tool xuất hiện đúng.
5. **Skills** — kiểm tra skill ID không đổi sau khi di chuyển thư mục.
6. **Plugins** — đây là mục dễ hỏng nhất, vì code V1 không chạy.
7. **Compaction** — theo dõi hành vi nén context trong session dài.
8. **Instructions** — xác nhận `AGENTS.md` vẫn được load đúng.

{% hint style="danger" %}
Giữ nguyên setup V1 cho tới khi bạn đã xác nhận được hành vi V2 cần, và **không trỏ V1 vào cấu hình đã convert sang native V2 shape**.
{% endhint %}

***

## Tài liệu tham khảo

* [V2 — Migrate from V1](https://opencode.ai/v2/docs/migrate-v1/)
* [V2 — Docs chính thức](https://opencode.ai/v2/docs)
* [V2 — CLI cài đặt](https://opencode.ai/v2/docs/cli/)
* [V2 — Plugins](https://opencode.ai/v2/docs/plugins/)
* [V2 — Agents](https://opencode.ai/v2/docs/agents/)
* [V2 — Permissions](https://opencode.ai/v2/docs/permissions/)
* [V2 — MCP servers](https://opencode.ai/v2/docs/mcp-servers/)
* [V2 — Skills](https://opencode.ai/v2/docs/skills/)
* [V2 — References](https://opencode.ai/v2/docs/references/)
* [V2 — Compaction](https://opencode.ai/v2/docs/compaction/)
* [V2 — Policies](https://opencode.ai/v2/docs/policies/)
* [V2 — API reference](https://opencode.ai/v2/docs/api/)
