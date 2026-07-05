---
description: >-
  Hướng dẫn chi tiết về caching trong Turborepo — local cache, remote cache,
  global hash, task hash, cache troubleshooting và best practices.
---

# Caching Guide — Không Bao Giờ Làm Lại Việc Đã Làm

Turborepo caching là cơ chế cốt lõi giúp monorepo của bạn **không bao giờ làm lại việc đã làm**. Khi task được cache, Turborepo khôi phục kết quả từ lần chạy trước dựa trên fingerprint (vân tay số) của inputs.

## 1. Caching hoạt động thế nào? <a href="#id-1" id="id-1"></a>

Mỗi task có một **fingerprint** được tính từ:

- **Global hash:** lockfile, `globalDependencies`, `globalEnv`, resolved task definition từ `turbo.json`
- **Task hash:** nội dung file trong package (theo `inputs`), `package.json`, environment variables

Nếu fingerprint giống hệt lần chạy trước → **cache hit** → replay logs + restore artifacts (~80ms).
Nếu fingerprint khác → **cache miss** → chạy task thật.

### Ví dụ

```bash
# Lần 1: cache miss, chạy thật
turbo build
>>> cache miss, executing abc123

# Lần 2 (không đổi code): cache hit, replay
turbo build
>>> cache hit, replaying logs abc123
>>> Tasks: 2 successful, 0 failed → FULL TURBO
```

## 2. Global Hash Inputs <a href="#id-2" id="id-2"></a>

| Input | Ví dụ thay đổi → miss cache |
|---|---|
| Resolved task definition từ `turbo.json` | Thay đổi `outputs`, `dependsOn` |
| Lockfile | Thêm/del dependency trong root |
| `globalDependencies` files | Sửa `./.env`, `tsconfig.json` |
| `globalEnv` values | Thay đổi `GITHUB_TOKEN`, `NODE_ENV` |
| CLI flags ảnh hưởng runtime | `--cache-dir`, `--framework-inference` |
| Passthrough arguments | `turbo build -- --my-flag` |

## 3. Task (Package) Hash Inputs <a href="#id-3" id="id-3"></a>

| Input | Ví dụ |
|---|---|
| Package configuration (`package.json`/`turbo.json`) | Đổi `name`, thêm script |
| Lockfile thay đổi ảnh hưởng package | Thêm dependency trong package |
| File trong package (theo `inputs` glob) | Mặc định tất cả file source-controlled |

Cấu hình `inputs` để kiểm soát file nào ảnh hưởng cache:

```json
{
  "tasks": {
    "test": {
      "inputs": ["src/**/*.ts", "test/**/*.ts", "!src/**/*.test.ts"]
    }
  }
}
```

## 4. Cache lưu ở đâu? <a href="#id-4" id="id-4"></a>

### Local Cache

Mặc định: `.turbo/cache/` trong thư mục gốc.

```json
{
  "cacheDir": ".turbo/cache",
  "cacheMaxAge": "7d",
  "cacheMaxSize": "10GB"
}
```

- **cacheMaxAge**: tự động xóa entries cũ (`30s`, `5m`, `24h`, `7d`, `2w`)
- **cacheMaxSize**: giới hạn dung lượng (`500MB`, `10GB`, `1TB`)

### Git Worktree Cache Sharing

Khi dùng `git worktree`, Turborepo tự động chia sẻ cache giữa main worktree và linked worktree:

```bash
git worktree add ../my-feature feature-branch
cd ../my-feature
turbo build  # dùng chung cache với main worktree
```

Cache sharing bị tắt nếu set `cacheDir` tùy chỉnh.

### Remote Cache

```bash
turbo login
turbo link
```

Khi active, cache được đồng bộ lên cloud (mặc định Vercel Remote Cache — miễn phí). CI cũng dùng chung cache này.

**Self-host Remote Cache:**

```bash
turbo login --manual
```

Hoặc dùng open-source implementations:
- [`brunojppb/turbo-cache-server`](https://github.com/brunojppb/turbo-cache-server)
- [`ducktors/turborepo-remote-cache`](https://github.com/ducktors/turborepo-remote-cache)

## 5. Artifact Integrity <a href="#id-5" id="id-5"></a>

Bật `signature: true` để HMAC-SHA256 sign artifacts:

```json
{
  "remoteCache": {
    "signature": true
  }
}
```

Cần set env `TURBO_REMOTE_CACHE_SIGNATURE_KEY`. Cache miss nếu signature không hợp lệ.

## 6. Troubleshooting <a href="#id-6" id="id-6"></a>

### --dry

Xem task graph mà không chạy thật:

```bash
turbo build --dry
```

Output JSON gồm: packages, tasks, dependencies, hash. So sánh hash giữa các lần chạy để debug cache miss.

### --summarize

Tạo JSON summary chứa toàn bộ inputs/outputs/hash:

```bash
turbo build --summarize
```

File lưu tại `.turbo/runs/`. So sánh diff giữa 2 summaries để biết tại sao hash khác nhau.

### --force

Bỏ qua cache, chạy lại từ đầu (chỉ bỏ qua read, vẫn write):

```bash
turbo build --force
```

### --no-cache

Tắt cache hoàn toàn cho lần chạy đó:

```bash
turbo build --no-cache
```

### Cache chậm hơn không cache

Một số trường hợp hiếm cache chậm hơn chạy thật:
- Task cực nhanh (< network round-trip tới Remote Cache)
- Output quá lớn (VD: Docker image)
- Script có caching riêng

Giải pháp: set `"cache": false` cho task đó.

## 7. Best Practices <a href="#id-7" id="id-7"></a>

1. **Khai báo `outputs` đầy đủ** — nếu không, Turborepo không cache file artifacts
2. **Dùng `inputs` để tinh chỉnh** — exclude file không ảnh hưởng (README, docs)
3. **Khai báo `env` đầy đủ** — nếu thiếu, task có thể hit cache sai (dùng `eslint-config-turbo` để detect)
4. **Remote Cache trong CI** — luôn set `TURBO_TOKEN` + `TURBO_TEAM`
5. **Kiểm tra với `--dry` và `--summarize`** — trước khi blame cache

## Tài liệu tham khảo

- [Caching Guide (official)](https://turborepo.dev/docs/crafting-your-repository/caching)
- [Remote Caching](https://turborepo.dev/docs/core-concepts/remote-caching)
- [Run Summaries](https://turborepo.dev/docs/reference/run#--summarize)
- [Cache Configuration](https://turborepo.dev/docs/reference/configuration#cachedir)
