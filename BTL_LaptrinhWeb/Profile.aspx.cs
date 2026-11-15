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
            if (Session["UserID"] != null)
            {
                string currentRole = Session["Role"] != null ? Session["Role"].ToString() : "Guest";
                if (currentRole == "Admin")
                {
                    Response.Redirect("AdminDashboard.aspx?tab=users");
                }
                else if (currentRole == "Host")
                {
                    Response.Redirect("HostDashboard.aspx?tab=bookings");
                }
                else
                {
                    Response.Redirect("Account.aspx");
                }
                return;
            }

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
                string query = @"SELECT UserID, FullName, ISNULL(Role, 'Guest') AS Role, 
                                 ISNULL(Status, N'Hoạt động') AS Status, LockReason 
                                 FROM Users WHERE Email = @Email AND Phone = @Phone";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Email", email);
                cmd.Parameters.AddWithValue("@Phone", sdt);

                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    if (reader.Read())
                    {
                        string status = reader["Status"].ToString();
                        if (status == "Bị khóa")
                        {
                            string reason = reader["LockReason"] != DBNull.Value ? reader["LockReason"].ToString() : "Vi phạm quy định hệ thống";
                            lblThongBao.Text = "Tài khoản của bạn đã bị khóa! Lý do: " + reason;
                            return;
                        }

                        string role = reader["Role"].ToString();

                        Session["UserID"] = reader["UserID"].ToString();
                        Session["UserEmail"] = email;
                        Session["Email"] = email;
                        Session["Role"] = role;
                        Session["FullName"] = reader["FullName"] != DBNull.Value && !string.IsNullOrWhiteSpace(reader["FullName"].ToString())
                            ? reader["FullName"].ToString()
                            : email.Split('@')[0];

                        if (role == "Admin")
                        {
                            Response.Redirect("AdminDashboard.aspx?tab=users");
                        }
                        else if (role == "Host")
                        {
                            Response.Redirect("HostDashboard.aspx?tab=bookings");
                        }
                        else
                        {
                            Response.Redirect("Trangchu.aspx");
                        }
                    }
                    else
                    {
                        // Chưa có tài khoản -> Lưu tạm Gmail & SĐT rồi chuyển sang trang OTP (Login.aspx)
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