using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace BTL_Web
{
    public partial class Bookings : System.Web.UI.Page
    {
        string strCon = ConfigurationManager.ConnectionStrings["DefaultConnection"]?.ConnectionString
                        ?? @"Data Source=.;Initial Catalog=Home_Sharing;Integrated Security=True;TrustServerCertificate=True";

        protected void Page_Load(object sender, EventArgs e)
        {
            // Chặn truy cập nếu chưa đăng nhập -> đẩy về trang Đăng nhập (Profile.aspx)
            if (Session["UserID"] == null)
            {
                Response.Redirect("Profile.aspx");
                return;
            }

            if (!IsPostBack)
            {
                ViewState["CurrentFilter"] = "ALL";
                ViewState["PayingBookingID"] = 0;
                ViewState["JustPaidBookingID"] = 0;
                LoadDanhSachHoatDong("ALL");
            }
        }

        protected void FilterTab_Click(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Profile.aspx");
                return;
            }

            LinkButton clickedTab = (LinkButton)sender;
            string filter = clickedTab.CommandArgument;

            ViewState["CurrentFilter"] = filter;
            ViewState["PayingBookingID"] = 0;
            ViewState["JustPaidBookingID"] = 0;

            tabAll.CssClass = "tab-pill";
            tabPendingConfirm.CssClass = "tab-pill";
            tabPendingPayment.CssClass = "tab-pill";
            tabUpcoming.CssClass = "tab-pill";
            tabCompleted.CssClass = "tab-pill";
            tabCancelled.CssClass = "tab-pill";

            clickedTab.CssClass = "tab-pill active";
            LoadDanhSachHoatDong(filter);
        }

        private void LoadDanhSachHoatDong(string filter)
        {
            if (Session["UserID"] == null) return;

            int userId = Convert.ToInt32(Session["UserID"]);
            int payingId = ViewState["PayingBookingID"] != null ? Convert.ToInt32(ViewState["PayingBookingID"]) : 0;
            int justPaidId = ViewState["JustPaidBookingID"] != null ? Convert.ToInt32(ViewState["JustPaidBookingID"]) : 0;

            using (SqlConnection conn = new SqlConnection(strCon))
            {
                string query = @"
                    SELECT b.BookingID, b.RoomID, b.CheckInDate, b.CheckOutDate, b.TotalPrice, 
                           ISNULL(b.PaymentMethod, 'Direct') AS PaymentMethod, b.Status,
                           r.Title, r.Address, r.ImageUrl
                    FROM Bookings b
                    INNER JOIN Rooms r ON b.RoomID = r.RoomID
                    WHERE b.GuestID = @UserID";

                if (filter == "PendingConfirm")
                {
                    query += " AND (b.Status = 'PendingConfirm' OR (b.Status = 'Pending' AND ISNULL(b.PaymentMethod, 'Direct') <> 'QR'))";
                }
                else if (filter == "PendingPayment")
                {
                    query += " AND (b.Status = 'Unpaid' OR (b.Status = 'Pending' AND b.PaymentMethod = 'QR'))";
                }
                else if (filter == "Confirmed")
                {
                    query += " AND b.Status = 'Confirmed'";
                }
                else if (filter == "Completed")
                {
                    query += " AND b.Status = 'Completed'";
                }
                else if (filter == "Cancelled")
                {
                    query += " AND b.Status = 'Cancelled'";
                }

                query += " ORDER BY b.BookingID DESC";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@UserID", userId);

                try
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable rawDt = new DataTable();
                    da.Fill(rawDt);

                    DataTable dtView = new DataTable();
                    dtView.Columns.Add("BookingID", typeof(int));
                    dtView.Columns.Add("RoomID", typeof(int));
                    dtView.Columns.Add("Title", typeof(string));
                    dtView.Columns.Add("Address", typeof(string));
                    dtView.Columns.Add("ImageUrl", typeof(string));
                    dtView.Columns.Add("CheckInDate", typeof(DateTime));
                    dtView.Columns.Add("CheckOutDate", typeof(DateTime));
                    dtView.Columns.Add("SoDem", typeof(int));
                    dtView.Columns.Add("TotalPrice", typeof(decimal));
                    dtView.Columns.Add("PaymentLabel", typeof(string));
                    dtView.Columns.Add("StatusLabel", typeof(string));
                    dtView.Columns.Add("BadgeClass", typeof(string));
                    dtView.Columns.Add("ShowPayBtn", typeof(bool));
                    dtView.Columns.Add("ShowCancelBtn", typeof(bool));
                    dtView.Columns.Add("ShowRebookBtn", typeof(bool));
                    dtView.Columns.Add("IsPayingQR", typeof(bool));
                    dtView.Columns.Add("IsJustPaidQR", typeof(bool));

                    foreach (DataRow r in rawDt.Rows)
                    {
                        int bId = Convert.ToInt32(r["BookingID"]);
                        DateTime dIn = Convert.ToDateTime(r["CheckInDate"]);
                        DateTime dOut = Convert.ToDateTime(r["CheckOutDate"]);
                        int nights = Math.Max(1, (dOut - dIn).Days);
                        string method = r["PaymentMethod"].ToString();
                        string status = r["Status"].ToString();

                        string payLabel = method == "QR" ? "Chuyển khoản QR" : "Thanh toán sau khi nhận phòng";
                        string statusLabel = "";
                        string badgeClass = "badge-yellow";
                        bool showPay = false, showCancel = false, showRebook = false;

                        if (status == "Unpaid" || (status == "Pending" && method == "QR"))
                        {
                            statusLabel = "Chờ thanh toán";
                            badgeClass = "badge-yellow";
                            showPay = true;
                            showCancel = true;
                        }
                        else if (status == "Pending" || status == "PendingConfirm")
                        {
                            statusLabel = "Chờ xác nhận";
                            badgeClass = "badge-yellow";
                            showCancel = true;
                        }
                        else if (status == "Confirmed")
                        {
                            statusLabel = "Đã xác nhận";
                            badgeClass = "badge-green";
                        }
                        else if (status == "Completed")
                        {
                            statusLabel = "Hoàn tất";
                            badgeClass = "badge-gray";
                            showRebook = true;
                        }
                        else if (status == "Cancelled")
                        {
                            statusLabel = "Đã hủy";
                            badgeClass = "badge-gray";
                            showRebook = true;
                        }

                        dtView.Rows.Add(
                            bId, r["RoomID"], r["Title"], r["Address"], r["ImageUrl"],
                            dIn, dOut, nights, r["TotalPrice"], payLabel, statusLabel, badgeClass,
                            showPay, showCancel, showRebook,
                            (bId == payingId),
                            (bId == justPaidId)
                        );
                    }

                    rptBookings.DataSource = dtView;
                    rptBookings.DataBind();

                    lblThongBao.Text = dtView.Rows.Count == 0 ? "Chưa có hoạt động đặt phòng nào trong mục này." : "";
                }
                catch (Exception ex)
                {
                    lblThongBao.Text = "Lỗi tải lịch sử đặt phòng: " + ex.Message;
                }
            }
        }

        protected void rptBookings_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Profile.aspx");
                return;
            }

            string currentFilter = ViewState["CurrentFilter"]?.ToString() ?? "ALL";

            if (e.CommandName == "OpenQR")
            {
                ViewState["PayingBookingID"] = Convert.ToInt32(e.CommandArgument);
                ViewState["JustPaidBookingID"] = 0;
            }
            else if (e.CommandName == "ClosePopover")
            {
                ViewState["PayingBookingID"] = 0;
                ViewState["JustPaidBookingID"] = 0;
            }
            else if (e.CommandName == "CompleteQR")
            {
                int bookingId = Convert.ToInt32(e.CommandArgument);
                using (SqlConnection conn = new SqlConnection(strCon))
                {
                    SqlCommand cmd = new SqlCommand("UPDATE Bookings SET Status = 'PendingConfirm' WHERE BookingID = @ID", conn);
                    cmd.Parameters.AddWithValue("@ID", bookingId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                ViewState["PayingBookingID"] = 0;
                ViewState["JustPaidBookingID"] = bookingId;
            }
            else if (e.CommandName == "CancelBooking")
            {
                int bookingId = Convert.ToInt32(e.CommandArgument);
                using (SqlConnection conn = new SqlConnection(strCon))
                {
                    SqlCommand cmd = new SqlCommand("UPDATE Bookings SET Status = 'Cancelled' WHERE BookingID = @ID", conn);
                    cmd.Parameters.AddWithValue("@ID", bookingId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                ViewState["PayingBookingID"] = 0;
                ViewState["JustPaidBookingID"] = 0;
            }

            LoadDanhSachHoatDong(currentFilter);
        }
    }
}