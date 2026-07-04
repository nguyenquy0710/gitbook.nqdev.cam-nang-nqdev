---
description: Docker - Beginners | Intermediate | Advanced
---

# Lab #2: Tạo một hình ảnh với lệnh ADD

COPY và ADD đều là các hướng dẫn Dockerfile phục vụ các mục đích tương tự. Chúng cho phép bạn sao chép tệp từ một vị trí cụ thể vào hình ảnh Docker.

COPY lấy một src và đích. Nó chỉ cho phép bạn sao chép một tệp hoặc thư mục cục bộ từ máy chủ của bạn (máy xây dựng hình ảnh Docker) vào chính hình ảnh Docker.

ADD cũng cho phép bạn làm điều đó nhưng nó cũng hỗ trợ 2 nguồn khác. Đầu tiên, bạn có thể sử dụng URL thay vì tệp/thư mục cục bộ. Thứ hai, bạn có thể trích xuất tệp tar từ nguồn trực tiếp vào đích.

### Tạo Dockerfile

```
FROM alpine:3.5
RUN apk update
ADD http://www.vlsitechnology.org/pharosc_8.4.tar.gz .
```

### Xây dựng hình ảnh Docker

```
docker build -t saiyam911/alpine-add . -f <name of dockerfile>
```

### Gắn thẻ hình ảnh dưới dạng labs-add

```
docker tag saiyam911/alpine-add saiyam911/labs-add:v1.0
```

### Xác minh hình ảnh

```
$ docker images
REPOSITORY                   TAG                 IMAGE ID            CREATED             SIZE
saiyam911/alpine-add        latest              cdf97cb49d48        38 minutes ago       300MB
saiyam911/labs-add          v1.0                cdf97cb49d48        38 minutes ago       300MB
```

### Tạo một thùng chứa

```
docker run -itd saiyam911/labs-add:v1.0 /bin/sh
```

```
$ docker ps
CONTAINER ID        IMAGE                      COMMAND             CREATED             STATUS              PORTS               NAMES
f0940750f61a        saiyam911/labs-add:v1.0   "/bin/sh"           20 seconds ago      Up 18 seconds                           distracted_darwin
```

### Nhập vào vỏ container

```
docker attach f094
```

Vui lòng nhấn phím “Enter” hai lần để nhập vào vỏ container

### Xác minh xem liên kết đã được trích xuất vào vùng chứa chưa

```
/ # ls -ltr
-rw-------    1 root     root     295168000 Sep 19  2007 pharosc_8.4.tar.gz
```

Lệnh THÊM cho phép bạn thêm tar trực tiếp từ một liên kết và phát nổ vào vùng chứa.



{% code title="Tài liệu tham khảo" overflow="wrap" lineNumbers="true" %}
```
https://dockerlabs.collabnix.com/beginners/dockerfile/Lab-2-Create-an-image-with-ADD-instruction.html
```
{% endcode %}
