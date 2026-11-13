# Lab #1: Tạo một hình ảnh có cài đặt GIT

### Tạo Dockerfile

{% code title="terminal" lineNumbers="true" %}
```sh
FROM alpine:3.5
RUN apk update
RUN apk add git
```
{% endcode %}

### Xây dựng hình ảnh Docker

{% code title="terminal" lineNumbers="true" %}
```sh
docker build -t ajeetraina/alpine-git .
```
{% endcode %}

### Gắn thẻ hình ảnh là labs-git

{% code title="terminal" lineNumbers="true" %}
```sh
docker tag ajeetraina/alpine-git ajeetraina/labs-git:v1.0
```
{% endcode %}

### Xác minh hình ảnh

{% code title="terminal" lineNumbers="true" %}
```sh
$ docker images
REPOSITORY              TAG                 IMAGE ID            CREATED             SIZE
ajeetraina/alpine-git   latest              cb913e37a593        16 seconds ago      26.6MB
ajeetraina/labs-git     v1.0                cb913e37a593        16 seconds ago      26.6MB
```
{% endcode %}

### Tạo một thùng chứa

{% code title="terminal" lineNumbers="true" %}
```sh
docker run -itd ajeetraina/labs-git:v1.0 /bin/sh
```
{% endcode %}

{% code title="terminal" lineNumbers="true" %}
```sh
$ docker ps
CONTAINER ID        IMAGE                      COMMAND             CREATED             STATUS              PORTS               NAMES
3e26a5268f55        ajeetraina/labs-git:v1.0   "/bin/sh"           4 seconds ago       Up 2 seconds                            elated_neumann
```
{% endcode %}

### Nhập vào vỏ container

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```sh
docker attach 3e26
```
{% endcode %}

Vui lòng nhấn phím “Enter” hai lần để nhập vào vỏ container

### Xác minh xem GIT đã được cài đặt chưa

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```shell
/ # git --version
git version 2.13.7
```
{% endcode %}



{% code title="Tài liệu tham khảo" overflow="wrap" lineNumbers="true" %}
```
https://dockerlabs.collabnix.com/beginners/dockerfile/lab1_dockerfile_git.html
```
{% endcode %}
