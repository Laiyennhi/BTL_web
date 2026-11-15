using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace BTL_Web
{
    public partial class TrangChu : System.Web.UI.Page
    {
        string strCon = ConfigurationManager.ConnectionStrings["DefaultConnection"]?.ConnectionString
                        ?? @"Data Source=.;Initial Catalog=Home_Sharing;Integrated Security=True;TrustServerCertificate=True";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadGoiYDiaDiem();
                LoadDanhSachPhong();
            }
        }

        // 1. Tải danh sách địa điểm gợi ý từ bảng SearchSuggestions
        private void LoadGoiYDiaDiem()
        {
            using (SqlConnection conn = new SqlConnection(strCon))
            {
                try
                {
                    conn.Open();
                    SqlDataAdapter da = new SqlDataAdapter("SELECT Value FROM SearchSuggestions WHERE Type = 'Location' ORDER BY CreatedAt DESC", conn);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    rptDiaDiem.DataSource = dt;
                    rptDiaDiem.DataBind();
                }
                catch { }
            }
        }

        // 2. Lưu địa điểm mới người dùng nhập từ bàn phím vào database
        private void LuuDiaDiemMoi(string value)
        {
            if (string.IsNullOrWhiteSpace(value)) return;

            using (SqlConnection conn = new SqlConnection(strCon))
            {
                string query = @"
                    IF NOT EXISTS (SELECT 1 FROM SearchSuggestions WHERE Type = 'Location' AND Value = @Value)
                    BEGIN
                        INSERT INTO SearchSuggestions (Type, Value) VALUES ('Location', @Value)
                    END";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Value", value.Trim());

                try
                {
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                catch { }
            }
        }

        // 3. Sự kiện bấm nút Kính lúp Tìm kiếm
        protected void btnTimKiem_Click(object sender, EventArgs e)
        {
            string diaDiemNhap = txtDiaDiem.Text.Trim();
            if (!string.IsNullOrEmpty(diaDiemNhap))
            {
                LuuDiaDiemMoi(diaDiemNhap);
            }

            LoadGoiYDiaDiem();
            LoadDanhSachPhong();
        }

        // 4. Lọc danh sách phòng theo Địa điểm (Hà Nội) và Sắp xếp Giá
        private void LoadDanhSachPhong()
        {
            // Chưa đăng nhập thì userId = 0 (không hiện trạng thái đã thích của tài khoản khác)
            int userId = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 0;
            string diaDiem = txtDiaDiem.Text.Trim();
            string dieuKienGia = hfSapXepGia.Value;

            if (string.IsNullOrEmpty(dieuKienGia))
            {
                if (txtHienThiGia.Text == "Từ cao xuống thấp") dieuKienGia = "DESC";
                else if (txtHienThiGia.Text == "Từ thấp lên cao") dieuKienGia = "ASC";
                else if (txtHienThiGia.Text == "Dưới 700.000 đ") dieuKienGia = "UNDER_700";
                else if (txtHienThiGia.Text == "Từ 700.000 đ trở lên") dieuKienGia = "OVER_700";
            }

            using (SqlConnection conn = new SqlConnection(strCon))
            {
                // Chỉ hiển thị các phòng đã được duyệt hoạt động
                string query = @"
                    SELECT r.RoomID, r.Title, r.District, r.PricePerNight, r.ImageUrl,
                           CASE WHEN f.FavoriteID IS NOT NULL THEN 1 ELSE 0 END AS IsLiked
                    FROM Rooms r
                    LEFT JOIN Favorites f ON r.RoomID = f.RoomID AND f.UserID = @UserID
                    WHERE ISNULL(r.ApprovalStatus, N'Đang hoạt động') = N'Đang hoạt động'
                      AND ISNULL(r.IsAvailable, 1) = 1";

                string tuKhoaTim = "";

                if (!string.IsNullOrEmpty(diaDiem))
                {
                    tuKhoaTim = diaDiem;
                    if (diaDiem.Contains("-"))
                    {
                        string[] parts = diaDiem.Split('-');
                        tuKhoaTim = parts[0].Trim();
                    }

                    query += " AND (r.District LIKE @Keyword OR r.Address LIKE @Keyword OR r.Title LIKE @Keyword)";
                }

                if (dieuKienGia == "UNDER_700")
                {
                    query += " AND r.PricePerNight < 700000";
                }
                else if (dieuKienGia == "OVER_700")
                {
                    query += " AND r.PricePerNight >= 700000";
                }

                if (dieuKienGia == "DESC")
                {
                    query += " ORDER BY r.PricePerNight DESC";
                }
                else if (dieuKienGia == "ASC")
                {
                    query += " ORDER BY r.PricePerNight ASC";
                }
                else
                {
                    query += " ORDER BY r.CreatedAt DESC";
                }

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@UserID", userId);

                if (!string.IsNullOrEmpty(tuKhoaTim))
                {
                    cmd.Parameters.AddWithValue("@Keyword", "%" + tuKhoaTim + "%");
                }

                try
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    rptRooms.DataSource = dt;
                    rptRooms.DataBind();

                    lblThongBao.Text = dt.Rows.Count == 0 ? "Không tìm thấy phòng phù hợp với tiêu chí của bạn." : "";
                }
                catch (Exception ex)
                {
                    lblThongBao.Text = "Lỗi tải danh sách phòng: " + ex.Message;
                }
            }
        }

        // 5. Sự kiện thả tim / bỏ tim Yêu thích trực tiếp trên thẻ phòng
        protected void rptRooms_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "ToggleFavorite")
            {
                // Chưa đăng nhập -> đẩy về trang Đăng nhập (Profile.aspx)
                if (Session["UserID"] == null)
                {
                    Response.Redirect("Profile.aspx");
                    return;
                }

                int userId = Convert.ToInt32(Session["UserID"]);
                int roomId = Convert.ToInt32(e.CommandArgument);

                using (SqlConnection conn = new SqlConnection(strCon))
                {
                    conn.Open();
                    string checkQuery = "SELECT COUNT(*) FROM Favorites WHERE UserID = @UserID AND RoomID = @RoomID";
                    SqlCommand cmdCheck = new SqlCommand(checkQuery, conn);
                    cmdCheck.Parameters.AddWithValue("@UserID", userId);
                    cmdCheck.Parameters.AddWithValue("@RoomID", roomId);

                    int count = (int)cmdCheck.ExecuteScalar();
                    if (count > 0)
                    {
                        SqlCommand cmdDel = new SqlCommand("DELETE FROM Favorites WHERE UserID = @UserID AND RoomID = @RoomID", conn);
                        cmdDel.Parameters.AddWithValue("@UserID", userId);
                        cmdDel.Parameters.AddWithValue("@RoomID", roomId);
                        cmdDel.ExecuteNonQuery();
                    }
                    else
                    {
                        SqlCommand cmdIns = new SqlCommand("INSERT INTO Favorites (UserID, RoomID) VALUES (@UserID, @RoomID)", conn);
                        cmdIns.Parameters.AddWithValue("@UserID", userId);
                        cmdIns.Parameters.AddWithValue("@RoomID", roomId);
                        cmdIns.ExecuteNonQuery();
                    }
                }

                LoadDanhSachPhong();
            }
        }
    }
}