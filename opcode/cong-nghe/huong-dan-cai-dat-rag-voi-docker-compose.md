---
description: >-
  Hướng dẫn cài đặt hệ thống RAG hoàn chỉnh với Docker Compose,
  tích hợp FastAPI + LangChain + Qdrant + Open WebUI và 9Router.
---

# Hướng dẫn cài đặt RAG với Docker Compose

Hướng dẫn triển khai hệ thống **Retrieval-Augmented Generation (RAG)** hoàn chỉnh sử dụng Docker Compose. Hệ thống bao gồm backend API (FastAPI + LangChain), vector database (Qdrant), và giao diện chat (Open WebUI), tích hợp sẵn với 9Router.

## 1. Kiến trúc hệ thống <a href="#1-kien-truc-he-thong" id="1-kien-truc-he-thong"></a>

```text
┌──────────────────────────────────────────────────────────┐
│                    Open WebUI (:3000)                    │
│                  Giao diện chat Frontend                 │
└──────────────────┬───────────────────────────────────────┘
                   │ OpenAI API
┌──────────────────▼───────────────────────────────────────┐
│                    rag-api (:8000)                       │
│               FastAPI + LangChain RAG                    │
│         ┌──────────┬──────────┬────────────┐            │
│         │ Embedding│ Retriever│  Generator │            │
│         └────┬─────┴────┬─────┴─────┬──────┘            │
│              │          │           │                     │
└──────────────┼──────────┼───────────┼────────────────────┘
               │          │           │
┌──────────────▼───┐  ┌───▼───────────▼────────────────────┐
│   Qdrant (:6333) │  │   9Router (host.docker.internal)   │
│  Vector Database │  │        LLM Backend                 │
└──────────────────┘  └───────────────────────────────────┘
```

* **RAG (Retrieval-Augmented Generation):** Kỹ thuật kết hợp tìm kiếm tài liệu (retrieval) với sinh văn bản (generation) để tạo câu trả lời chính xác dựa trên dữ liệu thực tế.
* **FastAPI:** Web framework Python hiệu năng cao, dùng để xây dựng REST API.
* **LangChain:** Framework phát triển ứng dụng AI, cung cấp các công cụ cho RAG pipeline.
* **Qdrant:** Vector database chuyên dụng để lưu trữ và tìm kiếm vector embedding.
* **Open WebUI:** Giao diện web chat giống ChatGPT, có thể kết nối với nhiều LLM backend.
* **9Router:** Router LLM local, đóng vai trò sinh văn bản (text generation).

## 2. Yêu cầu <a href="#2-yeu-cau" id="2-yeu-cau"></a>

* **Hệ điều hành:** Linux, macOS, hoặc Windows (với Docker Desktop)
* **Docker:** Docker Engine 20.10+ hoặc Docker Desktop 4.0+
* **Docker Compose:** v2.0+
* **9Router:** Đang chạy trên máy host (port thường là 3000 hoặc 11434)
* **RAM:** Tối thiểu 4GB (8GB khuyến nghị cho model embedding)
* **Disk:** Tối thiểu 10GB trống

## 3. Cấu trúc thư mục <a href="#3-cau-truc-thu-muc" id="3-cau-truc-thu-muc"></a>

```text
rag-project/
├── docker-compose.yml
├── rag-api/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── main.py
└── qdrant-data/          # Tự tạo khi chạy
```

## 4. Hướng dẫn thực hiện <a href="#4-huong-dan-thuc-hien" id="4-huong-dan-thuc-hien"></a>

### 4.1 Tạo thư mục dự án

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
mkdir rag-project && cd rag-project
mkdir rag-api
```
{% endcode %}

### 4.2 Tạo file docker-compose.yml

{% code title="docker-compose.yml" overflow="wrap" lineNumbers="true" %}
```yaml
version: '3.8'

services:
  qdrant:
    image: qdrant/qdrant:latest
    ports:
      - "6333:6333"
      - "6334:6334"
    volumes:
      - qdrant_data:/qdrant/storage
    environment:
      QDRANT__SERVICE__GRPC_PORT: 6334
    restart: unless-stopped

  rag-api:
    build: ./rag-api
    ports:
      - "8000:8000"
    environment:
      QDRANT_HOST: qdrant
      QDRANT_PORT: 6333
      COLLECTION_NAME: documents
      LLM_BASE_URL: http://host.docker.internal:11434/v1
      LLM_API_KEY: not-needed
      LLM_MODEL: qwen2.5:7b
      EMBEDDING_MODEL: sentence-transformers/all-MiniLM-L6-v2
    volumes:
      - ./uploads:/app/uploads
    depends_on:
      - qdrant
    restart: unless-stopped
    extra_hosts:
      - "host.docker.internal:host-gateway"

  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    ports:
      - "3000:8080"
    environment:
      OPENAI_API_BASE_URL: http://rag-api:8000/v1
      OPENAI_API_KEY: rag-api-key
    volumes:
      - open_webui_data:/app/backend/data
    depends_on:
      - rag-api
    restart: unless-stopped

volumes:
  qdrant_data:
  open_webui_data:
```
{% endcode %}

### 4.3 Tạo file Dockerfile cho RAG API

{% code title="rag-api/Dockerfile" overflow="wrap" lineNumbers="true" %}
```dockerfile
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```
{% endcode %}

### 4.4 Tạo file requirements.txt

{% code title="rag-api/requirements.txt" overflow="wrap" %}
```text
fastapi==0.115.0
uvicorn==0.30.0
langchain==0.3.0
langchain-community==0.3.0
langchain-openai==0.2.0
qdrant-client==1.12.0
sentence-transformers==3.2.0
python-multipart==0.0.9
```
{% endcode %}

### 4.5 Tạo file main.py (Backend API)

{% code title="rag-api/main.py" overflow="wrap" lineNumbers="true" %}
```python
import os
import hashlib
from typing import List, Optional
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import Qdrant
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.document_loaders import (
    PyPDFLoader, TextLoader, Docx2txtLoader
)
from langchain_openai import ChatOpenAI
from langchain.chains import RetrievalQA
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams
import uuid

app = FastAPI(title="RAG API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

QDRANT_HOST = os.getenv("QDRANT_HOST", "qdrant")
QDRANT_PORT = int(os.getenv("QDRANT_PORT", 6333))
COLLECTION_NAME = os.getenv("COLLECTION_NAME", "documents")
LLM_BASE_URL = os.getenv("LLM_BASE_URL", "http://host.docker.internal:11434/v1")
LLM_API_KEY = os.getenv("LLM_API_KEY", "not-needed")
LLM_MODEL = os.getenv("LLM_MODEL", "qwen2.5:7b")
EMBEDDING_MODEL = os.getenv("EMBEDDING_MODEL", "sentence-transformers/all-MiniLM-L6-v2")

embeddings = HuggingFaceEmbeddings(model_name=EMBEDDING_MODEL)
text_splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=50)

qdrant_client = QdrantClient(host=QDRANT_HOST, port=QDRANT_PORT)

def ensure_collection():
    collections = qdrant_client.get_collections().collections
    if not any(c.name == COLLECTION_NAME for c in collections):
        qdrant_client.create_collection(
            collection_name=COLLECTION_NAME,
            vectors_config=VectorParams(size=384, distance=Distance.COSINE),
        )

ensure_collection()

class QueryRequest(BaseModel):
    query: str
    top_k: int = 4

class QueryResponse(BaseModel):
    answer: str
    sources: List[str]

@app.get("/health")
async def health():
    return {"status": "ok"}

@app.post("/v1/documents/upload")
async def upload_document(file: UploadFile = File(...)):
    allowed = {".pdf", ".txt", ".docx"}
    ext = os.path.splitext(file.filename)[1].lower()
    if ext not in allowed:
        raise HTTPException(400, f"Unsupported file type: {ext}")

    upload_dir = "/app/uploads"
    os.makedirs(upload_dir, exist_ok=True)
    file_path = os.path.join(upload_dir, f"{uuid.uuid4()}{ext}")

    content = await file.read()
    with open(file_path, "wb") as f:
        f.write(content)

    if ext == ".pdf":
        loader = PyPDFLoader(file_path)
    elif ext == ".docx":
        loader = Docx2txtLoader(file_path)
    else:
        loader = TextLoader(file_path)

    docs = loader.load()
    chunks = text_splitter.split_documents(docs)

    doc_id = hashlib.md5(file.filename.encode()).hexdigest()
    for i, chunk in enumerate(chunks):
        chunk.metadata["source"] = file.filename
        chunk.metadata["doc_id"] = doc_id
        chunk.metadata["chunk_index"] = i

    Qdrant.from_documents(
        chunks, embeddings,
        collection_name=COLLECTION_NAME,
        url=f"http://{QDRANT_HOST}:{QDRANT_PORT}",
    )

    return {
        "filename": file.filename,
        "chunks": len(chunks),
        "doc_id": doc_id,
    }

@app.post("/v1/query", response_model=QueryResponse)
async def query_rag(request: QueryRequest):
    vectorstore = Qdrant(
        client=qdrant_client,
        collection_name=COLLECTION_NAME,
        embedding_function=embeddings,
    )

    llm = ChatOpenAI(
        model=LLM_MODEL,
        base_url=LLM_BASE_URL,
        api_key=LLM_API_KEY,
        temperature=0.3,
    )

    qa_chain = RetrievalQA.from_chain_type(
        llm=llm,
        chain_type="stuff",
        retriever=vectorstore.as_retriever(search_kwargs={"k": request.top_k}),
        return_source_documents=True,
    )

    result = qa_chain({"query": request.query})

    sources = []
    for doc in result.get("source_documents", []):
        src = doc.metadata.get("source", "unknown")
        if src not in sources:
            sources.append(src)

    return QueryResponse(answer=result["result"], sources=sources)

@app.get("/v1/collections")
async def list_collections():
    collections = qdrant_client.get_collections().collections
    return {"collections": [c.name for c in collections]}
```
{% endcode %}

### 4.6 Tạo thư mục uploads

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
mkdir -p uploads
```
{% endcode %}

### 4.7 Cấu hình 9Router

Đảm bảo 9Router đang chạy trên máy host. Kiểm tra port bằng:

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
# Kiểm tra port 9Router
ss -tlnp | grep -E '11434|3000'

# Hoặc thử truy cập trực tiếp
curl http://localhost:11434/v1/models
```
{% endcode %}

Nếu 9Router chạy trên port khác, sửa `LLM_BASE_URL` trong `docker-compose.yml`:

{% code title="docker-compose.yml" overflow="wrap" %}
```yaml
LLM_BASE_URL: http://host.docker.internal:<port-cua-9router>/v1
```
{% endcode %}

### 4.8 Build và chạy hệ thống

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
# Build images và khởi chạy tất cả services
docker compose up -d --build

# Kiểm tra trạng thái
docker compose ps

# Xem logs
docker compose logs -f rag-api
```
{% endcode %}

## 5. Sử dụng hệ thống <a href="#5-su-dung-he-thong" id="5-su-dung-he-thong"></a>

### 5.1 Upload tài liệu

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
# Upload file PDF
curl -X POST http://localhost:8000/v1/documents/upload \
  -F "file=@tai-lieu-cua-ban.pdf"

# Upload file text
curl -X POST http://localhost:8000/v1/documents/upload \
  -F "file=@document.txt"

# Upload file Word
curl -X POST http://localhost:8000/v1/documents/upload \
  -F "file=@report.docx"
```
{% endcode %}

### 5.2 Query RAG

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
# Hỏi đáp dựa trên tài liệu đã upload
curl -X POST http://localhost:8000/v1/query \
  -H "Content-Type: application/json" \
  -d '{"query": "Tóm tắt nội dung tài liệu", "top_k": 4}'
```
{% endcode %}

### 5.3 Sử dụng giao diện Open WebUI

1. Truy cập: [http://localhost:3000](http://localhost:3000)
2. Đăng ký tài khoản đầu tiên (tài khoản admin)
3. Vào **Settings** → **Connections**
4. Thêm OpenAI API endpoint:
   * **API Base URL:** `http://rag-api:8000/v1`
   * **API Key:** `rag-api-key`
5. Bắt đầu chat!

### 5.4 API Documentation

Truy cập Swagger UI tại: [http://localhost:8000/docs](http://localhost:8000/docs)

## 6. Tùy chỉnh hệ thống <a href="#6-tuy-chinh-he-thong" id="6-tuy-chinh-he-thong"></a>

### 6.1 Thay đổi model LLM

{% code title="docker-compose.yml" overflow="wrap" %}
```yaml
LLM_MODEL: qwen2.5:7b          # Nhẹ, nhanh
LLM_MODEL: llama3:8b           # Cân bằng
LLM_MODEL: mixtral:8x7b        # Mạnh nhưng tốn tài nguyên
```
{% endcode %}

### 6.2 Thay đổi chunk size

Sửa trong `main.py` để phù hợp với loại tài liệu:

{% code title="rag-api/main.py" overflow="wrap" %}
```python
# Tài liệu ngắn (email, chat): chunk_size nhỏ
text_splitter = RecursiveCharacterTextSplitter(chunk_size=200, chunk_overlap=20)

# Tài liệu dài (sách, báo cáo): chunk_size lớn
text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=100)
```
{% endcode %}

### 6.3 Hỗ trợ nhiều loại file

Thêm dependency vào `requirements.txt` nếu cần xử lý thêm định dạng:

{% code title="rag-api/requirements.txt" overflow="wrap" %}
```text
unstructured==0.15.0    # Hỗ trợ HTML, Markdown, Email...
openpyxl==3.1.0         # Hỗ trợ file Excel
```
{% endcode %}

## 7. Troubleshooting <a href="#7-troubleshooting" id="7-troubleshooting"></a>

### 7.1 Không kết nối được 9Router

{% code title="terminal" overflow="wrap" %}
```bash
# Kiểm tra 9Router có đang chạy không
curl http://localhost:11434/v1/models

# Kiểm tra container có resolve được host không
docker exec rag-project-rag-api-1 curl -s http://host.docker.internal:11434/v1/models

# Nếu lỗi DNS, thêm extra_hosts vào docker-compose.yml
extra_hosts:
  - "host.docker.internal:host-gateway"
```
{% endcode %}

### 7.2 Lỗi Qdrant connection

{% code title="terminal" overflow="wrap" %}
```bash
# Kiểm tra Qdrant có chạy không
curl http://localhost:6333/collections

# Nếu container crash, kiểm tra logs
docker compose logs qdrant

# Reset Qdrant (XÓA TẤT CẢ DỮ LIỆU)
docker compose down -v
docker compose up -d
```
{% endcode %}

### 7.3 Lỗi upload file

{% code title="terminal" overflow="wrap" %}
```bash
# Kiểm tra dung lượng disk
docker system df

# Kiểm tra thư mục uploads
docker exec rag-project-rag-api-1 ls -la /app/uploads

# Xóa file uploads cũ nếu cần
rm -rf ./uploads/*
```
{% endcode %}

## 8. Dừng hệ thống <a href="#8-dung-he-thong" id="8-dung-he-thong"></a>

{% code title="terminal" overflow="wrap" lineNumbers="true" %}
```bash
# Dừng nhưng giữ dữ liệu
docker compose down

# Dừng và XÓA tất cả dữ liệu (vector, uploads)
docker compose down -v
```
{% endcode %}

## Tài liệu tham khảo

* [FastAPI Documentation](https://fastapi.tiangolo.com/)
* [LangChain Documentation](https://python.langchain.com/docs/)
* [Qdrant Documentation](https://qdrant.tech/documentation/)
* [Open WebUI Documentation](https://docs.openwebui.com/)
* [Docker Compose Documentation](https://docs.docker.com/compose/)
