using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace BTL_Web
{
    public partial class Favorites : System.Web.UI.Page
    {
        string strCon = ConfigurationManager.ConnectionStrings["DefaultConnection"]?.ConnectionString
                        ?? @"Data Source=.;Initial Catalog=Home_Sharing;Integrated Security=True;TrustServerCertificate=True";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDanhSachYeuThich();
            }
        }

        private void LoadDanhSachYeuThich()
        {
            // Lấy UserID đang đăng nhập (mặc định 1 nếu đang chạy test chưa qua Login)
            int userId = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 1;

            using (SqlConnection conn = new SqlConnection(strCon))
            {
                string query = @"
                    SELECT r.RoomID, r.Title, r.District, r.PricePerNight, r.ImageUrl
                    FROM Favorites f
                    INNER JOIN Rooms r ON f.RoomID = r.RoomID
                    WHERE f.UserID = @UserID
                    ORDER BY f.FavoriteID DESC";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@UserID", userId);

                try
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    rptFavorites.DataSource = dt;
                    rptFavorites.DataBind();

                    if (dt.Rows.Count == 0)
                    {
                        lblThongBao.Text = "Bạn chưa có căn phòng yêu thích nào. Hãy khám phá Trang chủ và thả tim những căn phòng ưng ý nhé!";
                    }
                    else
                    {
                        lblThongBao.Text = "";
                    }
                }
                catch (Exception ex)
                {
                    lblThongBao.Text = "Lỗi tải danh sách yêu thích: " + ex.Message;
                }
            }
        }

        // Bấm vào nút tim đỏ để xóa phòng khỏi danh sách Yêu thích
        protected void rptFavorites_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "RemoveFavorite")
            {
                int userId = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 1;
                int roomId = Convert.ToInt32(e.CommandArgument);

                using (SqlConnection conn = new SqlConnection(strCon))
                {
                    string deleteSql = "DELETE FROM Favorites WHERE UserID = @UserID AND RoomID = @RoomID";
                    SqlCommand cmd = new SqlCommand(deleteSql, conn);
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.Parameters.AddWithValue("@RoomID", roomId);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                // Tải lại danh sách ngay sau khi bỏ thích
                LoadDanhSachYeuThich();
            }
        }
    }
}