---
description: >-
  Design Pattern là một giải pháp chung để giải quyết các vấn đề phổ biến khi
  thiết kế phần mềm trong lập trình hướng đối tượng OOP.
---

# Design Patterns là gì?

### I. Định nghĩa <a href="#i-dinh-nghia-0" id="i-dinh-nghia-0"></a>

* Design pattern là các giải pháp tổng thể đã được tối ưu hóa, được tái sử dụng cho các vấn đề phổ biến trong thiết kế phần mềm mà chúng ta thường gặp phải hàng ngày.
* Design patterns là một kỹ thuật trong lập trình hướng đối tượng, không phải là ngôn ngữ cụ thể nào cả, nó là một kĩ thuật lập trình. Nó có thể thực hiện được ở phần lớn các ngôn ngữ lập trình, chẳng hạn như Java, C#, thậm chí là Javascript hay bất kỳ ngôn ngữ lập trình nào khác Nó khá quan trọng và mọi lập trình viên muốn giỏi đều phải biết, nó cung cấp cho bạn các “mẫu thiết kế”, giải pháp để giải quyết các vấn đề chung, thường gặp trong lập trình. Các vấn đề mà bạn gặp phải có thể bạn sẽ tự nghĩ ra cách giải quyết nhưng có thể nó chưa phải là tối ưu.
* Design Pattern giúp bạn giải quyết vấn đề một cách tối ưu nhất, cung cấp cho bạn các giải pháp trong lập trình OOP. Tuy nhiên, nếu bạn là “newbie” – người mới tìm hiểu về lập trình, chưa nắm rõ kiến thức về OOP thì giờ chưa phải lúc các bạn chơi với Design Pattern. Muốn học Design Pattern, bạn cần phải có kiến thức vững chắc về lập trình, đặc biệt là lập trình OOP. Hiểu và áp dụng được kiến thức về OOP sẽ giúp bạn tiếp cận và nâng cao trình độ với Design Pattern dễ dàng và hiệu quả hơn

### II. Design Patterns hỗ trợ developers như thế nào <a href="#ii-design-patterns-ho-tro-developers-nhu-the-nao-1" id="ii-design-patterns-ho-tro-developers-nhu-the-nao-1"></a>

#### 1. Tăng tốc độ phát triển phần mềm <a href="#id-1-tang-toc-do-phat-trien-phan-mem-2" id="id-1-tang-toc-do-phat-trien-phan-mem-2"></a>

Trong quá trình phát triển ứng dụng, việc sử dụng design patterns cho phép các developers có một công cụ để giải quyết các vấn đề thông dụng trong thiết kế phần mềm. Kể cả khi không gặp phải những vấn đề đó, việc nắm vững design patterns cũng rất hữu ích khi nó giúp developers thấy được cách giải quyết vấn đề thông qua việc ứng dụng các nguyên tắc thiết kế hướng đối tượng.

#### 2. Code tường minh, dễ dàng team work <a href="#id-2-code-tuong-minh-de-dang-team-work-3" id="id-2-code-tuong-minh-de-dang-team-work-3"></a>

Bên cạnh đó, design patterns định nghĩa một ngôn ngữ chung mà developers có thể dùng để giao tiếp hiệu quả hơn. Chẳng hạn, chỉ cần nêu tên một pattern, tất cả những đồng đội trong nhóm đều sẽ hình dung được cấu trúc, ý tưởng đằng sau đó và cách ứng dụng nó. Tối ưu thời gian phát triển ý tưởng hơn vì hạn chế được thời gian giải thích.

#### 3. Tái sử dụng code <a href="#id-3-tai-su-dung-code-4" id="id-3-tai-su-dung-code-4"></a>

Về phía dự án phần mềm, design patterns giúp developers có thể dễ dàng tái sử dụng và mở rộng code với các giải pháp tối ưu đã được kiểm chứng để giải quyết những vấn đề thông thường trong phát triển phần mềm. Do đó, khi gặp vấn đề trong xây dựng phần mềm, developers có thể coi design patterns như là kim chỉ nam để giúp mình giải quyết những vấn đề thay vì tự đi tìm kiếm giải pháp (mà có thể chưa có sự kiểm chứng kĩ càng).

#### 4. Hạn chế lỗi tiềm ẩn, dễ dàng nâng cấp <a href="#id-4-han-che-loi-tiem-an-de-dang-nang-cap-5" id="id-4-han-che-loi-tiem-an-de-dang-nang-cap-5"></a>

Ngoài ra, việc sử dụng lại các design patterns còn giúp developers tránh các vấn đề tiềm ẩn có thể sẽ gây ra những lỗi lớn trong tương lai, cùng với đó, điều đó cũng giúp dự án dễ nâng cấp và bảo trì trong tương lai hơn.

### III. Phân loại Design Patterns <a href="#iii-phan-loai-design-patterns-6" id="iii-phan-loai-design-patterns-6"></a>

Hệ thống các mẫu design pattern hiện nay rất nhiều, nhưng thường tóm gọn bằng 23 mẫu được định nghĩa trong cuốn “Design patterns Elements of Reusable Object Oriented Software”. Hệ thống các mẫu design pattern được chia thành 3 nhóm, được phân loại theo mục đích sử dụng:

* Nhóm Creational
* Nhóm Structural
* Nhóm Behavioral

Dưới đây là link chi tiết từng mẫu về định nghĩa, kiến trúc, code minh họa... để các bạn tham khảo

#### 1. Creational Pattern (Nhóm khởi tạo) <a href="#id-1-creational-pattern-nhom-khoi-tao-7" id="id-1-creational-pattern-nhom-khoi-tao-7"></a>

Nhóm Creational Pattern gồm 5 mẫu:

* [Singleton](https://viblo.asia/p/signleton-desgin-pattern-tro-thu-dac-luc-cua-developers-Qbq5QBkJKD8)
* [Factory Method](https://viblo.asia/p/factory-method-design-pattern-tro-thu-dac-luc-cua-developers-924lJBLYlPM)
* [Abstract Factory](https://viblo.asia/p/abstract-factory-design-pattern-tro-thu-dac-luc-cua-developers-maGK7B4M5j2)
* [Builder](https://viblo.asia/p/builder-design-pattern-tro-thu-dac-luc-cua-developers-bWrZnowwlxw)
* [Prototype](https://viblo.asia/p/prototype-design-pattern-tro-thu-dac-luc-cua-developers-GrLZDBQO5k0)

Các patterns loại này cung cấp giải pháp để tạo ra các đối tượng và che giấu được logic của việc tạo ra nó thay vì tạo ra đối tượng theo cách trực tiếp (sử dụng từ khoá new). Điều này giúp chương trình trở nên mềm dẻo hơn trong việc quyết định đối tượng nào cần được tạo ra trong những tình huống khác nhau.

#### 2. Structural Pattern (Nhóm cấu trúc) <a href="#id-2-structural-pattern-nhom-cau-truc-8" id="id-2-structural-pattern-nhom-cau-truc-8"></a>

Nhóm Structural Pattern gồm 7 mẫu:

* [Adapter](https://viblo.asia/p/adapter-design-pattern-tro-thu-dac-luc-cua-developers-Az45bqYQlxY)
* [Bridge](https://viblo.asia/p/bridge-design-pattern-tro-thu-dac-luc-cua-developers-gDVK2oG2ZLj)
* [Composite](https://viblo.asia/p/composite-design-pattern-tro-thu-dac-luc-cua-developers-Qbq5QBk3KD8)
* [Decorator](https://viblo.asia/p/decorator-design-pattern-tro-thu-dac-luc-cua-developers-1VgZvQ1OKAw)
* [Facade](https://viblo.asia/p/facade-design-pattern-tro-thu-dac-luc-cua-developers-924lJBLNlPM)
* [Flyweight](https://viblo.asia/p/flyweight-design-pattern-tro-thu-dac-luc-cua-developers-maGK7B4b5j2)
* [Proxy](https://viblo.asia/p/proxy-design-pattern-tro-thu-dac-luc-cua-developers-RQqKLB2bl7z)

Những patterns loại này liên quan tới class và các thành phần của đối tượng. Nó dùng để thiết lập, định nghĩa quan hệ giữa các đối tượng. Hệ thống càng lớn thì mẫu này càng đóng vai trò quan trọng. Ta có thể dựa vào class diagram để theo dõi mẫu này.

#### 3. Behavioral Pattern (Nhóm hành vi) <a href="#id-3-behavioral-pattern-nhom-hanh-vi-9" id="id-3-behavioral-pattern-nhom-hanh-vi-9"></a>

Nhóm Behavioral Pattern gồm 11 mẫu:

* [Iterpreter](https://viblo.asia/p/interpreter-design-pattern-tro-thu-dac-luc-cua-developers-djeZ1d43KWz)
* [Template Method](https://viblo.asia/p/template-method-design-pattern-tro-thu-dac-luc-cua-developers-Az45bqYLlxY)
* [Chain of Responsibility](https://viblo.asia/p/chain-of-responsibility-design-pattern-tro-thu-dac-luc-cua-developers-yMnKMBNDZ7P)
* [Command](https://viblo.asia/p/command-design-pattern-tro-thu-dac-luc-cua-developers-4dbZNBqkZYM)
* [Iterator](https://viblo.asia/p/iterator-design-pattern-tro-thu-dac-luc-cua-developers-jvElaNwY5kw)
* [Mediator](https://viblo.asia/p/mediator-design-pattern-tro-thu-dac-luc-cua-developers-m68Z0jVj5kG)
* [Memento](https://viblo.asia/p/memento-design-pattern-tro-thu-dac-luc-cua-developers-gGJ59BzrKX2)
* [Observer](https://viblo.asia/p/observer-design-pattern-tro-thu-dac-luc-cua-developers-gAm5y7WAZdb)
* [State](https://viblo.asia/p/state-design-pattern-tro-thu-dac-luc-cua-developers-3P0lPB9PKox)
* [Strategy](https://viblo.asia/p/strategy-design-pattern-tro-thu-dac-luc-cua-developers-bJzKmdwP59N)
* [Visitor](https://viblo.asia/p/visitor-design-pattern-tro-thu-dac-luc-cua-developers-gDVK2oGeZLj)

Nhóm này liên quan đến các quan hệ hành vi để xử lí các chức năng giữa các đối tượng trong hệ thống. Đối với các mẫu thuộc nhóm này ta có thể dựa vào collaboration và sequence diagram để theo dõi.

Để hiểu rõ hơn về từng mẫu Desgin Pattern, các bạn hãy theo dõi series bài viết này của mình nhé!!

### Tài liệu tham khảo <a href="#tai-lieu-tham-khao-10" id="tai-lieu-tham-khao-10"></a>

\[1] Refactoring.Guru. [https://refactoring.guru/design-patterns](https://refactoring.guru/design-patterns)

\[2] Design Patterns for Dummies, Steve Holzner, PhD

\[3] Head First, Eric Freeman

\[4] Gang of Four Design Patterns 4.0

\[5] Dive into Design Pattern

\[6] Design Patterns là gì? Tại sao nó lại là trợ thủ đắc lực của Developers - Tổng hợp 23 mẫu Design Pattern.[https://viblo.asia/p/design-patterns-la-gi-tai-sao-no-lai-la-tro-thu-dac-luc-cua-developers-tong-hop-23-mau-design-pattern-GrLZDBQV5k0](https://viblo.asia/p/design-patterns-la-gi-tai-sao-no-lai-la-tro-thu-dac-luc-cua-developers-tong-hop-23-mau-design-pattern-GrLZDBQV5k0)
