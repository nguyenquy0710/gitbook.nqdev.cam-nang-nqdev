# Hướng dẫn Cài đặt LocalAI: Từ Docker đến Tùy biến Sâu

LocalAI có thể chạy trên hầu hết các nền tảng (Linux, macOS, Windows). Dưới đây là 3 phương pháp phổ biến nhất để anh em "lên đồ" cho hệ thống AI của mình.

### 1. Cách nhanh nhất: Sử dụng Docker (Khuyến nghị)

Đây là cách an toàn và ít lỗi nhất, giúp cô lập môi trường và dễ dàng quản lý tài nguyên.

#### Cho hệ thống chạy CPU (Phổ thông)

Bash

```
docker run -p 8080:8080 --name local-ai -ti localai/localai:latest
```

#### Cho hệ thống có GPU NVIDIA (Cần cài NVIDIA Container Toolkit)

Nếu bạn có card đồ họa, hãy sử dụng tag `-cuda` để tăng tốc xử lý:

Bash

```
docker run -p 8080:8080 --gpus all --name local-ai -ti localai/localai:latest-gpu-nvidia-cuda-12
```

> Lưu ý: Sau khi chạy, hãy truy cập `http://localhost:8080` để vào giao diện quản lý (WebUI) của LocalAI.

***

### 2. Cách "Hạt nhân": Cài đặt qua Binary (Không cần Docker)

Nếu anh em muốn chạy trực tiếp trên OS để giảm overhead của Docker hoặc tùy biến backend thủ công:

1. Truy cập [LocalAI Releases](https://github.com/mudler/LocalAI/releases).
2. Tải bản phù hợp với OS (ví dụ: `local-ai-linux-amd64` hoặc `local-ai-darwin-arm64` cho Mac M1/M2/M3).
3.  Cấp quyền thực thi và chạy:

    Bash

    ```
    chmod +x local-ai
    ./local-ai --models-path ./models --threads 4
    ```

***

### 3. Quản lý và Cài đặt Model

LocalAI không đi kèm sẵn các model nặng để tiết kiệm dung lượng. Bạn có 2 cách để thêm model:

#### Cách A: Dùng thư viện có sẵn (Gallery)

LocalAI có một danh sách các model đã được cấu hình sẵn (Llama 3, Phi-3, Whisper, Stable Diffusion...). Bạn chỉ cần gọi API:

Bash

```
curl http://localhost:8080/models/apply -H "Content-Type: application/json" -d '{
  "id": "hermes-2-pro-llama-3-8b"
}'
```

#### Cách B: Thêm Model thủ công (Custom)

Nếu bạn có file `.gguf` tải từ HuggingFace:

1. Tạo thư mục `models/`.
2. Copy file model vào đó (ví dụ: `my-model.gguf`).
3.  Tạo một file định nghĩa `my-model.yaml` trong cùng thư mục để cấu hình tham số (nhiệt độ, prompt template...):

    YAML

    ```
    name: my-model
    parameters:
      model: my-model.gguf
    context_size: 4096
    backend: llama-cpp
    ```

***

### 4. Kiểm tra trạng thái "Sống sót"

Sau khi cài đặt và tải model, hãy thử kiểm tra xem API đã sẵn sàng phục vụ chưa:

| Tác vụ          | Endpoint                 | Phương thức |
| --------------- | ------------------------ | ----------- |
| Liệt kê model   | `/v1/models`             | GET         |
| Chat Completion | `/v1/chat/completions`   | POST        |
| Tạo ảnh         | `/v1/images/generations` | POST        |

Ví dụ lệnh cURL nhanh:

Bash

```
curl http://localhost:8080/v1/chat/completions -H "Content-Type: application/json" -d '{
     "model": "gpt-4", 
     "messages": [{"role": "user", "content": "Say hello!"}]
   }'
```

_(Lưu ý: LocalAI thường map tên model bạn tải về thành tên thân thiện như `gpt-4` nếu bạn cấu hình trong file YAML)._

***

### 5. NQDEV "Pro-Tips" cho anh em

* Tối ưu CPU: Sử dụng tham số `--threads` bằng với số nhân thực tế của CPU để đạt hiệu suất tốt nhất.
* Lưu trữ: Nếu dùng Docker, hãy map volume thư mục `models` ra ngoài máy thật để khi xóa container không bị mất các file model nặng hàng chục GB: `-v $(pwd)/models:/build/models`
* Biến môi trường: Bạn có thể dùng tệp `.env` để cấu hình các tham số như `DEBUG=true`, `THREADS=8`, `GALLERIES=[...]`.

***

Chúc anh em cài đặt thành công và sớm có con "hàng" AI chạy local cực mượt cho dự án của mình!
