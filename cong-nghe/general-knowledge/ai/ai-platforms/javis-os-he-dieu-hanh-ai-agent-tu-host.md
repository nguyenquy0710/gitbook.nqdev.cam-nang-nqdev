---
description: >-
  Javis OS là hệ điều hành AI agent tự host, mã nguồn mở MIT: đổi bộ não linh
  hoạt, Second Brain bằng Markdown, MCP Hub và việc chạy nền 24/7.
---

# Javis OS: Hệ điều hành AI Agent tự host với "bộ não" của riêng bạn

**Javis OS** là một **AI agentic tự host** (self-hosted agentic AI), mã nguồn mở theo giấy phép **MIT**, chạy trên máy cá nhân hoặc VPS của bạn. Thay vì là một khung chat, nó đóng vai trò **lớp điều phối**: đọc ghi file, gọi công cụ qua **MCP**, chạy skill, giao việc nền và tự đặt lịch — tất cả phía sau một dashboard điều khiển bằng giọng nói, kèm một **Second Brain** (bộ nhớ + wiki) dạng Markdown tích luỹ tri thức theo thời gian.

Điểm khác biệt cốt lõi nằm ở một câu triết lý của dự án: **năng lực nằm ở Javis, không nằm ở model.** Model là bộ phận thay được; bộ não là tài sản của bạn.

{% hint style="info" %}
Số liệu tham khảo tại thời điểm viết bài (11/2026): khoảng **820 stars**, **260 forks**, hơn **2.000 commits**. Giấy phép **MIT** (Copyright 2026 Nguyễn Minh Quý). Dự án đang phát triển rất nhanh nên tính năng và con số có thể đã thay đổi — luôn đối chiếu repo chính thức.
{% endhint %}

***

## Vì sao cần một "hệ điều hành" cho AI agent?

Dùng một app AI mỗi ngày trong một năm, bên trong nó sẽ chất đầy thứ bạn không mang đi được:

* **Hàng trăm cuộc trò chuyện:** chứa quyết định và bối cảnh bạn đã mất công cùng AI nghĩ ra.
* **Trí nhớ về bạn:** bạn là ai, làm việc kiểu gì, kinh doanh bán gì.
* **Hướng dẫn riêng, trợ lý, dự án:** bí quyết bạn đã ngồi chỉnh hàng giờ.
* **Tự động hoá và agent:** chỉ chạy được trên đúng nền tảng đó.

Tất cả nằm trên máy chủ nhà cung cấp, theo định dạng của họ. Khi một model tốt hơn ra đời ở nơi khác, bạn dùng thử được nhưng **không mang công việc theo được**: app mới không biết gì về bạn, hướng dẫn cũ không sang được, lịch sử ở lại. Đây chính là **vendor lock-in** — rời đi nghĩa là làm lại từ đầu.

Javis OS đảo ngược mô hình đó: **thuê model, sở hữu bộ não**.

| Thứ bạn tích luỹ | Nằm ở đâu | Định dạng |
| --- | --- | --- |
| Lịch sử trò chuyện | `conversations.db` trên máy/VPS của bạn | SQLite, tìm kiếm toàn văn (FTS5) |
| Trí nhớ về bạn | `memory/` trong brain: `MEMORY.md` + mỗi sự kiện một file | Markdown |
| Tri thức | thư mục Wiki và Sources của brain | Markdown, mở được bằng Obsidian |
| Skill | `skills/<tên>/SKILL.md` | Markdown |
| Agent và workflow | `agents/*.md`, `workflows/*.md` | Markdown có front matter |
| Loop và nhắc hẹn | `Javis/loops/*.md`, `Javis/reminders.json` | Markdown, JSON |

### Javis OS so với chatbot thường

| Tiêu chí | Chatbot thường | **Javis OS** |
| --- | --- | --- |
| Bộ não | Khoá cứng 1 model, gọi API rời từng câu | **Đổi được**: 14 nhà cung cấp, cùng bộ tool/MCP/skill/session |
| Trí nhớ | Quên sau mỗi phiên | **Second Brain sống**, dày lên qua từng hội thoại |
| Dữ liệu | Bịa hoặc không có | **Số liệu thật** từ kết nối bạn đấu vào (POS, Ads, lịch, email, Zalo…) |
| Công việc nền | Không có | Task Kanban, loop, nhắc hẹn — báo lại khi xong |
| Giao diện | Khung chat | Dashboard + đồ thị tri thức + giọng nói + Telegram/Slack/WhatsApp/Zalo + CLI |
| Nơi lưu kết quả | Máy chủ nhà cung cấp | **File thường trên máy bạn**, mang sang model mới được |
| Triển khai | Cloud của người khác | **Tự host**: Docker, VPS, hoặc máy cá nhân |

***

## Kiến trúc: 4 trụ cột

{% code title="Luồng xử lý tổng quan" overflow="wrap" %}
```text
Dashboard (voice + đồ thị) ─┐
Telegram / Slack / Zalo ────┤→ FastAPI server ─┬→ CLI engines  (Claude Code, Codex, Grok, Antigravity)
javis CLI ──────────────────┤                  └→ API engines  (OpenRouter, OpenAI, Gemini, Groq,
Chatbot khách hàng ─────────┘                        DeepSeek, Ollama, endpoint tương thích)
                                        │
                                        ├→ MCP Hub (kho kết nối dùng chung cho MỌI engine)
                                        └→ Second Brain (vault Markdown: Memory + Wiki + Sources)
```
{% endcode %}

### 1. Swappable Brain — bộ não thay được

Javis tách lớp suy luận (inference) khỏi lớp công cụ và dữ liệu. Hiện hỗ trợ **14 đường** kết nối model, chia theo "cách trả tiền" chứ không theo hãng:

| Nhóm | Cách dùng | Ví dụ |
| --- | --- | --- |
| **Subscription CLI** | Dùng chính gói bạn đang trả, không cần mua API riêng | Claude Code, ChatGPT (qua Codex), Grok Build, Antigravity CLI |
| **API key** | Trả theo mức dùng | OpenRouter, OpenAI API, Anthropic API, Google Gemini, Groq, DeepSeek, Ollama Cloud |
| **Chạy tại chỗ** | Dữ liệu không rời máy | Ollama local, mọi endpoint tương thích OpenAI/Anthropic |

Nhóm CLI mạnh hơn về công cụ: chạy **lệnh máy**, **fetch/search web**, **spawn sub-agent song song**. Đổi sang nhóm API không mất chức năng nào khác ngoài shell. Model mới ra? Đổi ở trang **Models**, trí nhớ và công cụ giữ nguyên.

### 2. MCP Hub — cổng công cụ thống nhất

`MCP Hub` là **một MCP server duy nhất** mà mọi engine đều thấy. Nhờ đó bộ não nào cũng gọi được cùng một hộp đồ nghề.

* **Connector và connection tách rời:** catalog chứa *template* (URL/command, cách auth, tool nào đọc/ghi); store chứa *tài khoản thật* với secret được mã hoá.
* **Ba mức quyền, cưỡng chế trong code:** `readonly`, `safe`, `full`. Mỗi lượt chạy có `mode` (`suggest` ép readonly, `auto` chặn ở safe, `full` theo perm). Hub lấy mức **chặt hơn** trong hai — bất kể prompt nói gì.
* **Nhiều tài khoản cùng dịch vụ:** một tài khoản chỉ đọc không thể dùng để gửi, thanh toán hay publish.

Đây là điểm đáng chú ý nhất về mặt thiết kế: quyền hạn do **code** quyết định, không do model "tự giác".

### 3. Second Brain — bộ não bằng Markdown

* **Vault Markdown tương thích Obsidian:** `memory/` (trí nhớ), `wiki/` (tri thức đã chưng cất), `sources/` (tài liệu gốc), liên kết bằng `[[wikilink]]`.
* **Đồ thị tri thức:** hiển thị trực quan, canvas nhẹ, chạy offline.
* **Tự học:** sau mỗi hội thoại, `learn.py` chắt lọc ký ức, tri thức Wiki và kỹ năng; **mỗi lượt học là một git commit** nên hoàn tác được một chạm.
* **Sao lưu GitHub:** đồng bộ hai chiều mọi brain lên repo riêng tư, dùng chung giữa laptop và VPS.
* **Đọc được cả khi không có Javis:** lỡ dự án mai không còn, tri thức vẫn nằm đó dưới dạng chữ thường.

### 4. Việc chạy nền — làm khi bạn ngủ

| Thành phần | Chức năng | Lưu tại |
| --- | --- | --- |
| **Tasks (Kanban)** | Giao "goal" bằng lời, AI tự đặc tả, chọn worker, chạy nền, chỉ gọi bạn khi có ngoại lệ | `kanban.sqlite3` |
| **Loops** | Việc lặp "mỗi X phút tìm một đơn vị việc", tự kiểm chứng kết quả | `Javis/loops/` |
| **Reminders / cron** | Nhắc hẹn theo giờ hoặc biểu thức cron 5 trường | `Javis/reminders.json` |
| **Workflows** | Chuỗi agent nhiều bước có checkpoint | `workflows/*.md` |
| **Chatbot đa kênh** | Đưa một cộng sự ra chăm khách trên Zalo, WhatsApp, Messenger, Telegram, Slack, Lark… | `chatbots.json` |

***

## Tính năng nổi bật

* **Trò chuyện bằng giọng nói rảnh tay:** Edge TTS miễn phí (mặc định), hoặc OpenAI, ElevenLabs.
* **Cộng sự (Coworkers):** mỗi cộng sự một vai trò, một model, prompt và skill riêng; bật **Auto** là tự chạy tiếp.
* **Teams:** gom nhiều cộng sự vào một phòng chat, trưởng nhóm chia việc; xuất cả team thành một file `.team.javis.zip`.
* **Skills và Plugins:** thả một thư mục để dạy cách làm (`SKILL.md`), hoặc thêm tool Python native cho mọi engine.
* **Kênh chat:** Telegram, Slack, WhatsApp, Zalo, Zalo OA, CLI — cùng một Javis, trả lời đúng ngôn ngữ bạn viết.
* **Từ ý tưởng đến pull request:** nối repo GitHub, Javis làm trên nhánh riêng, mở PR, theo dõi CI và tự sửa chỗ lỗi.
* **Đo mức dùng:** token và chi phí theo ngày, theo nhà cung cấp, tách phần bạn gõ tay với phần chạy nền.
* **Bảo mật khi lên VPS:** tự bắt buộc đăng nhập khi bind public, 2FA (TOTP), rate-limit, chặn CSRF/DNS-rebinding, mã hoá secret trong `settings.json`.

***

## Cài đặt

{% tabs %}
{% tab title="Windows" %}
Tải bộ cài và mở như ứng dụng thường (Windows 10/11):

```text
https://github.com/blogminhquy/javis-os/releases/download/desktop/JavisOS-Setup.exe
```

Hoặc một lệnh:

{% code title="PowerShell" overflow="wrap" %}
```powershell
git clone https://github.com/blogminhquy/javis-os.git javis; cd javis; powershell -ExecutionPolicy Bypass -File install.ps1
```
{% endcode %}
{% endtab %}
{% tab title="Linux / macOS" %}
{% code title="terminal" overflow="wrap" %}
```bash
git clone https://github.com/blogminhquy/javis-os.git javis && cd javis && chmod +x install.sh && ./install.sh
```
{% endcode %}
{% endtab %}
{% tab title="Docker" %}
{% code title="terminal" overflow="wrap" %}
```bash
curl -fsSLO https://raw.githubusercontent.com/blogminhquy/javis-os/main/docker-compose.yml && docker compose up -d
```
{% endcode %}
{% endtab %}
{% tab title="Hostinger VPS" %}
Docker Manager → Compose → URL → dán file compose rồi Deploy:

```text
https://raw.githubusercontent.com/blogminhquy/javis-os/main/docker-compose.hostinger.yml
```

Cần điền `DOMAIN_NAME`, `JAVIS_ADMIN_USER`, `JAVIS_ADMIN_PASSWORD` (và tuỳ chọn `JAVIS_AUTO_UPDATE=true`).
{% endtab %}
{% endtabs %}

Sau khi cài, mở `http://localhost:7777` và làm theo wizard:

1. **Tạo tài khoản admin** — bắt buộc khi chạy public.
2. **Chọn bộ não** — đăng nhập một gói subscription, hoặc dán API key ở trang **Models**.
3. **Chọn model** — đổi lúc nào cũng được, không mất chức năng.
4. **Đấu kết nối** (tuỳ chọn) — POS, quảng cáo, lịch, email, Zalo…

{% hint style="warning" %}
Cài thêm CLI **sau khi** Javis đã chạy thì phải **khởi động lại Javis**. Tiến trình đang chạy giữ `PATH` của lúc nó bật, nên CLI vừa cài nó không thấy — trang Models sẽ vẫn báo "CLI chưa cài".
{% endhint %}

{% hint style="danger" %}
Javis chạy bộ não AI với **toàn quyền** trên máy. Khi chạy public (Docker/VPS), hãy đặt sẵn admin qua biến môi trường ngay lúc deploy — khi chưa có admin, **ai mở link trước sẽ tạo được tài khoản admin**. Tạo xong thì bật **2FA** ngay.
{% endhint %}

***

## Lưu ý quan trọng về gói thuê bao

Đây là điểm dễ hiểu sai nhất khi dùng Javis OS.

**Anthropic** giới hạn gói Claude Pro/Max ở phạm vi **dùng cá nhân, thông thường** của Claude Code. Chạy nền liên tục (loop, nhắc hẹn, Kanban, chatbot), chạy trên VPS, hoặc nhiều người dùng chung một tài khoản đều **nằm ngoài phạm vi đó** — có nguy cơ bị khoá tài khoản, dù chính dự án ghi nhận chưa có trường hợp nào. Gói của xAI cũng chưa nói rõ.

Cách giảm rủi ro mà dự án khuyến nghị:

* Cho Claude Code chạy bằng **API key** thay vì gói, hoặc
* Trỏ **model việc nền** (`aux_engine`) sang một nhà cung cấp API rẻ như Gemini Flash hay DeepSeek qua OpenRouter.

Mô hình lai này cũng là cách tiết kiệm nhất: model mạnh cho phiên chat chiến lược, model rẻ cho việc nền định kỳ.

***

## Mã nguồn mở và dịch vụ thương mại

Cần phân biệt hai thứ dễ nhầm:

* **javisos.com** — website và repo chính thức của dự án mã nguồn mở, tác giả **Nguyễn Minh Quý**. Phần mềm miễn phí theo giấy phép MIT; bạn chỉ trả cho nhà cung cấp AI và máy chủ (nếu dùng).
* **javisos.com.vn** — do **Công ty TNHH Phần mềm MienTay Media** triển khai. Đây là **dịch vụ thương mại**: khảo sát, cài đặt, đào tạo, vận hành trọn gói, máy chủ riêng, phân quyền nhân viên, kèm các gói giải pháp theo ngành (bán lẻ, spa, F&B, bất động sản, giáo dục, hành chính công). Phần mềm vẫn là Javis OS mã nguồn mở; bạn trả cho **công triển khai và vận hành**, không phải phí bản quyền.

Nếu bạn đủ kỹ thuật, tự cài bản mã nguồn mở là đủ. Nếu cần người chịu trách nhiệm vận hành và đào tạo nhân viên, con đường thương mại tồn tại cho đúng nhu cầu đó.

***

## Ưu điểm và hạn chế

**Ưu điểm**

* **Không lock-in thật sự:** bộ não là file Markdown + git, mang đi bất cứ đâu.
* **Tận dụng gói đang trả:** dùng Claude/ChatGPT/Grok subscription thay vì mua thêm API token.
* **Quyền hạn cưỡng chế bằng code:** ba mức `readonly`/`safe`/`full`, kiểm tra ở hub chứ không tin model.
* **Chạy được trên hạ tầng nhỏ:** frontend JS thuần, không build step; backend FastAPI một tiến trình.
* **Hệ sinh thái kết nối Việt Nam:** Zalo cá nhân, Zalo OA, Pancake POS, Botcake — thứ các agent quốc tế thường thiếu.

**Hạn chế và điều cần cân nhắc**

* **Dự án non trẻ, tiến hoá rất nhanh:** hàng nghìn commit, thay đổi liên tục; API nội bộ và cấu trúc brain có thể đổi giữa các bản.
* **Không phải sản phẩm "bấm là xong":** cài đặt dễ, nhưng để hữu ích thật cần biết thiết kế cộng sự, skill, phân quyền kết nối.
* **Rủi ro ToS như đã nêu** nếu lạm dụng gói subscription cho việc chạy nền 24/7.
* **Vận hành server là của bạn:** backup, cập nhật, giám sát — bản mã nguồn mở không có ai làm hộ.

### Phù hợp với ai?

* **Dev/DevOps** muốn một agent có trí nhớ dài hạn, tự host, đọc ghi được file và repo.
* **Người đã trả gói Claude/ChatGPT** và muốn biến nó thành đội ngũ chạy nền thay vì mở tab chat.
* **Team nhỏ/SME** cần trợ lý bán hàng, báo cáo số liệu, tự động hoá content nhưng dữ liệu phải nằm trong tay mình.
* **Không phù hợp** nếu bạn cần một sản phẩm SaaS cắm-là-chạy, hoặc không muốn quản lý máy chủ.

***

## Kết luận

Javis OS đại diện cho một hướng đi khác của AI cá nhân: không cố làm model tốt hơn, mà làm **lớp sở hữu** quanh model — nơi trí nhớ, kỹ năng, quyền hạn và kết quả công việc thuộc về bạn. Với giấy phép MIT, kiến trúc MCP Hub rõ ràng và một cộng đồng Việt Nam đang lớn, đây là dự án đáng thử nếu bạn đã "đủ đau" với việc dọn ngữ cảnh qua lại giữa các tab chat.

Điều cần nhớ trước khi bắt đầu: **đọc kỹ cảnh báo ToS**, bật 2FA ngay khi chạy public, và đặt quyền kết nối ở mức thấp nhất đủ dùng.

**Tài liệu tham khảo:**

* [Javis OS — website chính thức](https://javisos.com/)
* [Javis OS Việt Nam — dịch vụ triển khai của MienTay Media](https://javisos.com.vn/)
* [GitHub — blogminhquy/javis-os](https://github.com/blogminhquy/javis-os)
* [Blog — Chọn bộ não cho Javis OS](https://javisos.com/blog/chon-bo-nao-cho-javis-os/)
* [Javis OS là gì: Hướng dẫn toàn diện (dochidung.com)](https://dochidung.com/javis-os-la-gi-huong-dan-toan-dien/)
* [README tiếng Việt](https://github.com/blogminhquy/javis-os/blob/main/docs/i18n/vi/README.md)
* [ARCHITECTURE.md](https://github.com/blogminhquy/javis-os/blob/main/ARCHITECTURE.md)
* [Model Context Protocol](https://modelcontextprotocol.io)