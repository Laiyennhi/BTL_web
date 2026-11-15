using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace BTL_Web
{
    public partial class AdminDashboard : System.Web.UI.Page
    {
        string strCon = ConfigurationManager.ConnectionStrings["DefaultConnection"]?.ConnectionString
                        ?? @"Data Source=.;Initial Catalog=Home_Sharing;Integrated Security=True;TrustServerCertificate=True";

        public string CurrentTab => Request.QueryString["tab"] ?? "users";
        public string CurrentFilter => Request.QueryString["filter"] ?? "all";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null || Session["Role"].ToString() != "Admin")
            {
                Response.Redirect("Trangchu.aspx");
                return;
            }

            if (!IsPostBack)
            {
                RouteTab();
            }
        }

        private void RouteTab()
        {
            pnlUsers.Visible = false;
            pnlUserDetail.Visible = false;
            pnlBookings.Visible = false;
            pnlRooms.Visible = false;
            pnlRoomDetail.Visible = false;

            switch (CurrentTab)
            {
                case "userdetail":
                    pnlUserDetail.Visible = true;
                    LoadUserDetail();
                    break;
                case "bookings":
                    pnlBookings.Visible = true;
                    LoadBookings();
                    break;
                case "rooms":
                    pnlRooms.Visible = true;
                    LoadRooms();
                    break;
                case "roomdetail":
                    pnlRoomDetail.Visible = true;
                    LoadRoomDetail();
                    break;
                default:
                    pnlUsers.Visible = true;
                    LoadUsers();
                    break;
            }
        }

        // 1. TẢI DANH SÁCH NGƯỜI DÙNG
        private void LoadUsers()
        {
            using (SqlConnection conn = new SqlConnection(strCon))
            {
                string sql = @"SELECT u.UserID, u.FullName, u.Email, ISNULL(u.Role,'Guest') AS Role, ISNULL(u.Status, N'Hoạt động') AS Status,
                               (SELECT COUNT(*) FROM Bookings b WHERE b.GuestID = u.UserID) AS BookingCount,
                               (SELECT COUNT(*) FROM Rooms r WHERE r.HostID = u.UserID) AS RoomCount
                               FROM Users u WHERE 1=1";
                if (CurrentFilter == "Guest") sql += " AND ISNULL(u.Role,'Guest') = 'Guest'";
                else if (CurrentFilter == "Host") sql += " AND u.Role = 'Host'";
                else if (CurrentFilter == "Locked") sql += " AND u.Status = N'Bị khóa'";

                SqlDataAdapter da = new SqlDataAdapter(sql + " ORDER BY u.UserID DESC", conn);
                DataTable dt = new DataTable();
                da.Fill(dt);
                rptUsers.DataSource = dt;
                rptUsers.DataBind();
            }
        }

        // 2. CHI TIẾT TÀI KHOẢN (KHÁCH HÀNG / CHỦ PHÒNG)
        private void LoadUserDetail()
        {
            int userId = Convert.ToInt32(Request.QueryString["id"] ?? "0");
            using (SqlConnection conn = new SqlConnection(strCon))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand("SELECT FullName, Email, ISNULL(Role,'Guest') AS Role, ISNULL(Status, N'Hoạt động') AS Status FROM Users WHERE UserID = @ID", conn);
                cmd.Parameters.AddWithValue("@ID", userId);
                SqlDataReader rd = cmd.ExecuteReader();
                if (!rd.Read()) return;

                string role = rd["Role"].ToString();
                string status = rd["Status"].ToString();
                lblDetailName.Text = rd["FullName"].ToString();
                lblDetailEmail.Text = rd["Email"].ToString();
                lblDetailRole.Text = role == "Host" ? "Chủ Phòng" : "Khách hàng";
                lblDetailStatus.Text = status;
                lblDetailStatus.CssClass = status == "Bị khóa" ? "status-badge st-red" : "status-badge st-green";
                rd.Close();

                litDetailLockBtn.Text = status == "Bị khóa"
                    ? ""
                    : $"<button type='button' class='btn-modal-red' onclick=\"openReasonModal('LockUser', '{userId}', 'Lý do khóa', 'Khóa')\">Khóa tài khoản</button>";

                if (role == "Host")
                {
                    lblDetailHeading.Text = "Thông tin tài khoản - Phòng đã đăng";
                    lblStat1Title.Text = "Tổng số phòng";
                    lblStat2Title.Text = "Phòng đang hoạt động";
                    lblStat3Title.Text = "Phòng đã tắt";

                    lblStat1Val.Text = new SqlCommand($"SELECT COUNT(*) FROM Rooms WHERE HostID={userId}", conn).ExecuteScalar().ToString();
                    lblStat2Val.Text = new SqlCommand($"SELECT COUNT(*) FROM Rooms WHERE HostID={userId} AND ApprovalStatus=N'Đang hoạt động'", conn).ExecuteScalar().ToString();
                    lblStat3Val.Text = new SqlCommand($"SELECT COUNT(*) FROM Rooms WHERE HostID={userId} AND ApprovalStatus=N'Đã tắt'", conn).ExecuteScalar().ToString();

                    SqlDataAdapter da = new SqlDataAdapter($@"SELECT ('HG0' + CAST(RoomID AS VARCHAR)) AS ColCode, Title AS ColTitle, 
                        District AS ColSub, PricePerNight AS ColPrice, ISNULL(ApprovalStatus,N'Đang hoạt động') AS ColStatus 
                        FROM Rooms WHERE HostID={userId}", conn);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    rptUserSubList.DataSource = dt;
                    rptUserSubList.DataBind();
                }
                else
                {
                    lblDetailHeading.Text = "Thông tin tài khoản - Đơn đã đặt";
                    lblStat1Title.Text = "Tổng số đơn";
                    lblStat2Title.Text = "Đơn hoàn tất";
                    lblStat3Title.Text = "Đơn đã hủy";

                    lblStat1Val.Text = new SqlCommand($"SELECT COUNT(*) FROM Bookings WHERE GuestID={userId}", conn).ExecuteScalar().ToString();
                    lblStat2Val.Text = new SqlCommand($"SELECT COUNT(*) FROM Bookings WHERE GuestID={userId} AND Status='Completed'", conn).ExecuteScalar().ToString();
                    lblStat3Val.Text = new SqlCommand($"SELECT COUNT(*) FROM Bookings WHERE GuestID={userId} AND Status='Cancelled'", conn).ExecuteScalar().ToString();

                    SqlDataAdapter da = new SqlDataAdapter($@"SELECT CAST(b.BookingID AS VARCHAR) AS ColCode, r.Title AS ColTitle,
                        (CONVERT(VARCHAR(5), b.CheckInDate, 103) + ' - ' + CONVERT(VARCHAR(5), b.CheckOutDate, 103)) AS ColSub,
                        b.TotalPrice AS ColPrice, b.Status AS ColStatus
                        FROM Bookings b JOIN Rooms r ON b.RoomID = r.RoomID WHERE b.GuestID={userId}", conn);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    rptUserSubList.DataSource = dt;
                    rptUserSubList.DataBind();
                }
            }
        }

        // 3. TẢI DANH SÁCH ĐƠN ĐẶT
        private void LoadBookings()
        {
            using (SqlConnection conn = new SqlConnection(strCon))
            {
                string sql = @"SELECT b.BookingID, u.FullName AS GuestName, b.RoomID, b.CheckInDate, b.CheckOutDate, 
                               ISNULL(b.PaymentMethod,'QR') AS PaymentMethod, b.TotalPrice, b.Status
                               FROM Bookings b LEFT JOIN Users u ON b.GuestID = u.UserID WHERE 1=1";
                if (CurrentFilter != "all") sql += " AND b.Status = @Status";

                SqlCommand cmd = new SqlCommand(sql + " ORDER BY b.BookingID DESC", conn);
                if (CurrentFilter != "all") cmd.Parameters.AddWithValue("@Status", CurrentFilter);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                rptBookings.DataSource = dt;
                rptBookings.DataBind();
            }
        }

        // 4. TẢI DANH SÁCH PHÒNG
        private void LoadRooms()
        {
            using (SqlConnection conn = new SqlConnection(strCon))
            {
                string sql = @"SELECT r.RoomID, r.Title, r.District, r.PricePerNight, ISNULL(r.ApprovalStatus, N'Chờ duyệt') AS ApprovalStatus,
                               u.FullName AS HostName FROM Rooms r LEFT JOIN Users u ON r.HostID = u.UserID WHERE 1=1";
                if (CurrentFilter != "all") sql += " AND ISNULL(r.ApprovalStatus, N'Chờ duyệt') = @St";

                SqlCommand cmd = new SqlCommand(sql + " ORDER BY r.RoomID DESC", conn);
                if (CurrentFilter != "all") cmd.Parameters.AddWithValue("@St", CurrentFilter);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                rptRooms.DataSource = dt;
                rptRooms.DataBind();
            }
        }

        // 5. CHI TIẾT PHÒNG KHI BẤM XEM
        private void LoadRoomDetail()
        {
            int roomId = Convert.ToInt32(Request.QueryString["id"] ?? "0");
            using (SqlConnection conn = new SqlConnection(strCon))
            {
                string sql = "SELECT r.*, u.FullName AS HostName FROM Rooms r LEFT JOIN Users u ON r.HostID = u.UserID WHERE r.RoomID = @ID";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@ID", roomId);
                conn.Open();
                SqlDataReader rd = cmd.ExecuteReader();
                if (rd.Read())
                {
                    lblRoomDetailTitle.Text = rd["Title"] + " - HG0" + roomId;
                    lblRdName.Text = rd["Title"].ToString();
                    lblRdHost.Text = rd["HostName"].ToString();
                    lblRdDistrict.Text = rd["District"].ToString();
                    lblRdPrice.Text = string.Format("{0:N0} đ", rd["PricePerNight"]);
                    lblRdAddress.Text = rd["Address"].ToString();
                    lblRdDesc.Text = rd["Description"].ToString();
                    if (rd["ImageUrl"] != DBNull.Value && !string.IsNullOrEmpty(rd["ImageUrl"].ToString()))
                        imgRoomMain.Src = rd["ImageUrl"].ToString();

                    litDetailRejectBtn.Text = $"<button type='button' class='btn-modal-cancel' onclick=\"openReasonModal('RejectRoom', '{roomId}', 'Lý do từ chối', 'Từ chối')\">Từ chối</button>";
                }
            }
        }

        // XỬ LÝ NÚT MỞ KHÓA USER
        protected void rptUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "UnlockUser")
            {
                ExecuteSql("UPDATE Users SET Status = N'Hoạt động', LockReason = NULL WHERE UserID = @ID", Convert.ToInt32(e.CommandArgument));
                lblThongBao.Text = "✓ Đã mở khóa tài khoản.";
                RouteTab();
            }
        }

        // XỬ LÝ DUYỆT / TẮT PHÒNG TRÊN BẢNG
        protected void rptRooms_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int roomId = Convert.ToInt32(e.CommandArgument);
            if (e.CommandName == "ApproveRoom")
            {
                ExecuteSql("UPDATE Rooms SET ApprovalStatus = N'Đang hoạt động', IsAvailable = 1 WHERE RoomID = @ID", roomId);
                lblThongBao.Text = "✓ Đã duyệt hiển thị phòng.";
            }
            else if (e.CommandName == "HideRoom")
            {
                ExecuteSql("UPDATE Rooms SET ApprovalStatus = N'Đã tắt', IsAvailable = 0 WHERE RoomID = @ID", roomId);
                lblThongBao.Text = "✓ Đã tắt hiển thị phòng.";
            }
            RouteTab();
        }

        protected void btnDetailApprove_Click(object sender, EventArgs e)
        {
            int roomId = Convert.ToInt32(Request.QueryString["id"] ?? "0");
            ExecuteSql("UPDATE Rooms SET ApprovalStatus = N'Đang hoạt động', IsAvailable = 1 WHERE RoomID = @ID", roomId);
            Response.Redirect("AdminDashboard.aspx?tab=rooms");
        }

        // XỬ LÝ XÁC NHẬN MODAL LÝ DO (KHÓA USER / HỦY ĐƠN / TỪ CHỐI PHÒNG)
        protected void btnSubmitReason_Click(object sender, EventArgs e)
        {
            string action = hfActionType.Value;
            int id = Convert.ToInt32(hfTargetId.Value);
            string reason = txtModalReason.Text.Trim();

            using (SqlConnection conn = new SqlConnection(strCon))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand("", conn);
                if (action == "LockUser")
                {
                    cmd.CommandText = "UPDATE Users SET Status = N'Bị khóa', LockReason = @Reason WHERE UserID = @ID";
                    lblThongBao.Text = "✓ Đã khóa tài khoản.";
                }
                else if (action == "CancelBooking")
                {
                    cmd.CommandText = "UPDATE Bookings SET Status = 'Cancelled', CancelReason = @Reason WHERE BookingID = @ID";
                    lblThongBao.Text = "✓ Đã hủy đơn đặt phòng.";
                }
                else if (action == "RejectRoom")
                {
                    cmd.CommandText = "UPDATE Rooms SET ApprovalStatus = N'Bị từ chối', IsAvailable = 0, RejectReason = @Reason WHERE RoomID = @ID";
                    lblThongBao.Text = "✓ Đã từ chối duyệt phòng.";
                }
                cmd.Parameters.AddWithValue("@Reason", reason);
                cmd.Parameters.AddWithValue("@ID", id);
                cmd.ExecuteNonQuery();
            }

            if (CurrentTab == "roomdetail") Response.Redirect("AdminDashboard.aspx?tab=rooms");
            else if (CurrentTab == "userdetail") Response.Redirect("AdminDashboard.aspx?tab=users");
            else RouteTab();
        }

        private void ExecuteSql(string query, int id)
        {
            using (SqlConnection conn = new SqlConnection(strCon))
            {
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@ID", id);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        public string GetBookingBadgeClass(string st)
        {
            if (st == "Confirmed") return "st-green";
            if (st == "Pending" || st == "Unpaid") return "st-yellow";
            if (st == "Cancelled") return "st-red";
            return "st-gray";
        }

        public string FormatBookingStatus(string st)
        {
            switch (st)
            {
                case "Pending": return "Chờ xác nhận";
                case "Unpaid": return "Chờ thanh toán";
                case "Confirmed": return "Đã xác nhận";
                case "Completed": return "Hoàn tất";
                case "Cancelled": return "Đã hủy";
                default: return st;
            }
        }

        public string GetRoomBadgeClass(string st)
        {
            if (st == "Đang hoạt động") return "st-green";
            if (st == "Chờ duyệt") return "st-yellow";
            if (st == "Bị từ chối" || st == "Đã hủy") return "st-red";
            return "st-gray";
        }
    }
}