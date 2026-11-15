using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Drawing;

namespace BTL_Web
{
    public partial class Login : System.Web.UI.Page
    {
        string strCon = ConfigurationManager.ConnectionStrings["DefaultConnection"]?.ConnectionString
                        ?? @"Data Source=.;Initial Catalog=Home_Sharing;Integrated Security=True;TrustServerCertificate=True";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                lblThongBao.Text = "";

                // Nếu chuyển từ Profile.aspx sang để đăng ký tài khoản mới thì điền sẵn Gmail & SĐT
                if (Session["PendingRegisterEmail"] != null)
                {
                    txtGmail.Text = Session["PendingRegisterEmail"].ToString();
                }
                if (Session["PendingRegisterPhone"] != null)
                {
                    txtSDT.Text = Session["PendingRegisterPhone"].ToString();
                }
            }
        }

        // Bước 1: Nhập Gmail + SĐT -> Bấm Gửi mã
        protected void btnGuiMa_Click(object sender, EventArgs e)
        {
            string email = txtGmail.Text.Trim();
            string sdt = txtSDT.Text.Trim();

            if (string.IsNullOrEmpty(email) || !email.Contains("@") || string.IsNullOrEmpty(sdt))
            {
                lblThongBao.ForeColor = Color.Red;
                lblThongBao.Text = "Vui lòng nhập đầy đủ Gmail và Số điện thoại trước khi gửi mã!";
                return;
            }

            Random rand = new Random();
            string otpCode = rand.Next(100000, 999999).ToString();

            Session["OTP_Code"] = otpCode;
            Session["OTP_Email"] = email;
            Session["OTP_Phone"] = sdt;
            Session["OTP_Expire"] = DateTime.Now.AddMinutes(5);

            lblThongBao.ForeColor = Color.Green;
            lblThongBao.Text = $"Mã xác nhận đã gửi tới {email}. (Mã test của bạn: {otpCode})";
        }

        // Bước 2: Nhập mã OTP -> Bấm Đăng nhập -> Lưu DB & Gán đầy đủ Session
        protected void btnDangNhap_Click(object sender, EventArgs e)
        {
            string emailNhap = txtGmail.Text.Trim();
            string sdtNhap = txtSDT.Text.Trim();
            string otpNhap = txtOtp.Text.Trim();

            if (Session["OTP_Code"] == null || Session["OTP_Email"] == null || Session["OTP_Phone"] == null)
            {
                lblThongBao.ForeColor = Color.Red;
                lblThongBao.Text = "Vui lòng bấm 'Gửi mã' trước khi đăng nhập!";
                return;
            }

            if (DateTime.Now > (DateTime)Session["OTP_Expire"])
            {
                lblThongBao.ForeColor = Color.Red;
                lblThongBao.Text = "Mã OTP đã hết hạn. Vui lòng bấm gửi lại mã mới!";
                return;
            }

            if (emailNhap != Session["OTP_Email"].ToString() ||
                sdtNhap != Session["OTP_Phone"].ToString() ||
                otpNhap != Session["OTP_Code"].ToString())
            {
                lblThongBao.ForeColor = Color.Red;
                lblThongBao.Text = "Gmail, Số điện thoại hoặc mã OTP không chính xác!";
                return;
            }

            string fullName = emailNhap.Split('@')[0];
            string role = "Guest";
            string lockError = "";

            int userId = LuuTaiKhoanVaoDB(emailNhap, sdtNhap, ref fullName, ref role, ref lockError);

            if (!string.IsNullOrEmpty(lockError))
            {
                lblThongBao.ForeColor = Color.Red;
                lblThongBao.Text = lockError;
                return;
            }

            if (userId > 0)
            {
                // Đồng bộ toàn bộ Session cho Header Popover & Phân quyền
                Session["UserID"] = userId;
                Session["Email"] = emailNhap;
                Session["UserEmail"] = emailNhap;
                Session["FullName"] = fullName;
                Session["Role"] = role;

                // Dọn dẹp Session tạm
                Session.Remove("OTP_Code");
                Session.Remove("OTP_Email");
                Session.Remove("OTP_Phone");
                Session.Remove("OTP_Expire");
                Session.Remove("PendingRegisterEmail");
                Session.Remove("PendingRegisterPhone");

                // Điều hướng theo đúng phân quyền
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
                    Response.Redirect("TrangChu.aspx");
                }
            }
        }

        private int LuuTaiKhoanVaoDB(string email, string phone, ref string fullName, ref string role, ref string lockError)
        {
            using (SqlConnection conn = new SqlConnection(strCon))
            {
                try
                {
                    conn.Open();

                    string selectQuery = @"
                        SELECT UserID, FullName, ISNULL(Role, 'Guest') AS Role, 
                               ISNULL(Status, N'Hoạt động') AS Status, LockReason 
                        FROM Users WHERE Email = @Email";
                    SqlCommand cmdSelect = new SqlCommand(selectQuery, conn);
                    cmdSelect.Parameters.AddWithValue("@Email", email);

                    using (SqlDataReader rd = cmdSelect.ExecuteReader())
                    {
                        if (rd.Read())
                        {
                            string status = rd["Status"].ToString();
                            if (status == "Bị khóa")
                            {
                                string reason = rd["LockReason"] != DBNull.Value ? rd["LockReason"].ToString() : "Vi phạm quy định hệ thống.";
                                lockError = "Tài khoản của bạn đã bị khóa! Lý do: " + reason;
                                return -1;
                            }

                            int existingId = Convert.ToInt32(rd["UserID"]);
                            if (rd["FullName"] != DBNull.Value && !string.IsNullOrWhiteSpace(rd["FullName"].ToString()))
                            {
                                fullName = rd["FullName"].ToString();
                            }
                            role = rd["Role"].ToString();
                            rd.Close();

                            SqlCommand cmdUpdate = new SqlCommand("UPDATE Users SET Phone = @Phone WHERE UserID = @UserID", conn);
                            cmdUpdate.Parameters.AddWithValue("@Phone", phone);
                            cmdUpdate.Parameters.AddWithValue("@UserID", existingId);
                            cmdUpdate.ExecuteNonQuery();
                            return existingId;
                        }
                    }

                    // Tạo tài khoản mới với vai trò mặc định là Guest và trạng thái Hoạt động
                    string insertQuery = @"
                        INSERT INTO Users (Email, FullName, Phone, Role, Status, CreatedAt) 
                        OUTPUT INSERTED.UserID 
                        VALUES (@Email, @FullName, @Phone, 'Guest', N'Hoạt động', GETDATE())";
                    SqlCommand cmdInsert = new SqlCommand(insertQuery, conn);
                    cmdInsert.Parameters.AddWithValue("@Email", email);
                    cmdInsert.Parameters.AddWithValue("@FullName", fullName);
                    cmdInsert.Parameters.AddWithValue("@Phone", phone);

                    role = "Guest";
                    return Convert.ToInt32(cmdInsert.ExecuteScalar());
                }
                catch (Exception ex)
                {
                    lblThongBao.ForeColor = Color.Red;
                    lblThongBao.Text = "Lỗi kết nối CSDL: " + ex.Message;
                    return -1;
                }
            }
        }
    }
}