# Hướng dẫn cấu hình Swagger trong NextJS

Swagger là một công cụ mạnh mẽ giúp tự động tạo tài liệu API và cung cấp giao diện thử nghiệm API một cách trực quan. Trong bài viết này, chúng ta sẽ tìm hiểu cách cấu hình Swagger trong Next.js để hiển thị tài liệu API cho ứng dụng của bạn.

### 1. Mục tiêu

* **Cấu hình Swagger cho API**: Tạo tài liệu API từ các route API trong ứng dụng Next.js.
* **Hiển thị Swagger UI**: Sử dụng Swagger UI để hiển thị tài liệu API dưới dạng giao diện người dùng.
* **Cấu hình linh hoạt**: Cho phép loại bỏ layout mặc định cho trang Swagger riêng biệt.

### 2. Cài đặt các thư viện cần thiết

Trước tiên, chúng ta cần cài đặt các thư viện hỗ trợ Swagger:

```bash
npm install swagger-jsdoc swagger-ui-dist
npm install @types/swagger-jsdoc @types/swagger-ui-dist --save-dev
```

* **swagger-jsdoc**: Tự động tạo tài liệu Swagger từ mã nguồn API.
* **swagger-ui-dist**: Hiển thị giao diện Swagger UI trong ứng dụng.

### 3. Tạo API Route để trả về Swagger JSON

Chúng ta cần tạo một API route để trả về tài liệu Swagger dưới dạng JSON, giúp Swagger UI hiển thị thông tin về các endpoint API.

#### Tạo file **pages/api/swagger.ts**:

```javascript
import { NextApiRequest, NextApiResponse } from 'next';
import swaggerJSDoc from 'swagger-jsdoc';

const swaggerDefinition = {
  openapi: '3.0.0',
  info: {
    title: 'My API',
    version: '1.0.0',
    description: 'API documentation for My App',
  },
  servers: [
    { url: 'http://localhost:3000' },
  ],
};

const options = {
  swaggerDefinition,
  apis: ['./pages/api/**/*.ts'],
};

const swaggerSpec = swaggerJSDoc(options);

export default function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method === 'GET') {
    res.status(200).json(swaggerSpec);
  } else {
    res.status(405).json({ message: 'Method Not Allowed' });
  }
}
```

### 4. Tạo trang Swagger UI để hiển thị tài liệu API

Tiếp theo, chúng ta tạo một trang riêng biệt để hiển thị Swagger UI.

#### Tạo file **pages/swagger.tsx**:

```javascript
'use client';
import { useEffect } from 'react';
import SwaggerUI from 'swagger-ui-dist/swagger-ui-bundle';
import 'swagger-ui-dist/swagger-ui.css';

export const metadata = {
  title: 'Swagger UI - My API',
  description: 'API documentation for My App',
};

export default function SwaggerPage() {
  useEffect(() => {
    SwaggerUI({
      dom_id: '#swagger-ui',
      url: '/api/swagger',
      deepLinking: true,
      presets: [SwaggerUI.presets.apis],
    });
  }, []);

  return (
    <div>
      <h1>Swagger API Documentation</h1>
      <div id="swagger-ui"></div>
    </div>
  );
}
```

### 5. Tắt Layout cho trang Swagger

Để tránh layout mặc định ảnh hưởng đến Swagger UI, bạn có thể điều chỉnh trong **app/layout.tsx**:

```javascript
import { ReactNode } from 'react';
import { usePathname } from 'next/navigation';

export default function Layout({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  if (pathname === '/swagger') {
    return <>{children}</>;
  }
  return (
    <html lang="en">
      <body>
        <header>
          <h1>My App Header</h1>
        </header>
        <main>{children}</main>
        <footer>Footer Content</footer>
      </body>
    </html>
  );
}
```

### 6. Thêm các Comment JSDoc vào API Route

Swagger sử dụng JSDoc để tự động tạo tài liệu API. Hãy thêm comment vào các API route của bạn như sau:

```javascript
import { NextApiRequest, NextApiResponse } from 'next';

/**
 * @openapi
 * /api/users:
 *   get:
 *     description: Returns a list of users
 *     responses:
 *       200:
 *         description: A list of users
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 type: object
 *                 properties:
 *                   id:
 *                     type: integer
 *                   name:
 *                     type: string
 */
export default function handler(req: NextApiRequest, res: NextApiResponse) {
  const users = [
    { id: 1, name: 'John Doe' },
    { id: 2, name: 'Jane Doe' },
  ];
  res.status(200).json(users);
}
```

### 7. Truy cập Swagger UI

Sau khi hoàn thành các bước trên, bạn có thể truy cập tài liệu API tại địa chỉ:

```http
http://localhost:3000/swagger
```

### 8. Tóm tắt

| Bước                             | Nội dung                                     |
| -------------------------------- | -------------------------------------------- |
| **Cài đặt thư viện**             | Cài đặt `swagger-jsdoc` và `swagger-ui-dist` |
| **Tạo API Route**                | Trả về tài liệu Swagger JSON                 |
| **Tạo trang Swagger UI**         | Hiển thị tài liệu API với Swagger UI         |
| **Tắt layout cho trang Swagger** | Đảm bảo Swagger UI hiển thị độc lập          |
| **Thêm Comment JSDoc**           | Giúp Swagger tự động tạo tài liệu API        |

Với các bước trên, bạn đã có một hệ thống Swagger UI hoàn chỉnh trong Next.js để tài liệu hóa và thử nghiệm API của mình một cách dễ dàng. Chúc bạn thành công!
