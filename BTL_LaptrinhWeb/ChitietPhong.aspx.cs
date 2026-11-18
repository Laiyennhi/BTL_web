using System;
using System.Configuration;
using System.Data.SqlClient;

namespace BTL_Web
{
    public partial class ChitietPhong : System.Web.UI.Page
    {
        string strCon = ConfigurationManager.ConnectionStrings["DefaultConnection"]?.ConnectionString
                        ?? @"Data Source=.;Initial Catalog=Home_Sharing;Integrated Security=True;TrustServerCertificate=True";

        protected void Page_Load(object sender, EventArgs e)
        {
            modalCheckStatus.Attributes["class"] = "modal-overlay";
            lblStatusResult.Text = "";

            if (!IsPostBack)
            {
                int roomId = 1;
                if (Request.QueryString["id"] != null)
                {
                    int.TryParse(Request.QueryString["id"], out roomId);
                }
                ViewState["RoomID"] = roomId;
                LoadChiTietPhong(roomId);
            }
        }

        private void LoadChiTietPhong(int roomId)
        {
            int userId = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 0;

            using (SqlConnection conn = new SqlConnection(strCon))
            {
                string query = @"
                    SELECT r.*, u.FullName AS HostName, u.Phone AS HostPhone, u.Email AS HostEmail,
                           CASE WHEN f.FavoriteID IS NOT NULL THEN 1 ELSE 0 END AS IsLiked
                    FROM Rooms r
                    LEFT JOIN Users u ON r.HostID = u.UserID
                    LEFT JOIN Favorites f ON r.RoomID = f.RoomID AND f.UserID = @UserID
                    WHERE r.RoomID = @RoomID";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@RoomID", roomId);
                cmd.Parameters.AddWithValue("@UserID", userId);

                try
                {
                    conn.Open();
                    SqlDataReader rd = cmd.ExecuteReader();
                    if (rd.Read())
                    {
                        string code = "HG0" + roomId;
                        lblDistrictTop.Text = rd["District"].ToString();
                        lblCodeTop.Text = code;
                        lblCodeTag.Text = code;
                        lblTitle.Text = rd["Title"].ToString();
                        lblSpecs.Text = rd["RoomSpecs"] != DBNull.Value ? rd["RoomSpecs"].ToString() : "1 Phòng Khách - 2 Phòng Ngủ - 1 Phòng Bếp";
                        lblDescription.Text = rd["Description"] != DBNull.Value ? rd["Description"].ToString() : "Phòng đẹp, sạch sẽ, thoáng mát tại trung tâm Hà Nội.";
                        lblFullAddress.Text = rd["Address"].ToString();

                        decimal price = Convert.ToDecimal(rd["PricePerNight"]);
                        lblPricePerNight.Text = price.ToString("N0");
                        hfUnitPrice.Value = price.ToString("0");

                        string hostName = rd["HostName"] != DBNull.Value ? rd["HostName"].ToString() : "Chủ Nhà";
                        string hostPhone = rd["HostPhone"] != DBNull.Value ? rd["HostPhone"].ToString() : "0774397225";
                        string hostEmail = rd["HostEmail"] != DBNull.Value ? rd["HostEmail"].ToString() : "host@gmail.com";
                        lblHostName.Text = hostName;
                        lblHostContact.Text = $"{hostPhone} / {hostEmail}";

                        string mainUrl = rd["ImageUrl"].ToString();
                        imgMain.ImageUrl = mainUrl;
                        imgSub1.ImageUrl = "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&w=500&q=80";
                        imgSub2.ImageUrl = "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=500&q=80";
                        imgSub3.ImageUrl = "https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=500&q=80";
                        imgSub4.ImageUrl = "https://images.unsplash.com/photo-1484154218962-a197022b5858?auto=format&fit=crop&w=500&q=80";

                        if (Convert.ToInt32(rd["IsLiked"]) == 1)
                        {
                            svgHeart.Attributes["fill"] = "#F8B8BE";
                            svgHeart.Attributes["stroke"] = "#E57373";
                        }
                    }
                    rd.Close();

                    // Cập nhật huy hiệu trạng thái thực tế của phòng
                    CapNhatHuyHieuTrangThaiPhong(conn, roomId);
                }
                catch { }
            }
        }

        // Hiển thị chính xác trạng thái phòng (Đã có lịch đặt hôm nay / Sắp có lịch / Đang trống)
        private void CapNhatHuyHieuTrangThaiPhong(SqlConnection conn, int roomId)
        {
            // Kiểm tra xem hôm nay phòng có đang có khách ở/đặt không
            string sqlToday = @"
                SELECT TOP 1 CheckInDate, CheckOutDate 
                FROM Bookings 
                WHERE RoomID = @RoomID 
                  AND Status IN ('Pending', 'Unpaid', 'Confirmed')
                  AND CAST(GETDATE() AS DATE) >= CheckInDate 
                  AND CAST(GETDATE() AS DATE) < CheckOutDate";
            SqlCommand cmdToday = new SqlCommand(sqlToday, conn);
            cmdToday.Parameters.AddWithValue("@RoomID", roomId);

            using (SqlDataReader rd = cmdToday.ExecuteReader())
            {
                if (rd.Read())
                {
                    DateTime outDate = Convert.ToDateTime(rd["CheckOutDate"]);
                    lblRoomStatusBadge.Text = $"🔴 Đã được đặt (đến {outDate:dd/MM})";
                    lblRoomStatusBadge.Style["background-color"] = "#fdecea";
                    lblRoomStatusBadge.Style["color"] = "#c80000";
                    return;
                }
            }

            // Kiểm tra xem sắp tới có lịch đặt nào chưa
            string sqlUpcoming = @"
                SELECT TOP 1 CheckInDate, CheckOutDate 
                FROM Bookings 
                WHERE RoomID = @RoomID 
                  AND Status IN ('Pending', 'Unpaid', 'Confirmed')
                  AND CheckInDate > CAST(GETDATE() AS DATE)
                ORDER BY CheckInDate ASC";
            SqlCommand cmdUp = new SqlCommand(sqlUpcoming, conn);
            cmdUp.Parameters.AddWithValue("@RoomID", roomId);

            using (SqlDataReader rdUp = cmdUp.ExecuteReader())
            {
                if (rdUp.Read())
                {
                    DateTime inDate = Convert.ToDateTime(rdUp["CheckInDate"]);
                    DateTime outDate = Convert.ToDateTime(rdUp["CheckOutDate"]);
                    lblRoomStatusBadge.Text = $"🟡 Trống hôm nay (Đã đặt {inDate:dd/MM} - {outDate:dd/MM})";
                    lblRoomStatusBadge.Style["background-color"] = "#fff8e1";
                    lblRoomStatusBadge.Style["color"] = "#b26a00";
                    return;
                }
            }

            lblRoomStatusBadge.Text = "🟢 Đang trống";
            lblRoomStatusBadge.Style["background-color"] = "#e8f5e9";
            lblRoomStatusBadge.Style["color"] = "#1e7e34";
        }

        // Hàm kiểm tra trùng lịch dùng chung cho cả nút Kiểm tra và nút Đặt phòng
        private bool KiemTraPhongTrongTheoNgay(int roomId, DateTime checkIn, DateTime checkOut, out string conflictInfo)
        {
            conflictInfo = "";
            using (SqlConnection conn = new SqlConnection(strCon))
            {
                string query = @"
                    SELECT TOP 1 CheckInDate, CheckOutDate 
                    FROM Bookings 
                    WHERE RoomID = @RoomID 
                      AND Status IN ('Pending', 'Unpaid', 'Confirmed')
                      AND (@CheckIn < CheckOutDate AND @CheckOut > CheckInDate)";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@RoomID", roomId);
                cmd.Parameters.AddWithValue("@CheckIn", checkIn.Date);
                cmd.Parameters.AddWithValue("@CheckOut", checkOut.Date);

                conn.Open();
                using (SqlDataReader rd = cmd.ExecuteReader())
                {
                    if (rd.Read())
                    {
                        DateTime cIn = Convert.ToDateTime(rd["CheckInDate"]);
                        DateTime cOut = Convert.ToDateTime(rd["CheckOutDate"]);
                        conflictInfo = $"Rất tiếc! Phòng đã có khách đặt từ ngày {cIn:dd/MM/yyyy} đến {cOut:dd/MM/yyyy}. Vui lòng chọn ngày khác!";
                        return false;
                    }
                }
            }
            return true;
        }

        // Kiểm tra tình trạng phòng
        protected void btnKiemTraPhong_Click(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Profile.aspx");
                return;
            }

            DateTime checkIn, checkOut;
            if (!DateTime.TryParse(txtCheckIn.Text, out checkIn) || !DateTime.TryParse(txtCheckOut.Text, out checkOut))
            {
                lblStatusResult.Text = "Vui lòng chọn đầy đủ ngày Nhận phòng và Trả phòng!";
                modalCheckStatus.Attributes["class"] = "modal-overlay active";
                return;
            }

            if (checkIn.Date < DateTime.Today || checkOut.Date < DateTime.Today)
            {
                lblStatusResult.Text = "Không thể đặt ngày đã qua! Vui lòng chọn từ hôm nay (" + DateTime.Today.ToString("dd/MM/yyyy") + ") trở đi.";
                modalCheckStatus.Attributes["class"] = "modal-overlay active";
                return;
            }

            if (checkOut.Date <= checkIn.Date)
            {
                lblStatusResult.Text = "Ngày Trả phòng phải sau ngày Nhận phòng ít nhất 1 đêm!";
                modalCheckStatus.Attributes["class"] = "modal-overlay active";
                return;
            }

            int roomId = Convert.ToInt32(ViewState["RoomID"] ?? "1");

            try
            {
                string conflictMsg;
                if (!KiemTraPhongTrongTheoNgay(roomId, checkIn, checkOut, out conflictMsg))
                {
                    lblStatusResult.Text = conflictMsg;
                }
                else
                {
                    lblStatusResult.Text = "Phòng hiện đang TRỐNG trong khoảng ngày bạn chọn. Bạn có thể đặt ngay!";
                }
            }
            catch (Exception ex)
            {
                lblStatusResult.Text = "Lỗi kiểm tra dữ liệu: " + ex.Message;
            }

            modalCheckStatus.Attributes["class"] = "modal-overlay active";
        }

        // Chuyển sang giao diện thanh toán mã QR (có kiểm tra trống trước khi mở QR)
        protected void btnChonQR_Click(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Profile.aspx");
                return;
            }

            int roomId = Convert.ToInt32(ViewState["RoomID"]);
            DateTime checkIn = DateTime.Parse(txtCheckIn.Text);
            DateTime checkOut = DateTime.Parse(txtCheckOut.Text);

            string conflictMsg;
            if (!KiemTraPhongTrongTheoNgay(roomId, checkIn, checkOut, out conflictMsg))
            {
                lblStatusResult.Text = conflictMsg;
                modalCheckStatus.Attributes["class"] = "modal-overlay active";
                return;
            }

            decimal total = TinhTongTienServer();
            lblQRTongTien.Text = total.ToString("N0") + " đ";
            lblQRNoiDung.Text = $"HG0{roomId} - {checkIn:dd/MM/yy}";

            pnlBookingForm.Visible = false;
            pnlDirectPayment.Visible = false;
            pnlPendingConfirm.Visible = false;
            pnlQRPayment.Visible = true;
        }

        // Chuyển sang giao diện thanh toán trực tiếp (có kiểm tra trống trước khi mở)
        protected void btnChonDirect_Click(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Profile.aspx");
                return;
            }

            int roomId = Convert.ToInt32(ViewState["RoomID"]);
            DateTime checkIn = DateTime.Parse(txtCheckIn.Text);
            DateTime checkOut = DateTime.Parse(txtCheckOut.Text);

            string conflictMsg;
            if (!KiemTraPhongTrongTheoNgay(roomId, checkIn, checkOut, out conflictMsg))
            {
                lblStatusResult.Text = conflictMsg;
                modalCheckStatus.Attributes["class"] = "modal-overlay active";
                return;
            }

            decimal total = TinhTongTienServer();
            lblDirectTongTien.Text = total.ToString("N0") + " đ";

            pnlBookingForm.Visible = false;
            pnlQRPayment.Visible = false;
            pnlPendingConfirm.Visible = false;
            pnlDirectPayment.Visible = true;
        }

        protected void btnQuayLaiForm_Click(object sender, EventArgs e)
        {
            pnlQRPayment.Visible = false;
            pnlDirectPayment.Visible = false;
            pnlPendingConfirm.Visible = false;
            pnlBookingForm.Visible = true;
        }

        // Hoàn tất đặt phòng qua QR
        protected void btnXacNhanQR_Click(object sender, EventArgs e)
        {
            if (Session["UserID"] == null) { Response.Redirect("Profile.aspx"); return; }

            if (LuuDonDatPhong("QR", "Unpaid"))
            {
                lblPendingMessage.Text = "Shop đang kiểm tra giao dịch của bạn. Vui lòng chờ xác nhận thanh toán";
                pnlQRPayment.Visible = false;
                pnlPendingConfirm.Visible = true;
            }
        }

        // Hoàn tất đặt phòng thanh toán trực tiếp
        protected void btnGuiYeuCauDirect_Click(object sender, EventArgs e)
        {
            if (Session["UserID"] == null) { Response.Redirect("Profile.aspx"); return; }

            if (LuuDonDatPhong("Trực tiếp", "Pending"))
            {
                lblPendingMessage.Text = "Shop đang kiểm tra đơn đặt hàng. Vui lòng chờ shop xác nhận";
                pnlDirectPayment.Visible = false;
                pnlPendingConfirm.Visible = true;
            }
        }

        private decimal TinhTongTienServer()
        {
            decimal unitPrice = decimal.Parse(hfUnitPrice.Value);
            DateTime d1 = DateTime.Parse(txtCheckIn.Text);
            DateTime d2 = DateTime.Parse(txtCheckOut.Text);
            int nights = (d2 - d1).Days;
            return nights > 0 ? unitPrice * nights : 0;
        }

        private bool LuuDonDatPhong(string paymentMethod, string bookingStatus)
        {
            int guestId = Convert.ToInt32(Session["UserID"]);
            int roomId = Convert.ToInt32(ViewState["RoomID"]);

            DateTime checkIn, checkOut;
            if (!DateTime.TryParse(txtCheckIn.Text, out checkIn) || !DateTime.TryParse(txtCheckOut.Text, out checkOut)
                || checkIn.Date < DateTime.Today || checkOut.Date <= checkIn.Date)
            {
                lblStatusResult.Text = "Ngày đặt phòng không hợp lệ hoặc đã ở trong quá khứ!";
                modalCheckStatus.Attributes["class"] = "modal-overlay active";
                return false;
            }

            // Kiểm tra lần cuối ngay trước khi INSERT để chống đặt trùng
            string conflictMsg;
            if (!KiemTraPhongTrongTheoNgay(roomId, checkIn, checkOut, out conflictMsg))
            {
                lblStatusResult.Text = conflictMsg;
                modalCheckStatus.Attributes["class"] = "modal-overlay active";
                btnQuayLaiForm_Click(null, null);
                return false;
            }

            decimal totalPrice = TinhTongTienServer();

            using (SqlConnection conn = new SqlConnection(strCon))
            {
                conn.Open();

                // 1. Lưu đơn vào bảng Bookings
                string sql = @"INSERT INTO Bookings (RoomID, GuestID, CheckInDate, CheckOutDate, TotalPrice, Status, PaymentMethod, CreatedAt)
                               VALUES (@RoomID, @GuestID, @CheckIn, @CheckOut, @Total, @Status, @PayMethod, GETDATE())";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@RoomID", roomId);
                cmd.Parameters.AddWithValue("@GuestID", guestId);
                cmd.Parameters.AddWithValue("@CheckIn", checkIn.Date);
                cmd.Parameters.AddWithValue("@CheckOut", checkOut.Date);
                cmd.Parameters.AddWithValue("@Total", totalPrice);
                cmd.Parameters.AddWithValue("@Status", bookingStatus);
                cmd.Parameters.AddWithValue("@PayMethod", paymentMethod);
                cmd.ExecuteNonQuery();

                // 2. Đồng bộ trạng thái phòng trong bảng Rooms nếu ngày đặt bao gồm hôm nay
                if (DateTime.Today >= checkIn.Date && DateTime.Today < checkOut.Date)
                {
                    SqlCommand cmdRoom = new SqlCommand("UPDATE Rooms SET Status = 'Booked' WHERE RoomID = @RoomID", conn);
                    cmdRoom.Parameters.AddWithValue("@RoomID", roomId);
                    cmdRoom.ExecuteNonQuery();
                }

                // 3. Cập nhật ngay nhãn trạng thái phòng trên giao diện
                CapNhatHuyHieuTrangThaiPhong(conn, roomId);
            }

            return true;
        }

        // Thả tim / Bỏ tim
        protected void btnHeartDetail_Click(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Profile.aspx");
                return;
            }

            int userId = Convert.ToInt32(Session["UserID"]);
            int roomId = Convert.ToInt32(ViewState["RoomID"]);

            using (SqlConnection conn = new SqlConnection(strCon))
            {
                conn.Open();
                SqlCommand cmdCheck = new SqlCommand("SELECT COUNT(*) FROM Favorites WHERE UserID=@U AND RoomID=@R", conn);
                cmdCheck.Parameters.AddWithValue("@U", userId);
                cmdCheck.Parameters.AddWithValue("@R", roomId);

                if ((int)cmdCheck.ExecuteScalar() > 0)
                {
                    SqlCommand cmdDel = new SqlCommand("DELETE FROM Favorites WHERE UserID=@U AND RoomID=@R", conn);
                    cmdDel.Parameters.AddWithValue("@U", userId);
                    cmdDel.Parameters.AddWithValue("@R", roomId);
                    cmdDel.ExecuteNonQuery();
                    svgHeart.Attributes["fill"] = "none";
                    svgHeart.Attributes["stroke"] = "#333333";
                }
                else
                {
                    SqlCommand cmdIns = new SqlCommand("INSERT INTO Favorites (UserID, RoomID) VALUES (@U, @R)", conn);
                    cmdIns.Parameters.AddWithValue("@U", userId);
                    cmdIns.Parameters.AddWithValue("@R", roomId);
                    cmdIns.ExecuteNonQuery();
                    svgHeart.Attributes["fill"] = "#F8B8BE";
                    svgHeart.Attributes["stroke"] = "#E57373";
                }
            }
        }
    }
}