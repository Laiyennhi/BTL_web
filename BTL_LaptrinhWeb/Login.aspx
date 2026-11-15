<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="BTL_Web.Login" %>
<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xác thực OTP | Hanoi Stay Nest</title>
    <link rel="stylesheet" href="stylesheet/style.css?v=6" />
</head>
<body>
    <form id="form1" runat="server" style="display: flex; flex-direction: column; min-height: 100vh;">

        <!-- MAIN CONTENT -->
        <main class="login-main">
            <!-- Logo lớn ở trung tâm -->
            <a href="Trangchu.aspx" class="login-logo">
                <svg width="160" height="75" viewBox="0 0 80 40" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M10 30L40 8L70 30" stroke="#E5989B" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M22 25L45 14L62 28" stroke="#E5989B" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M55 12V19" stroke="#E5989B" stroke-width="3.2" stroke-linecap="round"/>
                </svg>
                <span>Hanoi</span>
                <span>Stay Nest</span>
            </a>

            <p class="login-subtitle">Nhập email của bạn, chúng tôi sẽ gửi mã xác nhận</p>

            <div class="login-form-container">
                <!-- Hàng 1: Gmail + Nút Gửi mã -->
                <div class="login-row">
                    <label for="txtGmail">Gmail:</label>
                    <asp:TextBox ID="txtGmail" runat="server" CssClass="login-input" TextMode="Email" placeholder="Nhập Gmail..."></asp:TextBox>
                    <asp:Button ID="btnGuiMa" runat="server" Text="Gửi mã" CssClass="btn-send-otp" OnClick="btnGuiMa_Click" />
                </div>

                <!-- Hàng 2: Số điện thoại -->
                <div class="login-row">
                    <label for="txtSDT">SĐT :</label>
                    <asp:TextBox ID="txtSDT" runat="server" CssClass="login-input" placeholder="Nhập số điện thoại..."></asp:TextBox>
                    <div class="otp-spacer"></div>
                </div>

                <!-- Hàng 3: Mã OTP -->
                <div class="login-row">
                    <label for="txtOtp">Otp :</label>
                    <asp:TextBox ID="txtOtp" runat="server" CssClass="login-input" MaxLength="6" placeholder="Nhập mã 6 số..."></asp:TextBox>
                    <div class="otp-spacer"></div>
                </div>

                <!-- Nút Đăng nhập / Xác nhận -->
                <div class="login-submit-wrapper">
                    <asp:Button ID="btnDangNhap" runat="server" Text="Đăng nhập" CssClass="btn-login-submit" OnClick="btnDangNhap_Click" />
                </div>

                <!-- Nhãn thông báo -->
                <div style="text-align: center; margin-top: 10px;">
                    <asp:Label ID="lblThongBao" runat="server" Font-Bold="true"></asp:Label>
                </div>
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

    </form>
</body>
</html>