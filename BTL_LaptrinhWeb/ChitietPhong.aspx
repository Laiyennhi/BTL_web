<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ChitietPhong.aspx.cs" Inherits="BTL_Web.ChitietPhong" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết phòng | Hanoi Stay Nest</title>
    <link rel="stylesheet" href="stylesheet/style.css?v=6" />
</head>
<body>
    <form id="form1" runat="server" style="display: flex; flex-direction: column; min-height: 100vh;">

        <!-- HEADER ĐÃ ĐỒNG BỘ PHÂN QUYỀN -->
        <header>
            <a href="Trangchu.aspx" class="logo-box">
                <svg width="65" height="32" viewBox="0 0 80 40" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M10 30L40 8L70 30" stroke="#D68C94" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M22 25L45 14L62 28" stroke="#D68C94" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M55 12V19" stroke="#D68C94" stroke-width="3.5" stroke-linecap="round"/>
                </svg>
                <span>Hanoi</span>
                <span>Stay Nest</span>
            </a>

            <ul class="nav-menu">
                <li><a href="Trangchu.aspx" class="active">Trang chủ</a></li>
                <% if (Session["UserID"] != null) { %>
                    <li><a href="Favorites.aspx">Yêu Thích</a></li>
                    <li><a href="Bookings.aspx">Hoạt động</a></li>
                <% } else { %>
                    <li><a href="Profile.aspx">Yêu Thích</a></li>
                    <li><a href="Profile.aspx">Hoạt động</a></li>
                <% } %>
            </ul>

            <!-- CỤM AVATAR & POPOVER MENU TÀI KHOẢN -->
            <div class="avatar-menu-wrapper">
                <button type="button" class="header-avatar-btn" onclick="toggleAccountMenu(event)" title="Tài khoản">
                    <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
                        <circle cx="50" cy="50" r="50" fill="#F8B8BE"/>
                        <circle cx="50" cy="38" r="17" fill="#FFFFFF"/>
                        <path d="M20 88C20 68 33 58 50 58C67 58 80 68 80 88" fill="#FFFFFF"/>
                    </svg>
                </button>

                <div id="accountPopover" class="account-popover-menu">
                    <% if (Session["UserID"] != null) { %>
                        <a href="Account.aspx" class="popover-user-header">
                            <div class="popover-mini-avatar">
                                <%= (Session["FullName"] != null && Session["FullName"].ToString().Length > 0)
                                    ? Session["FullName"].ToString().Substring(0, 1).ToUpper() : "U" %>
                            </div>
                            <div class="popover-user-info">
                                <div class="popover-user-name"><%= Session["FullName"] ?? "Thành viên" %></div>
                                <div class="popover-user-sub"><%= Session["Email"] ?? Session["UserEmail"] ?? "Khách thuê phòng" %></div>
                            </div>
                            <span class="popover-chevron">›</span>
                        </a>

                        <div class="popover-divider"></div>

                        <a href="Account.aspx" class="popover-menu-row"><span>👤 Thông tin cá nhân</span></a>
                        <a href="Bookings.aspx" class="popover-menu-row"><span>📅 Hoạt động đặt phòng</span></a>
                        <a href="Favorites.aspx" class="popover-menu-row"><span>❤️ Danh sách yêu thích</span></a>

                        <div class="popover-divider"></div>

                        <% 
                            string currentRole = Session["Role"] != null ? Session["Role"].ToString() : "Guest";
                            if (currentRole == "Admin") { 
                        %>
                            <a href="AdminDashboard.aspx?tab=users" class="popover-menu-row" style="color: #b83b5e; font-weight: 600;">
                                <span>🛡️ Quản trị hệ thống (Admin)</span>
                            </a>
                        <% } else if (currentRole == "Host") { %>
                            <a href="HostDashboard.aspx?tab=bookings" class="popover-menu-row" style="color: #d66b76; font-weight: 600;">
                                <span>📋 Kênh Chủ phòng (Đơn đặt)</span>
                            </a>
                            <a href="HostDashboard.aspx?tab=rooms" class="popover-menu-row">
                                <span>🏠 Phòng của tôi</span>
                            </a>
                        <% } else { %>
                            <a href="DangKyHost.aspx" class="popover-menu-row" style="color: #d66b76; font-weight: 500;">
                                <span>🏠 Đăng ký làm Host</span>
                            </a>
                        <% } %>

                        <div class="popover-divider"></div>

                        <a href="#" class="popover-menu-row"><span style="flex:1;">🛟 Trợ giúp</span><span class="popover-chevron">›</span></a>
                        <a href="Logout.aspx" class="popover-menu-row" onclick="return confirm('Bạn có chắc chắn muốn đăng xuất?');"><span>🚪 Đăng xuất</span></a>
                    <% } else { %>
                        <div class="popover-user-header" style="cursor: default;">
                            <div class="popover-mini-avatar" style="background-color: #f8b8be;">?</div>
                            <div class="popover-user-info">
                                <div class="popover-user-name">Khách</div>
                                <div class="popover-user-sub">Chưa đăng nhập</div>
                            </div>
                        </div>
                        <div class="popover-divider"></div>
                        <a href="Profile.aspx" class="popover-menu-row"><span>🔑 <strong>Đăng nhập / Đăng ký</strong></span></a>
                        <div class="popover-divider"></div>
                        <a href="#" class="popover-menu-row"><span style="flex:1;">🛟 Trợ giúp</span><span class="popover-chevron">›</span></a>
                    <% } %>
                </div>
            </div>
        </header>

        <!-- MAIN CONTENT -->
        <main class="detail-container" style="flex: 1;">
            
            <!-- Breadcrumb -->
            <div class="breadcrumb-text">
                Trang chủ / <asp:Label ID="lblDistrictTop" runat="server"></asp:Label> / <asp:Label ID="lblCodeTop" runat="server"></asp:Label>
            </div>

            <!-- Tiêu đề + Nút thả tim -->
            <div class="detail-header-row">
                <div>
                    <div class="detail-title">
                        <asp:Label ID="lblTitle" runat="server"></asp:Label>
                        <span class="detail-code-tag">#<asp:Label ID="lblCodeTag" runat="server"></asp:Label></span>
                    </div>
                    <div class="detail-specs">
                        <asp:Label ID="lblSpecs" runat="server"></asp:Label>
                    </div>
                </div>

                <asp:LinkButton ID="btnHeartDetail" runat="server" OnClick="btnHeartDetail_Click" style="background:none; border:none; cursor:pointer; padding:5px;">
                    <svg id="svgHeart" runat="server" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#333333" stroke-width="1.8">
                        <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"></path>
                    </svg>
                </asp:LinkButton>
            </div>

            <!-- Lưới 5 ảnh -->
            <div class="gallery-grid">
                <div class="gallery-main">
                    <asp:Image ID="imgMain" runat="server" />
                </div>
                <div class="gallery-sub"><asp:Image ID="imgSub1" runat="server" /></div>
                <div class="gallery-sub"><asp:Image ID="imgSub2" runat="server" /></div>
                <div class="gallery-sub"><asp:Image ID="imgSub3" runat="server" /></div>
                <div class="gallery-sub"><asp:Image ID="imgSub4" runat="server" /></div>
            </div>

            <!-- Nội dung 2 cột -->
            <div class="detail-body-grid">
                
                <!-- Cột trái: Chủ phòng, Mô tả, Tiện nghi, Địa chỉ -->
                <div>
                    <div class="host-info-box">
                        <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80" class="host-avatar" alt="Host" />
                        <div>
                            <div style="font-size: 20px; font-weight: 500; color: #111;">
                                Chủ Phòng [ <asp:Label ID="lblHostName" runat="server"></asp:Label> ]
                            </div>
                            <div style="font-size: 15px; color: #777; margin-top: 4px;">
                                [ <asp:Label ID="lblHostContact" runat="server"></asp:Label> ]
                            </div>
                        </div>
                    </div>

                    <div class="detail-section">
                        <h3>Mô Tả</h3>
                        <p style="font-size: 16px; color: #333; line-height: 1.6;">
                            <asp:Label ID="lblDescription" runat="server"></asp:Label>
                        </p>
                    </div>

                    <div class="detail-section">
                        <h3>Tiện Nghi</h3>
                        <div class="amenities-grid">
                            <div>🍳 Nhà bếp</div>
                            <div>📶 Wifi</div>
                            <div>🚿 Vệ sinh khép kín</div>
                            <div>📹 Camera</div>
                            <div>📺 Tivi</div>
                            <div>🧺 Máy giặt</div>
                        </div>
                    </div>

                    <div style="font-size: 19px; font-weight: 500; color: #111;">
                        Địa chỉ chi tiết : <asp:Label ID="lblFullAddress" runat="server" Font-Bold="false"></asp:Label>
                    </div>
                </div>

                <!-- Cột phải: Card đặt phòng -->
                <div>
                    <!-- TRẠNG THÁI 1: Form chọn ngày & tính tiền -->
                    <asp:Panel ID="pnlBookingForm" runat="server" CssClass="booking-card">
                        <div class="booking-price-header">
                            <asp:Label ID="lblPricePerNight" runat="server"></asp:Label> đ / đêm
                        </div>

                        <div class="date-inputs-row">
                            <div class="date-field">
                                <label>Nhận Phòng</label>
                                <asp:TextBox ID="txtCheckIn" runat="server" TextMode="Date" onchange="tinhTienPhong()"></asp:TextBox>
                            </div>
                            <div class="date-field">
                                <label>Trả Phòng</label>
                                <asp:TextBox ID="txtCheckOut" runat="server" TextMode="Date" onchange="tinhTienPhong()"></asp:TextBox>
                            </div>
                        </div>

                        <asp:Button ID="btnKiemTraPhong" runat="server" Text="Kiểm tra tình trạng phòng" 
                                    CssClass="btn-check-avail" OnClick="btnKiemTraPhong_Click" />

                        <div class="price-calc-row">
                            <span id="lblCalcFormula">0 đ x 0 đêm</span>
                            <span id="lblSubTotal">0 đ</span>
                        </div>
                        <div class="price-total-row">
                            <span>Tổng</span>
                            <span id="lblGrandTotal">0 đ</span>
                        </div>

                        <button type="button" class="btn-book-red" onclick="moPopupThanhToan()">Đặt Phòng</button>
                    </asp:Panel>

                    <!-- TRẠNG THÁI 2: Màn hình quét mã QR -->
                    <asp:Panel ID="pnlQRPayment" runat="server" CssClass="booking-card" Visible="false" style="text-align: center;">
                        <asp:LinkButton ID="btnCloseQR" runat="server" CssClass="modal-close-btn" OnClick="btnQuayLaiForm_Click">X</asp:LinkButton>
                        <div style="font-size: 16px; font-weight: 500; margin-bottom: 16px;">Quét mã bằng ngân hàng bạn chọn</div>
                        
                        <img src="https://api.qrserver.com/v1/create-qr-code/?size=160x160&data=HanoiStayNest_ThanhToan" 
                             alt="QR Code" style="width: 160px; height: 160px; margin: 0 auto 16px auto; display: block;" />
                        
                        <div style="display: flex; justify-content: space-between; font-size: 15px; font-weight: 600; margin-bottom: 8px;">
                            <span>Tổng</span>
                            <asp:Label ID="lblQRTongTien" runat="server"></asp:Label>
                        </div>
                        <div style="text-align: left; font-size: 15px; margin-bottom: 18px;">
                            Nội dung: <strong><asp:Label ID="lblQRNoiDung" runat="server"></asp:Label></strong>
                        </div>

                        <asp:Button ID="btnXacNhanQR" runat="server" Text="Thanh toán hoàn tất" CssClass="btn-check-avail" OnClick="btnXacNhanQR_Click" />
                        <div style="font-size: 12px; color: #666;">Vui lòng thanh toán trước 24h. Quá hạn đơn sẽ tự hủy</div>
                    </asp:Panel>

                    <!-- TRẠNG THÁI 3: Màn hình thanh toán trực tiếp -->
                    <asp:Panel ID="pnlDirectPayment" runat="server" CssClass="booking-card" Visible="false">
                        <asp:LinkButton ID="btnCloseDirect" runat="server" CssClass="modal-close-btn" OnClick="btnQuayLaiForm_Click">X</asp:LinkButton>
                        <div style="font-size: 16px; line-height: 1.5; margin-bottom: 18px; padding-right: 20px;">
                            Vui lòng thanh toán cho chủ phòng sau khi nhận phòng.
                        </div>
                        <div style="display: flex; justify-content: space-between; font-size: 16px; font-weight: 600; margin-bottom: 22px;">
                            <span>Tổng</span>
                            <asp:Label ID="lblDirectTongTien" runat="server"></asp:Label>
                        </div>
                        <asp:Button ID="btnGuiYeuCauDirect" runat="server" Text="Gửi yêu cầu đặt phòng" CssClass="btn-check-avail" OnClick="btnGuiYeuCauDirect_Click" />
                    </asp:Panel>

                    <!-- TRẠNG THÁI 4: Đang chờ xác nhận -->
                    <asp:Panel ID="pnlPendingConfirm" runat="server" CssClass="booking-card" Visible="false" style="text-align: center; padding: 35px 25px;">
                        <div style="font-size: 42px; margin-bottom: 12px;">🕒</div>
                        <div style="font-size: 18px; font-weight: 600; margin-bottom: 10px;">Đang chờ xác nhận</div>
                        <div style="font-size: 13px; color: #555; line-height: 1.5; margin-bottom: 22px;">
                            <asp:Label ID="lblPendingMessage" runat="server"></asp:Label>
                        </div>
                        <a href="Trangchu.aspx" class="btn-check-avail" style="display: inline-flex; align-items: center; justify-content: center; text-decoration: none; width: 70%;">
                            Về trang chủ
                        </a>
                    </asp:Panel>
                </div>

            </div>
        </main>

        <!-- POPUP 1: Thông báo kiểm tra tình trạng phòng -->
        <div id="modalCheckStatus" runat="server" EnableViewState="false" class="modal-overlay">
            <div class="modal-box" style="text-align: center; padding: 40px 25px;">
                <div style="font-size: 18px; color: #222; margin-bottom: 35px; line-height: 1.5;">
                    <asp:Label ID="lblStatusResult" runat="server" EnableViewState="false"></asp:Label>
                </div>
                <button type="button" class="btn-book-red" style="width: 110px;" onclick="dongModal('<%= modalCheckStatus.ClientID %>')">OK</button>
            </div>
        </div>

        <!-- POPUP 2: Chọn phương thức thanh toán -->
        <div id="modalPaymentMethod" class="modal-overlay">
            <div class="modal-box">
                <button type="button" class="modal-close-btn" onclick="dongModal('modalPaymentMethod')">X</button>
                <div style="font-size: 18px; font-weight: 500; margin-bottom: 18px;">Phương thức thanh toán</div>

                <asp:LinkButton ID="btnChonQR" runat="server" CssClass="payment-option-row" OnClick="btnChonQR_Click" style="text-decoration: none;">
                    <span>📱 Thanh toán bằng mã qr</span>
                    <span>○</span>
                </asp:LinkButton>

                <asp:LinkButton ID="btnChonDirect" runat="server" CssClass="payment-option-row" OnClick="btnChonDirect_Click" style="text-decoration: none; border-top: 1px solid #eee;">
                    <span>💵 Nhận phòng thanh toán trực tiếp</span>
                    <span>○</span>
                </asp:LinkButton>
            </div>
        </div>

        <asp:HiddenField ID="hfUnitPrice" runat="server" Value="0" />
        <asp:HiddenField ID="hfCalculatedTotal" runat="server" Value="0" />

        <!-- FOOTER -->
        <footer>
            <a href="Trangchu.aspx" class="logo-box">
                <svg width="65" height="32" viewBox="0 0 80 40" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M10 30L40 8L70 30" stroke="#D68C94" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M22 25L45 14L62 28" stroke="#D68C94" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M55 12V19" stroke="#D68C94" stroke-width="3.5" stroke-linecap="round"/>
                </svg>
                <span>Hanoi</span>
                <span>Stay Nest</span>
            </a>
            <div class="footer-center">
                <div class="footer-links">
                    <a href="#">Giới thiệu</a><span>|</span><a href="#">Điều khoản</a><span>|</span><a href="#">Liên hệ</a><span>|</span><a href="#">Chính sách</a>
                </div>
                <div class="copyright">copyright@HanoiStayNest.com</div>
            </div>
        </footer>

        <script>
            var isLoggedIn = <%= Session["UserID"] != null ? "true" : "false" %>;

            function toggleAccountMenu(event) {
                event.stopPropagation();
                var menu = document.getElementById("accountPopover");
                if (menu) menu.classList.toggle("show");
            }

            document.addEventListener("click", function (e) {
                var menu = document.getElementById("accountPopover");
                var wrapper = document.querySelector(".avatar-menu-wrapper");
                if (menu && wrapper && !wrapper.contains(e.target)) {
                    menu.classList.remove("show");
                }
            });

            function getTodayString() {
                var today = new Date();
                var yyyy = today.getFullYear();
                var mm = String(today.getMonth() + 1).padStart(2, '0');
                var dd = String(today.getDate()).padStart(2, '0');
                return yyyy + '-' + mm + '-' + dd;
            }

            function thietLapGioiHanNgay() {
                var todayStr = getTodayString();
                var chkIn = document.getElementById('<%= txtCheckIn.ClientID %>');
                var chkOut = document.getElementById('<%= txtCheckOut.ClientID %>');

                chkIn.setAttribute('min', todayStr);
                chkOut.setAttribute('min', todayStr);

                if (chkIn.value) {
                    var nextDay = new Date(chkIn.value);
                    nextDay.setDate(nextDay.getDate() + 1);
                    var minOutStr = nextDay.toISOString().split('T')[0];
                    chkOut.setAttribute('min', minOutStr);

                    if (chkOut.value && chkOut.value <= chkIn.value) {
                        chkOut.value = minOutStr;
                    }
                }
            }

            function tinhTienPhong() {
                thietLapGioiHanNgay();

                var price = parseFloat(document.getElementById('<%= hfUnitPrice.ClientID %>').value) || 0;
                var d1 = document.getElementById('<%= txtCheckIn.ClientID %>').value;
                var d2 = document.getElementById('<%= txtCheckOut.ClientID %>').value;

                var nights = 0;
                if (d1 && d2) {
                    var date1 = new Date(d1);
                    var date2 = new Date(d2);
                    var diff = (date2 - date1) / (1000 * 60 * 60 * 24);
                    if (diff > 0) nights = diff;
                }

                var total = price * nights;
                document.getElementById('<%= hfCalculatedTotal.ClientID %>').value = total;
                document.getElementById('lblCalcFormula').innerText = price.toLocaleString('vi-VN') + ' đ x ' + nights + ' đêm';
                document.getElementById('lblSubTotal').innerText = total.toLocaleString('vi-VN') + ' đ';
                document.getElementById('lblGrandTotal').innerText = total.toLocaleString('vi-VN') + ' đ';
            }

            function moPopupThanhToan() {
                // Nếu chưa đăng nhập -> đẩy thẳng sang trang Đăng nhập (Profile.aspx)
                if (!isLoggedIn) {
                    window.location.href = 'Profile.aspx';
                    return;
                }

                var todayStr = getTodayString();
                var d1 = document.getElementById('<%= txtCheckIn.ClientID %>').value;
                var d2 = document.getElementById('<%= txtCheckOut.ClientID %>').value;

                if (!d1 || !d2) {
                    alert('Vui lòng chọn đầy đủ ngày Nhận phòng và Trả phòng!');
                    return;
                }
                if (d1 < todayStr || d2 < todayStr) {
                    alert('Không thể đặt phòng cho ngày đã qua! Vui lòng chọn từ ngày hiện tại trở đi.');
                    return;
                }
                if (d2 <= d1) {
                    alert('Ngày Trả phòng phải sau ngày Nhận phòng ít nhất 1 đêm!');
                    return;
                }

                document.getElementById('modalPaymentMethod').classList.add('active');
            }

            function dongModal(id) {
                document.getElementById(id).classList.remove('active');
            }

            window.onload = function () {
                thietLapGioiHanNgay();
                tinhTienPhong();
            };
        </script>
    </form>
</body>
</html>