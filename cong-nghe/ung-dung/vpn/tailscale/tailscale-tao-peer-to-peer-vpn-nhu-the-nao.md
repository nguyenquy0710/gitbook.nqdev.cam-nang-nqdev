# Tailscale tạo Peer to Peer VPN như thế nào?

> VPN từ sau đợt Covid nở rộ rất nhiều, nhu cầu làm việc từ xa cao, mình thấy nhiều đơn vị tổ chức cũng hơi lúng túng trong việc thiết lập nó hiệu quả. Chỗ mình thì setup từ trước rồi nên cũng có gì nhiều để bàn, nhưng đợt đó mình mới biết được 1 dịch vụ P2P VPN khá hay là tailscale, từ đó mình dùng cho các máy chủ cá nhân của mình. Ví dụ như RDP, SSH các máy tính, máy chủ của mình mà không cần Anydesk, không cần IP Public, NAT port gì nữa, khá nhẹ người. Bài viết này mình sẽ tổng hợp những cái gì mình học đường từ 2 bài blog của hãng

## VPN 101 <a href="#vpn-101-0" id="vpn-101-0"></a>

Như các bạn đã biết, mô hình Virtual Private Network (VPN) truyền thống là 1 client kết nối đến 1 server VPN gateway để kết nối các máy chủ, dịch vụ khác bên trong. Với các dịch vụ VPN mua thì chỉ dùng với công dụng để đổi địa chỉ IP và mã hóa đường truyền đến máy chủ VPN đích là chính chứ không nhiều tác dụng secure lắm _(Tailscale cũng quy VPN là phần mềm "connectivity" không phải "security")_

<figure><img src="https://images.viblo.asia/9f612aad-ac9e-4d72-b941-87e6e6e49c26.png" alt=""><figcaption></figcaption></figure>

Mô hình VPN này đến nay hoạt động vẫn rất hiệu quả, **tuy nhiên vấn đề xảy ra khi bạn "scale" lên** , ví dụ như công ty ngày xưa 2-3 người, nay là 10 người hay 100 người, lúc này nhiều client kết nối tới sẽ thấy ngay là bị "chậm". Hay công ty phát triển lên có nhiều chi nhánh, văn phòng, lúc này sẽ cần cấu hình nhiều hơn trên vpn gateway tổng hoặc chia ra nhiều cái VPN gateway, mọi việc bắt đầu phức tạp lên cho cả quản trị và người dùng.

Có một số tình huống nhược điểm có thể thấy, ví dụ như bạn ở Hà Nội, nhưng lại phải kết nối vào VPN ở HCM để kết nối máy chủ ở HN => đơn giản thì mình có thể tạo ra các VPN riêng, có ip tĩnh và mở cổng firewall.

## Lý do Tailscale ra đời? <a href="#ly-do-tailscale-ra-doi-1" id="ly-do-tailscale-ra-doi-1"></a>

Ở tình huống của Tailscale, họ lựa chọn sử dụng cái core là Wireguard. Wireguard giờ dạng như "tiêu chuẩn ngành" cho VPN vì nó nhanh, nhẹ, an toàn. Wireguard tạo các tunnel rất gọn nhẹ giữa các node trong mạng, cách Wireguard hoạt động thì mình cũng chưa biết, chắc sẽ có 1 bài riêng để tìm hiểu 👌

Công thức cho nồi lẩu wireguard chúng ta cần là public key, địa chỉ IP public, port của các node kết nối trực tiếp với nhau. **Với bài toán nhỏ thì đơn giản, nhưng tưởng tượng vấn đề scale với bài toán hàng trăm node, khi có 1 cập nhật gì thì phải cấu hình lại cho 100 node đó** (mình đã từng gặp bài toán như vậy và giải quyết bằng script 😅)

Và đó cơ bản là lý do ông Tailscale ra đời. Ông này hiểu đơn giản là 1 ông "điều phối viên", chứa các public key và policy truy cập của các node và phần mềm vpn client hiểu cách giao tiếp nói chuyện với nhau đó.

<figure><img src="https://images.viblo.asia/6f020b05-5584-4706-845a-1f2a9fcf1825.png" alt=""><figcaption></figcaption></figure>

**Cơ bản trong mỗi node thực hiện các việc sau:**

1. Mỗi node tự tạo ra 1 cặp random public/private key
2. Mỗi Node kết nối với server điều phối của tailscale ([login.tailscale.com](http://login.tailscale.com/)) và để lại ghi chú như public key và đường đến node đó.
3. Mỗi Node tiện thể download thêm các public key của các node khác
4. Mỗi Node tự cấu hình Wireguard với list public key vừa lấy về

Public key là public nên gửi đi ok, Private key thì vẫn nằm trên node chứ không gửi trên server nên cơ bản khá an toàn.

#### Làm thế nào để xác thực người dùng? <a href="#lam-the-nao-de-xac-thuc-nguoi-dung-2" id="lam-the-nao-de-xac-thuc-nguoi-dung-2"></a>

Tất nhiên, để "bán" được và cho người dùng dễ tiếp cân, Tailscale sẽ cần phát triển thêm tính năng như Login, rồi set policy và làm sao để dễ setup. Với Login họ cân nhắc bài toán user/password rồi thêm 2FA nhưng lại quay xe outsource vụ authentication ra các dịch vụ bên ngoài, họ chọn oauth2, oidc, saml như Google, Github,... cùng với khái niệm `machine certificate`. Cơ bản mình nghĩ đây cũng là một nước đi hay, giảm rủi ro, tăng minh bạch và tập trung vào mấy cái chính của họ. Sau khi cài app client và đăng nhập với account bên thứ 3 thành công, app client sẽ tạo cặp key và gửi và download public key trên server điều phối theo tài khoản vừa xác thực như đã nói ở phần trước.

#### Làm thế nào để quản lý ACL policy? <a href="#lam-the-nao-de-quan-ly-acl-policy-3" id="lam-the-nao-de-quan-ly-acl-policy-3"></a>

Nếu bạn đã từng cấu hình Firewall, có thể thấy Rule firewall cơ bản quản lý theo địa chỉ IP chứ không phải user hay role, vì thế bình thường để secure chúng ta cần thêm nhiều lớp xác thực ở tầng transport và application nữa. Nhưng có 1 cái pain point là việc kêt nối mấy giải pháp này với nhau khá mệt, cấu hình firewall mà miss tí là dễ toang.

> Ngày xửa ngày xưa, đội Dev cần test nhanh 1 dịch vụ nên có xin 1 cái rule mở all cổng từ ngày xưa, nhưng máy chủ đó tắt lâu rồi. 1 năm sau đội Dev hay SA đã thay đổi, địa chỉ IP ngày xưa được cấp và MongoDB, Kibana không pass tình cờ được open phơi ra cho cả Internet vào xem hộ =]].

<figure><img src="https://images.viblo.asia/c77ebf1c-b896-480e-96c0-ca8f002aa492.png" alt=""><figcaption></figcaption></figure>

Wireguard mặc định cũng chỉ hỗ trợ cấu hình policy khá cơ bản, nó chỉ có `AllowIPs`. Ví dụ bạn muốn chỉ đi qua VPN với 1 số IP nhất định, kiểu Split tunnel thì phải tự tính allow ip net ranges, cái pain point này trên mạng có 1 anh blogger làm cái tool để tính như hình trên.

**Vậy Tailscale giải quyết bài toán này như thế nào?**

<figure><img src="https://images.viblo.asia/1a11c8b7-ebed-44a0-8ee7-17388e428e18.png" alt=""><figcaption></figcaption></figure>

Tailscale tiếp cận theo hướng mỗi node là 1 firewall và hiểu rule policy ACL, sẽ chặn / cho phép theo rule. Vì đã có một máy chủ điều phối, nên các bảo vệ đơn giản là quản lý rule tập trung 1 chỗ trên máy chủ điều phối.

Nếu chặn bằng việc cấu hình AllowIPs như trên thì khá dễ bị bypass. Vì Node A để kết nối được đến node B thì sẽ cần public key của nhau. Vì vậy để chặn kết nối A đến B Tailscale chọn cách đơn giản hơn `server điều phối sẽ không gửi các public key của node A và node B cho nhau nên không kết nối được`. Ez, right? 🤣 Tưởng tượng đoạn này mà làm tay thì đúng khổ.

Tiếp đến với phần hay nhất của họ, **tạo mô hình P2P VPN thông qua việc bypass NAT**

## Làm thế nào để kết nối 2 máy tính trực tiếp với nhau? <a href="#lam-the-nao-de-ket-noi-2-may-tinh-truc-tiep-voi-nhau-4" id="lam-the-nao-de-ket-noi-2-may-tinh-truc-tiep-voi-nhau-4"></a>

<figure><img src="https://images.viblo.asia/7d25800e-f853-4eb3-ad13-31cf994067dd.png" alt=""><figcaption></figcaption></figure>

Hình trên là mô hình hay gặp nhất trong cuộc sống, thường mạng đều được `NAT (Network Address Translation - một kỹ thuật để tiết kiệm địa chỉ IP Public, giúp mạng Private đi ra được Internet)` , mạng cafe hay mạng 4G thì cũng NAT, IP thì động liên tục. Nên bình thường nếu ở Cafe muốn kết nối mạng ở nhà thì phải mở cổng Firewall, NAT Port forwarding, Dynamic DNS đi kèm đống rủi ro mạng nhà mình bị hack lúc nào không biết.

Rõ ràng để kết nối 2 máy tính với nhau chúng ta sẽ cần 2 bên thông cổng nào đó. Vậy làm thế nào để kết nối nhỉ?

Cơ bản, Tailscale tận dụng 2 chuẩn là `STUN` và `ICE` (cái này có đề cập trong webrtc ở bài trước)

Chi tiết write up kỹ thuật rất hay này viết ở blog của Tailscale [https://tailscale.com/blog/how-nat-traversal-works/](https://tailscale.com/blog/how-nat-traversal-works/) nhưng mình sẽ đưa mấy ý chính lên trước, định viết chung 1 bài luôn nhưng chắc vẫn cần tách ra bài sau phân tích mới đã.

**Nguyên liệu nấu cơm**

* Làm việc với UDP Protocol (TCP thì tăng độ khó lên nhiều lần)
*   Direct access UDP Socket, vì mình sẽ cần gửi ké thêm phần `bypass NAT` để có thông tin tìm đường đi cho nhau<br>

    <figure><img src="https://images.viblo.asia/52320010-83ee-4ced-96f6-763fe395fa5f.png" alt=""><figcaption></figcaption></figure>
* Một side channel để kết nối các nodes.
* Một số máy chủ `STUN` , và một mạng các fallback relay

**Công thức chế biến** Vì kết nối là port sang port nên bản chất chúng ta cần tìm đường Port

* Dò tất cả `ip:port` của socket trên interface đang connect trực tiếp
*   Query STUN server để tìm WAN `ip:port` và độ khó của NAT (kiểu có phải CGNAT hay không)<br>

    <figure><img src="https://images.viblo.asia/1e0e816a-c454-4af6-b563-70a49228130b.png" alt=""><figcaption></figcaption></figure>
* Sử dụng Port Mapping Protocol để tìm thêm WAN `ip:port`
* Check NAT64 và tìm WAN `ip:port` tiếp
* Trao đổi các `ip:port` với node thông qua side channel cùng với key cho an toàn
* Kết nối các node thông qua fallback relays (giúp tìm đường nhanh hơn)
* Dò các `ip:port` của node kia để kết nối nếu cần thiết, tiếp tục thực hiện `birthday attack` để đi qua những trường hợp NAT khó
* Trong quá trình kết nối, nếu tìm thấy đường đi tốt hơn thì cập nhật ngầm đường đi mới, nếu đường đi toang thì lùi về đường cũ để đảm bảo kết nối ổn định

***

## Today I Learned <a href="#today-i-learned-5" id="today-i-learned-5"></a>

1. Biết đến Tailscale, 1 dạng VPN P2P rất tiện, giờ có thể tạm quên đến mở cổng, cấu hình firewall, DDNS. Có thể cài Tailscale lên VPN openwrt hay Pi ở nhà, bật `mode subnet` lên và kết nối thiết bị ở nhà mọi lúc mọi nơi hay dùng mạng nhà làm `Exit node` (Gateway đi ra internet) để đổi ip public luôn.
2. Phần mềm core ngon nhưng chưa dễ dùng thì mình làm Wrapper lên cho nó, Tailscale ra đời giải quyết bài toán cấu hình phức tạp của Wireguard, hiểu được cách họ giải quyết vụ quản lý key, quản lý ACL policy, authentication thế nào cho hiệu quả,...
3. Hiểu sương sương cơ chế bypass NAT thông qua 1 loạt biện pháp dò đường, cơ bản nhờ vận dụng 2 chuẩn `ICE` và `STUN` bây giờ. Hôm sau phân tích kỹ hơn phần này tiếp.

## **Tham khảo**

* [https://tailscale.com/blog/how-tailscale-works/](https://tailscale.com/blog/how-tailscale-works/)
* [https://tailscale.com/blog/how-nat-traversal-works/](https://tailscale.com/blog/how-nat-traversal-works/)
