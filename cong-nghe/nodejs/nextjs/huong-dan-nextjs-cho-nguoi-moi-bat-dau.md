# Hướng dẫn NextJS cho người mới bắt đầu

Next.js là một framework mạnh mẽ dựa trên React, giúp bạn xây dựng các ứng dụng web hiện đại với khả năng tối ưu hóa SEO, hiệu năng cao và các tính năng tích hợp sẵn như Server-Side Rendering (SSR), Static Site Generation (SSG), và API Routes.

Bài viết này sẽ hướng dẫn bạn các bước cơ bản để bắt đầu với Next.js.

<figure><img src="https://nextjs.org/_next/image?url=%2Fdocs%2Fdark%2Fproject-organization-colocation.png&#x26;w=3840&#x26;q=75" alt=""><figcaption></figcaption></figure>



***

## **1. Cài Đặt Môi Trường**

### **Yêu cầu:**

* **Node.js**: Tải về và cài đặt từ [Node.js](https://nodejs.org/).
* **npm** hoặc **yarn**: Được cài đặt sẵn khi bạn cài Node.js.

### **Khởi tạo dự án Next.js:**

Sử dụng lệnh sau để tạo một dự án Next.js mới:

```bash
npx create-next-app@latest my-nextjs-app
```

Lựa chọn các cấu hình theo ý thích (TypeScript, ESLint, Tailwind CSS, v.v.).

Di chuyển vào thư mục dự án:

```bash
cd my-nextjs-app
```

### Chạy ứng dụng:

```bash
npm run dev
```

Truy cập ứng dụng tại http://localhost:3000.

***

## **2. Cấu Trúc Thư Mục Next.js**

Khi bạn tạo một dự án Next.js, cấu trúc thư mục cơ bản sẽ như sau:

```bash
my-nextjs-app/
├── pages/          # Chứa các file định nghĩa route
├── public/         # Chứa các tài nguyên tĩnh (hình ảnh, favicon, ...)
├── styles/         # Chứa các file CSS
├── package.json    # File cấu hình dự án
├── next.config.js  # File cấu hình Next.js
```

### **Thư mục quan trọng:**

* **`pages`**: Mỗi file trong thư mục này sẽ tự động trở thành một route.
* **`public`**: Các tài nguyên tĩnh trong thư mục này có thể truy cập qua URL.
* **`styles`**: Chứa các file CSS để định dạng giao diện.

***

## **3. Tạo Trang Đầu Tiên**

### **Tạo một trang đơn giản:**

Tạo file `about.js` trong thư mục `pages`:

```javascript
// pages/about.js
export default function AboutPage() {
  return (
    <div>
      <h1>Giới Thiệu</h1>
      <p>Đây là trang giới thiệu cơ bản.</p>
    </div>
  );
}
```

Truy cập http://localhost:3000/about để xem trang.

### **Trang chính (`index.js`):**

File `index.js` trong thư mục `pages` là trang mặc định (home page):

```javascript
// pages/index.js
export default function HomePage() {
  return (
    <div>
      <h1>Chào mừng đến với Next.js</h1>
      <p>Bạn đã bắt đầu với Next.js thành công!</p>
    </div>
  );
}
```

***

## **4. Styles với CSS**

### **Thêm CSS toàn cục:**

Trong file `styles/globals.css`, bạn có thể định nghĩa CSS áp dụng cho toàn bộ ứng dụng:

```css
/* styles/globals.css */
body {
  font-family: Arial, sans-serif;
  margin: 0;
  padding: 0;
}
```

Đừng quên nhập file này trong `_app.js`:

```javascript
// pages/_app.js
import '../styles/globals.css';

export default function MyApp({ Component, pageProps }) {
  return <Component {...pageProps} />;
}
```

### **CSS module:**

Next.js hỗ trợ CSS module để quản lý CSS cục bộ:

```javascript
// components/Button.module.css
.button {
  background-color: blue;
  color: white;
  padding: 10px 20px;
  border: none;
  cursor: pointer;
}
```

### Sử dụng trong component:

```javascript
// components/Button.js
import styles from './Button.module.css';

export default function Button() {
  return <button className={styles.button}>Nhấn vào đây</button>;
}
```

***

## **5. API Routes**

Next.js hỗ trợ xây dựng API dễ dàng. Tạo file `hello.js` trong thư mục `pages/api`:

```javascript
// pages/api/hello.js
export default function handler(req, res) {
  res.status(200).json({ message: 'Xin chào từ API của Next.js!' });
}
```

Truy cập http://localhost:3000/api/hello để xem API phản hồi.

***

## **6. Data Fetching**

Next.js hỗ trợ nhiều phương thức để lấy dữ liệu:

### **Server-Side Rendering (SSR):**

Lấy dữ liệu trên server trước khi render trang:

```javascript
// pages/ssr.js
export async function getServerSideProps() {
  return {
    props: {
      message: 'Dữ liệu từ SSR',
    },
  };
}

export default function SSRPage({ message }) {
  return <div>{message}</div>;
}
```

### **Static Site Generation (SSG):**

Lấy dữ liệu tại thời điểm build:

```javascript
// pages/ssg.js
export async function getStaticProps() {
  return {
    props: {
      message: 'Dữ liệu từ SSG',
    },
  };
}

export default function SSGPage({ message }) {
  return <div>{message}</div>;
}
```

***

## **7. Triển Khai Ứng Dụng**

Triển khai ứng dụng Next.js rất dễ dàng với [Vercel](https://vercel.com/), nền tảng được thiết kế để tối ưu hóa cho Next.js.

### **Các bước triển khai:**

1. Đăng ký tài khoản trên Vercel.
2. Kết nối dự án với GitHub/GitLab/Bitbucket.
3. Chọn repository và cấu hình Next.js.
4. Nhấn "Deploy" để hoàn tất.

***

## **Kết Luận**

Next.js là một framework mạnh mẽ và dễ sử dụng, phù hợp cho cả người mới bắt đầu lẫn các dự án lớn. Với các tính năng hiện đại như SSR, SSG, và API Routes, bạn có thể xây dựng các ứng dụng web tối ưu, hiệu quả và dễ bảo trì.

Hãy thử ngay hôm nay và tận hưởng trải nghiệm lập trình với Next.js!
