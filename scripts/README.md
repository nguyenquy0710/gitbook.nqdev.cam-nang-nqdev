# scripts/

## upload-image.sh

Tự động upload ảnh mới lên repo `nqdev-storage/s3-001` và trả raw URL để chèn vào book.

### Yêu cầu

- `git`, `curl`
- PAT có quyền push vào `nqdev-storage/s3-001` (đặt trong biến môi trường `S3_001_TOKEN`).
  Token mặc định của repo book (`GITHUB_TOKEN`) chỉ có quyền pull, không push được vào s3-001.
- Clone local sẽ được tạo tại `~/.cache/nqdev-s3-001` (hoặc `S3_001_DIR`).

### Cách dùng

```bash
# Một ảnh, suy ra book/subdir/slug từ đường dẫn bài
scripts/upload-image.sh ./screenshot.png \
  --article cong-nghe/devsecops/docker/README.md

# Nhiều ảnh trong một lần chạy (tự đánh số -001, -002)
scripts/upload-image.sh a.png b.png \
  --article cong-nghe/foo/bar.md --width 563 --caption "Mô tả"

# Chỉ định tường minh book/subdir/slug
scripts/upload-image.sh ./img.png \
  --book cong-nghe --subdir infra/acme --slug acme-serial3 --name acme-serial3-cover

# Chèn snippet trực tiếp vào bài (append cuối file)
scripts/upload-image.sh ./img.png \
  --article cong-nghe/foo/bar.md --insert

# Chèn sau một dòng chứa marker
scripts/upload-image.sh ./img.png \
  --article cong-nghe/foo/bar.md --insert --marker '<!-- images -->'

# Chỉ xem kế hoạch, không push
scripts/upload-image.sh ./img.png --article cong-nghe/foo/bar.md --dry-run
```

### Output

- Raw URL mỗi ảnh (stdout): `https://raw.githubusercontent.com/nqdev-storage/s3-001/main/gitbook/blogs/<book>/<subdir>/<slug>-NNN.<ext>`
- Snippet `<figure>...</figure>` để paste vào bài.
- HTTP verify (200) sau push.

### Quy ước đường dẫn

`gitbook/blogs/<book>/<subdir>/<slug>-NNN.<ext>` — khớp các ảnh đang dùng trong repo.

### Rollback

```bash
cd ~/.cache/nqdev-s3-001
git revert HEAD && git push origin main
# hoặc xoá file + commit + push
```

### Lưu ý

- Không commit ảnh nhị phân vào repo book.
- Script chỉ soạn + push khi đã có PAT; không tự deploy GitBook.
- `--force` để ghi đè file đích đã tồn tại.
- `--fresh` để clone lại từ đầu.
