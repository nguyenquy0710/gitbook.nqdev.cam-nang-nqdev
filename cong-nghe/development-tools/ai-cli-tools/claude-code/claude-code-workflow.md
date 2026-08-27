---
description: >-
  Claude Code Workflow — Framework tổ chức dự án Claude Code với cấu trúc thư
  mục phân tầng 3 Layer, giúp AI hiểu và vận hành dự án hiệu quả hơn.
---

# Claude Code Workflow — Framework tổ chức dự án phân tầng

Claude Code mạnh nhưng **không có cấu trúc tổ chức rõ ràng**, nó sẽ:
Quên context giữa các session, không biết khi nào nên dùng skill nào, và thiếu hệ thống lưu trữ progress một cách có hệ thống.

**Claude Code Workflow** là framework tổ chức thư mục phân tầng với 3 Layer, biến Claude từ "AI aide" thành "AI team member" hiểu rõ dự án, tự động lưu tiến trình, và biết chính xác cần làm gì trong mọi tình huống.

***

## Cấu trúc thư mục tổng quan

{% code title="Cấu trúc thư mục Claude Code Workflow" overflow="wrap" %}
```
claude-code-workflow/
├── CLAUDE.md                          # Entry point – Claude đọc đầu tiên
├── README.md
├── rules/                             # Layer 0: Always loaded
│   ├── behaviors.md                   # Core behavior rules
│   ├── skill-triggers.md              # Khi nào tự invoke skill nào
│   └── memory-flush.md                # Auto-save triggers
├── docs/                              # Layer 1: On-demand reference
│   ├── agents.md                      # Multi-model collaboration
│   ├── behaviors-extended.md          # Extended rules
│   ├── behaviors-reference.md         # Detailed operation guides
│   ├── content-safety.md              # AI hallucination prevention
│   ├── scaffolding-checkpoint.md      # "Có thực sự cần self-host?" checklist
│   └── task-routing.md                # Model tier routing + cost
├── memory/                            # Layer 2: Working state
│   ├── today.md                       # Daily session log
│   ├── projects.md                    # Cross-project status
│   ├── goals.md                       # Week/month/quarter goals
│   └── active-tasks.json              # Cross-session task registry
├── skills/                            # Reusable skill definitions
│   ├── session-end/SKILL.md
│   ├── verification-before-completion/SKILL.md
│   ├── systematic-debugging/SKILL.md
│   ├── planning-with-files/SKILL.md
│   └── experience-evolution/SKILL.md
├── agents/                            # Custom agent definitions
│   ├── pr-reviewer.md
│   ├── security-reviewer.md
│   └── performance-analyzer.md
└── commands/                          # Custom slash commands
    ├── debug.md
    ├── deploy.md
    ├── exploration.md
    └── review.md
```
{% endcode %}

***

## Phần 1: Kiến trúc 3 Layer

Bí quyết của workflow này là **3 Layer tách biệt**, mỗi layer có mục đích và cơ chế load riêng.

{% hint style="info" %}
Nguyên tắc cốt lõi: **Layer 0 luôn load → Layer 1 load khi cần → Layer 2 ghi lại trạng thái làm việc thực tế.** Claude không cần nhớ mọi thứ — nó biết tìm ở đâu.
{% endhint %}

### Layer 0 — Rules (Always Loaded)

Đây là các quy tắc **luôn luôn được Claude load** khi bắt đầu session mới. Không cần invoke, không cần ask — Claude tự động đọc.

**Nội dung chính:**

* **behaviors.md:** Các hành vi cốt lõi — cách debug, commit convention, routing task đến agent/skill phù hợp. Đây là "DNA behavior" của Claude trong dự án.
* **skill-triggers.md:** Định nghĩa khi nào Claude nên tự động invoke skill nào. Ví dụ: khi gặp lỗi → trigger `systematic-debugging`, khi end session → trigger `session-end`.
* **memory-flush.md:** Các trigger tự động lưu progress — không bao giờ mất dữ liệu giữa session. Ví dụ: mỗi 10 lần edit file → flush memory, trước khi compact → save state.

{% code title="rules/behaviors.md (ví dụ)" overflow="wrap" %}
```markdown
# Core Behaviors

## Debugging
1. Recall — Check memory/ and today.md for related history
2. Read — Understand the actual error, don't guess
3. Root Cause — Trace back to the source, not symptoms
4. Fix — Minimal changes, verify with tests
5. Record — Save findings to memory/

## Commits
- Use conventional commits: feat:, fix:, refactor:, docs:
- Never commit without running tests first
- Include issue number if available

## Routing
- Security issues → security-reviewer agent
- Performance → performance-analyzer agent
- Code review → pr-reviewer agent
- Complex planning → planning-with-files skill
```
{% endcode %}

### Layer 1 — Docs (On-demand Reference)

Các tài liệu tham khảo **chỉ load khi Claude cần**. Claude tự quyết định khi nào cần đọc dựa trên context hiện tại.

**Nội dung chính:**

* **agents.md:** Framework cho multi-model collaboration — khi nào dùng Claude Opus, khi nào dùng Sonnet, và cách các agent phối hợp.
* **behaviors-extended.md:** Rules mở rộng — knowledge base, associations, domain-specific rules cho dự án.
* **behaviors-reference.md:** Hướng dẫn vận hành chi tiết — step-by-step cho từng loại task.
* **content-safety.md:** Hệ thống ngăn AI hallucination — verify before claim, reference sources.
* **scaffolding-checkpoint.md:** Checklist "Có thực sự cần self-host?" — prevents over-engineering.
* **task-routing.md:** Model tier routing + cost comparison — chọn đúng model cho đúng task.

{% hint style="warning" %}
Layer 1 **không nên quá lớn**. Nếu document vượt quá 200 dòng, hãy tách thành nhiều file nhỏ hơn hoặc summarizes lại. Claude hoạt động tốt nhất với context ngắn và tập trung.
{% endhint %}

### Layer 2 — Memory (Working State)

Đây là **working memory templates** — nơi Claude lưu và đọc trạng thái làm việc thực tế. Khác với Layer 0 và 1 (static), Layer 2 **thay đổi liên tục** trong quá trình làm việc.

**Nội dung chính:**

* **today.md:** Daily session log — ghi lại những gì đã làm trong ngày. Khi bắt đầu session mới, Claude đọc file này để "nhớ lại" context.
* **projects.md:** Cross-project status overview — tổng quan trạng thái các dự án đang làm.
* **goals.md:** Week/month/quarter goals — mục tiêu ngắn hạn và dài hạn.
* **active-tasks.json:** Cross-session task registry — registry các task đang chờ, đã hoàn thành, và ưu tiên.

{% code title="memory/today.md (ví dụ)" overflow="wrap" %}
```markdown
# Session Log — 2026-08-25

## Đã hoàn thành
- [x] Fix authentication middleware bug (commit: abc1234)
- [x] Add unit tests for UserService
- [x] Update API documentation

## Đang làm
- [ ] Refactor payment module (phase 2/3)

## Context cần giữ
- Payment module đang migrate từ v1 → v2
- v1 API vẫn cần backward compatibility
- Test coverage target: 80%

## Blockers
- Need database migration for new schema (blocked on DBA review)
```
{% endcode %}

{% tabs %}
{% tab title="Layer 0 — Rules" %}
* **Load:** Luôn luôn, tự động
* **Thay đổi:** Rất ít (stable rules)
* **Mục đích:** Định hình behavior
* **Ví dụ:** Debug flow, commit convention, routing rules
{% endtab %}
{% tab title="Layer 1 — Docs" %}
* **Load:** Khi Claude cần tham khảo
* **Thay đổi:** Thỉnh thoảng cập nhật
* **Mục đích:** Kiến thức chuyên sâu
* **Ví dụ:** Agent framework, safety rules, cost optimization
{% endtab %}
{% tab title="Layer 2 — Memory" %}
* **Load:** Mỗi session start
* **Thay đổi:** Liên tục trong quá trình làm việc
* **Mục đích:** Lưu trạng thái thực tế
* **Ví dụ:** Daily log, project status, active tasks
{% endtab %}
{% endtabs %}

***

## Phần 2: Skills

Skills là các **workflow tái sử dụng** được define trong thư mục `skills/`. Mỗi skill giải quyết một loại task cụ thể và được Claude invoke khi phù hợp.

### session-end — Auto Wrap-up

**Vấn đề:** Claude thường kết thúc session mà không save progress, không commit, không record lại đã làm gì.

**Giải pháp:** Skill `session-end` tự động thực hiện 3 bước khi end session:

1. **Save progress** — Ghi lại vào `memory/today.md` những gì đã làm
2. **Commit** — Stage và commit các thay đổi với conventional commit message
3. **Record** — Cập nhật `memory/active-tasks.json` và `memory/projects.md`

{% code title="skills/session-end/SKILL.md (tóm tắt)" overflow="wrap" %}
```markdown
---
name: session-end
description: Auto wrap-up when ending a session
---
When session is ending:
1. Read memory/today.md and append session summary
2. Run `git status` to check uncommitted changes
3. Stage and commit with conventional commit message
4. Update memory/active-tasks.json with task status
5. Update memory/projects.md if project status changed
```
{% endcode %}

{% hint style="info" %}
Skill này rất quan trọng vì nó **đảm bảo không bao giờ mất progress**. Dù session bị cắt đột ngột, progress đã được lưu.
{% endhint %}

### verification-before-completion — "Run the Test. Read the Output. THEN Claim."

**Vấn đề:** Claude có xu hướng claim "đã xong" mà chưa thực sự verify.

**Giải pháp:** Skill này enforce một nguyên tắc cứng: **Run the test → Read the output → THEN claim done.**

{% code title="skills/verification-before-completion/SKILL.md (tóm tắt)" overflow="wrap" %}
```markdown
---
name: verification-before-completion
description: Never claim done without running verification
---
NEVER claim task is complete without:
1. Running the relevant tests
2. Reading the actual output (not just assuming)
3. Confirming the output matches expected behavior
4. If tests fail, treat as new bug and debug
```
{% endcode %}

* **Nguyên tắc:** Không bao giờ nói "done" nếu chưa chạy test và đọc output
* **Áp dụng:** Cho mọi task có test suite — bug fix, feature, refactor
* **Lợi ích:** Loại bỏ hoàn toàn "false positive" — Claude nói xong nhưng thực tế chưa xong

### systematic-debugging — 5-Phase Debugging

**Vấn đề:** Claude thường nhảy thẳng vào fix mà chưa hiểu root cause.

**Giải pháp:** Skill enforce 5 phase debugging có kỷ luật:

{% tabs %}
{% tab title="Phase 1: Recall" %}
Kiểm tra `memory/` và `today.md` — đã gặp bug này chưa? Có context gì từ session trước?
{% endtab %}
{% tab title="Phase 2: Read" %}
Đọc actual error message. Đừng guess — đọc output thật kỹ.
{% endtab %}
{% tab title="Phase 3: Root Cause" %}
Trace ngược từ error đến source. Không fix symptom — fix root cause.
{% endtab %}
{% tab title="Phase 4: Fix" %}
Minimal changes. Chỉ sửa những gì cần sửa.
{% endtab %}
{% tab title="Phase 5: Record" %}
Ghi lại findings vào `memory/` để lần sau không cần debug lại.
{% endtab %}
{% endtabs %}

### planning-with-files — File-based Planning

**Vấn đề:** Task phức tạp cần plan chi tiết, nhưng Claude thường lose track khi plan quá dài.

**Giải pháp:** Skill này giúp Claude **tạo file plan riêng** thay vì giữ trong context.

{% code title="skills/planning-with-files/SKILL.md (tóm tắt)" overflow="wrap" %}
```markdown
---
name: planning-with-files
description: File-based planning for complex tasks
---
For tasks with 3+ steps:
1. Create a plan file: plans/<task-name>.md
2. Break down into ordered steps
3. Track status of each step (pending/done/blocked)
4. Reference the plan file instead of holding in context
5. Update status as each step completes
```
{% endcode %}

* **Tác dụng:** Plan nằm trong file, không chiếm context window
* **Khi dùng:** Task có hơn 3 bước, refactor lớn, migration
* **Ưu điểm:** Claude có thể "quên" plan trong context nhưng không bao giờ quên plan trong file

### experience-evolution — Auto Accumulate Knowledge

**Vấn đề:** Claude học được nhiều điều về dự án trong quá trình làm việc nhưng không lưu lại.

**Giải pháp:** Skill tự động tích lũy project knowledge vào memory.

{% code title="skills/experience-evolution/SKILL.md (tóm tắt)" overflow="wrap" %}
```markdown
---
name: experience-evolution
description: Auto-accumulate project knowledge
---
After completing any task:
1. What did I learn about this codebase?
2. What patterns/approaches worked well?
3. What to avoid next time?
4. Save to memory/projects.md or memory/today.md
```
{% endcode %}

* **Knowledge domains:** Architecture decisions, coding patterns, gotchas, performance tips
* **Storage:** Ghi vào `memory/projects.md` dưới các mục tương ứng
* **Giá trị:** Sau 1 tháng, Claude hiểu dự án sâu hơn bất kỳ team member mới nào

***

## Phần 3: Agents & Commands

### Custom Agents

Agents là các **AI specialist** được define sẵn với role và scope cụ thể. Khi cần phân tích chuyên sâu, Claude sẽ delegate cho agent phù hợp.

{% code title="agents/pr-reviewer.md" overflow="wrap" %}
```markdown
---
name: pr-reviewer
description: Code review agent
tools: Read, Grep, Glob, Bash
---
You are a senior code reviewer. Review for:
- Code quality and maintainability
- Edge cases and error handling
- Performance implications
- Test coverage gaps
Provide specific line references and actionable feedback.
```
{% endcode %}

{% code title="agents/security-reviewer.md" overflow="wrap" %}
```markdown
---
name: security-reviewer
description: OWASP security scanning agent
tools: Read, Grep, Glob, Bash
---
You are a security engineer. Scan for:
- OWASP Top 10 vulnerabilities
- Hardcoded secrets or credentials
- Insecure data handling
- Authentication/authorization flaws
Provide severity levels and remediation steps.
```
{% endcode %}

{% code title="agents/performance-analyzer.md" overflow="wrap" %}
```markdown
---
name: performance-analyzer
description: Performance bottleneck analysis agent
tools: Read, Grep, Glob, Bash
---
You are a performance engineer. Analyze for:
- N+1 queries and database bottlenecks
- Memory leaks and inefficient allocations
- Unnecessary network calls
- Cache optimization opportunities
Provide metrics-based recommendations.
```
{% endcode %}

### Custom Commands

Commands là **slash commands** mà bạn có thể gọi trực tiếp trong Claude Code.

| Command | Mục đích | Khi dùng |
| ------- | -------- | -------- |
| `/debug` | Bắt đầu systematic debugging | Khi gặp bug, cần debug có kỷ luật |
| `/deploy` | Pre-deployment checklist | Trước khi deploy lên production |
| `/exploration` | CTO challenge trước khi coding | Trước khi implement feature mới |
| `/review` | Chuẩn bị code review | Sau khi hoàn thành feature/fix |

{% code title="commands/debug.md" overflow="wrap" %}
```markdown
---
name: debug
description: Start systematic debugging
---
Use the systematic-debugging skill.
Start from Phase 1: Recall — check memory for related history.
Then Phase 2: Read — understand the actual error.
Do not skip phases.
```
{% endcode %}

{% code title="commands/deploy.md" overflow="wrap" %}
```markdown
---
name: deploy
description: Pre-deployment checklist
---
Run pre-deployment checklist:
1. All tests passing
2. No uncommitted changes
3. Environment variables reviewed
4. Database migrations ready
5. Rollback plan documented
Do not proceed if any item fails.
```
{% endcode %}

{% code title="commands/exploration.md" overflow="wrap" %}
```markdown
---
name: exploration
description: CTO challenge before coding
---
Before implementing, challenge the approach:
1. Is this the simplest solution?
2. What are the tradeoffs?
3. Can we reuse existing code/patterns?
4. What's the maintenance cost?
Present analysis before writing any code.
```
{% endcode %}

{% code title="commands/review.md" overflow="wrap" %}
```markdown
---
name: review
description: Prepare code review
---
Prepare for code review:
1. Run all tests and linters
2. Generate diff summary
3. Identify areas needing special attention
4. Use the verification-before-completion skill
```
{% endcode %}

***

## Phần 4: Cách áp dụng

### Bước 1: Tạo cấu trúc thư mục

{% code title="Terminal" overflow="wrap" lineNumbers="true" %}
```bash
# Tạo cấu trúc thư mục cơ bản
mkdir -p claude-code-workflow/{rules,docs,memory,skills/{session-end,verification-before-completion,systematic-debugging,planning-with-files,experience-evolution},agents,commands}
```
{% endcode %}

### Bước 2: Tạo CLAUDE.md entry point

`CLAUDE.md` là file **Claude đọc đầu tiên** khi vào repo. Nó phải reference đến Layer 0 rules:

{% code title="CLAUDE.md" overflow="wrap" %}
```markdown
# Project: [Tên dự án]

## Quick Start
Read `rules/behaviors.md` for core behavior rules.
Read `rules/skill-triggers.md` for skill invocation rules.
Read `memory/today.md` for current session context.

## Architecture
[Thêm mô tả kiến trúc dự án]

## Commands
[Thêm các lệnh build, test, deploy]

## Rules
- Always read memory/ before starting work
- Always save progress before compacting
- Never claim done without running tests
```
{% endcode %}

### Bước 3: Tích hợp vào dự án hiện có

{% hint style="warning" %}
**Không cần thiết phải tạo đầy đủ tất cả các file ngay.** Bắt đầu với Layer 0 (rules/) và 1-2 skills quan trọng nhất (session-end, verification-before-completion). Mở rộng dần khi cần.
{% endhint %}

{% tabs %}
{% tab title="Phase 1 — Cơ bản" %}
* Tạo `CLAUDE.md` với project overview
* Tạo `rules/behaviors.md` với core rules
* Tạo `memory/today.md` template
* Tạo skill `session-end` cơ bản
{% endtab %}
{% tab title="Phase 2 — Mở rộng" %}
* Thêm `rules/skill-triggers.md`
* Thêm `rules/memory-flush.md`
* Thêm `verification-before-completion` skill
* Thêm `systematic-debugging` skill
{% endtab %}
{% tab title="Phase 3 — Đầy đủ" %}
* Thêm Layer 1 docs khi cần
* Tạo custom agents
* Tạo custom commands
* Thêm `planning-with-files` và `experience-evolution`
{% endtab %}
{% endtabs %}

### Workflow sử dụng hàng ngày

1. **Bắt đầu session:** Claude tự động đọc `CLAUDE.md` → Layer 0 rules → `memory/today.md`
2. **Làm việc:** Claude tự động invoke skills theo `skill-triggers.md`, delegate cho agents khi cần
3. **Kết thúc session:** Skill `session-end` tự động save progress, commit, và record
4. **Session tiếp theo:** Claude đọc `memory/today.md` để "nhớ lại" context từ session trước

***

## Kết luận

**Claude Code Workflow** không phải là framework phức tạp — nó chỉ tổ chức lại những gì Claude cần biết thành cấu trúc rõ ràng:

* **Layer 0** đảm bảo Claude **luôn luôn hành xử đúng**
* **Layer 1** đảm bảo Claude **biết tìm ở đâu khi cần kiến thức chuyên sâu**
* **Layer 2** đảm bảo Claude **không bao giờ mất progress**
* **Skills** đảm bảo Claude **làm đúng quy trình** cho từng loại task
* **Agents & Commands** đảm bảo Claude **biết delegate đúng việc**

Khi nào nên dùng workflow này?

* Dự án có nhiều session kéo dài (không chỉ 1 lần ask rồi xong)
* Team muốn Claude hiểu rõ coding conventions và architecture
* Cần audit trail — Claude đã làm gì, khi nào, kết quả ra sao
* Muốn ngăn Claude "hallucinate" và claim done mà chưa verify

{% hint style="success" %}
**Mẹo:** Bắt đầu nhỏ. Tạo `CLAUDE.md` + `rules/behaviors.md` + `memory/today.md` + 1 skill `session-end` là đủ để thấy hiệu quả ngay lập tức.
{% endhint %}

**Tài liệu tham khảo:**
* [Claude Code Skills](https://code.claude.com/docs/en/skills)
* [Claude Code Subagents](https://code.claude.com/docs/en/sub-agents)
* [Mở rộng Claude Code — Skills, Hooks, Subagents và MCP](mo-rong-claude-code-skills-hooks-subagents-mcp.md)
* [CLAUDE.md — Bộ nhớ dự án và Auto Memory](claude-md-bo-nho-du-an-va-auto-memory.md)
