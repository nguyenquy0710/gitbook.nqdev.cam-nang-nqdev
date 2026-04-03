# Hướng dẫn deploy EmDash trên Cloudflare Workers

Trong bài viết trước của **Cẩm nang NQDEV**, chúng ta đã phân tích vì sao EmDash là một CMS đáng chú ý trong kỷ nguyên mới.\
Bây giờ, hãy đi vào phần thực tế hơn: **deploy EmDash lên Cloudflare Workers** – nơi nó phát huy đúng sức mạnh kiến trúc.

Bài viết này sẽ giúp bạn:

* Hiểu rõ cách EmDash chạy trên Workers
* Triển khai từng bước từ local → production
* Tránh các lỗi phổ biến khi deploy

***

## 1. Tổng quan kiến trúc deploy EmDash

Trước khi bắt tay vào làm, cần hiểu một điểm quan trọng:

👉 EmDash không chạy như CMS truyền thống (PHP + server)

Thay vào đó:

* Build bằng **Astro**
* Deploy lên **Cloudflare Workers**
* Plugin chạy trong **Worker isolates (sandbox)**

#### Kiến trúc đơn giản:

```
User Request → Cloudflare Edge → Worker → Render (Astro) → Response
```

👉 Điều này giúp:

* Tốc độ cực nhanh (Edge)
* Scale gần như không giới hạn
* Bảo mật tốt hơn

***

## 2. Chuẩn bị môi trường

### 2.1. Yêu cầu cần có

* Node.js >= 18
* npm hoặc pnpm
* Tài khoản Cloudflare
* Wrangler CLI

***

### 2.2. Cài đặt Wrangler

```
npm install -g wrangler
```

Đăng nhập:

```
wrangler login
```

👉 Sau bước này, bạn đã sẵn sàng deploy lên Cloudflare.

***

## 3. Clone và chạy EmDash local

### 3.1. Clone source

```
git clone https://github.com/emdash-cms/emdash.git
cd emdash
```

### 3.2. Cài dependencies

```
npm install
```

### 3.3. Chạy local

```
npm run dev
```

👉 Truy cập:

```
http://localhost:4321
```

#### Kiểm tra:

* Admin dashboard hoạt động
* Tạo bài viết thử
* Navigation mượt

***

## 4. Build project cho Cloudflare Workers

### 4.1. Build production

```
npm run build
```

Sau khi build:

* Output nằm trong thư mục `dist/`
* Astro đã tối ưu cho production

***

### 4.2. Cấu hình adapter cho Workers

EmDash sử dụng Astro → cần adapter Cloudflare

Kiểm tra file:

```
astro.config.mjs
```

Đảm bảo có:

```
import cloudflare from '@astrojs/cloudflare';

export default {
  adapter: cloudflare()
};
```

👉 Đây là bước quan trọng để chạy trên Workers.

***

## 5. Cấu hình Wrangler

### 5.1. Tạo file cấu hình

```
wrangler init
```

Hoặc tạo nhanh `wrangler.toml`:

```
name = "emdash-app"
main = "./dist/_worker.js"
compatibility_date = "2024-01-01"

[assets]
directory = "./dist"
```

***

### 5.2. Cấu hình bindings (nếu có)

Nếu EmDash dùng:

* KV
* R2
* D1

Bạn cần khai báo:

```
[[kv_namespaces]]
binding = "CACHE"
id = "your-kv-id"
```

👉 Đây là nơi plugin sẽ truy cập tài nguyên theo permission.

***

## 6. Deploy lên Cloudflare Workers

### 6.1. Deploy

```
wrangler deploy
```

Sau khi chạy:

* Cloudflare sẽ build Worker
* Cấp URL dạng:

```
https://emdash-app.your-subdomain.workers.dev
```

***

### 6.2. Kiểm tra

* Truy cập URL
* Test:
  * Trang blog
  * Admin dashboard
  * Tạo / sửa bài viết

👉 Nếu mọi thứ hoạt động → deploy thành công 🎉

***

## 7. Custom domain (tuỳ chọn)

Bạn có thể gắn domain riêng:

```
wrangler publish --route yourdomain.com/*
```

Hoặc cấu hình trong Cloudflare Dashboard:

* Workers → Routes
* Add domain

***

## 8. Những lỗi thường gặp & cách xử lý

### ❌ Lỗi 404 sau deploy

👉 Nguyên nhân:

* Sai đường dẫn `_worker.js`

✔ Fix:

* Kiểm tra `main` trong `wrangler.toml`

***

### ❌ Plugin không hoạt động

👉 Nguyên nhân:

* Chưa khai báo bindings / capabilities

✔ Fix:

* Kiểm tra manifest plugin
* Đảm bảo đúng scope

***

### ❌ Lỗi environment variables

👉 Fix:

```
wrangler secret put API_KEY
```

***

### ❌ Build lỗi Astro

👉 Fix:

* Kiểm tra version Node
* Xoá `node_modules` và cài lại

***

## 9. Tối ưu khi chạy production

Để tận dụng tối đa EmDash:

#### ✅ Sử dụng KV cache

* Cache nội dung blog
* Giảm thời gian render

#### ✅ Dùng R2 cho media

* Lưu ảnh, file upload
* Giảm chi phí

#### ✅ Phân quyền plugin rõ ràng

* Không cấp quyền dư thừa
* Theo nguyên tắc least privilege

***

## 10. Kết luận – Deploy chỉ là bước đầu

Triển khai EmDash trên Cloudflare Workers không quá phức tạp, nhưng giá trị thật nằm ở:

👉 **kiến trúc Edge + sandbox plugin**

Đây là nền tảng để bạn:

* Xây CMS an toàn hơn
* Scale dễ dàng hơn
* Tối ưu trải nghiệm người dùng

***

### Góc nhìn từ Cẩm nang NQDEV

Tại **Cẩm nang NQDEV**, chúng tôi tin rằng:

> Deploy không chỉ là đưa code lên server, mà là lựa chọn kiến trúc phù hợp ngay từ đầu.

EmDash + Cloudflare Workers chính là một ví dụ rõ ràng cho hướng đi:

* Serverless-first
* Security-by-design
* Performance-native

Nếu bạn đang phát triển sản phẩm trên **NQDEV Platform**, hãy thử triển khai EmDash để cảm nhận sự khác biệt.

***

📚 Xem thêm các bài viết chuyên sâu tại:\
👉 [https://blogs.nhquydev.net/](https://blogs.nhquydev.net/)
