<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Favorites.aspx.cs" Inherits="BTL_Web.Favorites" %>
<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Yêu thích | Hanoi Stay Nest</title>
    <link rel="stylesheet" href="stylesheet/style.css?v=6" />
</head>
<body>
    <form id="form1" runat="server" style="display: flex; flex-direction: column; min-height: 100vh;">

        <!-- HEADER ĐÃ ĐỒNG BỘ POPOVER MENU 3 VAI TRÒ -->
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
                <li><a href="Favorites.aspx" class="active">Yêu Thích</a></li>
                <li><a href="Bookings.aspx">Hoạt động</a></li>
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
        <main style="flex: 1; padding: 35px 0 60px 0;">
            
            <div style="max-width: 1050px; width: 100%; margin: 0 auto 30px auto; padding: 0 25px;">
                <h2 style="font-size: 24px; font-weight: 500; color: #111111;">
                    Các căn phòng bạn đã yêu thích
                </h2>
            </div>

            <!-- Thông báo khi chưa có phòng yêu thích nào -->
            <div style="max-width: 1050px; width: 100%; margin: 0 auto; padding: 0 25px;">
                <asp:Label ID="lblThongBao" runat="server" ForeColor="#888888" Font-Size="16px"></asp:Label>
            </div>

            <!-- Lưới các phòng đã yêu thích -->
            <div class="room-grid">
                <asp:Repeater ID="rptFavorites" runat="server" OnItemCommand="rptFavorites_ItemCommand">
                    <ItemTemplate>
                        <div class="room-card">
                            <div class="room-img-wrapper">
                                <a href='ChitietPhong.aspx?id=<%# Eval("RoomID") %>'>
                                    <img src='<%# Eval("ImageUrl") %>' alt='<%# Eval("Title") %>' 
                                         onerror="this.src='https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=600&q=80'" />
                                </a>

                                <!-- Nút trái tim đỏ đậm: Bấm vào để bỏ yêu thích -->
                                <asp:LinkButton ID="btnBoThich" runat="server" CssClass="btn-heart" 
                                    CommandName="RemoveFavorite" CommandArgument='<%# Eval("RoomID") %>' ToolTip="Bỏ yêu thích">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="#D91E18" stroke="#D91E18" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                        <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"></path>
                                    </svg>
                                </asp:LinkButton>
                            </div>

                            <a href='ChitietPhong.aspx?id=<%# Eval("RoomID") %>' class="room-info" style="text-decoration: none;">
                                <div class="room-title"><%# Eval("Title") %></div>
                                <div class="room-code" style="display: none;">HG0<%# Eval("RoomID") %></div>
                                <div class="room-price"><%# String.Format("{0:N0} đ/ đêm", Eval("PricePerNight")) %></div>
                            </a>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

        </main>

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

document.addEventListener("click", function(e) {
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