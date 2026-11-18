using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI.WebControls;

namespace BTL_Web
{
    public partial class HostDashboard : System.Web.UI.Page
    {
        string strCon = ConfigurationManager.ConnectionStrings["DefaultConnection"]?.ConnectionString
                        ?? @"Data Source=.;Initial Catalog=Home_Sharing;Integrated Security=True;TrustServerCertificate=True";

        public string CurrentTab => Request.QueryString["tab"] ?? "bookings";
        public string CurrentFilter => Request.QueryString["filter"] ?? "all";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Profile.aspx");
                return;
            }

            // Nếu tài khoản đang là Guest -> Tự động chuyển thẳng sang Role 'Host' (bỏ qua bước đăng ký trung gian)
            string role = Session["Role"]?.ToString() ?? "Guest";
            if (role == "Guest")
            {
                int userId = Convert.ToInt32(Session["UserID"]);
                using (SqlConnection conn = new SqlConnection(strCon))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand("UPDATE Users SET Role = 'Host' WHERE UserID = @ID", conn);
                    cmd.Parameters.AddWithValue("@ID", userId);
                    cmd.ExecuteNonQuery();
                }
                Session["Role"] = "Host";
                role = "Host";
            }

            if (!IsPostBack)
            {
                RouteTab();
            }
        }

        private void RouteTab()
        {
            pnlBookings.Visible = false;
            pnlMyRooms.Visible = false;
            pnlRoomForm.Visible = false;
            pnlHostAccount.Visible = false;

            switch (CurrentTab)
            {
                case "rooms":
                    pnlMyRooms.Visible = true;
                    LoadMyRooms();
                    break;
                case "addroom":
                    pnlRoomForm.Visible = true;
                    lblFormHeading.Text = "Thêm phòng mới";
                    break;
                case "editroom":
                    pnlRoomForm.Visible = true;
                    lblFormHeading.Text = "Sửa Phòng";
                    LoadRoomForEdit();
                    break;
                case "account":
                    pnlHostAccount.Visible = true;
                    LoadHostAccount();
                    break;
                default:
                    pnlBookings.Visible = true;
                    LoadHostBookings();
                    break;
            }
        }

        // 1. TẢI ĐƠN ĐẶT PHÒNG CỦA CHỦ PHÒNG
        private void LoadHostBookings()
        {
            int hostId = Convert.ToInt32(Session["UserID"]);
            using (SqlConnection conn = new SqlConnection(strCon))
            {
                conn.Open();

                SqlCommand cmdTotal = new SqlCommand("SELECT COUNT(*) FROM Bookings b JOIN Rooms r ON b.RoomID = r.RoomID WHERE r.HostID = @HostID", conn);
                cmdTotal.Parameters.AddWithValue("@HostID", hostId);
                lblTotalOrders.Text = cmdTotal.ExecuteScalar().ToString();

                SqlCommand cmdPending = new SqlCommand("SELECT COUNT(*) FROM Bookings b JOIN Rooms r ON b.RoomID = r.RoomID WHERE r.HostID = @HostID AND b.Status IN ('Pending','Unpaid')", conn);
                cmdPending.Parameters.AddWithValue("@HostID", hostId);
                lblPendingOrders.Text = cmdPending.ExecuteScalar().ToString();

                SqlCommand cmdRev = new SqlCommand("SELECT ISNULL(SUM(b.TotalPrice), 0) FROM Bookings b JOIN Rooms r ON b.RoomID = r.RoomID WHERE r.HostID = @HostID AND b.Status IN ('Confirmed','Completed')", conn);
                cmdRev.Parameters.AddWithValue("@HostID", hostId);
                lblTotalRevenue.Text = string.Format("{0:N0} đ", cmdRev.ExecuteScalar());

                string sql = @"SELECT b.BookingID, u.FullName AS GuestName, b.RoomID, b.CheckInDate, b.CheckOutDate,
                               ISNULL(b.PaymentMethod, 'QR') AS PaymentMethod, b.TotalPrice, b.Status
                               FROM Bookings b
                               JOIN Rooms r ON b.RoomID = r.RoomID
                               LEFT JOIN Users u ON b.GuestID = u.UserID
                               WHERE r.HostID = @HostID";
                if (CurrentFilter != "all") sql += " AND b.Status = @Status";

                SqlCommand cmd = new SqlCommand(sql + " ORDER BY b.BookingID DESC", conn);
                cmd.Parameters.AddWithValue("@HostID", hostId);
                if (CurrentFilter != "all") cmd.Parameters.AddWithValue("@Status", CurrentFilter);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                rptHostBookings.DataSource = dt;
                rptHostBookings.DataBind();
            }
        }

        protected void rptHostBookings_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int bookingId = Convert.ToInt32(e.CommandArgument);
            string newStatus = "";
            if (e.CommandName == "ConfirmOrder") newStatus = "Confirmed";
            else if (e.CommandName == "RejectOrder") newStatus = "Cancelled";
            else if (e.CommandName == "CompleteOrder") newStatus = "Completed";

            if (!string.IsNullOrEmpty(newStatus))
            {
                using (SqlConnection conn = new SqlConnection(strCon))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand("UPDATE Bookings SET Status = @St WHERE BookingID = @ID", conn);
                    cmd.Parameters.AddWithValue("@St", newStatus);
                    cmd.Parameters.AddWithValue("@ID", bookingId);
                    cmd.ExecuteNonQuery();

                    // Đồng bộ lại trạng thái phòng trong bảng Rooms dựa trên các đơn đặt hiện hành
                    string syncRoomSql = @"
                        UPDATE Rooms 
                        SET Status = CASE 
                            WHEN EXISTS (
                                SELECT 1 FROM Bookings 
                                WHERE RoomID = Rooms.RoomID 
                                  AND Status IN ('Pending', 'Unpaid', 'Confirmed')
                                  AND CAST(GETDATE() AS DATE) >= CheckInDate 
                                  AND CAST(GETDATE() AS DATE) < CheckOutDate
                            ) THEN 'Booked'
                            ELSE 'Available'
                        END
                        WHERE RoomID = (SELECT RoomID FROM Bookings WHERE BookingID = @ID)";
                    SqlCommand cmdSync = new SqlCommand(syncRoomSql, conn);
                    cmdSync.Parameters.AddWithValue("@ID", bookingId);
                    cmdSync.ExecuteNonQuery();
                }
                lblThongBao.ForeColor = System.Drawing.Color.Green;
                lblThongBao.Text = "✓ Đã cập nhật trạng thái đơn #" + bookingId;
                LoadHostBookings();
            }
        }

        // 2. TẢI PHÒNG CỦA TÔI
        private void LoadMyRooms()
        {
            int hostId = Convert.ToInt32(Session["UserID"]);
            using (SqlConnection conn = new SqlConnection(strCon))
            {
                string sql = "SELECT RoomID, Title, Address, PricePerNight, ImageUrl, ISNULL(ApprovalStatus, N'Chờ duyệt') AS ApprovalStatus FROM Rooms WHERE HostID = @HostID ORDER BY RoomID DESC";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@HostID", hostId);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                rptMyRooms.DataSource = dt;
                rptMyRooms.DataBind();
            }
        }

        // 3. TẢI THÔNG TIN PHÒNG KHI SỬA (Nạp cả 4 ảnh chi tiết vào 4 ô riêng)
        private void LoadRoomForEdit()
        {
            int roomId = Convert.ToInt32(Request.QueryString["id"] ?? "0");
            using (SqlConnection conn = new SqlConnection(strCon))
            {
                SqlCommand cmd = new SqlCommand("SELECT * FROM Rooms WHERE RoomID = @ID", conn);
                cmd.Parameters.AddWithValue("@ID", roomId);
                conn.Open();
                SqlDataReader rd = cmd.ExecuteReader();
                if (rd.Read())
                {
                    txtRoomTitle.Text = rd["Title"].ToString();
                    txtRoomPrice.Text = Convert.ToInt64(rd["PricePerNight"]).ToString("N0").Replace(",", ".");
                    txtRoomAddress.Text = rd["Address"].ToString();
                    txtRoomDesc.Text = rd["Description"].ToString();
                    txtCoverImg.Text = rd["ImageUrl"] != DBNull.Value ? rd["ImageUrl"].ToString() : "";

                    if (rd["SubImages"] != DBNull.Value && !string.IsNullOrWhiteSpace(rd["SubImages"].ToString()))
                    {
                        string[] subs = rd["SubImages"].ToString().Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                        if (subs.Length > 0) txtSub1.Text = subs[0].Trim();
                        if (subs.Length > 1) txtSub2.Text = subs[1].Trim();
                        if (subs.Length > 2) txtSub3.Text = subs[2].Trim();
                        if (subs.Length > 3) txtSub4.Text = subs[3].Trim();
                    }

                    if (ddlDistrict.Items.FindByValue(rd["District"].ToString()) != null)
                        ddlDistrict.SelectedValue = rd["District"].ToString();

                    string amen = rd["Amenities"] != DBNull.Value ? rd["Amenities"].ToString() : "";
                    chkDieuHoa.Checked = amen.Contains("Điều hòa");
                    chkTivi.Checked = amen.Contains("Tivi");
                    chkChoDeXe.Checked = amen.Contains("Chỗ để xe");
                    chkMayGiat.Checked = amen.Contains("Máy giặt");
                    chkWifi.Checked = amen.Contains("Wifi");
                    chkBanCong.Checked = amen.Contains("Ban công");
                }
            }
        }

        // Hàm xử lý lưu file từ máy hoặc lấy link URL cho từng ô ảnh
        private string XuLyMotAnh(FileUpload fu, TextBox txtUrl, string folderPath, string prefix, string defaultImg)
        {
            if (fu.HasFile)
            {
                string ext = Path.GetExtension(fu.FileName);
                string fileName = prefix + "_" + DateTime.Now.Ticks + ext;
                fu.SaveAs(Path.Combine(folderPath, fileName));
                return "images/" + fileName;
            }
            if (!string.IsNullOrWhiteSpace(txtUrl.Text))
            {
                return txtUrl.Text.Trim();
            }
            return defaultImg;
        }

        // LƯU PHÒNG MỚI HOẶC CẬP NHẬT SỬA PHÒNG
        protected void btnSaveRoom_Click(object sender, EventArgs e)
        {
            int hostId = Convert.ToInt32(Session["UserID"]);

            string rawPrice = txtRoomPrice.Text.Replace(".", "").Replace(",", "").Trim();
            if (!decimal.TryParse(rawPrice, out decimal pricePerNight) || pricePerNight <= 0)
            {
                lblThongBao.ForeColor = System.Drawing.Color.Red;
                lblThongBao.Text = "⚠️ Vui lòng nhập giá phòng hợp lệ bằng số (lớn hơn 0)!";
                return;
            }

            string folderPath = Server.MapPath("~/images/");
            if (!Directory.Exists(folderPath))
            {
                Directory.CreateDirectory(folderPath);
            }

            // 1. Ảnh bìa
            string img = XuLyMotAnh(fuCoverImg, txtCoverImg, folderPath, "cover",
                "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800");

            // 2. Gom tối đa 4 ảnh chi tiết từ 4 ô riêng biệt
            List<string> subImgList = new List<string>();
            string s1 = XuLyMotAnh(fuSub1, txtSub1, folderPath, "sub1", "");
            string s2 = XuLyMotAnh(fuSub2, txtSub2, folderPath, "sub2", "");
            string s3 = XuLyMotAnh(fuSub3, txtSub3, folderPath, "sub3", "");
            string s4 = XuLyMotAnh(fuSub4, txtSub4, folderPath, "sub4", "");

            if (!string.IsNullOrEmpty(s1)) subImgList.Add(s1);
            if (!string.IsNullOrEmpty(s2)) subImgList.Add(s2);
            if (!string.IsNullOrEmpty(s3)) subImgList.Add(s3);
            if (!string.IsNullOrEmpty(s4)) subImgList.Add(s4);

            string subImagesStr = subImgList.Count > 0 ? string.Join(",", subImgList) : null;

            List<string> amenList = new List<string>();
            if (chkDieuHoa.Checked) amenList.Add("Điều hòa");
            if (chkTivi.Checked) amenList.Add("Tivi");
            if (chkChoDeXe.Checked) amenList.Add("Chỗ để xe");
            if (chkMayGiat.Checked) amenList.Add("Máy giặt");
            if (chkWifi.Checked) amenList.Add("Wifi");
            if (chkBanCong.Checked) amenList.Add("Ban công");
            string amenitiesStr = string.Join(", ", amenList);

            using (SqlConnection conn = new SqlConnection(strCon))
            {
                conn.Open();
                SqlCommand cmd;
                if (CurrentTab == "editroom")
                {
                    int roomId = Convert.ToInt32(Request.QueryString["id"] ?? "0");
                    cmd = new SqlCommand(@"UPDATE Rooms SET Title=@Title, District=@District, Address=@Address, PricePerNight=@Price, 
                                           Description=@Desc, ImageUrl=@Img, SubImages=@SubImgs, Amenities=@Amen 
                                           WHERE RoomID=@ID AND HostID=@HostID", conn);
                    cmd.Parameters.AddWithValue("@ID", roomId);
                }
                else
                {
                    cmd = new SqlCommand(@"INSERT INTO Rooms (HostID, CategoryID, Title, Description, Address, District, PricePerNight, MaxGuests, ImageUrl, SubImages, IsAvailable, ApprovalStatus, Amenities)
                                           VALUES (@HostID, 1, @Title, @Desc, @Address, @District, @Price, 2, @Img, @SubImgs, 0, N'Chờ duyệt', @Amen)", conn);
                }

                cmd.Parameters.AddWithValue("@HostID", hostId);
                cmd.Parameters.AddWithValue("@Title", txtRoomTitle.Text.Trim());
                cmd.Parameters.AddWithValue("@District", ddlDistrict.SelectedValue);
                cmd.Parameters.AddWithValue("@Address", txtRoomAddress.Text.Trim());
                cmd.Parameters.AddWithValue("@Price", pricePerNight);
                cmd.Parameters.AddWithValue("@Desc", txtRoomDesc.Text.Trim());
                cmd.Parameters.AddWithValue("@Img", img);
                cmd.Parameters.AddWithValue("@SubImgs", (object)subImagesStr ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Amen", amenitiesStr);
                cmd.ExecuteNonQuery();
            }

            Response.Redirect("HostDashboard.aspx?tab=rooms");
        }

        // XỬ LÝ MODAL TẮT / BẬT / XÓA PHÒNG
        protected void btnConfirmRoomAction_Click(object sender, EventArgs e)
        {
            string action = hfRoomAction.Value;
            int roomId = Convert.ToInt32(hfRoomTargetId.Value);

            using (SqlConnection conn = new SqlConnection(strCon))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand("", conn);
                if (action == "DisableRoom")
                    cmd.CommandText = "UPDATE Rooms SET ApprovalStatus = N'Đã tắt', IsAvailable = 0 WHERE RoomID = @ID";
                else if (action == "EnableRoom")
                    cmd.CommandText = "UPDATE Rooms SET ApprovalStatus = N'Đang hoạt động', IsAvailable = 1 WHERE RoomID = @ID";
                else if (action == "DeleteRoom")
                {
                    SqlCommand cmdDelFav = new SqlCommand("DELETE FROM Favorites WHERE RoomID = @ID", conn);
                    cmdDelFav.Parameters.AddWithValue("@ID", roomId);
                    cmdDelFav.ExecuteNonQuery();

                    SqlCommand cmdDelBook = new SqlCommand("DELETE FROM Bookings WHERE RoomID = @ID", conn);
                    cmdDelBook.Parameters.AddWithValue("@ID", roomId);
                    cmdDelBook.ExecuteNonQuery();

                    cmd.CommandText = "DELETE FROM Rooms WHERE RoomID = @ID";
                }
                cmd.Parameters.AddWithValue("@ID", roomId);
                cmd.ExecuteNonQuery();
            }

            lblThongBao.ForeColor = System.Drawing.Color.Green;
            lblThongBao.Text = "✓ Đã cập nhật phòng thành công.";
            RouteTab();
        }

        // 4. TẢI & CẬP NHẬT TÀI KHOẢN CHỦ PHÒNG
        private void LoadHostAccount()
        {
            int userId = Convert.ToInt32(Session["UserID"]);
            using (SqlConnection conn = new SqlConnection(strCon))
            {
                SqlCommand cmd = new SqlCommand("SELECT FullName, Email, Phone FROM Users WHERE UserID = @ID", conn);
                cmd.Parameters.AddWithValue("@ID", userId);
                conn.Open();
                SqlDataReader rd = cmd.ExecuteReader();
                if (rd.Read())
                {
                    lblHostEmail.Text = rd["Email"].ToString();
                    txtHostName.Text = rd["FullName"].ToString();
                    txtHostPhone.Text = rd["Phone"].ToString();
                }
            }
        }

        protected void btnUpdateHostInfo_Click(object sender, EventArgs e)
        {
            int userId = Convert.ToInt32(Session["UserID"]);
            using (SqlConnection conn = new SqlConnection(strCon))
            {
                SqlCommand cmd = new SqlCommand("UPDATE Users SET FullName=@Name, Phone=@Phone WHERE UserID=@ID", conn);
                cmd.Parameters.AddWithValue("@Name", txtHostName.Text.Trim());
                cmd.Parameters.AddWithValue("@Phone", txtHostPhone.Text.Trim());
                cmd.Parameters.AddWithValue("@ID", userId);
                conn.Open();
                cmd.ExecuteNonQuery();
                Session["FullName"] = txtHostName.Text.Trim();
            }
            lblThongBao.ForeColor = System.Drawing.Color.Green;
            lblThongBao.Text = "✓ Đã lưu thông tin chủ phòng.";
        }

        public string GetBookingBadge(string st)
        {
            if (st == "Confirmed") return "bg-green";
            if (st == "Pending" || st == "Unpaid") return "bg-yellow";
            if (st == "Cancelled") return "bg-red";
            return "bg-gray";
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

        public string GetRoomBadge(string st)
        {
            if (st == "Đang hoạt động") return "bg-green";
            if (st == "Chờ duyệt") return "bg-yellow";
            return "bg-gray";
        }
    }
}