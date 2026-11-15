<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Account.aspx.cs" Inherits="BTL_Web.Account" %>
<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Thông tin cá nhân | Hanoi Stay Nest</title>
    <link rel="stylesheet" href="stylesheet/style.css?v=6" />
</head>
<body>
    <form id="form1" runat="server" style="display: flex; flex-direction: column; min-height: 100vh;">

        <!-- ================= HEADER + AVATAR POPOVER MENU ================= -->
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
                <li><a href="Trangchu.aspx">Trang chủ</a></li>
                <li><a href="Favorites.aspx">Yêu Thích</a></li>
                <li><a href="Bookings.aspx">Hoạt động</a></li>
            </ul>

            <!-- CỤM AVATAR & POPOVER MENU TÀI KHOẢN -->
            <div class="avatar-menu-wrapper">
                <button type="button" class="header-avatar-btn" onclick="toggleAccountMenu(event)" title="Tài khoản" style="box-shadow: 0 0 0 3px #f8b8be;">
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

                        <a href="Account.aspx" class="popover-menu-row">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                <circle cx="12" cy="7" r="4"></circle>
                            </svg>
                            <span><strong>Thông tin cá nhân</strong></span>
                        </a>

                        <a href="Bookings.aspx" class="popover-menu-row">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                                <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                                <line x1="16" y1="2" x2="16" y2="6"></line>
                                <line x1="8" y1="2" x2="8" y2="6"></line>
                                <line x1="3" y1="10" x2="21" y2="10"></line>
                            </svg>
                            <span>Hoạt động đặt phòng</span>
                        </a>

                        <a href="Favorites.aspx" class="popover-menu-row">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"></path>
                            </svg>
                            <span>Danh sách yêu thích</span>
                        </a>

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

                        <a href="#" class="popover-menu-row">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                                <circle cx="12" cy="12" r="10"></circle>
                                <circle cx="12" cy="12" r="4"></circle>
                                <line x1="4.93" y1="4.93" x2="9.17" y2="9.17"></line>
                                <line x1="14.83" y1="14.83" x2="19.07" y2="19.07"></line>
                                <line x1="14.83" y1="9.17" x2="19.07" y2="4.93"></line>
                                <line x1="4.93" y1="19.07" x2="9.17" y2="14.83"></line>
                            </svg>
                            <span style="flex: 1;">Trợ giúp</span>
                            <span class="popover-chevron">›</span>
                        </a>

                        <a href="Logout.aspx" class="popover-menu-row" onclick="return confirm('Bạn có chắc chắn muốn đăng xuất?');">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                                <polyline points="16 17 21 12 16 7"></polyline>
                                <line x1="21" y1="12" x2="9" y2="12"></line>
                            </svg>
                            <span>Đăng xuất</span>
                        </a>
                    <% } else { %>
                        <a href="Profile.aspx" class="popover-menu-row">
                            <span>🔑 <strong>Đăng nhập / Đăng ký</strong></span>
                        </a>
                    <% } %>
                </div>
            </div>
        </header>

        <!-- ================= MAIN CONTENT: THÔNG TIN CÁ NHÂN ================= -->
        <main class="profile-main" style="flex: 1; display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 45px 20px 65px 20px;">
            
            <div style="width: 130px; height: 130px; margin-bottom: 16px;">
                <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
                    <circle cx="50" cy="50" r="50" fill="#F8B8BE"/>
                    <circle cx="50" cy="38" r="17" fill="#FFFFFF"/>
                    <path d="M20 88C20 68 33 58 50 58C67 58 80 68 80 88" fill="#FFFFFF"/>
                </svg>
            </div>

            <div style="font-size: 16px; color: #777777; margin-bottom: 24px;">
                <asp:Label ID="lblEmail" runat="server" Text="user@gmail.com"></asp:Label>
            </div>

            <div style="text-align: center; margin-bottom: 14px; min-height: 22px;">
                <asp:Label ID="lblThongBao" runat="server" Font-Bold="true" Font-Size="14px"></asp:Label>
            </div>

            <div style="display: flex; flex-direction: column; gap: 18px; width: 100%; max-width: 480px;">
                <div style="display: flex; align-items: center; gap: 15px;">
                    <label for="txtFullName" style="font-size: 19px; width: 95px; color: #111;">Họ tên :</label>
                    <asp:TextBox ID="txtFullName" runat="server" placeholder="Nhập họ và tên..." CssClass="login-input" style="flex: 1;"></asp:TextBox>
                </div>

                <div style="display: flex; align-items: center; gap: 15px;">
                    <label for="txtPhone" style="font-size: 19px; width: 95px; color: #111;">SĐT :</label>
                    <asp:TextBox ID="txtPhone" runat="server" placeholder="Nhập số điện thoại..." CssClass="login-input" style="flex: 1;"></asp:TextBox>
                </div>

                <div style="display: flex; align-items: center; gap: 15px;">
                    <label for="txtCreatedAt" style="font-size: 19px; width: 95px; color: #111;">Tham gia :</label>
                    <asp:TextBox ID="txtCreatedAt" runat="server" ReadOnly="true" CssClass="login-input" style="flex: 1; background-color: #f7f7f7; color: #777777; cursor: default;"></asp:TextBox>
                </div>

                <div style="display: flex; justify-content: center; align-items: center; gap: 16px; margin-top: 24px;">
                    <asp:Button ID="btnCapNhat" runat="server" Text="Lưu thay đổi" CssClass="btn-send-otp" 
                                style="width: 175px; height: 46px; font-size: 17px; border-radius: 23px; cursor: pointer;" 
                                OnClick="btnCapNhat_Click" />

                    <a href="Logout.aspx" onclick="return confirm('Bạn có chắc chắn muốn đăng xuất?');"
                       style="display: inline-flex; align-items: center; justify-content: center; width: 145px; height: 46px; border-radius: 23px; border: 1px solid #e5b5b5; background-color: #ffffff; color: #c80000; text-decoration: none; font-size: 17px; font-weight: 500; box-shadow: 0 3px 8px rgba(0,0,0,0.05);">
                        Đăng xuất
                    </a>
                </div>
            </div>

        </main>

        <!-- ================= FOOTER ================= -->
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
                    <a href="#">Giới thiệu</a>
                    <span>|</span>
                    <a href="#">Điều khoản</a>
                    <span>|</span>
                    <a href="#">Liên hệ</a>
                    <span>|</span>
                    <a href="#">Chính sách</a>
                </div>
                <div class="copyright">copyright@HanoiStayNest.com</div>
            </div>
        </footer>

        <script>
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
        </script>

    </form>
</body>
</html>