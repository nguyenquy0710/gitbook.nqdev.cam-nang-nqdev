---
description: >-
  Hướng dẫn quản lý environment variables trong Turborepo — task hashing, env
  modes, strict mode, framework inference, .env files và best practices.
---

# Environment Variables & Cache Keys

Environment variables là nguyên nhân số 1 gây **cache sai** (cache hit khi đáng lẽ miss). Turborepo cung cấp cơ chế kiểm soát chặt chẽ để tránh điều này.

## 1. Khai báo env vars cho task hash <a href="#id-1" id="id-1"></a>

### Task-level env

```json
{
  "tasks": {
    "build": {
      "env": ["MY_API_URL", "MY_API_KEY"]
    }
  }
}
```

Thay đổi giá trị → task miss cache.

### Global env

```json
{
  "globalEnv": ["GITHUB_TOKEN", "NODE_ENV", "CI"]
}
```

Thay đổi → **tất cả tasks** miss cache.

### Wildcards

```json
{
  "tasks": {
    "build": {
      "env": ["NEXT_PUBLIC_*", "VITE_*"]
    }
  }
}
```

Wildcard `*` ở cuối pattern. Escape: `"\\!"` cho literal `!`.

### Negation

```json
{
  "tasks": {
    "build": {
      "env": ["!MY_API_URL"]
    }
  }
}
```

Dùng để loại trừ env var khỏi wildcard.

## 2. Framework Inference <a href="#id-2" id="id-2"></a>

Turborepo tự động thêm prefix wildcards cho các framework phổ biến:

| Framework | Prefix được tự động thêm |
|---|---|
| Next.js | `NEXT_PUBLIC_*` |
| Vite | `VITE_*` |
| Create React App | `REACT_APP_*` |
| Gatsby | `GATSBY_*` |
| Nuxt | `NUXT_*`, `NUXT_ENV_*` |
| Expo | `EXPO_PUBLIC_*` |
| Astro | `PUBLIC_*` |
| SvelteKit | `PUBLIC_*` |
| Remix | `REMIX_*` |
| SolidStart | `VITE_*` |
| RedwoodJS | `REDWOOD_ENV_*` |
| Sanity | `SANITY_STUDIO_*` |

Framework inference là per-package.

**Tắt framework inference:**

```bash
turbo build --framework-inference=false
```

Hoặc thêm negative wildcard:

```json
{
  "tasks": {
    "build": {
      "env": ["!NEXT_PUBLIC_*"]
    }
  }
}
```

## 3. Environment Modes <a href="#id-3" id="id-3"></a>

### Strict Mode (default)

Chỉ cho phép env vars khai báo trong `env` + `globalEnv` đi vào task runtime. Các env var khác bị filter — task sẽ fail nếu cần nhưng không được khai báo.

```json
{
  "envMode": "strict"
}
```

**Lợi ích:** Phát hiện sớm env var thiếu → tránh cache sai.

**Rủi ro:** Vẫn có thể hit cache sai nếu app gracefully handle missing env var.

### Passthrough Env

Khi cần env var trong runtime nhưng không muốn ảnh hưởng hash:

```json
{
  "globalPassThroughEnv": ["AWS_SECRET_KEY"],
  "tasks": {
    "build": {
      "passThroughEnv": ["MY_DEBUG_FLAG"]
    }
  }
}
```

### Loose Mode

Cho phép tất cả env vars của process:

```bash
turbo build --env-mode=loose
```

**Nguy hiểm:** Dễ quên khai báo env var → cache hit sai. Chỉ dùng để migrate dần lên Strict Mode.

## 4. Env vars từ dependencies <a href="#id-4" id="id-4"></a>

Khi app A phụ thuộc package B:

**Scenario 1:** B có build step, khai báo env trong `turbo.json` của B → Turborepo tự động xử lý. Đổi env → B miss cache → A rebuild.

**Scenario 2:** B không có build step, app A import trực tiếp và dùng `process.env.MY_VAR` → **A phải khai báo** `MY_VAR` trong `env` của nó:

```json
{
  "tasks": {
    "build": {
      "env": ["MY_VAR"]
    }
  }
}
```

## 5. .env Files <a href="#id-5" id="id-5"></a>

Turborepo **không tự động load** `.env` files. Việc này do framework hoặc `dotenv` package đảm nhiệm.

Nhưng Turborepo cần biết `.env` thay đổi để miss cache:

```json
{
  "globalDependencies": [".env*"],
  "tasks": {
    "build": {
      "inputs": ["$TURBO_DEFAULT$", ".env*"]
    }
  }
}
```

**Best practice:** Đặt `.env` trong từng Application Package, không ở root.

### Ví dụ Next.js:

```json
{
  "tasks": {
    "build": {
      "env": ["MY_API_URL", "MY_API_KEY"],
      "inputs": [
        "$TURBO_DEFAULT$",
        ".env.production.local",
        ".env.local",
        ".env.production",
        ".env"
      ]
    },
    "dev": {
      "inputs": [
        "$TURBO_DEFAULT$",
        ".env.development.local",
        ".env.local",
        ".env.development",
        ".env"
      ]
    }
  }
}
```

## 6. eslint-config-turbo <a href="#id-6" id="id-6"></a>

Phát hiện env vars dùng trong code nhưng chưa khai báo trong `turbo.json`:

```bash
pnpm add eslint-config-turbo --save-dev
```

```json
{
  "extends": ["turbo"]
}
```

## 7. Troubleshooting <a href="#id-7" id="id-7"></a>

### --summarize

```bash
turbo build --summarize
```

Kiểm tra `globalEnv` và `env` trong file summary. So sánh diff 2 lần chạy để tìm env var thiếu.

### Strict Mode fails

Nếu task fail vì thiếu env var, thêm vào `env` hoặc `passThroughEnv`:

```json
{
  "tasks": {
    "build": {
      "env": ["THIEN_ENV_VAR"],
      "passThroughEnv": ["OPTIONAL_DEBUG_FLAG"]
    }
  }
}
```

## 8. Best Practices <a href="#id-8" id="id-8"></a>

1. **Luôn dùng Strict Mode** — không dùng Loose Mode trong CI
2. **Khai báo đầy đủ env vars** — nếu không biết cần gì, dùng `eslint-config-turbo` scan
3. **Không tạo/mutate env vars trong script** — Turborepo không detect được
4. **Đặt .env trong Application Package** — không dùng root `.env`
5. **Dùng wildcards cho prefix** — tránh liệt kê từng biến
6. **Familiar với `--summarize`** — debug env var issues

## Tài liệu tham khảo

- [Using Environment Variables (official)](https://turborepo.dev/docs/crafting-your-repository/using-environment-variables)
- [Configuration Reference](https://turborepo.dev/docs/reference/configuration)
- [eslint-config-turbo](https://turborepo.dev/docs/reference/eslint-config-turbo)
