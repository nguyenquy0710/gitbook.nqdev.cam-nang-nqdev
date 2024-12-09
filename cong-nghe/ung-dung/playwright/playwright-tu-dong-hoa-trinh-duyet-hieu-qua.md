---
description: >-
  Chào mừng bạn đến với bài viết hướng dẫn Playwright - công cụ tự động hóa
  trình duyệt mạnh mẽ dành cho lập trình viên và tester!
---

# Playwright: Tự Động Hóa Trình Duyệt Hiệu Quả

Trong bài viết này, chúng ta sẽ tìm hiểu Playwright là gì, cách cài đặt và sử dụng Playwright để kiểm thử tự động hoặc tự động hóa các tác vụ trình duyệt.

***

## **1. Playwright là gì?**

**Playwright** là một thư viện mã nguồn mở được phát triển bởi **Microsoft**, hỗ trợ tự động hóa trình duyệt web như **Chromium**, Firefox, và WebKit. Với Playwright, bạn có thể:

* Kiểm thử giao diện người dùng trên nhiều trình duyệt và thiết bị.
* Tự động hóa các tác vụ trình duyệt như điền form, chụp ảnh màn hình, và thu thập dữ liệu.
* Mô phỏng hành vi người dùng, kiểm tra hiệu suất và khả năng tương thích của ứng dụng.

***

## **2. Cài đặt Playwright**

### **Bước 1: Cài đặt Node.js**

Trước tiên, hãy đảm bảo bạn đã cài đặt **Node**.js trên máy tính.

* Kiểm tra Node.js bằng lệnh:

```bash
node -v
npm -v
```

***

### **Bước 2: Cài đặt Playwright**

Chạy lệnh sau trong terminal:

```bash
npm install @playwright/test
```

Lệnh này sẽ cài đặt Playwright và các trình duyệt cần thiết.

***

### **Bước 3: Tải các trình duyệt**

Sau khi cài đặt, tải các trình duyệt hỗ trợ:

```bash
npx playwright install
```

***

## **3. Viết và chạy một kịch bản Playwright đơn giản**

### **Tạo file kiểm thử**

Tạo file `example.spec.js` và thêm nội dung sau:

```javascript
const { test, expect } = require('@playwright/test');

test('Kiểm tra tiêu đề của Google', async ({ page }) => {
    // Mở trang Google
    await page.goto('https://www.google.com');

    // Kiểm tra tiêu đề trang
    const title = await page.title();
    expect(title).toBe('Google');
});
```

***

### **Chạy kiểm thử**

Chạy kiểm thử bằng lệnh:

```bash
npx playwright test
```

Kết quả sẽ hiển thị trạng thái bài kiểm thử (PASS hoặc FAIL).

***

## **4. Một số tính năng nổi bật của Playwright**

### **4.1. Chụp ảnh màn hình**

Thêm dòng sau vào file kiểm thử để chụp ảnh màn hình:

```javascript
await page.screenshot({ path: 'screenshot.png' });
```

***

### **4.2. Tự động hóa điền form**

Dưới đây là ví dụ điền form tìm kiếm Google:

```javascript
await page.fill('input[name="q"]', 'Playwright');
await page.press('input[name="q"]', 'Enter');
```

***

### **4.3. Kiểm tra responsive**

Mô phỏng thiết bị di động bằng cách cấu hình kích thước và user agent:

```javascript
const iPhone11 = playwright.devices['iPhone 11'];
const browser = await playwright.chromium.launch();
const context = await browser.newContext({ ...iPhone11 });
const page = await context.newPage();
await page.goto('https://example.com');
```

***

### **4.4. Ghi lại kịch bản tự động**

Playwright có công cụ ghi lại kịch bản:

```bash
npx playwright codegen
```

Công cụ này sẽ ghi lại các thao tác trên trình duyệt và tự động tạo mã kiểm thử.

***

## **5. Kết hợp Playwright với CI/CD**

Playwright hỗ trợ tích hợp với các pipeline CI/CD phổ biến như GitHub Actions, Jenkins, hoặc GitLab CI. Bạn chỉ cần thêm Playwright vào workflow và thiết lập môi trường kiểm thử.

Ví dụ tích hợp với GitHub Actions:

```yaml
name: Playwright Tests

on:
  push:
    branches:
      - main

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Setup Node.js
        uses: actions/setup-node@v2
        with:
          node-version: 16

      - name: Install dependencies
        run: npm install

      - name: Run Playwright tests
        run: npx playwright test
```

***

## **6. Kết luận**

Playwright là một công cụ không thể thiếu cho các lập trình viên và tester hiện đại, giúp tự động hóa trình duyệt dễ dàng và hiệu quả. Với khả năng hỗ trợ đa trình duyệt, tích hợp CI/CD, và kiểm thử trên nhiều thiết bị, Playwright là giải pháp toàn diện cho kiểm thử ứng dụng web.

**Hãy thử ngay và chia sẻ trải nghiệm của bạn trên blog Cẩm nang NQDEV!**

***

## **Bạn muốn tìm hiểu thêm?**

Nếu có câu hỏi hoặc muốn biết thêm về các tính năng khác của Playwright, hãy để lại bình luận bên dưới hoặc liên hệ với mình qua [Cẩm nang NQDEV](https://blogs.nhquydev.net/)! 😊
