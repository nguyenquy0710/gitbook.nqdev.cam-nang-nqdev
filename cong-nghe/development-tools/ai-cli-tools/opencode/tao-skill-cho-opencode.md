---
description: >-
  Tạo skill cho OpenCode V2: SKILL.md, discovery, sources, frontmatter, IDs,
  precedence, loading, permissions và troubleshooting.
---

# Tạo skill cho OpenCode

Skill là tập hướng dẫn tái sử dụng mà agent load khi cần. Bài này hướng dẫn tạo `SKILL.md`, discovery locations, sources, frontmatter, ID, precedence, loading và permissions.

## Khái niệm cơ bản

* **Skill:** Markdown instructions + supporting files; agent load bằng tool `skill` hoặc `@skill-id`.
* **SKILL.md:** file chính; frontmatter name/description/metadata.
* **ID:** path-derived, case-sensitive; frontmatter `name` chỉ display label.
* **Discovery:** global/project + compatibility `.claude`/`.agents`; search up to 6 levels.

## Yêu cầu

* Đã cài OpenCode V2.
* Quen thuộc YAML frontmatter.

## Hướng dẫn thực hiện

### Bước 1: Tạo skill directory

{% code title=".opencode/skills/git-release/SKILL.md" overflow="wrap" lineNumbers="true" %}
```md
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

Supporting files beside SKILL.md:

```text
.opencode/skills/
└── git-release/
    ├── SKILL.md
    ├── scripts/
    │   └── changelog.ts
    └── references/
        └── release-policy.md
```

Paths trong skill relative to directory containing SKILL.md. Directory form recommended.

Flat form cũng được: `.opencode/skills/review.md` (phải ở source root).

### Bước 2: Discovery locations

| Scope | Sources |
|---|---|
| Global | `~/.config/opencode/skills` |
| Global compatibility | `~/.claude/skills`, `~/.agents/skills` |
| Project | `.opencode/skills` |
| Project compatibility | `.claude/skills`, `.agents/skills` |

Project sources search từ current directory đến project root, include matching dirs ở mọi level. Mỗi source có thể chứa flat `*.md` (root only) hoặc nested `SKILL.md`. A directory containing SKILL.md là một skill; không search thêm bên trong. Hidden files/dirs và `node_modules` skipped. Search stops six directories below source root.

### Bước 3: Sources config

Thêm directories/URLs qua `skills` array trong config:

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "skills": [
    "./team-skills",
    "~/shared/opencode-skills",
    "/opt/company-skills",
    "https://example.com/opencode/skills/",
  ],
}
```
{% endcode %}

| Value | Resolution |
|---|---|
| Relative path | Từ active working directory, không phải config file |
| `~/` path | Home directory |
| Absolute path | Dùng as written |
| `http://`/`https://` URL | Loaded as HTTP catalog |

Mọi discovered config file contributes entries; arrays combined rather than replaced. Connected OpenCode Console workspace cũng có thể share skills.

### Bước 4: HTTP catalog

Catalog là base URL với `index.json`:

{% code title="index.json" overflow="wrap" lineNumbers="true" %}
```json
{
  "skills": [
    {
      "name": "git-release",
      "version": "3",
      "files": ["git-release.md", "references/release-policy.md"]
    }
  ]
}
```
{% endcode %}

OpenCode download mỗi file từ `<base-url>/git-release/<file>`. Paths phải safe, relative, same-origin. Entry file include `SKILL.md` hoặc `<name>.md`. Tăng `version` khi files change để refresh cache. Downloaded skill directory becomes source root named after entry, nên cả `git-release.md` và `SKILL.md` có ID `git-release`.

### Bước 5: Frontmatter

{% code title="SKILL.md" overflow="wrap" lineNumbers="true" %}
```md
---
name: Git Release
description: Prepare a repository release
metadata:
  opencode/autoinvoke: false
---

Prepare the changelog, version bump, tag, and release notes.
```
{% endcode %}

| Field | Behavior |
|---|---|
| `name` | Display name; default path-derived ID |
| `description` | Summary để show skill cho model |
| `metadata.opencode/autoinvoke` | `false` omit skill khỏi model available list |
| `disable-model-invocation` | `true` same effect |
| `license`, `compatibility` | Accepted but not interpreted |

All frontmatter optional runtime. Add clear `description` nếu model nên discover; skills without description không advertised. `opencode/autoinvoke: false` chỉ hide khỏi model available list; vẫn registered và load explicit by ID. Nếu cả hai set, `opencode/autoinvoke` wins.

### Bước 6: IDs

Path determines ID:

| File | ID |
|---|---|
| `<source>/git-release.md` | `git-release` |
| `<source>/git-release/SKILL.md` | `git-release` |
| `<source>/teams/release/SKILL.md` | `release` |

IDs exact và case-sensitive. Portable skills: unique lowercase kebab-case ID 1–64 chars, aligned với directory name regex `^[a-z0-9]+(-[a-z0-9]+)*$`. V2 hiện không enforce pattern, length, name match, max description length.

### Bước 7: Precedence

Selected by ID; later source supplies skill:

```text
~/.config/opencode/skills/git-release/SKILL.md  ← lower
.opencode/skills/git-release/SKILL.md           ← loaded
```

Sources registered lower → higher:
1. Built-in skills
2. `.claude/skills`, global first then farthest ancestor toward current
3. `.agents/skills`, global first then farthest ancestor toward current
4. `~/.config/opencode/skills`
5. Project `.opencode/skills`, from project root toward current
6. Explicit `skills` config entries, in config priority and array order

Avoid duplicate IDs unless override intended.

### Bước 8: Loading

At each model step, OpenCode lists permitted skills with description and not `opencode/autoinvoke: false`. List includes ID, name, description only (not full body).

Model loads skill by calling `skill` tool with exact ID:

{% code title="skill tool input" overflow="wrap" lineNumbers="true" %}
```json
{
  "id": "git-release"
}
```
{% endcode %}

OpenCode then:
1. Select current definition for ID.
2. Check selected agent's `skill` permission.
3. Add Markdown body (without frontmatter) to conversation.
4. Provide skill's base directory and sample up to ten supporting file paths.

To load yourself, mention in prompt as `@skill-id`. Supporting file contents not auto-loaded; agent reads when skill directs. File sample available for directory-based SKILL.md; flat Markdown skills do not receive neighboring file list.

### Bước 9: Permissions

Use `skill` action and skill ID as resource. Rules in order, last matching wins:

{% code title="opencode.jsonc" overflow="wrap" lineNumbers="true" %}
```jsonc
{
  "permissions": [
    { "action": "skill", "resource": "*", "effect": "allow" },
    { "action": "skill", "resource": "internal-*", "effect": "deny" },
    { "action": "skill", "resource": "experimental-*", "effect": "ask" },
  ],
}
```
{% endcode %}

| Effect | Behavior |
|---|---|
| `allow` | Advertise and load without approval |
| `ask` | Advertise and ask before loading |
| `deny` | Hide from model and reject loading |

Place same rules under `agents.<id>.permissions` to apply to one agent.

## Xác minh kết quả

* Kiểm tra ID path-derived, case-sensitive.
* Ensure description present for discovery.
* Check autoinvoke and skill permissions.
* Look for later source defining same ID.
* HTTP catalog: verify `index.json`, same-origin paths, changed version.

## Lưu ý quan trọng

{% hint style="warning" %}
Skill ID là path-derived, không phải frontmatter `name`. Ví dụ directory `release` → ID `release`, dù name "Git Release".
{% endhint %}

* Flat Markdown must be at source root.
* Nested SKILL.md directory is one skill; no deeper skill search inside.
* Search stops six directories below source root.
* `opencode/autoinvoke` wins over `disable-model-invocation`.

## Tài liệu tham khảo

* [OpenCode V2 — Skills](https://opencode.ai/v2/docs/skills)
* [OpenCode V2 — Agents](https://opencode.ai/v2/docs/agents)
* [OpenCode V2 — Config](https://opencode.ai/v2/docs/config)
* {% content-ref url="tao-agent-tuy-chinh-cho-opencode.md" %}[Tạo agent tùy chỉnh cho OpenCode](tao-agent-tuy-chinh-cho-opencode.md){% endcontent-ref %}