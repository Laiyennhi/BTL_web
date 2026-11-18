<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="HostDashboard.aspx.cs" Inherits="BTL_Web.HostDashboard" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Kênh Chủ Phòng | Hanoi Stay Nest</title>
    <link rel="stylesheet" href="stylesheet/host.css?v=2" />
    <style>
        .host-avatar-wrapper { position: relative; display: inline-block; }
        .host-avatar-btn { width: 44px; height: 44px; border: none; background: none; padding: 0; cursor: pointer; display: block; }
        .host-popover-menu {
            display: none; position: absolute; right: 0; top: 54px; width: 260px;
            background: #fff; border-radius: 16px; box-shadow: 0 10px 30px rgba(0,0,0,0.14);
            border: 1px solid #f0e4e6; z-index: 9999; padding: 10px 0;
        }
        .host-popover-menu.show { display: block; }
        .host-popover-header {
            display: flex; align-items: center; gap: 12px; padding: 10px 16px; text-decoration: none;
        }
        .host-mini-avatar {
            width: 38px; height: 38px; border-radius: 50%; background: #f8b8be; color: #fff;
            font-weight: 700; display: flex; align-items: center; justify-content: center; font-size: 16px;
        }
        .host-popover-divider { height: 1px; background: #f2f2f2; margin: 6px 0; }
        .host-popover-row {
            display: flex; align-items: center; padding: 10px 16px; font-size: 14px;
            color: #333; text-decoration: none; transition: background 0.15s;
        }
        .host-popover-row:hover { background: #fff5f6; }
    </style>
</head>
<body>
    <form id="form1" runat="server" style="display: flex; flex-direction: column; min-height: 100vh;">

        <!-- HEADER CHỦ PHÒNG -->
        <header class="host-header">
            <a href="HostDashboard.aspx?tab=bookings" class="host-logo">
                <svg width="62" height="30" viewBox="0 0 80 40" fill="none">
                    <path d="M10 30L40 8L70 30" stroke="#D68C94" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round" />
                    <path d="M22 25L45 14L62 28" stroke="#D68C94" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" />
                    <path d="M55 12V19" stroke="#D68C94" stroke-width="3.5" stroke-linecap="round" />
                </svg>
                <span>Hanoi</span>
                <span>Stay Nest</span>
            </a>

            <ul class="host-nav">
                <li><a href="HostDashboard.aspx?tab=bookings" class='<%= CurrentTab == "bookings" ? "active" : "" %>'>Đơn đặt phòng</a></li>
                <li><a href="HostDashboard.aspx?tab=rooms" class='<%= CurrentTab == "rooms" || CurrentTab == "addroom" || CurrentTab == "editroom" ? "active" : "" %>'>Phòng của tôi</a></li>
            </ul>

            <!-- CỤM AVATAR & POPOVER MENU CHỦ PHÒNG -->
            <div class="host-avatar-wrapper">
                <button type="button" class="host-avatar-btn" onclick="toggleHostMenu(event)" title="Tài khoản chủ phòng">
                    <svg viewBox="0 0 100 100">
                        <circle cx="50" cy="50" r="50" fill="#F8B8BE" />
                        <circle cx="50" cy="38" r="17" fill="#FFFFFF" />
                        <path d="M20 88C20 68 33 58 50 58C67 58 80 68 80 88" fill="#FFFFFF" />
                    </svg>
                </button>

                <div id="hostAccountPopover" class="host-popover-menu">
                    <a href="HostDashboard.aspx?tab=account" class="host-popover-header">
                        <div class="host-mini-avatar">
                            <%= (Session["FullName"] != null && Session["FullName"].ToString().Length > 0)
                                ? Session["FullName"].ToString().Substring(0, 1).ToUpper() : "H" %>
                        </div>
                        <div>
                            <div style="font-weight: 600; font-size: 14.5px; color: #222;"><%= Session["FullName"] ?? "Chủ phòng" %></div>
                            <div style="font-size: 12px; color: #777;">Chế độ Chủ phòng (Host)</div>
                        </div>
                    </a>

                    <div class="host-popover-divider"></div>

                    <a href="HostDashboard.aspx?tab=account" class="host-popover-row">
                        <span>👤 Hồ sơ Chủ phòng</span>
                    </a>
                    <a href="HostDashboard.aspx?tab=bookings" class="host-popover-row">
                        <span>📋 Quản lý đơn đặt phòng</span>
                    </a>
                    <a href="HostDashboard.aspx?tab=rooms" class="host-popover-row">
                        <span>🏠 Quản lý phòng của tôi</span>
                    </a>

                    <div class="host-popover-divider"></div>

                    <!-- NÚT CHUYỂN SANG GIAO DIỆN GUEST -->
                    <a href="TrangChu.aspx" class="host-popover-row" style="color: #d66b76; font-weight: 600;">
                        <span>🔄 Chuyển sang chế độ Guest</span>
                    </a>

                    <div class="host-popover-divider"></div>

                    <a href="Logout.aspx" class="host-popover-row" onclick="return confirm('Bạn có chắc chắn muốn đăng xuất?');">
                        <span>🚪 Đăng xuất</span>
                    </a>
                </div>
            </div>
        </header>

        <main class="host-main">
            <asp:Label ID="lblThongBao" runat="server" Font-Bold="true" ForeColor="#1e7e34" Style="display: block; margin-bottom: 14px;"></asp:Label>

            <!-- ==================== TAB 1: ĐƠN ĐẶT PHÒNG ==================== -->
            <asp:Panel ID="pnlBookings" runat="server">
                <h1 class="page-title" style="margin-bottom: 22px;">Đơn đặt phòng</h1>

                <!-- 3 Ô THỐNG KÊ -->
                <div class="stats-grid-3">
                    <div class="stat-card-box">
                        <div class="stat-card-top"><span>Số đơn</span></div>
                        <div class="stat-card-num">
                            <asp:Label ID="lblTotalOrders" runat="server" Text="0"></asp:Label></div>
                    </div>
                    <div class="stat-card-box">
                        <div class="stat-card-top"><span>Số đơn cần được xử lý</span></div>
                        <div class="stat-card-num">
                            <asp:Label ID="lblPendingOrders" runat="server" Text="0"></asp:Label></div>
                    </div>
                    <div class="stat-card-box">
                        <div class="stat-card-top"><span>Tổng doanh thu</span><span>›</span></div>
                        <div class="stat-card-num">
                            <asp:Label ID="lblTotalRevenue" runat="server" Text="0 đ"></asp:Label></div>
                    </div>
                </div>

                <!-- BỘ LỌC TRẠNG THÁI ĐƠN -->
                <div class="filter-bar">
                    <a href="HostDashboard.aspx?tab=bookings&filter=all" class='filter-pill <%= CurrentFilter == "all" ? "active" : "" %>'>Tất cả</a>
                    <a href="HostDashboard.aspx?tab=bookings&filter=Pending" class='filter-pill <%= CurrentFilter == "Pending" ? "active" : "" %>'>Chờ xác nhận</a>
                    <a href="HostDashboard.aspx?tab=bookings&filter=Unpaid" class='filter-pill <%= CurrentFilter == "Unpaid" ? "active" : "" %>'>Chờ thanh toán</a>
                    <a href="HostDashboard.aspx?tab=bookings&filter=Confirmed" class='filter-pill <%= CurrentFilter == "Confirmed" ? "active" : "" %>'>Đã xác nhận</a>
                    <a href="HostDashboard.aspx?tab=bookings&filter=Completed" class='filter-pill <%= CurrentFilter == "Completed" ? "active" : "" %>'>Hoàn tất</a>
                    <a href="HostDashboard.aspx?tab=bookings&filter=Cancelled" class='filter-pill <%= CurrentFilter == "Cancelled" ? "active" : "" %>'>Đã hủy</a>
                </div>

                <div class="table-card">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Mã đơn</th>
                                <th>Khách</th>
                                <th>Phòng</th>
                                <th>Ngày ở</th>
                                <th>Thanh toán</th>
                                <th>Tổng tiền</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptHostBookings" runat="server" OnItemCommand="rptHostBookings_ItemCommand">
                                <ItemTemplate>
                                    <tr>
                                        <td><%# Eval("BookingID") %></td>
                                        <td><%# Eval("GuestName") %></td>
                                        <td>HG0<%# Eval("RoomID") %></td>
                                        <td><%# Convert.ToDateTime(Eval("CheckInDate")).ToString("dd/MM") %> - <%# Convert.ToDateTime(Eval("CheckOutDate")).ToString("dd/MM") %></td>
                                        <td><%# Eval("PaymentMethod") %></td>
                                        <td><%# String.Format("{0:N0} đ", Eval("TotalPrice")) %></td>
                                        <td>
                                            <span class='badge <%# GetBookingBadge(Eval("Status").ToString()) %>'>
                                                <%# FormatBookingStatus(Eval("Status").ToString()) %>
                                            </span>
                                        </td>
                                        <td>
                                            <!-- Chờ thanh toán (QR) -> Xác nhận / Từ chối -->
                                            <asp:LinkButton runat="server" CssClass="btn-red-sm" CommandName="ConfirmOrder" CommandArgument='<%# Eval("BookingID") %>'
                                                Visible='<%# Eval("Status").ToString() == "Unpaid" %>'>Xác nhận</asp:LinkButton>

                                            <!-- Chờ xác nhận (Trực tiếp) -> Đã nhận tiền / Từ chối -->
                                            <asp:LinkButton runat="server" CssClass="btn-red-sm" CommandName="ConfirmOrder" CommandArgument='<%# Eval("BookingID") %>'
                                                Visible='<%# Eval("Status").ToString() == "Pending" %>'>Đã nhận tiền</asp:LinkButton>

                                            <!-- Nút Từ chối cho đơn chưa duyệt -->
                                            <asp:LinkButton runat="server" CssClass="btn-outline-sm" CommandName="RejectOrder" CommandArgument='<%# Eval("BookingID") %>'
                                                Visible='<%# Eval("Status").ToString() == "Unpaid" || Eval("Status").ToString() == "Pending" %>'
                                                OnClientClick="return confirm('Từ chối đơn đặt phòng này?');">Từ chối</asp:LinkButton>

                                            <!-- Đã xác nhận -> Đã thu tiền (Hoàn tất) -->
                                            <asp:LinkButton runat="server" CssClass="btn-red-sm" CommandName="CompleteOrder" CommandArgument='<%# Eval("BookingID") %>'
                                                Visible='<%# Eval("Status").ToString() == "Confirmed" %>'>Đã thu tiền</asp:LinkButton>

                                            <!-- Hoàn tất / Đã hủy -->
                                            <span style="font-size: 12px; color: #888;" runat="server" visible='<%# Eval("Status").ToString() == "Completed" %>'>Không có thao tác</span>
                                            <span style="font-size: 12px; color: #888;" runat="server" visible='<%# Eval("Status").ToString() == "Cancelled" %>'>(30 ngày tự xóa đơn)</span>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
            </asp:Panel>

            <!-- ==================== TAB 2: PHÒNG CỦA TÔI ==================== -->
            <asp:Panel ID="pnlMyRooms" runat="server" Visible="false">
                <div class="page-header-row">
                    <h1 class="page-title">Phòng của tôi</h1>
                    <a href="HostDashboard.aspx?tab=addroom" class="btn-red-pill">+ Thêm phòng</a>
                </div>

                <asp:Repeater ID="rptMyRooms" runat="server">
                    <ItemTemplate>
                        <div class="room-item-card">
                            <div class="room-item-left">
                                <img class="room-thumb" src='<%# Eval("ImageUrl") %>' onerror="this.style.background='#f8b8be';" />
                                <div>
                                    <div class="room-info-title">
                                        <span><%# Eval("Title") %></span>
                                        <span class='badge <%# GetRoomBadge(Eval("ApprovalStatus").ToString()) %>'>
                                            <%# Eval("ApprovalStatus").ToString() == "Đang hoạt động" ? "Đang hiển thị" : Eval("ApprovalStatus") %>
                                        </span>
                                    </div>
                                    <div class="room-info-sub"><%# Eval("Address") %></div>
                                    <div class="room-info-price"><%# String.Format("{0:N0} đ / đêm", Eval("PricePerNight")) %></div>
                                </div>
                            </div>

                            <div class="room-item-actions">
                                <%# Eval("ApprovalStatus").ToString() == "Đã tắt"
                                    ? "<button type='button' class='act-box' onclick=\"openConfirmModal('EnableRoom', '" + Eval("RoomID") + "', 'Bạn có chắc chắn muốn bật phòng này', 'Bật', 'power')\">Bật</button>"
                                    : "<button type='button' class='act-box' onclick=\"openConfirmModal('DisableRoom', '" + Eval("RoomID") + "', 'Bạn có chắc chắn muốn tắt phòng này', 'Tắt', 'power')\">Tắt</button>" %>
                                <a href='HostDashboard.aspx?tab=editroom&id=<%# Eval("RoomID") %>' class="act-box">Sửa</a>
                                <button type="button" class="act-box del" onclick="openConfirmModal('DeleteRoom', '<%# Eval("RoomID") %>', 'Bạn có chắc chắn muốn xóa phòng này', 'Xóa', 'trash')">Xóa</button>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </asp:Panel>

            <!-- ==================== TAB 3: THÊM PHÒNG MỚI / SỬA PHÒNG ==================== -->
            <asp:Panel ID="pnlRoomForm" runat="server" Visible="false">
                <h1 class="page-title" style="margin-bottom: 24px;">
                    <asp:Label ID="lblFormHeading" runat="server" Text="Thêm phòng mới"></asp:Label></h1>

                <label class="form-label">Tên phòng</label>
                <asp:TextBox ID="txtRoomTitle" runat="server" CssClass="form-control" placeholder="Ví dụ : Phòng tại Hồ Gươm"></asp:TextBox>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
                    <div>
                        <label class="form-label">Khu vực</label>
                        <asp:DropDownList ID="ddlDistrict" runat="server" CssClass="form-control">
                            <asp:ListItem Value="Hồ Gươm">Hồ Gươm, Hà Nội</asp:ListItem>
                            <asp:ListItem Value="Hoàn Kiếm">Hoàn Kiếm, Hà Nội</asp:ListItem>
                            <asp:ListItem Value="Ba Đình">Ba Đình, Hà Nội</asp:ListItem>
                            <asp:ListItem Value="Tây Hồ">Tây Hồ, Hà Nội</asp:ListItem>
                            <asp:ListItem Value="Đống Đa">Đống Đa, Hà Nội</asp:ListItem>
                            <asp:ListItem Value="Cầu Giấy">Cầu Giấy, Hà Nội</asp:ListItem>
                            <asp:ListItem Value="Hai Bà Trưng">Hai Bà Trưng, Hà Nội</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div>
                        <label class="form-label">Giá mỗi phòng / đêm (VNĐ)</label>
                        <asp:TextBox ID="txtRoomPrice" runat="server" CssClass="form-control"
                            placeholder="Nhập giá phòng/đêm (VD: 850.000)..."
                            inputmode="numeric"
                            autocomplete="off"
                            oninput="formatCurrencyInput(this)"></asp:TextBox>
                    </div>
                </div>

                <label class="form-label">Địa chỉ chi tiết</label>
                <asp:TextBox ID="txtRoomAddress" runat="server" CssClass="form-control" placeholder="Số nhà , Số đường"></asp:TextBox>

                <label class="form-label">Mô tả</label>
                <asp:TextBox ID="txtRoomDesc" runat="server" TextMode="MultiLine" CssClass="form-textarea" placeholder="Giới thiệu không gian , mô tả địa chỉ , quy định của chủ nhà"></asp:TextBox>

                <label class="form-label">Tiện nghi</label>
                <div class="amenities-grid">
                    <label>
                        <asp:CheckBox ID="chkDieuHoa" runat="server" Checked="true" />
                        Điều hòa</label>
                    <label>
                        <asp:CheckBox ID="chkTivi" runat="server" Checked="true" />
                        Tivi</label>
                    <label>
                        <asp:CheckBox ID="chkChoDeXe" runat="server" />
                        Chỗ để xe</label>
                    <label>
                        <asp:CheckBox ID="chkMayGiat" runat="server" Checked="true" />
                        Máy giặt</label>
                    <label>
                        <asp:CheckBox ID="chkWifi" runat="server" Checked="true" />
                        Wifi</label>
                    <label>
                        <asp:CheckBox ID="chkBanCong" runat="server" />
                        Ban công</label>
                </div>

                <label class="form-label">Ảnh phòng (1 Ảnh bìa & 4 Ảnh chi tiết tách riêng)</label>

                <!-- KHUNG ẢNH BÌA -->
                <div style="background: #fff9fa; border: 1.5px solid #f3b5bd; border-radius: 12px; padding: 14px; margin-bottom: 14px;">
                    <div style="font-size: 14px; font-weight: 600; color: #d66b76; margin-bottom: 8px;">★ Ảnh bìa (Hiển thị chính ở Trang chủ)</div>
                    <div style="display: grid; grid-template-columns: 1fr 1fr 75px; gap: 10px; align-items: center;">
                        <asp:FileUpload ID="fuCoverImg" runat="server" CssClass="form-control" accept="image/*" style="margin: 0; padding: 7px;" onchange="previewFile(this, 'prevCover')" />
                        <asp:TextBox ID="txtCoverImg" runat="server" CssClass="form-control" placeholder="Hoặc dán link ảnh bìa (https://...)" style="margin: 0;" oninput="previewUrl(this, 'prevCover')"></asp:TextBox>
                        <img id="prevCover" src="https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=200" style="width: 75px; height: 50px; object-fit: cover; border-radius: 8px; border: 1px solid #ddd; background: #f3f3f3;" />
                    </div>
                </div>

                <!-- 4 KHUNG ẢNH CHI TIẾT TÁCH RIÊNG (LƯỚI 2x2) -->
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 18px;">
                    <!-- Ô 1 -->
                    <div style="border: 1px solid #e5e5e5; border-radius: 10px; padding: 12px; background: #fafafa;">
                        <div style="font-size: 13px; font-weight: 600; margin-bottom: 6px;">Ảnh chi tiết 1</div>
                        <asp:FileUpload ID="fuSub1" runat="server" CssClass="form-control" accept="image/*" style="margin-bottom: 6px; padding: 6px;" onchange="previewFile(this, 'prevSub1')" />
                        <div style="display: flex; gap: 8px; align-items: center;">
                            <asp:TextBox ID="txtSub1" runat="server" CssClass="form-control" placeholder="Hoặc dán link ảnh 1..." style="margin: 0; flex: 1;" oninput="previewUrl(this, 'prevSub1')"></asp:TextBox>
                            <img id="prevSub1" style="width: 52px; height: 40px; object-fit: cover; border-radius: 6px; border: 1px solid #ddd; background: #eee;" />
                        </div>
                    </div>

                    <!-- Ô 2 -->
                    <div style="border: 1px solid #e5e5e5; border-radius: 10px; padding: 12px; background: #fafafa;">
                        <div style="font-size: 13px; font-weight: 600; margin-bottom: 6px;">Ảnh chi tiết 2</div>
                        <asp:FileUpload ID="fuSub2" runat="server" CssClass="form-control" accept="image/*" style="margin-bottom: 6px; padding: 6px;" onchange="previewFile(this, 'prevSub2')" />
                        <div style="display: flex; gap: 8px; align-items: center;">
                            <asp:TextBox ID="txtSub2" runat="server" CssClass="form-control" placeholder="Hoặc dán link ảnh 2..." style="margin: 0; flex: 1;" oninput="previewUrl(this, 'prevSub2')"></asp:TextBox>
                            <img id="prevSub2" style="width: 52px; height: 40px; object-fit: cover; border-radius: 6px; border: 1px solid #ddd; background: #eee;" />
                        </div>
                    </div>

                    <!-- Ô 3 -->
                    <div style="border: 1px solid #e5e5e5; border-radius: 10px; padding: 12px; background: #fafafa;">
                        <div style="font-size: 13px; font-weight: 600; margin-bottom: 6px;">Ảnh chi tiết 3</div>
                        <asp:FileUpload ID="fuSub3" runat="server" CssClass="form-control" accept="image/*" style="margin-bottom: 6px; padding: 6px;" onchange="previewFile(this, 'prevSub3')" />
                        <div style="display: flex; gap: 8px; align-items: center;">
                            <asp:TextBox ID="txtSub3" runat="server" CssClass="form-control" placeholder="Hoặc dán link ảnh 3..." style="margin: 0; flex: 1;" oninput="previewUrl(this, 'prevSub3')"></asp:TextBox>
                            <img id="prevSub3" style="width: 52px; height: 40px; object-fit: cover; border-radius: 6px; border: 1px solid #ddd; background: #eee;" />
                        </div>
                    </div>

                    <!-- Ô 4 -->
                    <div style="border: 1px solid #e5e5e5; border-radius: 10px; padding: 12px; background: #fafafa;">
                        <div style="font-size: 13px; font-weight: 600; margin-bottom: 6px;">Ảnh chi tiết 4</div>
                        <asp:FileUpload ID="fuSub4" runat="server" CssClass="form-control" accept="image/*" style="margin-bottom: 6px; padding: 6px;" onchange="previewFile(this, 'prevSub4')" />
                        <div style="display: flex; gap: 8px; align-items: center;">
                            <asp:TextBox ID="txtSub4" runat="server" CssClass="form-control" placeholder="Hoặc dán link ảnh 4..." style="margin: 0; flex: 1;" oninput="previewUrl(this, 'prevSub4')"></asp:TextBox>
                            <img id="prevSub4" style="width: 52px; height: 40px; object-fit: cover; border-radius: 6px; border: 1px solid #ddd; background: #eee;" />
                        </div>
                    </div>
                </div>

                <p style="font-size: 13px; color: #777; line-height: 1.6; margin-bottom: 22px;">
                    Bạn có thể chọn file từ máy tính hoặc dán đường dẫn ảnh online cho từng ô riêng biệt.<br />
                    Phòng mới sẽ ở trạng thái "Chờ duyệt" cho đến khi quản trị viên duyệt.
                </p>

                <div style="display: flex; gap: 14px;">
                    <asp:Button ID="btnSaveRoom" runat="server" Text="Lưu phòng" CssClass="btn-red-pill" OnClick="btnSaveRoom_Click" />
                    <a href="HostDashboard.aspx?tab=rooms" class="btn-white-pill">Hủy</a>
                </div>
            </asp:Panel>

            <!-- ==================== TAB 4: TÀI KHOẢN CỦA CHỦ PHÒNG ==================== -->
            <asp:Panel ID="pnlHostAccount" runat="server" Visible="false">
                <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 25px 0;">
                    <svg width="145" height="145" viewBox="0 0 100 100" style="margin-bottom: 20px;">
                        <circle cx="50" cy="50" r="50" fill="#F8B8BE" />
                        <circle cx="50" cy="38" r="17" fill="#FFFFFF" />
                        <path d="M20 88C20 68 33 58 50 58C67 58 80 68 80 88" fill="#FFFFFF" />
                    </svg>

                    <div style="font-size: 24px; font-weight: 500; margin-bottom: 8px;">
                        <asp:Label ID="lblHostEmail" runat="server"></asp:Label>
                    </div>

                    <a href="TrangChu.aspx" style="font-size: 15px; color: #444; text-decoration: none; margin-bottom: 26px;">
                        Chuyển về giao diện Khách thuê ⇔
                    </a>

                    <div style="width: 100%; max-width: 440px; display: flex; flex-direction: column; gap: 16px;">
                        <div style="display: flex; align-items: center; gap: 14px;">
                            <label style="width: 70px; font-size: 20px;">Tên :</label>
                            <asp:TextBox ID="txtHostName" runat="server" CssClass="form-control" Style="margin: 0; border-radius: 22px; box-shadow: 0 3px 10px rgba(0,0,0,0.06);"></asp:TextBox>
                        </div>
                        <div style="display: flex; align-items: center; gap: 14px;">
                            <label style="width: 70px; font-size: 20px;">SDT :</label>
                            <asp:TextBox ID="txtHostPhone" runat="server" CssClass="form-control" Style="margin: 0; border-radius: 22px; box-shadow: 0 3px 10px rgba(0,0,0,0.06);"></asp:TextBox>
                        </div>
                        <div style="display: flex; justify-content: center; gap: 14px; margin-top: 18px;">
                            <asp:Button ID="btnUpdateHostInfo" runat="server" Text="Lưu" CssClass="btn-white-pill" OnClick="btnUpdateHostInfo_Click" />
                            <a href="Logout.aspx" onclick="return confirm('Bạn có chắc chắn muốn đăng xuất?');"
                                style="display: inline-flex; align-items: center; justify-content: center; width: 175px; height: 44px; border-radius: 22px; background: #f8b8be; color: #fff; font-size: 18px; font-weight: 600; text-decoration: none; box-shadow: 0 4px 12px rgba(248,184,190,0.45);">Đăng xuất
                            </a>
                        </div>
                    </div>
                </div>
            </asp:Panel>

            <!-- ==================== MODAL XÁC NHẬN TẮT / BẬT / XÓA PHÒNG ==================== -->
            <asp:HiddenField ID="hfRoomAction" runat="server" />
            <asp:HiddenField ID="hfRoomTargetId" runat="server" />
            <div id="confirmModal" class="modal-overlay">
                <div class="confirm-modal-box">
                    <div id="confirmIcon" style="font-size: 34px; margin-bottom: 14px;">⏻</div>
                    <div id="confirmMsg" style="font-size: 15.5px; font-weight: 600; margin-bottom: 22px;">Bạn có chắc chắn?</div>
                    <div style="display: flex; justify-content: center; gap: 14px;">
                        <button type="button" class="btn-white-pill" onclick="closeConfirmModal()">Hủy</button>
                        <asp:Button ID="btnConfirmRoomAction" runat="server" Text="Xác nhận" CssClass="btn-red-pill" OnClick="btnConfirmRoomAction_Click" />
                    </div>
                </div>
            </div>

        </main>

        <!-- FOOTER -->
        <footer class="host-footer">
            <a href="HostDashboard.aspx?tab=bookings" class="host-logo">
                <svg width="62" height="30" viewBox="0 0 80 40" fill="none">
                    <path d="M10 30L40 8L70 30" stroke="#D68C94" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round" />
                    <path d="M22 25L45 14L62 28" stroke="#D68C94" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" />
                    <path d="M55 12V19" stroke="#D68C94" stroke-width="3.5" stroke-linecap="round" />
                </svg>
                <span>Hanoi</span>
                <span>Stay Nest</span>
            </a>
            <div style="text-align: center;">
                <div class="footer-links">
                    <a href="#">Giới thiệu</a>|<a href="#">Điều khoản</a>|<a href="#">Liên hệ</a>|<a href="#">Chính sách</a>
                </div>
                <div style="font-size: 13px; color: #888; margin-top: 6px;">copyright@HanoiStayNest.com</div>
            </div>
            <div style="width: 62px;"></div>
        </footer>

        <script>
            function toggleHostMenu(event) {
                event.stopPropagation();
                var menu = document.getElementById("hostAccountPopover");
                if (menu) menu.classList.toggle("show");
            }
            document.addEventListener("click", function (e) {
                var menu = document.getElementById("hostAccountPopover");
                var wrapper = document.querySelector(".host-avatar-wrapper");
                if (menu && wrapper && !wrapper.contains(e.target)) {
                    menu.classList.remove("show");
                }
            });
            function openConfirmModal(action, roomId, message, btnText, iconType) {
                document.getElementById('<%= hfRoomAction.ClientID %>').value = action;
                document.getElementById('<%= hfRoomTargetId.ClientID %>').value = roomId;
                document.getElementById('confirmMsg').innerText = message;
                document.getElementById('<%= btnConfirmRoomAction.ClientID %>').value = btnText;
                document.getElementById('confirmIcon').innerText = iconType === 'trash' ? '🗑️' : '⏻';
                document.getElementById('confirmModal').classList.add('show');
            }
            function closeConfirmModal() {
                document.getElementById('confirmModal').classList.remove('show');
            }
            function formatCurrencyInput(input) {
                let rawValue = input.value.replace(/\D/g, '');
                if (rawValue === '') {
                    input.value = '';
                    return;
                }
                input.value = Number(rawValue).toLocaleString('vi-VN');
            }
            function previewFile(input, imgId) {
                if (input.files && input.files[0]) {
                    var reader = new FileReader();
                    reader.onload = function (e) {
                        document.getElementById(imgId).src = e.target.result;
                    };
                    reader.readAsDataURL(input.files[0]);
                }
            }
            function previewUrl(input, imgId) {
                var url = input.value.trim();
                if (url !== '') {
                    document.getElementById(imgId).src = url;
                }
            }
            window.addEventListener('DOMContentLoaded', function () {
                var pairs = [
                    ['<%= txtCoverImg.ClientID %>', 'prevCover'],
                    ['<%= txtSub1.ClientID %>', 'prevSub1'],
                    ['<%= txtSub2.ClientID %>', 'prevSub2'],
                    ['<%= txtSub3.ClientID %>', 'prevSub3'],
                    ['<%= txtSub4.ClientID %>', 'prevSub4']
                ];
                pairs.forEach(function (p) {
                    var tb = document.getElementById(p[0]);
                    if (tb && tb.value.trim() !== '') {
                        document.getElementById(p[1]).src = tb.value.trim();
                    }
                });
            });
        </script>
    </form>
</body>
</html>