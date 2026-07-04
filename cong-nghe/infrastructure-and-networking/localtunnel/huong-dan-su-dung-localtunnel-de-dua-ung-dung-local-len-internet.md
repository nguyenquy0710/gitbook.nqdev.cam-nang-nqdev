# Hướng dẫn sử dụng Localtunnel để đưa ứng dụng Local lên Internet

Localtunnel là một công cụ mã nguồn mở tuyệt vời, giúp bạn chia sẻ ứng dụng web đang chạy trên máy local ra internet mà không cần phải lo lắng về cấu hình DNS hay firewall phức tạp. Đây là lựa chọn hoàn hảo cho các lập trình viên muốn nhanh chóng chia sẻ bản demo, kiểm tra ứng dụng trên thiết bị di động, hoặc debug từ xa.

Trong bài viết này, [**Cẩm nang NQDEV**](https://app.gitbook.com/o/ZnO3U2gDjowIXUi3yNwm/s/riO9WU3lEu4DXKD3d9zp/) sẽ hướng dẫn bạn từng bước để cài đặt và sử dụng Localtunnel, giúp đưa ứng dụng local của bạn ra thế giới chỉ trong vài phút!

## Localtunnel Là Gì? Tại Sao Nên Sử Dụng?

**Localtunnel** tạo ra một "đường hầm" (tunnel) từ máy local của bạn đến một URL công cộng. Nhờ đó, bất kỳ ai cũng có thể truy cập ứng dụng của bạn thông qua một địa chỉ tạm thời, mà bạn không cần phải triển khai lên server.

**Từ khóa chính**: Localtunnel, chia sẻ ứng dụng local, công cụ lập trình, Node.js.

## Lợi Ích Khi Sử Dụng Localtunnel

* **Chia sẻ nhanh chóng**: Dễ dàng gửi bản demo cho đồng nghiệp hoặc khách hàng mà không cần deploy.
* **Kiểm tra đa thiết bị**: Test ứng dụng trên điện thoại, máy tính bảng hoặc các trình duyệt khác nhau.
* **Hỗ trợ debug từ xa**: Cho phép người khác truy cập để hỗ trợ tìm lỗi.
* **Đơn giản, không phức tạp**: Không cần cấu hình mạng hay DNS rườm rà.

## Yêu Cầu Trước Khi Bắt Đầu

Để sử dụng Localtunnel, bạn cần chuẩn bị:

* Máy tính đã cài đặt **Node.js** (tải tại [nodejs.org](https://nodejs.org) nếu chưa có).
* Một ứng dụng web đang chạy trên máy local, ví dụ: server Node.js chạy trên cổng 3000.

## Hướng Dẫn Cài Đặt Và Sử Dụng Localtunnel

Dưới đây là các bước chi tiết để bắt đầu với Localtunnel:

### Bước 1: Cài Đặt Localtunnel

Mở terminal (hoặc command prompt) và chạy lệnh sau để cài đặt Localtunnel toàn cục:

`npm install -g localtunnel`

Lệnh này sẽ giúp bạn sử dụng lệnh lt từ bất kỳ đâu trên máy tính.

### Bước 2: Khởi Chạy Ứng Dụng Local

Đảm bảo ứng dụng của bạn đã chạy trên một cổng cụ thể. Ví dụ, nếu bạn có một server Node.js, hãy khởi động nó bằng:

`node app.js`

Hoặc nếu dự án dùng npm:

`npm start`

Giả sử ứng dụng chạy trên http://localhost:3000.

### Bước 3: Tạo Đường Hầm Với Localtunnel

Trong terminal, chạy lệnh sau để tạo đường hầm từ cổng local ra internet:

`lt --port 3000`

Localtunnel sẽ trả về một URL công cộng, ví dụ: https://flkajsfljas.loca.lt. Bạn có thể dùng URL này để truy cập ứng dụng từ bất kỳ đâu.

### Bước 4: Chia Sẻ URL

Sao chép URL được cung cấp và gửi cho bất kỳ ai bạn muốn. URL này sẽ hoạt động miễn là terminal chạy Localtunnel vẫn mở.

### Bước 5: Tùy Chỉnh Subdomain (Tùy Chọn)

Nếu muốn URL dễ nhớ hơn, bạn có thể chỉ định subdomain:

bashThu gọnBọc lạiSao chép`lt --port 3000 --subdomain mycoolapp`

Kết quả sẽ là: https://mycoolapp.loca.lt. Tuy nhiên, subdomain này phải chưa được người khác sử dụng.

## Các Tính Năng Nổi Bật Của Localtunnel

* **Bảo mật HTTPS**: Mọi đường hầm đều sử dụng giao thức an toàn.
* **Chia sẻ dễ dàng**: Hiển thị công việc của bạn cho bất kỳ ai.
* **Kiểm tra webhooks**: Dùng API để test các tích hợp webhook.
* **Hỗ trợ đa nền tảng**: Kiểm tra giao diện trên các trình duyệt đám mây.

## So Sánh Localtunnel Với Ngrok

Localtunnel và Ngrok đều là công cụ phổ biến để chia sẻ ứng dụng local. Tuy nhiên:

* **Localtunnel**: Miễn phí, không cần đăng ký, dễ dùng, nhưng subdomain ngẫu nhiên có thể thay đổi.
* **Ngrok**: Có tính năng cao cấp như custom domain, nhưng yêu cầu trả phí cho các gói nâng cao.

Nếu bạn cần giải pháp miễn phí và đơn giản, Localtunnel là lựa chọn lý tưởng.

## Lưu Ý Quan Trọng

* Đường hầm sẽ ngừng hoạt động nếu bạn đóng terminal hoặc dừng lệnh lt.
* URL công cộng là tạm thời, sẽ thay đổi mỗi khi bạn chạy lại Localtunnel.
* Tránh chia sẻ ứng dụng chứa dữ liệu nhạy cảm qua URL công khai.

## Kết Luận

Localtunnel là một công cụ mạnh mẽ, dễ sử dụng, giúp lập trình viên chia sẻ ứng dụng local ra internet chỉ trong vài bước đơn giản. Dù bạn muốn demo sản phẩm, kiểm tra giao diện, hay debug từ xa, Localtunnel đều đáp ứng tốt.

Hãy thử ngay Localtunnel trong dự án của bạn và chia sẻ trải nghiệm của mình trong phần bình luận nhé! Nếu bạn muốn tìm hiểu thêm về các công cụ tương tự, đừng bỏ lỡ bài viết về [Ngrok trên Cẩm nang NQDEV](https://blogs.nhquydev.net/) (nếu có).
