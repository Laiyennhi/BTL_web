<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="BTL_Web.Profile" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập | Hanoi Stay Nest</title>
    <link rel="stylesheet" href="stylesheet/style.css" />
</head>
<body>
    <form id="form1" runat="server" style="display: flex; flex-direction: column; min-height: 100vh;">

        <!-- HEADER -->
        <header>
            <a href="TrangChu.aspx" class="logo-box">
                <svg width="65" height="32" viewBox="0 0 80 40" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M10 30L40 8L70 30" stroke="#D68C94" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M22 25L45 14L62 28" stroke="#D68C94" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M55 12V19" stroke="#D68C94" stroke-width="3.5" stroke-linecap="round"/>
                </svg>
                <span>Hanoi</span>
                <span>Stay Nest</span>
            </a>

            <ul class="nav-menu">
                <li><a href="TrangChu.aspx">Trang chủ</a></li>
                <li><a href="Favorites.aspx">Yêu Thích</a></li>
                <li><a href="Bookings.aspx">Hoạt động</a></li>
            </ul>

            <a href="Profile.aspx" class="header-avatar" title="Tài khoản">
                <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
                    <circle cx="50" cy="50" r="50" fill="#F8B8BE"/>
                    <circle cx="50" cy="38" r="17" fill="#FFFFFF"/>
                    <path d="M20 88C20 68 33 58 50 58C67 58 80 68 80 88" fill="#FFFFFF"/>
                </svg>
            </a>
        </header>

        <!-- MAIN CONTENT -->
        <main class="profile-main" style="flex: 1; display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 40px 20px;">
            
            <!-- Avatar lớn trung tâm -->
            <div style="width: 140px; height: 140px; margin-bottom: 28px;">
                <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
                    <circle cx="50" cy="50" r="50" fill="#F8B8BE"/>
                    <circle cx="50" cy="38" r="17" fill="#FFFFFF"/>
                    <path d="M20 88C20 68 33 58 50 58C67 58 80 68 80 88" fill="#FFFFFF"/>
                </svg>
            </div>

            <!-- Form nhập Gmail và Số điện thoại -->
            <div style="display: flex; flex-direction: column; gap: 18px; width: 100%; max-width: 480px;">
                <div style="display: flex; align-items: center; gap: 15px;">
                    <label for="txtGmail" style="font-size: 20px; width: 75px; color: #111;">Gmail :</label>
                    <asp:TextBox ID="txtGmail" runat="server" TextMode="Email" placeholder="Nhập địa chỉ Gmail..." CssClass="login-input" style="flex: 1;"></asp:TextBox>
                </div>

                <div style="display: flex; align-items: center; gap: 15px;">
                    <label for="txtSDT" style="font-size: 20px; width: 75px; color: #111;">SDT :</label>
                    <asp:TextBox ID="txtSDT" runat="server" placeholder="Nhập số điện thoại..." CssClass="login-input" style="flex: 1;"></asp:TextBox>
                </div>

                <!-- Nút Đăng nhập -->
                <div style="display: flex; justify-content: center; margin-top: 22px;">
                    <asp:Button ID="btnDangNhap" runat="server" Text="Đăng nhập" CssClass="btn-send-otp" 
                                style="width: 190px; height: 48px; font-size: 19px; border-radius: 24px;" 
                                OnClick="btnDangNhap_Click" />
                </div>

                <!-- Thông báo lỗi nếu bỏ trống -->
                <div style="text-align: center; margin-top: 8px;">
                    <asp:Label ID="lblThongBao" runat="server" ForeColor="Red" Font-Bold="true"></asp:Label>
                </div>
            </div>

        </main>

        <!-- FOOTER -->
        <footer>
            <a href="TrangChu.aspx" class="logo-box">
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

    </form>
</body>
</html>