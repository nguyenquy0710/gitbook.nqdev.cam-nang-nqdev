---
description: >-
  OpenCode V2: agent phân vai, phân quyền action + resource + effect, compaction,
  references, MCP Code Mode và Skills.
---

# OpenCode V2: Những thay đổi quan trọng

OpenCode V2 đánh dấu một bước chuyển mình quan trọng: từ **một công cụ CLI hỗ trợ chat và sửa code đơn thuần** sang **môi trường thực thi coding agent (agent runtime) toàn diện**. Nếu V1 trả lời câu hỏi "làm sao để sửa hàm này", thì V2 tự điều phối nhiều agent chuyên trách, tự phân quyền theo loại tài nguyên, tự nén context, và tự chọn đúng model cho từng công đoạn.

{% hint style="info" %}
Bài này là phần **chuyên sâu về V2**. Nếu bạn mới bắt đầu, hãy đọc bài tổng quan trước — nó phủ cài đặt, TUI, CLI, environment variables, tools, formatters, custom commands và plugin system.
{% endhint %}

{% content-ref url="opencode-personal-ai-assistant.md" %}
[OpenCode - Personal AI Assistant](opencode-personal-ai-assistant.md)
{% endcontent-ref %}

***

{% hint style="warning" %}
**Không cài song song mặc định.** Docs V2 ghi rõ: OpenCode 1 và OpenCode 2 **cùng dùng lệnh `opencode`** và không còn được cài song song theo mặc định. Phải gỡ bản V1 do package manager quản lý trước khi cài V2 — curl installer của V2 sẽ thay thế binary V1. Chi tiết trong bài [Migrate từ OpenCode V1 sang OpenCode V2](migrate-opencode-v1-sang-v2.md).
{% endhint %}

## Bối cảnh: V2 đang ở đâu?

* **Trạng thái:** V2 hiện ở **phiên bản Beta** (bản phát hành docs: `2.0.6`).
* **Cùng lệnh, cùng config:** V2 dùng chung lệnh `opencode` và đọc **cùng các vị trí cấu hình** với V1, nên cấu hình V1 hợp lệ vẫn chạy được.
* **Đường nâng cấp:** V2 nâng cấp `share`, `permission` → `permissions`, `mcp` → `mcp.servers`, `compaction` → `keep`/`buffer`, `agent` → `agents`… nhưng tất cả đều **tùy chọn**.

| | OpenCode V1 | OpenCode V2 |
|:---|:---|:---|
| Lệnh | `opencode` | `opencode` |
| npm package | `opencode-ai` | `@opencode/cli` |
| Homebrew tap | `anomalyco/tap/opencode` | `anomalyco/tap/opencode-v2` |
| Cài từ curl | `https://opencode.ai/install` | `https://opencode.ai/v2/install` |
| Docker tag | tag chung | `ghcr.io/anomalyco/opencode:2.0.0` |
| Tài liệu | [opencode.ai/docs](https://opencode.ai/docs) | [opencode.ai/v2/docs](https://opencode.ai/v2/docs) |
| Mô hình agent | Agent đơn lẻ ôm hết việc | Primary agent + subagents tách context |
| Phân quyền | Theo từng tool đơn lẻ | `action` + `resource` + `effect` |
| Plugin | API hiện hành | Server/Client API và Plugin API được tái thiết kế |

{% hint style="info" %}
Windows package manager **không được hỗ trợ** khi cài bằng npm/pnpm/yarn. Xem bài migration cho đầy đủ các lệnh cài theo từng công cụ.
{% endhint %}

***

## 1. Kiến trúc Agent phân vai

Thay vì bắt một agent duy nhất đảm nhận toàn bộ công việc — từ tra cứu, lên kế hoạch đến sửa code — V2 chia hệ thống thành **agent chính (primary agent)** và **agent phụ (subagent)** chạy trong **child session với context riêng biệt**. Đây là giải pháp trực tiếp cho vấn đề làm quá tải context.

### Bốn agent tích hợp sẵn

{% tabs %}
{% tab title="build" %}
**Mode:** `primary` — agent lập trình mặc định.

* **Vai trò:** viết code, sửa file, chạy công cụ, xử lý công việc lập trình thông thường.
* **Quyền mặc định:** tools được cho phép; đọc file môi trường nhạy cảm và truy cập ngoài workspace thì **hỏi phê duyệt**.
* **Bổ sung so với chính sách gốc:** cho phép dùng `question`.
{% endtab %}
{% tab title="plan" %}
**Mode:** `primary` — khám phá và lập kế hoạch mà không sửa file dự án.

* **Vai trò:** phân tích kiến trúc, thiết kế hướng tiếp cận, đề xuất kế hoạch triển khai.
* **Giới hạn:** bị chặn quyền chỉnh sửa file dự án thông thường; được phép ghi **file plan của OpenCode** (`~/.opencode/plan`) khi được yêu cầu.
* **Bổ sung so với chính sách gốc:** cho phép dùng `question`; chặn `edit` trừ file dưới `~/.opencode/plan`.
{% endtab %}
{% tab title="general" %}
**Mode:** `subagent` — đa dụng.

* **Vai trò:** nghiên cứu và quy trình làm việc nhiều bước, với tool access rộng.
* **Giới hạn:** **không** cho phép đặt câu hỏi và **không** được khởi chạy subagent mới.
{% endtab %}
{% tab title="explore" %}
**Mode:** `subagent` — chuyên đọc, read-only.

* **Vai trò:** tìm kiếm file, grep codebase, tra cứu tài liệu web — mà **không tự ý sửa code**.
* **Giới hạn:** chặn mọi hành động ngoài `read`, `glob`, `grep`, `webfetch`, `websearch`; hỏi phê duyệt cho thư mục ngoài workspace và đọc `.env`.
{% endtab %}
{% endtabs %}

Ngoài ra còn có các agent **ẩn** phục vụ bảo trì nội bộ: `compaction`, `title`, `summary` — không thể chọn trực tiếp. Agent ẩn chỉ gồm `compaction` giữ nguyên chính sách gốc, còn `title` và `summary` chặn toàn bộ hành động.

{% hint style="warning" %}
**V2 không còn agent `scout` tích hợp sẵn.** Nếu bạn đang dùng `scout`, hãy chuyển sang `explore` hoặc tự định nghĩa một custom agent thay thế.
{% endhint %}

### Ba mode của agent

| Mode | Hành vi |
|:---|:---|
| `primary` | Chạy làm agent chính cho một session. Đây là mặc định của custom agent mới. |
| `subagent` | Chỉ chạy trong child session thông qua tool `subagent`. |
| `all` | Chạy được cả hai vai trò. |

Subagent chạy với **context sạch** trong foreground hoặc background child session. Quyền `subagent` của agent cha kiểm soát agent cha được phép khởi chạy agent nào; **agent con dùng permissions do chính nó cấu hình**, không phải subset của agent cha.

{% code title="Giới hạn agent orchestrator chỉ được gọi một subagent" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "agents": {
    "orchestrator": {
      "permissions": [
        { "action": "subagent", "resource": "*", "effect": "deny" },
        { "action": "subagent", "resource": "reviewer", "effect": "allow" }
      ]
    }
  }
}
```
{% endcode %}

### Vị trí lưu agent

{% code title="Cấu trúc thư mục agent" overflow="wrap" lineNumbers="true" %}
```text
~/.config/opencode/agents/<name>.md    # Global, dùng cho mọi project
.opencode/agents/<name>.md             # Project-level
.opencode/agents/team/reviewer.md      # Đường dẫn lồng nhau → ID: team/reviewer
```
{% endcode %}

OpenCode dò thư mục `.opencode` của project từ thư mục hiện tại ngược lên tới project root.

### Tạo Custom Agent

Custom agent gộp **system prompt + model + permissions + hiển thị** vào một profile có tên. Ví dụ kinh điển — một Reviewer Agent chỉ đọc, cấm sửa source code và cấm chạy lệnh shell, trong khi Build Agent vẫn giữ đầy đủ quyền triển khai:

{% code title=".opencode/agents/reviewer.md — Reviewer read-only" overflow="wrap" lineNumbers="true" %}
```markdown
---
description: Reviews changes for correctness and regressions
mode: subagent
model: anthropic/claude-sonnet-4-5#high
permissions:
  - action: edit
    resource: "*"
    effect: deny
  - action: shell
    resource: "*"
    effect: deny
---

Review the current changes. List findings in severity order with file and line references.
```
{% endcode %}

Sau đó chỉ cần yêu cầu agent chính:

{% code title="Gọi subagent từ agent chính" overflow="wrap" %}
```text
Use the reviewer subagent to review my current changes.
```
{% endcode %}

### Các tuỳ chọn của agent

| Option | Mô tả |
|:---|:---|
| `description` | Giải thích mục đích. **Nên có cho subagent** — OpenCode dùng nó để model chọn đúng agent |
| `mode` | `primary`, `subagent` hoặc `all`; mặc định `primary` |
| `model` | `provider/model` kèm `#variant` tuỳ chọn, ví dụ `anthropic/claude-sonnet-4-5#high` |
| `system` | System prompt. Giá trị khác rỗng **thay thế** base prompt của provider cho agent đó |
| `permissions` | Danh sách quy tắc có thứ tự (xem phần 2) |
| `steps` | Số bước model tối đa, phải là số dương |
| `hidden` | Ẩn khỏi danh sách, khám phá tương tác và catalog subagent |
| `color` | Màu UI, mã hex 6 chữ số |
| `disabled` | Gỡ bỏ agent tích hợp sẵn hoặc custom agent |

{% hint style="success" %}
`steps` rất hữu ích để kiểm soát chi phí và tránh agent lặp vô hạn: ở **bước cuối cùng**, OpenCode thu hẹp tools và yêu cầu model tóm tắt bằng văn bản. Người dùng nhập input mới sẽ reset hạn mức.
{% endhint %}

{% code title="Đặt hạn mức bước cho một agent" overflow="wrap" lineNumbers="true" %}
```yaml
steps: 8
```
{% endcode %}

{% hint style="warning" %}
Đừng dùng các field top-level cũ trong cấu hình agent V2: `temperature`, `top_p`, `prompt`, `permission`, `tools`, `disable`, `maxSteps`. Chúng đã bị thay thế hoàn toàn.
{% endhint %}

### Định nghĩa agent bằng JSONC

{% code title="Định nghĩa agents trong opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "default_agent": "writer",
  "agents": {
    "writer": { "mode": "primary" },
    "reviewer": {
      "description": "Reviews current changes",
      "mode": "subagent",
      "system": "Report findings in severity order.",
      "permissions": [
        { "action": "edit", "resource": "*", "effect": "deny" },
      ],
    },
  },
}
```
{% endcode %}

Agent mặc định được chọn bằng `default_agent`, phải tồn tại, phải nhìn thấy được và phải hỗ trợ vai trò `primary`. Nếu không, OpenCode fallback về `build`, rồi tới agent `primary` nhìn thấy được đầu tiên. Thay đổi `default_agent` **không** thay agent đã lưu trên session đang tồn tại.

### Cách ghi đè agent tích hợp sẵn

Dùng **cùng ID** để ghi đè — các định nghĩa được gộp theo thứ tự cấu hình: giá trị scalar sau thay giá trị trước, request map gộp theo key, quy tắc permission được **nối thêm** (không thay thế).

{% code title="Ghi đè chính sách của build agent" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "permissions": [
    { "action": "shell", "resource": "*", "effect": "ask" }
  ],
  "agents": {
    "build": {
      "permissions": [
        { "action": "shell", "resource": "git status", "effect": "allow" }
      ]
    }
  }
}
```
{% endcode %}

***

## 2. Phân quyền granular và kiểm soát an toàn

V1 quản lý quyền chủ yếu theo **từng công cụ đơn lẻ**. V2 chuyển sang mô hình quy tắc rõ ràng dựa trên **bộ ba: hành động (action) + tài nguyên (resource) + hiệu lực (effect)**.

### Ba trường của một quy tắc

| Field | Ý nghĩa |
|:---|:---|
| `action` | Hành động/tool cần kiểm soát. Hỗ trợ wildcard. |
| `resource` | Giá trị bị tác động: đường dẫn, lệnh shell, URL, truy vấn, skill ID, agent ID. Hỗ trợ wildcard. |
| `effect` | `allow` (cho qua không hỏi), `deny` (chặn), `ask` (chờ quyết định từ client) |

### Cơ chế xét quy tắc

* Hệ thống xét các quy tắc **từ trên xuống dưới**; **quy tắc phù hợp xuất hiện sau cùng** được áp dụng.
* Thứ tự nạp: cấu hình ưu tiên thấp → global rules → agent rules (nối thêm sau cùng).
* **Nếu không có quy tắc nào khớp, hệ thống mặc định sẽ hỏi ý kiến người dùng** trước khi thực thi.
* Với thao tác kiểm tra nhiều tài nguyên (ví dụ patch chạm nhiều file): **bất kỳ `deny` nào cũng chặn toàn bộ**; nếu không thì bất kỳ `ask` nào cũng hỏi; nếu không thì cho phép.

### Chuẩn hóa tên gọi

V2 đổi tên một số công cụ để nhất quán hơn:

| V1 | V2 |
|:---|:---|
| `bash` | `shell` |
| `task` | `subagent` |
| `write`, `patch` | `edit` |
| `permission` (object) | `permissions` (mảng quy tắc) |

### Wildcard

| Pattern | Khớp |
|:---|:---|
| `*` | Zero hoặc nhiều ký tự, bao gồm `/` |
| `?` | Đúng một ký tự |
| Ký tự khác | Ký tự literal |

Pattern khớp với **toàn bộ giá trị đã chuẩn hóa**: dấu gạch chéo ngược được chuyển thành `/`, và so khớp **không phân biệt hoa thường** trên Windows. Một pattern shell kết thúc bằng ` *` cũng khớp cả lệnh không có tham số — `git status *` khớp cả `git status` lẫn `git status --short`.

### Ví dụ thực tế: đọc tất cả trừ `.env`, và Git có kiểm soát

{% code title="Chính sách phân quyền mẫu cho dự án thực tế" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "permissions": [
    { "action": "read", "resource": "*", "effect": "allow" },
    { "action": "read", "resource": "*.env", "effect": "deny" },
    { "action": "read", "resource": "secrets/*", "effect": "deny" },
    { "action": "shell", "resource": "*", "effect": "ask" },
    { "action": "shell", "resource": "git status *", "effect": "allow" },
    { "action": "shell", "resource": "git diff *", "effect": "allow" },
    { "action": "shell", "resource": "git push *", "effect": "deny" }
  ]
}
```
{% endcode %}

Cấu hình này cho phép agent đọc toàn bộ mã nguồn nhưng cấm đọc file nhạy cảm; cho `git status` và `git diff` chạy tự do, còn `git push` bị chặn hoàn toàn.

### Bảng action của V2

Tên action là chuỗi, nên **plugin có thể định nghĩa action riêng**.

| Action | Resource tương ứng |
|:---|:---|
| `read` | Đường dẫn nội bộ tương đối, hoặc đường dẫn tuyệt đối đã chuẩn hóa bên ngoài |
| `edit` | Đường dẫn đích cho `edit`, `write`, `patch` |
| `glob` | Glob pattern được yêu cầu |
| `grep` | Regular expression được yêu cầu — **không phải** đường dẫn tìm kiếm |
| `shell` | Chuỗi lệnh do scanner sinh ra; lệnh ghép có thể sinh nhiều resource |
| `subagent` | Agent ID đích |
| `skill` | Skill ID |
| `question` | `*` |
| `webfetch` | URL được yêu cầu |
| `websearch` | Truy vấn tìm kiếm |
| `external_directory` | Biên của thư mục ngoài, thường kết thúc bằng `/*` |
| `<server>_<tool>` | `*` cho tool MCP; ký tự không hợp lệ trong cả hai tên trở thành `_` |
| `execute` | `*`; điều khiển khả năng dùng Code Mode, tool lồng nhau tự áp dụng quy tắc riêng |

{% hint style="info" %}
`doom_loop` và `lsp` **không** còn là permission action của V2 Core. Nếu chính sách của bạn dùng chúng, hãy loại bỏ.
{% endhint %}

### Chính sách gốc mặc định

**Mọi agent** — kể cả custom agent — đều khởi đầu với chính sách gốc có thứ tự này:

{% code title="Chính sách gốc áp dụng cho mọi agent" overflow="wrap" lineNumbers="true" %}
```jsonc
[
  { "action": "*", "resource": "*", "effect": "allow" },
  { "action": "external_directory", "resource": "*", "effect": "ask" },
  { "action": "read", "resource": "*.env", "effect": "ask" },
  { "action": "read", "resource": "*.env.*", "effect": "ask" },
  { "action": "read", "resource": "*.env.example", "effect": "allow" }
]
```
{% endcode %}

Các agent tích hỵp sẵn nối thêm chính sách riêng:

| Agent | Chính sách bổ sung |
|:---|:---|
| `build` | Cho phép `question` |
| `plan` | Cho phép `question`; chặn `edit` trừ file dưới `~/.opencode/plan` |
| `general` | Chặn `question` và chặn khởi chạy subagent |
| `explore` | Chặn mọi thứ trừ `read`, `glob`, `grep`, `webfetch`, `websearch`; hỏi cho thư mục ngoài và `.env` |
| `title`, `summary` | Chặn toàn bộ hành động |
| `compaction` | Giữ nguyên chính sách gốc |

### external_directory: lớp phòng thủ cho thư mục ngoài workspace

Một đường dẫn nằm ngoài cả **Location đang hoạt động** lẫn worktree gốc của project sẽ cần phê duyệt `external_directory` **trước** khi được xét quyền `read`/`edit`.

{% code title="Cho đọc thư mục tham chiếu ngoài nhưng cấm sửa" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "permissions": [
    { "action": "external_directory", "resource": "~/projects/reference/*", "effect": "allow" },
    { "action": "read", "resource": "~/projects/reference/*", "effect": "allow" },
    { "action": "edit", "resource": "~/projects/reference/*", "effect": "deny" }
  ]
}
```
{% endcode %}

Với `external_directory`, `read` và `edit`, tiền tố `~`, `~/`, `$HOME`, `$HOME/` được mở rộng khi nạp cấu hình. **Resource của `shell` giữ nguyên text lệnh** và không mở rộng các giá trị này.

{% hint style="danger" %}
`shell` chạy với **quyền filesystem, process và network của chính user đang chạy**. Việc suy luận thư mục từ text lệnh chỉ là best effort — hãy ưu tiên **allowlist hẹp** cho `shell` thay vì cố nhận diện mọi lệnh nguy hiểm.
{% endhint %}

### Phê duyệt và lưu quy tắc

Khi một quy tắc resolve thành `ask`, client có thể trả lời:

| Lựa chọn | Reply | Kết quả |
|:---|:---|:---|
| Allow once | `once` | Chỉ duyệt yêu cầu đang chờ |
| Allow always | `always` | Duyệt và lưu pattern đề xuất của tool cho project |
| Reject | `reject` | Từ chối yêu cầu này **và mọi yêu cầu phê duyệt còn chờ** trong session |

{% hint style="warning" %}
Approval đã lưu là quy tắc `allow` **bền vững, giới hạn theo project**. Chúng **không bao giờ** ghi đè một `deny` đã cấu hình. Hãy rà soát và xoá các approval quá rộng không còn cần.
{% endhint %}

### Policies: lớp hard-deny cho tổ chức

Một **policy** có thể hard-deny **sau khi** các quy tắc và approval đã chạy — nó biến `allow` hoặc `ask` thành `deny` và **không bao giờ cấp quyền**.

{% code title="Chặn cứng lệnh sudo bằng policy" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "experimental": {
    "policies": [
      { "action": "permission", "resource": "shell:sudo *", "effect": "deny" }
    ]
  }
}
```
{% endcode %}

Policy toàn cục và policy do Console quản lý **ghi đè cấu hình project** — đây là cách tổ chức chặn một lệnh mà repository vốn cho phép.

### Portable shell scanner

Bật scanner thử nghiệm bằng `experimental.portable_shell_scanner: true`. Scanner này **thay thế** tree-sitter scanner mặc định, không phải fallback. Lệnh mà portable scanner không phân tích được sẽ trả về **lỗi scanner**, không phải từ chối permission.

***

## 3. Quản lý Context và tính năng thực tế

### Compaction dựa trên Checkpoint

Khi context tiến gần giới hạn, OpenCode tự động tóm tắt mọi thứ **trừ phần hội thoại gần nhất**, mặc định khoảng **15.000 token**. Bản tóm tắt được đặt **phía trước** phần hội thoại gần đó, và session tiếp tục từ đó.

{% code title="Cơ chế compaction" overflow="wrap" %}
```text
before   [ system prompt ][ older conversation ............ ][ recent 15k ][ pending work ]
after    [ system prompt ][ summary ][ recent 15k ][ pending work ]
```
{% endcode %}

Model nhìn thấy bản tóm tắt như hội thoại quá khứ. Những lần compaction sau **cập nhật cùng một bản tóm tắt** thay vì bắt đầu lại.

{% hint style="success" %}
Bản tóm tắt được cấu trúc để **agent khác có thể tiếp tục công việc**: mục tiêu và yêu cầu, các quyết định đã đưa ra, công việc đã hoàn thành và đang dang dở, blocker, bước tiếp theo, và các file liên quan.
{% endhint %}

{% code title="Cấu hình compaction" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "compaction": {
    "auto": true,
    "keep": { "tokens": 15000 },
    "buffer": 20000
  }
}
```
{% endcode %}

| Field | Mặc định | Hành vi |
|:---|:---|:---|
| `auto` | `true` | Tự compact gần giới hạn context, và phục hồi một lần khi provider từ chối request quá dài |
| `keep.tokens` | `15000` | Số token hội thoại gần nhất được giữ bên cạnh bản tóm tắt |
| `buffer` | `10%` giới hạn | Số token cần giữ trống dưới giới hạn model. Giá trị lớn hơn → bắt đầu compact sớm hơn |

{% hint style="warning" %}
Compaction là **lossy** — nó có thể mất chi tiết. Tăng `keep.tokens` khi chi tiết gần đây quan trọng, hoặc tự yêu cầu compact trước khi bản tự động kích hoạt. Cả `keep.tokens` và `buffer` đều nhận số nguyên không âm.
{% endhint %}

#### Native compaction của provider

Mặc định OpenCode tự viết bản tóm tắt bằng model của session. Một số provider có thể compact phía họ — bật qua `settings.compaction` theo provider hoặc model:

{% code title="Bật native compaction cho OpenAI" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "providers": {
    "openai": {
      "settings": { "compaction": { "type": "native" } },
      "models": {
        "gpt-4.1": { "settings": { "compaction": { "type": "summary" } } }
      }
    }
  }
}
```
{% endcode %}

Với native compaction, provider trả về một **item mã hoá, không đọc được** đại diện cho hội thoại cũ.

| Chủ đề | Hành vi |
|:---|:---|
| Hỗ trợ | OpenAI Responses models; độ hỗ trợ thay đổi theo deployment và model |
| Ngưỡng | Cùng `auto` và `buffer` như summary compaction |
| Tính di động | Checkpoint mã hoá chỉ dùng được với **cùng provider, model, endpoint**. Đổi model → session tiếp tục từ hội thoại gốc |
| Quá dài | Nếu provider từ chối vì quá dài, OpenCode thử lại với request nhỏ hơn; **không** chuyển sang summary |

#### Giới hạn của compaction

| Giới hạn | Kết quả |
|:---|:---|
| Model | Dùng model của session. Không có model compaction riêng. |
| Lịch sử | Cần hội thoại cũ để thay thế. Không tạo được chỗ khi request chủ yếu là instructions và tool schemas cố định |
| Kích thước | Nếu phần cần compact vốn đã quá dài, OpenCode gửi phiên bản text rút gọn và có thể bỏ các lượt trao đổi cũ nhất |
| Phục hồi | Request bị từ chối vì quá dài được compact và thử lại **một lần**; lần từ chối thứ hai trả về lỗi |

{% code title="Trường hợp compaction không giúp được" overflow="wrap" %}
```text
128k context = 120k fixed instructions and tools + 8k conversation
```
{% endcode %}

{% hint style="info" %}
**Migration từ V1:** V1 dùng hành vi tail-turn và pruning. V2 dùng **summary** kèm `compaction.keep.tokens`.
{% endhint %}

### `/undo` và `/redo` tích hợp Git snapshot

Ngoài việc quay lại lịch sử trò chuyện, `/undo` và `/redo` ở V2 còn **phục hồi được trạng thái file code** tương ứng nếu snapshot được ghi nhận thành công.

{% hint style="warning" %}
Cơ chế này dựa trên Git — **project của bạn bắt buộc phải là một Git repository** thì `/undo` và `/redo` mới hoạt động trọn vẹn.
{% endhint %}

### References: tham chiếu context ngoài workspace

References cho phép khai báo và tham chiếu các nguồn context **ngoài workspace chính** — thư mục local khác, kho Git dùng chung, SDK nội bộ — qua gợi ý `@`, mà **không cần copy mã nguồn vào dự án hiện tại**.

{% tabs %}
{% tab title="Thư mục local" %}
{% code title="Khai báo references local" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "references": {
    "docs": {
      "path": "../product-docs",
      "description": "Use for product behavior and terminology"
    },
    "design-system": {
      "path": "../design-system",
      "description": "Use when working with components or design tokens"
    }
  }
}
```
{% endcode %}

Dạng rút gọn bằng chuỗi khi không cần trường khác:

{% code title="Dạng rút gọn" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "references": {
    "docs": "../docs",
    "shared": "~/work/shared"
  }
}
```
{% endcode %}
{% endtab %}
{% tab title="Kho Git" %}
{% code title="Tham chiếu kho Git từ xa" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "references": {
    "effect": { "repository": "Effect-TS/effect", "branch": "main" },
    "internal-sdk": {
      "repository": "git@gitlab.example.com:platform/sdk.git",
      "branch": "release/v2"
    },
    "sdk": "example/sdk"
  }
}
```
{% endcode %}

Hỗ trợ: GitHub `owner/repo`, Git URL, dạng `host/path`, và remote kiểu SCP. **Không hỗ trợ** kho `file:` local. Thiếu `branch` thì checkout default branch của remote.
{% endtab %}
{% tab title="Lưu trữ & refresh" %}
OpenCode chuẩn hóa mỗi remote và lưu **một checkout cho mỗi cặp remote + branch** trong thư mục data toàn cục:

{% code title="Cấu trúc lưu trữ checkout" overflow="wrap" lineNumbers="true" %}
```text
opencode/repos/<host>/<repository-path>

// Ví dụ trên Linux
~/.local/share/opencode/repos/github.com/Effect-TS/effect

// Có branch rõ ràng → thêm hậu tố @<branch>
~/.local/share/opencode/repos/github.com/Effect-TS/effect@main
```
{% endcode %}

* Kho thiếu được **clone bất đồng bộ** — prompt không chờ.
* Checkout có sẵn được kiểm tra nền khi references load/reload và sau mỗi prompt mới.
* Một checkout đủ điều kiện refresh nếu lần thử gần nhất **từ 24 giờ trở lại**.
{% endtab %}
{% endtabs %}

#### Ví dụ thực tế

Khi muốn so sánh cách triển khai hiện tại với thư viện nội bộ:

{% code title="Đối chiếu với SDK ngoài workspace" overflow="wrap" lineNumbers="true" %}
```text
So sánh cách triển khai hiện tại với @sdk/src/client.ts
```
{% endcode %}

Agent đọc file tham chiếu để đối chiếu mà **không có quyền chỉnh sửa thư mục SDK** đó.

{% hint style="warning" %}
References **không cấp thêm tool permission nào**. Truy cập ra ngoài Location vẫn tuân theo quy tắc tool bình thường và permission `external_directory`; việc chỉnh sửa vẫn cần quyền `edit` tương ứng.

Checkout đã cache được **dùng chung và có thể được refresh trong lúc agent đang dùng** — tránh chỉnh sửa checkout cache vì một lần refresh sẽ reset nó.
{% endhint %}

{% hint style="info" %}
Chỉ references **có `description`** mới được giới thiệu tự động trong agent instructions (kèm alias và đường dẫn đã resolve). Reference không có `description` vẫn dùng được qua client nhưng không được quảng bá.
{% endhint %}

***

## 4. Chuẩn hóa MCP, Code Mode và Skills

### Cấu trúc `mcp.servers`

{% hint style="warning" %}
V2 **không** đặt tên server trực tiếp dưới `mcp`. Toàn bộ server nằm trong `mcp.servers`. Cấu hình project ưu tiên cao hơn sẽ **thay thế toàn bộ object server** cùng tên — nên dùng tên khác nhau cho các kết nối/tài khoản riêng biệt.
{% endhint %}

{% tabs %}
{% tab title="Local (stdio)" %}
{% code title="Cấu hình local MCP server" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "servers": {
      "everything": {
        "type": "local",
        "command": ["npx", "-y", "@modelcontextprotocol/server-everything"],
        "cwd": ".",
        "environment": {
          "LOG_LEVEL": "info",
          "MCP_API_KEY": "{env:MCP_API_KEY}"
        }
      }
    }
  }
}
```
{% endcode %}

| Field | Bắt buộc | Mô tả |
|:---|:---|:---|
| `type` | Có | Phải là `"local"` |
| `command` | Có | Executable kèm arguments |
| `cwd` | Không | Thư mục chạy process; đường dẫn tương đối resolve từ workspace |
| `environment` | Không | Biến được thêm vào process environment kế thừa |
| `disabled` | Không | Ngăn kết nối khi `true` |
| `codemode` | Không | Đặt `false` để expose tool trực tiếp. Mặc định `true` |
| `timeout` | Không | Ghi đè timeout của server |
| `protocol` | Không | `legacy` (mặc định), `auto`, hoặc `2026-07-28` |

{% hint style="info" %}
Dùng `{env:NAME}` để thay thế biến môi trường. **Biểu thức shell như `$NAME` không được mở rộng** trong chuỗi JSON.
{% endhint %}
{% endtab %}
{% tab title="Remote (Streamable HTTP)" %}
{% code title="Cấu hình remote MCP server" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "servers": {
      "context7": {
        "type": "remote",
        "url": "https://mcp.context7.com/mcp",
        "oauth": false,
        "headers": {
          "CONTEXT7_API_KEY": "{env:CONTEXT7_API_KEY}"
        }
      }
    }
  }
}
```
{% endcode %}

| Field | Bắt buộc | Mô tả |
|:---|:---|:---|
| `type` | Có | Phải là `"remote"` |
| `url` | Có | Endpoint Streamable HTTP tuyệt đối |
| `headers` | Không | HTTP headers gửi tới endpoint |
| `oauth` | Không | Cấu hình OAuth, hoặc `false` để tắt OAuth |
| `disabled` | Không | Ngăn kết nối khi `true` |
| `codemode` | Không | Mặc định `true` |
| `timeout` | Không | Ghi đè timeout của server |
| `protocol` | Không | `legacy` (mặc định), `auto`, hoặc `2026-07-28` |

Chỉ dùng `oauth: false` khi server **hoàn toàn** dùng API key hoặc header credential.
{% endtab %}
{% tab title="OAuth, PKCE" %}
Remote server **mặc định dùng OAuth**. OpenCode tự khám phá authorization server, dùng **PKCE**, làm mới token, và thử **dynamic client registration** khi được hỗ trợ. Credentials nằm ngoài cấu hình project.

{% code title="Đăng ký client có sẵn" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "mcp": {
    "servers": {
      "company-tools": {
        "type": "remote",
        "url": "https://mcp.example.com/mcp",
        "oauth": {
          "client_id": "{env:MCP_CLIENT_ID}",
          "client_secret": "{env:MCP_CLIENT_SECRET}",
          "scope": "tools:read tools:execute",
          "callback_port": 19876,
          "redirect_uri": "http://127.0.0.1:19876/callback"
        }
      }
    }
  }
}
```
{% endcode %}

| Field | Mô tả |
|:---|:---|
| `client_id` | Client ID đăng ký sẵn. Bỏ trống để thử dynamic registration |
| `client_secret` | Secret cho client đăng ký sẵn |
| `scope` | Scopes cách nhau bởi dấu cách |
| `callback_port` | Cổng callback local, từ `1` đến `65535` |
| `redirect_uri` | URI loopback đã đăng ký |
| `auth_server_metadata_url` | URL tài liệu metadata OAuth/OIDC của authorization server |

V2 dùng **snake_case** cho các field OAuth. Quản lý qua CLI:

{% code title="Các lệnh quản lý MCP" overflow="wrap" lineNumbers="true" %}
```bash
opencode mcp add context7 --url https://mcp.context7.com/mcp
opencode mcp add context7 --global --url https://mcp.context7.com/mcp
opencode mcp list
opencode mcp auth sentry
opencode mcp logout sentry
```
{% endcode %}

{% hint style="info" %}
Dùng `disabled`, **không** dùng `enabled`, để giữ một server đã cấu hình mà không kết nối. Trong TUI, chạy `/mcps` để xem, kết nối, ngắt kết nối hoặc xác thực server.
{% endhint %}
{% endtab %}
{% endtabs %}

### Timeouts và protocol version

{% code title="Cấu hình timeout theo phạm vi" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "mcp": {
    "timeout": {
      "startup": 45000,
      "catalog": 30000,
      "execution": 600000
    },
    "servers": {
      "slow-tools": {
        "type": "remote",
        "url": "https://mcp.example.com/mcp",
        "timeout": { "catalog": 60000 }
      }
    }
  }
}
```
{% endcode %}

| Timeout | Mặc định | Áp dụng cho |
|:---|:---|:---|
| `startup` | 30 giây | Kết nối transport và khởi tạo server |
| `catalog` | 30 giây | Liệt kê tools, prompts, resources, resource templates |
| `execution` | 12 giờ | Tool calls, prompt retrieval, resource reads |

| `protocol` | Hành vi |
|:---|:---|
| `legacy` | Mặc định. Gửi `initialize`, nói protocol tới bản `2025-11-25` |
| `auto` | Dò bằng `server/discover` cho bản `2026-07-28`, fallback về `legacy` |
| `2026-07-28` | Bắt buộc bản `2026-07-28`; kết nối thất bại với server cũ |

### Code Mode

{% hint style="success" %}
**Code Mode là mặc định trong V2.** Với MCP server chứa **quá nhiều công cụ**, Code Mode gom tool theo namespace thay vì đưa toàn bộ danh sách tool vào prompt — giúp tránh làm nặng context của model.

{% code title="Tool được gom theo namespace server" overflow="wrap" %}
```text
tools.context_7.resolve_library_id(...)
```
{% endcode %}

Đặt `codemode: false` khi tool của server phải nằm trên **native tool list** của provider.
{% endhint %}

Action `execute` điều khiển khả năng dùng Code Mode; các tool lồng nhau tự áp dụng quy tắc riêng. Muốn ẩn hoặc chặn tool mà không ngắt server, dùng permission action khớp tên đã chuẩn hóa:

{% code title="Chặn toàn bộ tool của context7" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "permissions": [
    { "action": "context7_*", "resource": "*", "effect": "deny" }
  ]
}
```
{% endcode %}

### Quy trình Skills

Các quy trình làm việc chuẩn — review pull request, chuẩn bị bản release, kiểm tra migration database — được đóng gói thành skill. Mô hình **chỉ tải nội dung skill vào context khi thực sự cần thiết**.

{% code title=".opencode/skills/git-release/SKILL.md" overflow="wrap" lineNumbers="true" %}
```markdown
---
name: Git Release
description: Prepare release notes, version bumps, and GitHub releases
---

## Workflow

1. Read `references/release-policy.md`.
2. Summarize merged changes since the previous tag.
3. Propose the version bump before changing files.
4. Run `scripts/changelog.ts` only after the user approves the version.
```
{% endcode %}

**Skill ID đến từ đường dẫn file**, không phải từ `name` trong frontmatter (`name` chỉ là nhãn hiển thị).

| File | ID |
|:---|:---|
| `<source>/git-release.md` | `git-release` |
| `<source>/git-release/SKILL.md` | `git-release` |
| `<source>/teams/release/SKILL.md` | `release` |

{% hint style="warning" %}
Skill **không có `description`** sẽ **không được quảng bá** cho model — và skill không có description thì không bao giờ được load. Luôn viết `description` rõ ràng.
{% endhint %}

{% code title="Phân quyền skill theo ID" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "permissions": [
    { "action": "skill", "resource": "*", "effect": "allow" },
    { "action": "skill", "resource": "internal-*", "effect": "deny" },
    { "action": "skill", "resource": "experimental-*", "effect": "ask" }
  ]
}
```
{% endcode %}

| Effect | Hành vi |
|:---|:---|
| `allow` | Quảng bá và load skill khớp không cần phê duyệt |
| `ask` | Quảng bá skill khớp và hỏi trước khi load |
| `deny` | **Ẩn** skill khớp khỏi model và từ chối load |

### Plugin: breaking change quan trọng

{% hint style="danger" %}
V2 tái thiết kế **Server/Client API** và **Plugin API**. Các plugin phát triển trên V1 **sẽ không tương thích trực tiếp** và cần được cập nhật theo cấu trúc mới. Hãy audit toàn bộ plugin trước khi chuyển.
{% endhint %}

***

## 5. Linh hoạt chọn Model

OpenCode V2 không bị giới hạn vào một model cố định mà hỗ trợ kết nối **hơn 75 nhà cung cấp** thông qua AI SDK và [Models.dev](https://models.dev), cho phép tuỳ chỉnh model phù hợp cho **từng công đoạn**.

### Phân bổ model theo vai trò

* **Model năng lực cao** cho khâu thiết kế kiến trúc hoặc xử lý bug khó.
* **Model chi phí thấp** cho việc tra cứu của Explore Agent — vì nó chỉ đọc và grep, không cần model đắt.
* **Model chuyên biệt về code** cho Build Agent.

{% code title="Gán model khác nhau cho từng agent" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "agents": {
    "build":    { "model": "anthropic/claude-sonnet-4-5#high" },
    "plan":     { "model": "anthropic/claude-sonnet-4-5" },
    "explore":  { "model": "anthropic/claude-haiku-4-5" },
    "general":  { "model": "anthropic/claude-haiku-4-5" }
  }
}
```
{% endcode %}

{% hint style="info" %}
Subagent dùng model được cấu hình của nó, hoặc **thừa hưởng model của session cha** nếu không cấu hình. Session lưu model đã chọn riêng — chọn primary agent theo ID **không** đổi model đó.
{% endhint %}

### Danh mục model

| Nhóm | Model được đề cập |
|:---|:---|
| **Thương mại cao cấp** | GPT 5.6, Claude Opus/Sonnet 5, Gemini 3.6 Flash, Kimi K2.7/K3, DeepSeek V4 |
| **Thử nghiệm miễn phí có thời hạn** | Big Pickle, DeepSeek V4 Flash Free, Laguna S 2.1 Free |
| **Model mới từ OpenCode** | **Fast Frank** được hé lộ và phát triển từ OpenCode, bên cạnh **Big Pickle** |

{% hint style="warning" %}
Danh mục model thay đổi rất nhanh theo từng tháng và một số model miễn phí có thời hạn. Hãy kiểm tra danh sách **trực tiếp** bằng `/models` (hoặc `opencode models --refresh`) thay vì dựa vào danh sách cố định trong bài viết.
{% endhint %}

### Cấu hình provider trong V2

Đối với provider **không có sẵn** trong catalog, khai báo credential, runtime package, endpoint và model đầu tiên cùng nhau:

{% code title="Provider OpenAI-compatible tự định nghĩa" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "providers": {
    "acme": {
      "name": "Acme",
      "env": ["ACME_API_KEY"],
      "package": "@opencode/ai/providers/openai-compatible",
      "settings": { "baseURL": "https://llm.acme.example/v1" },
      "models": {
        "qwen3-coder": { "name": "Qwen 3 Coder" }
      }
    }
  }
}
```
{% endcode %}

Đối với provider có sẵn, chỉ cần ghi đè `settings.baseURL` để đi qua proxy — package, models và connection vốn có vẫn giữ nguyên.

### Model local không cần tài khoản

{% tabs %}
{% tab title="Ollama" %}
{% code title="Dùng Ollama local" overflow="wrap" lineNumbers="true" %}
```bash
ollama serve
ollama pull qwen3:8b
```
{% endcode %}

OpenCode probe `http://127.0.0.1:11434`, phát hiện completion models và thêm vào `/models` **không cần kết nối tài khoản**.
{% endtab %}
{% tab title="LM Studio & vLLM" %}
{% code title="Kết nối runtime local khác" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "providers": {
    "lmstudio": { "settings": { "baseURL": "http://gpu-host:1234/v1" } },
    "vllm":     { "settings": { "baseURL": "http://gpu-host:8000/v1" } }
  }
}
```
{% endcode %}

Endpoint mặc định: LM Studio `http://127.0.0.1:1234/v1`, vLLM `http://127.0.0.1:8000/v1`.

{% hint style="info" %}
vLLM kiểm tra `/health` trước khi đọc `/v1/models`; discovery của nó **không suy luận được tool support**, nên các model vLLM phát hiện được bắt đầu với tools bị tắt.
{% endhint %}
{% endtab %}
{% endtabs %}

### Provider ID bị loại bỏ trong V2

{% hint style="warning" %}
V2 từ chối trực tiếp các provider ID đã bị loại bỏ, kèm hướng thay thế:

* `azure-cognitive-services/<model>` → dùng `azure/<model>`
* `google-vertex-anthropic/<model>` → dùng `google-vertex/<model>` — V2 gộp Gemini, Anthropic và OpenAI-compatible Vertex dưới **một** provider ID
{% endhint %}

***

## Tổng hợp: V1 → V2

| Hạng mục | V1 | V2 |
|:---|:---|:---|
| Cấu trúc agent | Agent đơn lẻ | `primary` + `subagent` với context riêng |
| Agent tích hợp sẵn | `build`, `plan` | `build`, `plan`, `general`, `explore` (+ ẩn: `compaction`, `title`, `summary`) |
| Agent `scout` | Không có | Không có — dùng `explore` |
| Cấu hình agent | `permission` (object) | `permissions` (mảng quy tắc) |
| Trường agent cũ | `temperature`, `top_p`, `prompt`, `tools`, `maxSteps` | Không dùng trong V2 |
| Tên tool | `bash`, `task`, `write`, `patch` | `shell`, `subagent`, `edit` |
| Mặc định khi không có quy tắc khớp | Tuỳ agent | `ask` |
| Compaction | tail-turn + pruning | summary + `keep.tokens` (mặc định 15000) |
| MCP | Server đặt trực tiếp dưới `mcp` | `mcp.servers` |
| MCP protocol | — | `legacy` / `auto` / `2026-07-28` |
| Code Mode | Không có | **Mặc định**, điều khiển bằng action `execute` |
| OAuth MCP | Thủ công | PKCE, dynamic client registration, tự làm mới token |
| Context ngoài workspace | Copy file vào project | `references` (path hoặc Git repository) |
| Chính sách tổ chức | Managed settings | `experimental.policies` + Console-managed policies |
| Plugin API | Hiện hành | **Tái thiết kế** — plugin V1 không tương thích |

***

## Khuyến nghị chuyển đổi

{% hint style="success" %}
Nếu OpenCode V1 hiện tại đang **phục vụ công việc ổn định** và bạn **phụ thuộc nhiều vào custom plugin**, bạn **chưa cần vội chuyển đổi**.

V2 vẫn đang trong giai đoạn Beta, nhưng bạn **không cần viết lại cấu hình**: V2 đọc cấu hình V1 từ **cùng vị trí** và tự normalize trong memory mà không ghi lại file gốc. Hãy backup cấu hình, thử V2 trên một project không critical, rồi mới chuyển dần.
{% endhint %}

### Lộ trình đề xuất

1. **Backup `~/.config/opencode/`** — V1 và V2 dùng chung config locations, nên không tồn tại "bản sao song song" tự nhiên.
2. **Gỡ V1 rồi cài V2** (cùng lệnh `opencode`), chỉ thử trên **một project không critical** để so sánh hành vi compaction, phân quyền và skills.
3. **Audit plugin trước** — đây là rủi ro migration lớn nhất, vì Plugin API đã tái thiết kế và code V1 **không chạy** trong V2.
4. **Chuyển đổi cấu hình là tùy chọn**, có thể làm dần: `permission` → `permissions`, `bash` → `shell`, `task` → `subagent`, MCP sang `mcp.servers`, `compaction` sang `keep`/`buffer`.
5. **Thử nghiệm phân vai agent** trên project thật — đây là lợi ích lớn nhất của V2.
6. **Chỉ bỏ V1** sau khi đã xác nhận model, credentials, agents, permissions, MCP servers và plugins đều hoạt động đúng trên V2.

{% hint style="danger" %}
Trước khi chuyển đổi, hãy **backup `~/.config/opencode/`** và chắc chắn project của bạn đã **commit sạch** trên Git. Cả `/undo` và `/redo` đều phụ thuộc Git history.
{% endhint %}

{% content-ref url="migrate-opencode-v1-sang-v2.md" %}
[Migrate từ OpenCode V1 sang OpenCode V2](migrate-opencode-v1-sang-v2.md)
{% endcontent-ref %}

***

## Tài liệu tham khảo

* [OpenCode V2 — Docs chính thức](https://opencode.ai/v2/docs)
* [V2 — Agents](https://opencode.ai/v2/docs/agents/)
* [V2 — Permissions](https://opencode.ai/v2/docs/permissions/)
* [V2 — MCP servers](https://opencode.ai/v2/docs/mcp-servers/)
* [V2 — Skills](https://opencode.ai/v2/docs/skills/)
* [V2 — References](https://opencode.ai/v2/docs/references/)
* [V2 — Compaction](https://opencode.ai/v2/docs/compaction)
* [V2 — Providers](https://opencode.ai/v2/docs/providers/)
* [V1 — Docs ổn định](https://opencode.ai/docs)
* [Models.dev](https://models.dev)
* [Schema cấu hình](https://opencode.ai/config.json)
