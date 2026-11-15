<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="HostDashboard.aspx.cs" Inherits="BTL_Web.HostDashboard" %>
<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Kênh Chủ Phòng | Hanoi Stay Nest</title>
    <link rel="stylesheet" href="stylesheet/host.css?v=1" />
</head>
<body>
    <form id="form1" runat="server" style="display:flex; flex-direction:column; min-height:100vh;">

        <!-- HEADER CHỦ PHÒNG -->
        <header class="host-header">
            <a href="HostDashboard.aspx?tab=bookings" class="host-logo">
                <svg width="62" height="30" viewBox="0 0 80 40" fill="none">
                    <path d="M10 30L40 8L70 30" stroke="#D68C94" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M22 25L45 14L62 28" stroke="#D68C94" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M55 12V19" stroke="#D68C94" stroke-width="3.5" stroke-linecap="round"/>
                </svg>
                <span>Hanoi</span>
                <span>Stay Nest</span>
            </a>

            <ul class="host-nav">
                <li><a href="HostDashboard.aspx?tab=bookings" class='<%= CurrentTab == "bookings" ? "active" : "" %>'>Đơn đặt phòng</a></li>
                <li><a href="HostDashboard.aspx?tab=rooms" class='<%= CurrentTab == "rooms" || CurrentTab == "addroom" || CurrentTab == "editroom" ? "active" : "" %>'>Phòng của tôi</a></li>
            </ul>

            <a href="HostDashboard.aspx?tab=account" title="Tài khoản chủ phòng" style="width:44px; height:44px; display:block;">
                <svg viewBox="0 0 100 100">
                    <circle cx="50" cy="50" r="50" fill="#F8B8BE"/>
                    <circle cx="50" cy="38" r="17" fill="#FFFFFF"/>
                    <path d="M20 88C20 68 33 58 50 58C67 58 80 68 80 88" fill="#FFFFFF"/>
                </svg>
            </a>
        </header>

        <main class="host-main">
            <asp:Label ID="lblThongBao" runat="server" Font-Bold="true" ForeColor="#1e7e34" style="display:block; margin-bottom:14px;"></asp:Label>

            <!-- ==================== TAB 1: ĐƠN ĐẶT PHÒNG ==================== -->
            <asp:Panel ID="pnlBookings" runat="server">
                <h1 class="page-title" style="margin-bottom:22px;">Đơn đặt phòng</h1>

                <!-- 3 Ô THỐNG KÊ -->
                <div class="stats-grid-3">
                    <div class="stat-card-box">
                        <div class="stat-card-top"><span>Số đơn</span></div>
                        <div class="stat-card-num"><asp:Label ID="lblTotalOrders" runat="server" Text="0"></asp:Label></div>
                    </div>
                    <div class="stat-card-box">
                        <div class="stat-card-top"><span>Số đơn cần được xử lý</span></div>
                        <div class="stat-card-num"><asp:Label ID="lblPendingOrders" runat="server" Text="0"></asp:Label></div>
                    </div>
                    <div class="stat-card-box">
                        <div class="stat-card-top"><span>Tổng doanh thu</span><span>›</span></div>
                        <div class="stat-card-num"><asp:Label ID="lblTotalRevenue" runat="server" Text="0 đ"></asp:Label></div>
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
                                            <span style="font-size:12px; color:#888;" runat="server" visible='<%# Eval("Status").ToString() == "Completed" %>'>Không có thao tác</span>
                                            <span style="font-size:12px; color:#888;" runat="server" visible='<%# Eval("Status").ToString() == "Cancelled" %>'>(30 ngày tự xóa đơn)</span>
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
                                            <%# Eval("ApprovalStatus").ToString() == "Đang hoạt động" ? "Đang hiện thị" : Eval("ApprovalStatus") %>
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
                <h1 class="page-title" style="margin-bottom:24px;"><asp:Label ID="lblFormHeading" runat="server" Text="Thêm phòng mới"></asp:Label></h1>

                <label class="form-label">Tên phòng</label>
                <asp:TextBox ID="txtRoomTitle" runat="server" CssClass="form-control" placeholder="Ví dụ : Phòng tại Hồ Gươm"></asp:TextBox>

                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:24px;">
                    <div>
                        <label class="form-label">Khu vực</label>
                        <asp:DropDownList ID="ddlDistrict" runat="server" CssClass="form-control">
                            <asp:ListItem Value="Hồ Gươm">Hồ Gươm, Hà Nội</asp:ListItem>
                            <asp:ListItem Value="Hoàn Kiếm">Hoàn Kiếm, Hà Nội</asp:ListItem>
                            <asp:ListItem Value="Ba Đình">Ba Đình, Hà Nội</asp:ListItem>
                            <asp:ListItem Value="Tây Hồ">Tây Hồ, Hà Nội</asp:ListItem>
                            <asp:ListItem Value="Đống Đa">Đống Đa, Hà Nội</asp:ListItem>
                            <asp:ListItem Value="Cầu Giấy">Cầu Giấy, Hà Nội</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div>
                        <label class="form-label">Giá mỗi phòng / đêm</label>
                        <asp:TextBox ID="txtRoomPrice" runat="server" TextMode="Number" CssClass="form-control" placeholder="2.123.000"></asp:TextBox>
                    </div>
                </div>

                <label class="form-label">Địa chỉ chi tiết</label>
                <asp:TextBox ID="txtRoomAddress" runat="server" CssClass="form-control" placeholder="Số nhà , Số đường"></asp:TextBox>

                <label class="form-label">Mô tả</label>
                <asp:TextBox ID="txtRoomDesc" runat="server" TextMode="MultiLine" CssClass="form-textarea" placeholder="Giới thiệu không gian , mô tả địa chỉ , quy định của chủ nhà"></asp:TextBox>

                <label class="form-label">Tiện nghi</label>
                <div class="amenities-grid">
                    <label><asp:CheckBox ID="chkDieuHoa" runat="server" Checked="true" /> Điều hòa</label>
                    <label><asp:CheckBox ID="chkTivi" runat="server" Checked="true" /> Tivi</label>
                    <label><asp:CheckBox ID="chkChoDeXe" runat="server" /> Chỗ để xe</label>
                    <label><asp:CheckBox ID="chkMayGiat" runat="server" Checked="true" /> Máy giặt</label>
                    <label><asp:CheckBox ID="chkWifi" runat="server" Checked="true" /> Wifi</label>
                    <label><asp:CheckBox ID="chkBanCong" runat="server" /> Ban công</label>
                </div>

                <label class="form-label">Ảnh phòng (Ảnh bìa & 4 ảnh chi tiết)</label>
                <asp:TextBox ID="txtCoverImg" runat="server" CssClass="form-control" placeholder="Dán đường dẫn ảnh bìa (https://...)"></asp:TextBox>
                <div class="photo-slots">
                    <div class="photo-slot cover">
                        <span class="cover-tag">Ảnh bìa</span>
                    </div>
                    <div class="photo-slot sub"></div>
                    <div class="photo-slot sub"></div>
                    <div class="photo-slot sub"></div>
                    <div class="photo-slot sub"></div>
                </div>

                <p style="font-size:13px; color:#777; line-height:1.6; margin-bottom:22px;">
                    Ảnh đầu tiên là ảnh bìa hiển thị ở trang chủ.<br />
                    Phòng mới sẽ ở trạng thái "Chờ duyệt" cho đến khi quản trị viên duyệt.
                </p>

                <div style="display:flex; gap:14px;">
                    <asp:Button ID="btnSaveRoom" runat="server" Text="Lưu phòng" CssClass="btn-red-pill" OnClick="btnSaveRoom_Click" />
                    <a href="HostDashboard.aspx?tab=rooms" class="btn-white-pill">Hủy</a>
                </div>
            </asp:Panel>

            <!-- ==================== TAB 4: TÀI KHOẢN CỦA CHỦ PHÒNG ==================== -->
            <asp:Panel ID="pnlHostAccount" runat="server" Visible="false">
                <div style="display:flex; flex-direction:column; align-items:center; justify-content:center; padding:25px 0;">
                    <svg width="145" height="145" viewBox="0 0 100 100" style="margin-bottom:20px;">
                        <circle cx="50" cy="50" r="50" fill="#F8B8BE"/>
                        <circle cx="50" cy="38" r="17" fill="#FFFFFF"/>
                        <path d="M20 88C20 68 33 58 50 58C67 58 80 68 80 88" fill="#FFFFFF"/>
                    </svg>

                    <div style="font-size:24px; font-weight:500; margin-bottom:8px;">
                        <asp:Label ID="lblHostEmail" runat="server"></asp:Label>
                    </div>

                    <a href="Trangchu.aspx" style="font-size:15px; color:#444; text-decoration:none; margin-bottom:26px;">
                        Chủ phòng ⇔
                    </a>

                    <div style="width:100%; max-width:440px; display:flex; flex-direction:column; gap:16px;">
                        <div style="display:flex; align-items:center; gap:14px;">
                            <label style="width:70px; font-size:20px;">Tên :</label>
                            <asp:TextBox ID="txtHostName" runat="server" CssClass="form-control" style="margin:0; border-radius:22px; box-shadow:0 3px 10px rgba(0,0,0,0.06);"></asp:TextBox>
                        </div>
                        <div style="display:flex; align-items:center; gap:14px;">
                            <label style="width:70px; font-size:20px;">SDT :</label>
                            <asp:TextBox ID="txtHostPhone" runat="server" CssClass="form-control" style="margin:0; border-radius:22px; box-shadow:0 3px 10px rgba(0,0,0,0.06);"></asp:TextBox>
                        </div>
                        <div style="display:flex; justify-content:center; gap:14px; margin-top:18px;">
                            <asp:Button ID="btnUpdateHostInfo" runat="server" Text="Lưu" CssClass="btn-white-pill" OnClick="btnUpdateHostInfo_Click" />
                            <a href="Logout.aspx" onclick="return confirm('Bạn có chắc chắn muốn đăng xuất?');"
                               style="display:inline-flex; align-items:center; justify-content:center; width:175px; height:44px; border-radius:22px; background:#f8b8be; color:#fff; font-size:18px; font-weight:600; text-decoration:none; box-shadow:0 4px 12px rgba(248,184,190,0.45);">
                                Đăng xuất
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
                    <div id="confirmIcon" style="font-size:34px; margin-bottom:14px;">⏻</div>
                    <div id="confirmMsg" style="font-size:15.5px; font-weight:600; margin-bottom:22px;">Bạn có chắc chắn?</div>
                    <div style="display:flex; justify-content:center; gap:14px;">
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
                    <path d="M10 30L40 8L70 30" stroke="#D68C94" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M22 25L45 14L62 28" stroke="#D68C94" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M55 12V19" stroke="#D68C94" stroke-width="3.5" stroke-linecap="round"/>
                </svg>
                <span>Hanoi</span>
                <span>Stay Nest</span>
            </a>
            <div style="text-align:center;">
                <div class="footer-links">
                    <a href="#">Giới thiệu</a>|<a href="#">Điều khoản</a>|<a href="#">Liên hệ</a>|<a href="#">Chính sách</a>
                </div>
                <div style="font-size:13px; color:#888; margin-top:6px;">copyright@HanoiStayNest.com</div>
            </div>
            <div style="width:62px;"></div>
        </footer>

        <script>
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
        </script>
    </form>
</body>
</html>