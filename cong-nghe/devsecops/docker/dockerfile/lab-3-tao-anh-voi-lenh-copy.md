---
description: Docker - Beginners | Intermediate | Advanced
---

# Lab #3: Tạo ảnh với lệnh COPY

Lệnh COPY sao chép các tập tin hoặc thư mục từ nguồn và thêm chúng vào hệ thống tập tin của vùng chứa ở đích.

Hai dạng lệnh COPY

```
COPY [--chown=<user>:<group>] <src>... <dest>
COPY [--chown=<user>:<group>] ["<src>",... "<dest>"] (this form is required for paths containing whitespace)
```

### Tạo ảnh với lệnh COPY

Dockerfile

```
FROM nginx:alpine
LABEL maintainer="Collabnix"

COPY index.html /usr/share/nginx/html/
ENTRYPOINT ["nginx", "-g", "daemon off;"]
```

Hãy tạo tệp **index.html**

```
$ echo "Welcome to Dockerlabs !" > index.html
```

#### Xây dựng hình ảnh Docker

```
$ docker image build -t cpy:v1 .
```

#### Nhìn chằm chằm vào container

```
$ docker container run -d --rm --name myapp1 -p 80:80 cpy:v1
```

#### Kiểm tra tập tin chỉ mục

```
$ curl localhost
Welcome to Dockerlabs !
```

### Hướng dẫn SAO CHÉP trong Bản dựng nhiều giai đoạn

Dockerfile

```
FROM alpine AS stage1
LABEL maintainer="Collabnix"
RUN echo "Welcome to Docker Labs!" > /opt/index.html

FROM nginx:alpine
LABEL maintainer="Collabnix"
COPY --from=stage1 /opt/index.html /usr/share/nginx/html/
ENTRYPOINT ["nginx", "-g", "daemon off;"]
```

#### Xây dựng hình ảnh Docker

```
$ docker image build -t cpy:v2 .
```

#### Nhìn chằm chằm vào container

```
$ docker container run -d --rm --name myapp2 -p 8080:80 cpy:v2
```

#### Kiểm tra tập tin chỉ mục

```
$ curl localhost:8080
Welcome to Docker Labs !
```

**LƯU Ý**: Bạn có thể đặt tên cho các giai đoạn của mình bằng cách thêm AS vào lệnh FROM. Theo mặc định, các giai đoạn không được đặt tên và bạn có thể tham chiếu chúng bằng số nguyên của chúng, bắt đầu bằng 0 cho lệnh FROM đầu tiên. Bạn không bị giới hạn Để sao chép từ các giai đoạn bạn đã tạo trước đó trong Dockerfile, bạn có thể sử dụng lệnh COPY --from để sao chép từ một hình ảnh riêng biệt, sử dụng tên hình ảnh cục bộ, thẻ có sẵn cục bộ hoặc trên sổ đăng ký Docker.

```
COPY --from=nginx:latest /etc/nginx/nginx.conf /nginx.conf
```



{% code title="Tài liệu tham khảo" overflow="wrap" lineNumbers="true" %}
```
https://dockerlabs.collabnix.com//beginners/dockerfile/lab4_dockerfile_copy.html
```
{% endcode %}
