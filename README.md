# Cẩm nang NQDEV

[![GitHub Pages](https://img.shields.io/badge/GitHub%20Pages-deployed-blue?logo=github)](https://nguyenquy0710.github.io/gitbook.nqdev.cam-nang-nqdev/)
[![GitBook](https://img.shields.io/badge/Built%20with-GitBook-3884FF?logo=gitbook)](https://www.gitbook.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Node.js](https://img.shields.io/badge/Node.js-v14-339933?logo=node.js)](https://nodejs.org/)

> Tổng hợp kiến thức, hướng dẫn và tài liệu tham khảo về công nghệ, DevSecOps và cuộc sống — dành cho lập trình viên và kỹ sư công nghệ.

**Tác giả:** Nguyễn Hữu Quý (Nguyễn Quý DevNet) · **Hệ sinh thái:** NQDEV Platform 
**Phiên bản:** v1.1.1 · **Release:** [Releases](https://github.com/nguyenquy0710/gitbook.nqdev.cam-nang-nqdev/releases)

---

## 📖 Giới thiệu

**Cẩm nang NQDEV** là một nền tảng tri thức chuyên sâu, mang tính ứng dụng cao, được xây dựng như một phần của hệ sinh thái **NQDEV Platform**. Mỗi bài viết không chỉ truyền đạt kiến thức kỹ thuật mà còn mở ra góc nhìn dài hạn, giúp bạn định hình tư duy và tự tin bước vào những dự án phức tạp hơn.

- **Nội dung chuyên sâu, gần gũi** — dễ hiểu và dễ vận dụng vào thực tế.
- **Kinh nghiệm thực chiến** — tổng hợp từ nhiều năm làm việc và phát triển hệ thống của Nguyễn Quý DevNet.
- **Tư duy chuẩn doanh nghiệp** — định hướng giải quyết vấn đề theo phương pháp chuẩn DevOps, chuẩn sản phẩm.
- **Luôn cập nhật** — rà soát và cập nhật theo các công nghệ mới.

## 📚 Nội dung

Dự án được tổ chức thành 7 "book" (sách) con, mỗi book có `SUMMARY.md` (mục lục) và `README.md` (giới thiệu):

| Book | Mô tả |
|------|-------|
| [cheat-sheet](cheat-sheet/) | Lệnh & thủ thuật nhanh (Git, Bash, Redis, HAProxy, Windows, …) |
| [cong-nghe](cong-nghe/) | Công nghệ & công cụ (lập trình, database, hạ tầng, AI, …) |
| [cuoc-song](cuoc-song/) | Kỹ năng mềm, sách và cuộc sống |
| [devsecops](devsecops/) | Bảo mật & DevOps (Docker, Ansible, VMware, …) |
| [hoi-dap](hoi-dap/) | Hỏi đáp (SQL, chia sẻ kinh nghiệm) |
| [lien-he](lien-he/) | Liên hệ, chính sách, fanpage |
| [prompts](prompts/) | Prompt engineering (ChatGPT, Gemini, coding, …) |

## 🗂️ Cấu trúc thư mục

```
.
├── README.md                 # File này
├── SUMMARY.md                # Mục lục tổng (GitBook)
├── book.json                 # Cấu hình GitBook
├── cheat-sheet/              # Book: cheat sheet
├── cong-nghe/                # Book: công nghệ
├── cuoc-song/                # Book: cuộc sống
├── devsecops/                # Book: devsecops
├── hoi-dap/                  # Book: hỏi đáp
├── lien-he/                  # Book: liên hệ
├── prompts/                  # Book: prompts
├── .github/workflows/        # CI/CD deploy GitBook
├── .opencode/                # Cấu hình OpenCode & skills
└── _book/                    # Artifact build (không commit)
```

## 🚀 Bắt đầu (chạy local)

### Yêu cầu

- **Node.js v14** (gitbook-cli không tương thích với phiên bản mới hơn)
- npm

### Cài đặt & build

```bash
# Cài GitBook CLI
npm install -g gitbook-cli --legacy-peer-deps

# Cài plugin và build
gitbook install
gitbook build        # output: _book/
```

### Serve local

```bash
gitbook serve        # mặc định http://localhost:4000
```

## 🌐 Deploy

Deploy **chỉ kích hoạt thủ công** (không auto-deploy khi push). Hai cách:

1. **Chạy local** rồi đẩy `_book/` lên GitHub Pages.
2. **Trigger workflow** `.github/workflows/deploy_gitbook.yml` trong tab **Actions** của repository (Node 14, build + deploy lên GitHub Pages).

## ✍️ Đóng góp

Mọi đóng góp đều được hoan nghênh! Khi thêm bài viết mới:

1. Đặt file `.md` trực tiếp vào thư mục book phù hợp (ví dụ `cong-nghe/<sub-dir>/bai-viet.md`).
2. Tuân theo quy ước:
   - YAML `description:` front matter (< 160 ký tự cho SEO)
   - Giữ GitBook syntax (`{% code %}`, `{% tabs %}`, `{% endcode %}`)
   - Tiếng Việt, giữ nguyên thuật ngữ tiếng Anh
   - Tên file: lowercase-kebab-case với đầy đủ dấu tiếng Việt
3. Thêm entry vào `SUMMARY.md` của book nguồn, đường dẫn tương đối so với thư mục book.
4. **Không** tạo thư mục `opcode/`.

Xem thêm chi tiết trong [`AGENTS.md`](AGENTS.md).

## 📄 License

Dự án phát hành theo [MIT License](LICENSE). © 2024 Nguyễn Hữu Quý.

## ☕ Ủng hộ

<p align="center">☕ <strong>Ủng hộ dự án tại</strong>: <a href="https://me.momo.vn/nhquydev">Mua cà phê cho NQDEV</a>.</p>

<figure><img src="https://img.vietqr.io/image/MB-VQRQAAXGO9340-gjSyj8L.png?amount=10000&#x26;accountName=NGUYEN%20HUU%20QUY&#x26;addInfo=Mua%20ca%20phe%20cho%20NQDEV" alt=""><figcaption></figcaption></figure>

## 📬 Liên hệ

- GitHub: [@nguyenquy0710](https://github.com/nguyenquy0710)
- Fanpage & liên hệ thêm xem trong book [lien-he](lien-he/).
