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

            // Sinh mã OTP 6 số
            Random rand = new Random();
            string otpCode = rand.Next(100000, 999999).ToString();

            // Lưu thông tin vào Session (hiệu lực 5 phút)
            Session["OTP_Code"] = otpCode;
            Session["OTP_Email"] = email;
            Session["OTP_Phone"] = sdt;
            Session["OTP_Expire"] = DateTime.Now.AddMinutes(5);

            lblThongBao.ForeColor = Color.Green;
            lblThongBao.Text = $"Mã xác nhận đã gửi tới {email}. (Mã test của bạn: {otpCode})";
        }

        // Bước 2: Nhập mã OTP -> Bấm Đăng nhập -> Chuyển về Trang chủ
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

            // Kiểm tra khớp Gmail, SĐT và Mã OTP
            if (emailNhap != Session["OTP_Email"].ToString() ||
                sdtNhap != Session["OTP_Phone"].ToString() ||
                otpNhap != Session["OTP_Code"].ToString())
            {
                lblThongBao.ForeColor = Color.Red;
                lblThongBao.Text = "Gmail, Số điện thoại hoặc mã OTP không chính xác!";
                return;
            }

            // Lưu hoặc cập nhật tài khoản trong bảng Users (Database Home_Sharing)
            int userId = LuuTaiKhoanVaoDB(emailNhap, sdtNhap);

            if (userId > 0)
            {
                Session["UserID"] = userId;
                Session["UserEmail"] = emailNhap;

                // Xóa Session OTP tạm
                Session.Remove("OTP_Code");
                Session.Remove("OTP_Email");
                Session.Remove("OTP_Phone");
                Session.Remove("OTP_Expire");

                // Chuyển thẳng đến Trang chủ
                Response.Redirect("TrangChu.aspx");
            }
        }

        private int LuuTaiKhoanVaoDB(string email, string phone)
        {
            using (SqlConnection conn = new SqlConnection(strCon))
            {
                try
                {
                    conn.Open();

                    // Kiểm tra Email đã có trong database chưa
                    string selectQuery = "SELECT UserID FROM Users WHERE Email = @Email";
                    SqlCommand cmdSelect = new SqlCommand(selectQuery, conn);
                    cmdSelect.Parameters.AddWithValue("@Email", email);

                    object result = cmdSelect.ExecuteScalar();
                    if (result != null)
                    {
                        int existingId = Convert.ToInt32(result);
                        SqlCommand cmdUpdate = new SqlCommand("UPDATE Users SET Phone = @Phone WHERE UserID = @UserID", conn);
                        cmdUpdate.Parameters.AddWithValue("@Phone", phone);
                        cmdUpdate.Parameters.AddWithValue("@UserID", existingId);
                        cmdUpdate.ExecuteNonQuery();
                        return existingId;
                    }

                    // Nếu chưa có thì tạo mới hoàn toàn
                    string insertQuery = "INSERT INTO Users (Email, FullName, Phone) OUTPUT INSERTED.UserID VALUES (@Email, @FullName, @Phone)";
                    SqlCommand cmdInsert = new SqlCommand(insertQuery, conn);
                    cmdInsert.Parameters.AddWithValue("@Email", email);
                    cmdInsert.Parameters.AddWithValue("@FullName", email.Split('@')[0]);
                    cmdInsert.Parameters.AddWithValue("@Phone", phone);

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