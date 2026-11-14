using System;
using System.Configuration;
using System.Data.SqlClient;

namespace BTL_Web
{
    public partial class Profile : System.Web.UI.Page
    {
        string strCon = ConfigurationManager.ConnectionStrings["DefaultConnection"]?.ConnectionString
                        ?? @"Data Source=.;Initial Catalog=Home_Sharing;Integrated Security=True;TrustServerCertificate=True";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                lblThongBao.Text = "";
            }
        }

        protected void btnDangNhap_Click(object sender, EventArgs e)
        {
            string email = txtGmail.Text.Trim();
            string sdt = txtSDT.Text.Trim();

            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(sdt))
            {
                lblThongBao.Text = "Vui lòng nhập đầy đủ Gmail và Số điện thoại!";
                return;
            }

            using (SqlConnection conn = new SqlConnection(strCon))
            {
                // Kiểm tra xem Email và SĐT đã tồn tại trong bảng Users chưa
                string query = "SELECT UserID, FullName FROM Users WHERE Email = @Email AND Phone = @Phone";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Email", email);
                cmd.Parameters.AddWithValue("@Phone", sdt);

                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    if (reader.Read())
                    {
                        // TRƯỜNG HỢP 1: Đã có tài khoản -> Lưu Session và chuyển về Trang chủ
                        Session["UserID"] = reader["UserID"].ToString();
                        Session["UserEmail"] = email;
                        Session["FullName"] = reader["FullName"] != DBNull.Value ? reader["FullName"].ToString() : email.Split('@')[0];

                        Response.Redirect("TrangChu.aspx");
                    }
                    else
                    {
                        // TRƯỜNG HỢP 2: Chưa có tài khoản -> Lưu tạm Gmail & SĐT rồi chuyển sang trang OTP (Login.aspx)
                        Session["Pending_Email"] = email;
                        Session["Pending_Phone"] = sdt;

                        Response.Redirect("Login.aspx");
                    }
                }
                catch (Exception ex)
                {
                    lblThongBao.Text = "Lỗi kết nối CSDL: " + ex.Message;
                }
            }
        }
    }
}