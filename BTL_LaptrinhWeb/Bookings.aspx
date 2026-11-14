<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Bookings.aspx.cs" Inherits="BTL_Web.Bookings" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hoạt động | Hanoi Stay Nest</title>
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
                <li><a href="Bookings.aspx" class="active">Hoạt động</a></li>
            </ul>

            <a href="Profile.aspx" class="header-avatar" title="Hồ sơ cá nhân">
                <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
                    <circle cx="50" cy="50" r="50" fill="#F8B8BE"/>
                    <circle cx="50" cy="38" r="17" fill="#FFFFFF"/>
                    <path d="M20 88C20 68 33 58 50 58C67 58 80 68 80 88" fill="#FFFFFF"/>
                </svg>
            </a>
        </header>

        <!-- MAIN CONTENT -->
        <main class="bookings-container" style="flex: 1;">
            <h2 class="bookings-heading">Hoạt động của tôi</h2>

            <!-- 6 Tab lọc trạng thái -->
            <div class="booking-tabs">
                <asp:LinkButton ID="tabAll" runat="server" CssClass="tab-pill active" CommandArgument="ALL" OnClick="FilterTab_Click">Tất cả</asp:LinkButton>
                <asp:LinkButton ID="tabPendingConfirm" runat="server" CssClass="tab-pill" CommandArgument="PendingConfirm" OnClick="FilterTab_Click">Chờ xác nhận</asp:LinkButton>
                <asp:LinkButton ID="tabPendingPayment" runat="server" CssClass="tab-pill" CommandArgument="PendingPayment" OnClick="FilterTab_Click">Chờ thanh toán</asp:LinkButton>
                <asp:LinkButton ID="tabUpcoming" runat="server" CssClass="tab-pill" CommandArgument="Confirmed" OnClick="FilterTab_Click">Sắp tới</asp:LinkButton>
                <asp:LinkButton ID="tabCompleted" runat="server" CssClass="tab-pill" CommandArgument="Completed" OnClick="FilterTab_Click">Hoàn tất</asp:LinkButton>
                <asp:LinkButton ID="tabCancelled" runat="server" CssClass="tab-pill" CommandArgument="Cancelled" OnClick="FilterTab_Click">Đã hủy</asp:LinkButton>
            </div>

            <!-- Thông báo khi danh sách trống -->
            <div style="margin-bottom: 15px;">
                <asp:Label ID="lblThongBao" runat="server" ForeColor="#888888" Font-Size="16px"></asp:Label>
            </div>

            <!-- Danh sách thẻ đơn đặt phòng -->
            <asp:Repeater ID="rptBookings" runat="server" OnItemCommand="rptBookings_ItemCommand">
                <ItemTemplate>
                    <div class="booking-card-wrapper">
                        <div class="booking-item-card">
                            
                            <div class="booking-item-left">
                                <a href='ChitietPhong.aspx?id=<%# Eval("RoomID") %>'>
                                    <img src='<%# Eval("ImageUrl") %>' alt='<%# Eval("Title") %>' class="booking-thumb"
                                         onerror="this.src='https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=400&q=80'" />
                                </a>

                                <div>
                                    <div class="booking-meta-title">
                                        <%# Eval("Title") %> - #HG0<%# Eval("RoomID") %>
                                    </div>
                                    <div class="booking-meta-sub">
                                        <div><%# Eval("Address") %></div>
                                        <div>
                                            <%# Convert.ToDateTime(Eval("CheckInDate")).ToString("dd/MM") %> - 
                                            <%# Convert.ToDateTime(Eval("CheckOutDate")).ToString("dd/MM") %>  
                                            <%# Eval("SoDem") %> đêm
                                        </div>
                                        <div><%# Eval("PaymentLabel") %></div>
                                    </div>

                                    <div class="booking-meta-bottom">
                                        <span class="booking-meta-price"><%# String.Format("{0:N0} đ", Eval("TotalPrice")) %></span>
                                        <span class='status-badge <%# Eval("BadgeClass") %>'><%# Eval("StatusLabel") %></span>
                                    </div>
                                </div>
                            </div>

                            <!-- Cụm nút hành động bên phải -->
                            <div class="booking-actions-col">
                                <asp:LinkButton ID="btnThanhToan" runat="server" CssClass="btn-action-red"
                                    Visible='<%# Convert.ToBoolean(Eval("ShowPayBtn")) %>'
                                    CommandName="OpenQR" CommandArgument='<%# Eval("BookingID") %>'>
                                    Thanh toán
                                </asp:LinkButton>

                                <asp:LinkButton ID="btnHuyDon" runat="server" CssClass="btn-action-outline"
                                    Visible='<%# Convert.ToBoolean(Eval("ShowCancelBtn")) %>'
                                    CommandName="CancelBooking" CommandArgument='<%# Eval("BookingID") %>'
                                    OnClientClick="return confirm('Bạn có chắc chắn muốn hủy đơn đặt phòng này không?');">
                                    Hủy đơn
                                </asp:LinkButton>

                                <a href='ChitietPhong.aspx?id=<%# Eval("RoomID") %>' class="btn-action-outline"
                                   style='<%# Convert.ToBoolean(Eval("ShowRebookBtn")) ? "" : "display:none;" %>'>
                                    Đặt lại phòng
                                </a>
                            </div>

                        </div>

                        <!-- KHUNG 1: POPOVER QUÉT MÃ QR NỔI GÓC PHẢI ĐƠN HÀNG -->
                        <asp:Panel ID="pnlInlineQR" runat="server" CssClass="inline-qr-popover"
                                   Visible='<%# Convert.ToBoolean(Eval("