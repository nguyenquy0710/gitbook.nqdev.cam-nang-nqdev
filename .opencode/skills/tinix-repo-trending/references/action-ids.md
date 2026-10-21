# Cập nhật Server Action IDs khi hết hạn

TiniX Repo Trending là Next.js app. Bảng trending tải qua server actions — mỗi action có một ID băm; ID có thể đổi khi site được deploy lại.

Nếu `scripts/tinix_api.py` không trả về dữ liệu (lỗi, rỗng bất thường, hoặc 404), khả năng cao action ID đã cũ.

## Cách tìm ID mới

1. Tải JS chunk của trang chủ:
   ```bash
   curl -s https://repo.tinix.ai/vi -o /tmp/tinix.html
   grep -oE 'src="[^"]+\.js"' /tmp/tinix.html | grep -vE 'media|css' | sort -u
   ```

2. Tải từng chunk và tìm `createServerReference`:
   ```bash
   grep -hoE 'createServerReference\("[a-f0-9]+"[^)]*\)"[^;]*' /tmp/chunk_*.js
   ```

3. Đối chiếu tên action cuối chuỗi:
   - `"fetchDynamicRankings"` → khóa `rankings`
   - `"fetchGlobalStats"` → khóa `stats`
   - `"fetchPopularFilters"` → khóa `filters`
   - `"actionSearchProjectsSuggestions"` → khóa `search`

4. Ghi đè `ACTIONS` trong `scripts/tinix_api.py` bằng ID mới.

## Kiểm tra nhanh bằng curl (không cần script)

```bash
curl -s -X POST 'https://repo.tinix.ai/vi' \
  -H 'Next-Action: <ACTION_ID>' \
  -H 'Content-Type: text/plain;charset=UTF-8' \
  -H 'Accept: text/x-component' \
  --data-raw '[{"days":7,"limit":3,"offset":0,"filterType":"trending"}]'
```

Phản hồi dạng `0:{...}` / `1:{projects:[...],total:N}`. Nếu dòng `1:` chứa `projects` là action còn dùng được.
