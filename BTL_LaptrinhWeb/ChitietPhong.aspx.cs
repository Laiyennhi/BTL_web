using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI.HtmlControls;

namespace BTL_Web
{
    public partial class ChitietPhong : System.Web.UI.Page
    {
        string strCon = ConfigurationManager.ConnectionStrings["DefaultConnection"]?.ConnectionString
                        ?? @"Data Source=.;Initial Catalog=Home_Sharing;Integrated Security=True;TrustServerCertificate=True";

        protected void Page_Load(object sender, EventArgs e)
        {
            // Ép tắt popup kiểm tra phòng ở mọi lần PostBack
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

                        string hostName = rd["HostName"] != DBNull.Value ? rd["HostName"].ToString() : "Đỗ Đức Minh";
                        string hostPhone = rd["HostPhone"] != DBNull.Value ? rd["HostPhone"].ToString() : "089459717";
                        string hostEmail = rd["HostEmail"] != DBNull.Value ? rd["HostEmail"].ToString() : "minh@gmail.com";
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
                }
                catch { }
            }
        }

        // Kiểm tra tình trạng phòng trống theo khoảng ngày chọn (Desktop - 4)
        protected void btnKiemTraPhong_Click(object sender, EventArgs e)
        {
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

            int roomId = 1;
            if (ViewState["RoomID"] != null)
                roomId = Convert.ToInt32(ViewState["RoomID"]);
            else if (Request.QueryString["id"] != null)
                int.TryParse(Request.QueryString["id"], out roomId);

            try
            {
                using (SqlConnection conn = new SqlConnection(strCon))
                {
                    // Kiểm tra trùng lịch trong bảng Bookings
                    string query = @"
                SELECT COUNT(*) FROM Bookings 
                WHERE RoomID = @RoomID 
                  AND Status IN ('Pending', 'Confirmed')
                  AND (@CheckIn < CheckOutDate AND @CheckOut > CheckInDate)";

                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@RoomID", roomId);
                    cmd.Parameters.AddWithValue("@CheckIn", checkIn.Date);
                    cmd.Parameters.AddWithValue("@CheckOut", checkOut.Date);

                    conn.Open();
                    int overlap = Convert.ToInt32(cmd.ExecuteScalar());

                    if (overlap > 0)
                    {
                        lblStatusResult.Text = "Rất tiếc! Phòng đã có khách đặt trong khoảng thời gian này.";
                    }
                    else
                    {
                        lblStatusResult.Text = "Phòng hiện đang TRỐNG trong khoảng ngày bạn chọn. Bạn có thể đặt ngay!";
                    }
                }
            }
            catch (Exception ex)
            {
                // Hiển thị chi tiết nếu tên cột ngày trong SQL Server khác với CheckInDate / CheckOutDate
                lblStatusResult.Text = "Lỗi kiểm tra dữ liệu: " + ex.Message;
            }

            modalCheckStatus.Attributes["class"] = "modal-overlay active";
        }

        // Chuyển sang giao diện thanh toán mã QR (Desktop - 6)
        protected void btnChonQR_Click(object sender, EventArgs e)
        {
            // Đảm bảo tắt hẳn popup kiểm tra phòng
            modalCheckStatus.Attributes["class"] = "modal-overlay";

            decimal total = TinhTongTienServer();
            int roomId = Convert.ToInt32(ViewState["RoomID"]);
            DateTime checkIn = DateTime.Parse(txtCheckIn.Text);

            lblQRTongTien.Text = total.ToString("N0") + " đ";
            lblQRNoiDung.Text = $"HG0{roomId} - {checkIn:dd/MM/yy}";

            pnlBookingForm.Visible = false;
            pnlDirectPayment.Visible = false;
            pnlPendingConfirm.Visible = false;
            pnlQRPayment.Visible = true;
        }

        // Chuyển sang giao diện thanh toán trực tiếp (Desktop - 8)
        protected void btnChonDirect_Click(object sender, EventArgs e)
        {
            decimal total = TinhTongTienServer();
            lblDirectTongTien.Text = total.ToString("N0") + " đ";

            pnlBookingForm.Visible = false;
            pnlQRPayment.Visible = false;
            pnlPendingConfirm.Visible = false;
            pnlDirectPayment.Visible = true;
        }

        // Nút X đóng bảng thanh toán quay lại form đặt phòng
        protected void btnQuayLaiForm_Click(object sender, EventArgs e)
        {
            pnlQRPayment.Visible = false;
            pnlDirectPayment.Visible = false;
            pnlPendingConfirm.Visible = false;
            pnlBookingForm.Visible = true;
        }

        // Hoàn tất đặt phòng qua QR (Desktop - 7)
        protected void btnXacNhanQR_Click(object sender, EventArgs e)
        {
            LuuDonDatPhong("QR");
            lblPendingMessage.Text = "Shop đang kiểm tra giao dịch của bạn. Vui lòng chờ xác nhận thanh toán";
            pnlQRPayment.Visible = false;
            pnlPendingConfirm.Visible = true;
        }

        // Hoàn tất đặt phòng thanh toán trực tiếp (Desktop - 10)
        protected void btnGuiYeuCauDirect_Click(object sender, EventArgs e)
        {
            LuuDonDatPhong("Direct");
            lblPendingMessage.Text = "Shop đang kiểm tra đơn đặt hàng. Vui lòng chờ shop xác nhận";
            pnlDirectPayment.Visible = false;
            pnlPendingConfirm.Visible = true;
        }

        private decimal TinhTongTienServer()
        {
            decimal unitPrice = decimal.Parse(hfUnitPrice.Value);
            DateTime d1 = DateTime.Parse(txtCheckIn.Text);
            DateTime d2 = DateTime.Parse(txtCheckOut.Text);
            int nights = (d2 - d1).Days;
            return nights > 0 ? unitPrice * nights : 0;
        }

        private void LuuDonDatPhong(string paymentMethod)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            DateTime checkIn, checkOut;
            if (!DateTime.TryParse(txtCheckIn.Text, out checkIn) || !DateTime.TryParse(txtCheckOut.Text, out checkOut)
                || checkIn.Date < DateTime.Today || checkOut.Date <= checkIn.Date)
            {
                lblStatusResult.Text = "Ngày đặt phòng không hợp lệ hoặc đã ở trong quá khứ!";
                modalCheckStatus.Attributes["class"] = "modal-overlay active";
                return;
            }

            // ... (Phần lệnh INSERT INTO Bookings giữ nguyên)
        }

        protected void btnHeartDetail_Click(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
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