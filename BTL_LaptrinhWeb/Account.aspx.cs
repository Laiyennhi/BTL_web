using System;
using System.Configuration;
using System.Data.SqlClient;

namespace BTL_Web
{
    public partial class Account : System.Web.UI.Page
    {
        string strCon = ConfigurationManager.ConnectionStrings["DefaultConnection"]?.ConnectionString
                        ?? @"Data Source=.;Initial Catalog=Home_Sharing;Integrated Security=True;TrustServerCertificate=True";

        protected void Page_Load(object sender, EventArgs e)
        {
            // Nếu chưa đăng nhập thì chuyển thẳng sang trang Đăng nhập/Đăng ký (Profile.aspx)
            if (Session["UserID"] == null)
            {
                Response.Redirect("Profile.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadThongTinCaNhan();
            }
        }

        private void LoadThongTinCaNhan()
        {
            int userId = Convert.ToInt32(Session["UserID"]);

            using (SqlConnection conn = new SqlConnection(strCon))
            {
                string query = "SELECT FullName, Email, Phone, CreatedAt FROM Users WHERE UserID = @UserID";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@UserID", userId);

                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    if (reader.Read())
                    {
                        string email = reader["Email"] != DBNull.Value ? reader["Email"].ToString() : "";
                        string fullName = reader["FullName"] != DBNull.Value ? reader["FullName"].ToString() : "";

                        lblEmail.Text = email;
                        txtFullName.Text = fullName;
                        txtPhone.Text = reader["Phone"] != DBNull.Value ? reader["Phone"].ToString() : "";
                        txtCreatedAt.Text = reader["CreatedAt"] != DBNull.Value
                            ? Convert.ToDateTime(reader["CreatedAt"]).ToString("dd/MM/yyyy")
                            : "2026";

                        // Đồng bộ lại Session để Menu Avatar luôn hiển thị đúng
                        Session["Email"] = email;
                        Session["UserEmail"] = email;
                        if (!string.IsNullOrEmpty(fullName))
                        {
                            Session["FullName"] = fullName;
                        }
                    }
                }
                catch (Exception ex)
                {
                    lblThongBao.ForeColor = System.Drawing.Color.Red;
                    lblThongBao.Text = "Lỗi tải thông tin: " + ex.Message;
                }
            }
        }

        protected void btnCapNhat_Click(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Profile.aspx");
                return;
            }

            int userId = Convert.ToInt32(Session["UserID"]);
            string newFullName = txtFullName.Text.Trim();
            string newPhone = txtPhone.Text.Trim();

            if (string.IsNullOrEmpty(newFullName) || string.IsNullOrEmpty(newPhone))
            {
                lblThongBao.ForeColor = System.Drawing.Color.Red;
                lblThongBao.Text = "Vui lòng nhập đầy đủ Họ tên và Số điện thoại!";
                return;
            }

            using (SqlConnection conn = new SqlConnection(strCon))
            {
                string updateQuery = "UPDATE Users SET FullName = @FullName, Phone = @Phone WHERE UserID = @UserID";
                SqlCommand cmd = new SqlCommand(updateQuery, conn);
                cmd.Parameters.AddWithValue("@FullName", newFullName);
                cmd.Parameters.AddWithValue("@Phone", newPhone);
                cmd.Parameters.AddWithValue("@UserID", userId);

                try
                {
                    conn.Open();
                    cmd.ExecuteNonQuery();

                    // Cập nhật lại Session để tên mới hiện ngay trên Menu Avatar góc phải
                    Session["FullName"] = newFullName;

                    lblThongBao.ForeColor = System.Drawing.Color.FromArgb(28, 126, 46);
                    lblThongBao.Text = "✓ Đã cập nhật thông tin cá nhân thành công!";
                }
                catch (Exception ex)
                {
                    lblThongBao.ForeColor = System.Drawing.Color.Red;
                    lblThongBao.Text = "Lỗi cập nhật: " + ex.Message;
                }
            }
        }
    }
}