<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="BTL_Web.AdminDashboard" %>
<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Quản trị Admin | Hanoi Stay Nest</title>
    <link rel="stylesheet" href="stylesheet/admin.css?v=7" />
</head>
<body>
    <form id="form1" runat="server" style="display:flex; flex-direction:column; min-height:100vh;">

        <!-- HEADER ADMIN -->
        <header class="admin-header">
            <a href="AdminDashboard.aspx?tab=users" class="admin-logo">
                <svg width="62" height="30" viewBox="0 0 80 40" fill="none">
                    <path d="M10 30L40 8L70 30" stroke="#D68C94" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M22 25L45 14L62 28" stroke="#D68C94" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M55 12V19" stroke="#D68C94" stroke-width="3.5" stroke-linecap="round"/>
                </svg>
                <span>Hanoi</span>
                <span>Stay Nest</span>
            </a>

            <ul class="admin-nav">
                <li><a href="AdminDashboard.aspx?tab=users" class='<%= CurrentTab == "users" || CurrentTab == "userdetail" ? "active" : "" %>'>Quản lý người dùng</a></li>
                <li><a href="AdminDashboard.aspx?tab=bookings" class='<%= CurrentTab == "bookings" ? "active" : "" %>'>Quản lý đơn đặt</a></li>
                <li><a href="AdminDashboard.aspx?tab=rooms" class='<%= CurrentTab == "rooms" || CurrentTab == "roomdetail" ? "active" : "" %>'>Quản lý phòng</a></li>
            </ul>

            <a href="Logout.aspx" class="btn-logout-icon" title="Đăng xuất" onclick="return confirm('Đăng xuất khỏi tài khoản Admin?');">
                <svg width="34" height="34" viewBox="0 0 24 24" fill="none" stroke="#F8B8BE" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"></path>
                    <polyline points="10 17 15 12 10 7"></polyline>
                    <line x1="15" y1="12" x2="3" y2="12"></line>
                </svg>
            </a>
        </header>

        <main class="admin-main">
            <asp:Label ID="lblThongBao" runat="server" Font-Bold="true" ForeColor="#1e7e34" style="display:block; margin-bottom:14px;"></asp:Label>

            <!-- ==================== 1. QUẢN LÝ NGƯỜI DÙNG ==================== -->
            <asp:Panel ID="pnlUsers" runat="server">
                <h1 class="page-title">Quản lý người dùng</h1>

                <div class="filter-bar">
                    <a href="AdminDashboard.aspx?tab=users&filter=all" class='filter-pill <%= CurrentFilter == "all" ? "active" : "" %>'>Tất cả</a>
                    <a href="AdminDashboard.aspx?tab=users&filter=Guest" class='filter-pill <%= CurrentFilter == "Guest" ? "active" : "" %>'>Khách hàng</a>
                    <a href="AdminDashboard.aspx?tab=users&filter=Host" class='filter-pill <%= CurrentFilter == "Host" ? "active" : "" %>'>Chủ Phòng</a>
                    <a href="AdminDashboard.aspx?tab=users&filter=Locked" class='filter-pill <%= CurrentFilter == "Locked" ? "active" : "" %>'>Đã khóa</a>
                </div>

                <div class="table-card">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Tên</th>
                                <th>Email</th>
                                <th>Vai trò</th>
                                <th>Số đơn/Số phòng</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptUsers" runat="server" OnItemCommand="rptUsers_ItemCommand">
                                <ItemTemplate>
                                    <tr>
                                        <td><strong><%# Eval("FullName") %></strong></td>
                                        <td><%# Eval("Email") %></td>
                                        <td><%# Eval("Role").ToString() == "Host" ? "Chủ phòng" : (Eval("Role").ToString() == "Admin" ? "Admin" : "Khách hàng") %></td>
                                        <td><%# Eval("Role").ToString() == "Host" ? Eval("RoomCount") + " phòng" : Eval("BookingCount") + " đơn" %></td>
                                        <td>
                                            <span class='status-badge <%# Eval("Status").ToString() == "Bị khóa" ? "st-red" : "st-green" %>'>
                                                <%# Eval("Status") %>
                                            </span>
                                        </td>
                                        <td>
                                            <%# Eval("Status").ToString() == "Bị khóa"
                                                ? ""
                                                : "<button type='button' class='act-btn danger' onclick=\"openReasonModal('LockUser', '" + Eval("UserID") + "', 'Lý do khóa', 'Khóa')\">Khóa</button>" %>
                                            <asp:LinkButton runat="server" CssClass="act-btn" CommandName="UnlockUser" CommandArgument='<%# Eval("UserID") %>'
                                                Visible='<%# Eval("Status").ToString() == "Bị khóa" %>'>Mở khóa</asp:LinkButton>
                                            <a href='AdminDashboard.aspx?tab=userdetail&id=<%# Eval("UserID") %>' class="act-btn">Xem</a>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
                <p class="helper-note">Khi bấm Khóa, hiện hộp nhập lý do để ghi chú nguyên nhân khóa tài khoản.</p>
            </asp:Panel>

            <!-- ==================== 2. CHI TIẾT NGƯỜI DÙNG (KHÁCH HÀNG / CHỦ PHÒNG) ==================== -->
            <asp:Panel ID="pnlUserDetail" runat="server" Visible="false">
                <a href="AdminDashboard.aspx?tab=users" class="back-title">
                    ← <asp:Label ID="lblDetailHeading" runat="server" Text="Thông tin tài khoản - Đơn đã đặt"></asp:Label>
                </a>

                <div class="user-profile-top">
                    <div style="display:flex; align-items:center; gap:20px;">
                        <svg width="95" height="95" viewBox="0 0 100 100">
                            <circle cx="50" cy="50" r="50" fill="#F8B8BE"/>
                            <circle cx="50" cy="38" r="17" fill="#FFFFFF"/>
                            <path d="M20 88C20 68 33 58 50 58C67 58 80 68 80 88" fill="#FFFFFF"/>
                        </svg>
                        <div>
                            <div style="font-size:21px; font-weight:600;"><asp:Label ID="lblDetailName" runat="server"></asp:Label></div>
                            <div style="font-size:15px; color:#666; margin:4px 0;"><asp:Label ID="lblDetailEmail" runat="server"></asp:Label></div>
                            <div style="font-size:15px; color:#555;"><asp:Label ID="lblDetailRole" runat="server"></asp:Label></div>
                        </div>
                    </div>

                    <div style="text-align:center;">
                        <div style="font-size:18px; margin-bottom:6px;">Trạng thái</div>
                        <asp:Label ID="lblDetailStatus" runat="server" CssClass="status-badge st-green"></asp:Label>
                    </div>

                    <div>
                        <asp:Literal ID="litDetailLockBtn" runat="server"></asp:Literal>
                    </div>
                </div>

                <!-- 3 Ô THỐNG KÊ -->
                <div class="stat-row">
                    <div class="stat-box">
                        <div class="stat-box-label"><asp:Label ID="lblStat1Title" runat="server"></asp:Label></div>
                        <div class="stat-box-val"><asp:Label ID="lblStat1Val" runat="server"></asp:Label></div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-box-label"><asp:Label ID="lblStat2Title" runat="server"></asp:Label></div>
                        <div class="stat-box-val"><asp:Label ID="lblStat2Val" runat="server"></asp:Label></div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-box-label"><asp:Label ID="lblStat3Title" runat="server"></asp:Label></div>
                        <div class="stat-box-val"><asp:Label ID="lblStat3Val" runat="server"></asp:Label></div>
                    </div>
                </div>

                <!-- BẢNG LỊCH SỬ ĐƠN (NẾU LÀ KHÁCH) HOẶC PHÒNG ĐÃ ĐĂNG (NẾU LÀ CHỦ PHÒNG) -->
                <div class="table-card">
                    <asp:Repeater ID="rptUserSubList" runat="server">
                        <HeaderTemplate>
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Mã</th>
                                        <th>Tên phòng</th>
                                        <th>Thời gian / Khu vực</th>
                                        <th>Tổng tiền / Giá đêm</th>
                                        <th>Trạng thái</th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <td><%# Eval("ColCode") %></td>
                                <td><%# Eval("ColTitle") %></td>
                                <td><%# Eval("ColSub") %></td>
                                <td><%# String.Format("{0:N0} đ", Eval("ColPrice")) %></td>
                                <td><span class="status-badge st-green"><%# Eval("ColStatus") %></span></td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate></tbody></table></FooterTemplate>
                    </asp:Repeater>
                </div>
            </asp:Panel>

            <!-- ==================== 3. QUẢN LÝ ĐƠN ĐẶT ==================== -->
            <asp:Panel ID="pnlBookings" runat="server" Visible="false">
                <h1 class="page-title">Quản lý đơn đặt</h1>

                <div class="filter-bar">
                    <a href="AdminDashboard.aspx?tab=bookings&filter=all" class='filter-pill <%= CurrentFilter == "all" ? "active" : "" %>'>Tất cả</a>
                    <a href="AdminDashboard.aspx?tab=bookings&filter=Pending" class='filter-pill <%= CurrentFilter == "Pending" ? "active" : "" %>'>Chờ xác nhận</a>
                    <a href="AdminDashboard.aspx?tab=bookings&filter=Unpaid" class='filter-pill <%= CurrentFilter == "Unpaid" ? "active" : "" %>'>Chờ thanh toán</a>
                    <a href="AdminDashboard.aspx?tab=bookings&filter=Confirmed" class='filter-pill <%= CurrentFilter == "Confirmed" ? "active" : "" %>'>Đã xác nhận</a>
                    <a href="AdminDashboard.aspx?tab=bookings&filter=Completed" class='filter-pill <%= CurrentFilter == "Completed" ? "active" : "" %>'>Hoàn tất</a>
                    <a href="AdminDashboard.aspx?tab=bookings&filter=Cancelled" class='filter-pill <%= CurrentFilter == "Cancelled" ? "active" : "" %>'>Đã hủy</a>
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
                            <asp:Repeater ID="rptBookings" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td><%# Eval("BookingID") %></td>
                                        <td><%# Eval("GuestName") %></td>
                                        <td>HG0<%# Eval("RoomID") %></td>
                                        <td><%# Convert.ToDateTime(Eval("CheckInDate")).ToString("dd/MM") %> - <%# Convert.ToDateTime(Eval("CheckOutDate")).ToString("dd/MM") %></td>
                                        <td><%# Eval("PaymentMethod") %></td>
                                        <td><%# String.Format("{0:N0} đ", Eval("TotalPrice")) %></td>
                                        <td>
                                            <span class='status-badge <%# GetBookingBadgeClass(Eval("Status").ToString()) %>'>
                                                <%# FormatBookingStatus(Eval("Status").ToString()) %>
                                            </span>
                                        </td>
                                        <td>
                                            <%# (Eval("Status").ToString() == "Completed" || Eval("Status").ToString() == "Cancelled")
                                                ? "<span style='font-size:12px; color:#888;'>Không có thao tác</span>"
                                                : "<button type='button' class='act-btn danger' onclick=\"openReasonModal('CancelBooking', '" + Eval("BookingID") + "', 'Lý do hủy đơn', 'Hủy đơn')\">Hủy đơn</button>" %>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
                <p class="helper-note">Admin chủ yếu để theo dõi. Ghi lý do hủy.</p>
            </asp:Panel>

            <!-- ==================== 4. QUẢN LÝ PHÒNG ==================== -->
            <asp:Panel ID="pnlRooms" runat="server" Visible="false">
                <h1 class="page-title">Quản lý phòng</h1>

                <div class="filter-bar">
                    <a href="AdminDashboard.aspx?tab=rooms&filter=all" class='filter-pill <%= CurrentFilter == "all" ? "active" : "" %>'>Tất cả</a>
                    <a href="AdminDashboard.aspx?tab=rooms&filter=Chờ duyệt" class='filter-pill <%= CurrentFilter == "Chờ duyệt" ? "active" : "" %>'>Chờ duyệt</a>
                    <a href="AdminDashboard.aspx?tab=rooms&filter=Đang hoạt động" class='filter-pill <%= CurrentFilter == "Đang hoạt động" ? "active" : "" %>'>Đang hiển thị</a>
                    <a href="AdminDashboard.aspx?tab=rooms&filter=Đã tắt" class='filter-pill <%= CurrentFilter == "Đã tắt" ? "active" : "" %>'>Đã tắt</a>
                    <a href="AdminDashboard.aspx?tab=rooms&filter=Bị từ chối" class='filter-pill <%= CurrentFilter == "Bị từ chối" ? "active" : "" %>'>Bị từ chối</a>
                </div>

                <div class="table-card">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Phòng</th>
                                <th>Chủ Phòng</th>
                                <th>Khu vực</th>
                                <th>Giá / đêm</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptRooms" runat="server" OnItemCommand="rptRooms_ItemCommand">
                                <ItemTemplate>
                                    <tr>
                                        <td style="text-align:left; font-weight:500;"><%# Eval("Title") %> - HG0<%# Eval("RoomID") %></td>
                                        <td><%# Eval("HostName") %></td>
                                        <td><%# Eval("District") %></td>
                                        <td><%# String.Format("{0:N0} đ", Eval("PricePerNight")) %></td>
                                        <td>
                                            <span class='status-badge <%# GetRoomBadgeClass(Eval("ApprovalStatus").ToString()) %>'>
                                                <%# Eval("ApprovalStatus") %>
                                            </span>
                                        </td>
                                        <td>
                                            <a href='AdminDashboard.aspx?tab=roomdetail&id=<%# Eval("RoomID") %>' class="act-btn">Xem</a>
                                            <asp:LinkButton runat="server" CssClass="act-btn danger" CommandName="ApproveRoom" CommandArgument='<%# Eval("RoomID") %>'
                                                Visible='<%# Eval("ApprovalStatus").ToString() == "Chờ duyệt" %>'>Duyệt</asp:LinkButton>
                                            <%# Eval("ApprovalStatus").ToString() == "Chờ duyệt"
                                                ? "<button type='button' class='act-btn' onclick=\"openReasonModal('RejectRoom', '" + Eval("RoomID") + "', 'Lý do từ chối', 'Từ chối')\">Từ chối</button>"
                                                : "" %>
                                            <asp:LinkButton runat="server" CssClass="act-btn" CommandName="HideRoom" CommandArgument='<%# Eval("RoomID") %>'
                                                Visible='<%# Eval("ApprovalStatus").ToString() == "Đang hoạt động" %>'>Tắt phòng</asp:LinkButton>
                                            <asp:LinkButton runat="server" CssClass="act-btn danger" CommandName="ApproveRoom" CommandArgument='<%# Eval("RoomID") %>'
                                                Visible='<%# Eval("ApprovalStatus").ToString() == "Đã tắt" %>'>Hiện Phòng</asp:LinkButton>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
                <p class="helper-note">Khi bấm Từ chối, hiện hộp nhập lý do để chủ phòng biết cần sửa gì.</p>
            </asp:Panel>

            <!-- ==================== 5. CHI TIẾT PHÒNG DUYỆT (KHI BẤM XEM PHÒNG) ==================== -->
            <asp:Panel ID="pnlRoomDetail" runat="server" Visible="false">
                <h1 class="page-title"><asp:Label ID="lblRoomDetailTitle" runat="server"></asp:Label></h1>

                <div class="room-gallery">
                    <img id="imgRoomMain" runat="server" class="main-img" src="https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800" />
                    <img src="https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=500" />
                    <img src="https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=500" />
                    <img src="https://images.unsplash.com/photo-1484154218962-a197022b5858?w=500" />
                    <img src="https://images.unsplash.com/photo-1554995207-c18c203602cb?w=500" />
                </div>

                <div><strong>Tên phòng</strong><div class="readonly-field"><asp:Label ID="lblRdName" runat="server"></asp:Label></div></div>
                <div><strong>Tên chủ phòng</strong><div class="readonly-field"><asp:Label ID="lblRdHost" runat="server"></asp:Label></div></div>

                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:20px;">
                    <div><strong>Khu vực</strong><div class="readonly-field"><asp:Label ID="lblRdDistrict" runat="server"></asp:Label>, Hà Nội</div></div>
                    <div><strong>Giá mỗi phòng / đêm</strong><div class="readonly-field"><asp:Label ID="lblRdPrice" runat="server"></asp:Label></div></div>
                </div>

                <div><strong>Địa chỉ chi tiết</strong><div class="readonly-field"><asp:Label ID="lblRdAddress" runat="server"></asp:Label></div></div>
                <div><strong>Mô tả</strong><div class="readonly-field" style="min-height:70px;"><asp:Label ID="lblRdDesc" runat="server"></asp:Label></div></div>

                <div style="display:flex; justify-content:space-between; align-items:flex-end; margin-top:16px;">
                    <div>
                        <strong>Tiện nghi</strong>
                        <div style="display:grid; grid-template-columns: repeat(3, 150px); gap:10px; margin-top:10px; font-size:14.5px;">
                            <span>☑ Điều hòa</span><span>☑ Tivi</span><span>☑ Chỗ để xe</span>
                            <span>☑ Máy giặt</span><span>☑ Wifi</span><span>☑ Ban công</span>
                        </div>
                    </div>
                    <div style="display:flex; gap:12px;">
                        <asp:Button ID="btnDetailApprove" runat="server" Text="Duyệt" CssClass="btn-modal-red" OnClick="btnDetailApprove_Click" />
                        <asp:Literal ID="litDetailRejectBtn" runat="server"></asp:Literal>
                    </div>
                </div>
            </asp:Panel>

            <!-- ==================== MODAL NHẬP LÝ DO CHUNG ==================== -->
            <asp:HiddenField ID="hfActionType" runat="server" />
            <asp:HiddenField ID="hfTargetId" runat="server" />
            <div id="reasonModal" class="modal-overlay">
                <div class="modal-box">
                    <div id="modalTitleText" class="modal-title">Lý do</div>
                    <asp:TextBox ID="txtModalReason" runat="server" TextMode="MultiLine" CssClass="modal-textarea" placeholder="Ghi chú..."></asp:TextBox>
                    <div class="modal-actions">
                        <asp:Button ID="btnSubmitReason" runat="server" Text="Xác nhận" CssClass="btn-modal-red" OnClick="btnSubmitReason_Click" />
                        <button type="button" class="btn-modal-cancel" onclick="closeReasonModal()">Hủy</button>
                    </div>
                </div>
            </div>

        </main>

        <!-- FOOTER -->
        <footer class="admin-footer">
            <a href="AdminDashboard.aspx?tab=users" class="admin-logo">
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
            function openReasonModal(actionType, targetId, titleText, submitLabel) {
                document.getElementById('<%= hfActionType.ClientID %>').value = actionType;
                document.getElementById('<%= hfTargetId.ClientID %>').value = targetId;
                document.getElementById('modalTitleText').innerText = titleText;
    document.getElementById('<%= btnSubmitReason.ClientID %>').value = submitLabel;
    document.getElementById('<%= txtModalReason.ClientID %>').value = '';
    document.getElementById('reasonModal').classList.add('show');
}
function closeReasonModal() {
    document.getElementById('reasonModal').classList.remove('show');
            }
        </script>
    </form>
</body>
</html>