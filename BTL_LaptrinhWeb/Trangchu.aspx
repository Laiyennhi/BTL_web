<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TrangChu.aspx.cs" Inherits="BTL_Web.TrangChu" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang chủ | Hanoi Stay Nest</title>
<link rel="stylesheet" href="stylesheet/style.css?v=2" /></head>
<body>
    <form id="form1" runat="server" style="display: flex; flex-direction: column; min-height: 100vh;">

        <!-- HEADER -->
        <header>
            <a href="TrangChu.aspx" class="logo-box">
                <svg width="65" height="32" viewBox="0 0 80 40" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M10 30L40 8L70 30" stroke="#D68C94" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M22 25L45 14L62 28" stroke="#D68C94" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M55 12V19" stroke="#D68C94" stroke-width="3.5" stroke-linecap="round"/>
                </svg>
                <span>Hanoi</span>
                <span>Stay Nest</span>
            </a>

            <ul class="nav-menu">
                <li><a href="TrangChu.aspx" class="active">Trang chủ</a></li>
                <li><a href="Favorites.aspx">Yêu Thích</a></li>
                <li><a href="Bookings.aspx">Hoạt động</a></li>
            </ul>

            <a href="Profile.aspx" class="header-avatar" title="Hồ sơ cá nhân">
                <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
                    <circle cx="50" cy="50" r="50" fill="#F8B8BE"/>
                    <circle cx="50" cy="38" r="17" fill="#FFFFFF"/>
                    <path d="M20 88C20 68 33 58 50 58C67 58 80 68 80 88" fill="#FFFFFF"/>
                </svg>
            </a>
        </header>

        <!-- MAIN CONTENT -->
        <main style="flex: 1; display: flex; flex-direction: column;">
            
            <!-- Thanh tìm kiếm & Lọc giá -->
            <div class="search-bar-container">
                
                <!-- 1. Ô Địa điểm: Nhập bàn phím + List xổ xuống tự động lưu -->
                <!-- 1. Ô Địa điểm: Chỉ nội bộ quanh Hà Nội -->
                    <div class="filter-box-wrapper">
                        <asp:TextBox ID="txtDiaDiem" runat="server" CssClass="search-select" 
                                     placeholder="Khu vực Hà Nội..." autocomplete="off" onclick="toggleMenu('menuDiaDiem')"></asp:TextBox>
                        <button type="button" class="dropdown-arrow-btn" onclick="toggleMenu('menuDiaDiem')">v</button>

                        <div id="menuDiaDiem" class="custom-dropdown-menu">
                            <!-- Tùy chọn reset để hiện tất cả phòng tại Hà Nội -->
                            <div class="dropdown-item-row" onclick="chonDiaDiem('')" style="font-weight: 500; color: #d68c94;">
                                <span>Tất cả khu vực Hà Nội</span>
                            </div>

                            <!-- Danh sách quận/phố Hà Nội đổ từ SQL Server -->
                            <asp:Repeater ID="rptDiaDiem" runat="server">
                                <ItemTemplate>
                                    <div class="dropdown-item-row" onclick="chonDiaDiem('<%# Eval("Value") %>')">
                                        <span><%# Eval("Value") %></span>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </div>

                <!-- 2. Ô Giá: Lọc Từ cao xuống thấp / Từ thấp lên cao -->
               <!-- 2. Ô Giá: Lọc theo khoảng giá & Sắp xếp -->
                    <div class="filter-box-wrapper">
                        <asp:TextBox ID="txtHienThiGia" runat="server" CssClass="search-select" 
                                     placeholder="Giá" onkeydown="return false;" onclick="toggleMenu('menuGia')"></asp:TextBox>
                        <asp:HiddenField ID="hfSapXepGia" runat="server" Value="" />
                        <button type="button" class="dropdown-arrow-btn" onclick="toggleMenu('menuGia')">v</button>

                        <div id="menuGia" class="custom-dropdown-menu">
                            <div class="dropdown-item-row" onclick="chonSapXepGia('', 'Tất cả mức giá')">
                                <span>Tất cả mức giá</span>
                            </div>
                            <div class="dropdown-item-row" onclick="chonSapXepGia('DESC', 'Từ cao xuống thấp')">
                                <span>Từ cao xuống thấp</span>
                                <span class="sort-arrow-icon">⇓</span>
                            </div>
                            <div class="dropdown-item-row" onclick="chonSapXepGia('ASC', 'Từ thấp lên cao')">
                                <span>Từ thấp lên cao</span>
                                <span class="sort-arrow-icon">⇑</span>
                            </div>
                            <div class="dropdown-item-row" onclick="chonSapXepGia('UNDER_700', 'Dưới 700.000 đ')">
                                <span>Dưới 700.000 đ</span>
                            </div>
                            <div class="dropdown-item-row" onclick="chonSapXepGia('OVER_700', 'Từ 700.000 đ trở lên')">
                                <span>Từ 700.000 đ trở lên</span>
                            </div>
                        </div>
                    </div>

                <!-- 3. Nút kính lúp Tìm kiếm -->
                <asp:LinkButton ID="btnTimKiem" runat="server" CssClass="btn-search-icon" ToolTip="Tìm kiếm" OnClick="btnTimKiem_Click">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="11" cy="11" r="7"></circle>
                        <line x1="20" y1="20" x2="16.35" y2="16.35"></line>
                    </svg>
                </asp:LinkButton>
            </div>

            <!-- Thông báo kết quả tìm kiếm / lỗi -->
            <div style="text-align: center; margin-bottom: 15px;">
                <asp:Label ID="lblThongBao" runat="server" ForeColor="#D68C94" Font-Bold="true"></asp:Label>
            </div>

            <!-- Lưới hiển thị danh sách phòng động từ SQL Server -->
            <div class="room-grid">
                <asp:Repeater ID="rptRooms" runat="server" OnItemCommand="rptRooms_ItemCommand">
                    <ItemTemplate>
                        <div class="room-card">
                            <div class="room-img-wrapper">
                                <!-- Link bấm vào ảnh phòng -> sang ChitietPhong.aspx kèm id -->
                                <a href='ChitietPhong.aspx?id=<%# Eval("RoomID") %>'>
                                    <img src='<%# Eval("ImageUrl") %>' alt='<%# Eval("Title") %>' 
                                         onerror="this.src='https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=600&q=80'" />
                                </a>
        
                                <!-- Nút thả tim Yêu thích -->
                                <asp:LinkButton ID="btnYeuThich" runat="server" CssClass="btn-heart" 
                                    CommandName="ToggleFavorite" CommandArgument='<%# Eval("RoomID") %>' ToolTip="Yêu thích">
                                    <svg width="20" height="20" viewBox="0 0 24 24" 
                                         fill='<%# Convert.ToInt32(Eval("IsLiked")) == 1 ? "#F8B8BE" : "none" %>' 
                                         stroke='<%# Convert.ToInt32(Eval("IsLiked")) == 1 ? "#E57373" : "#555555" %>' 
                                         stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                        <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"></path>
                                    </svg>
                                </asp:LinkButton>
                            </div>

                            <!-- Link bấm vào tên/giá phòng -> sang ChitietPhong.aspx kèm id -->
                            <a href='ChitietPhong.aspx?id=<%# Eval("RoomID") %>' class="room-info" style="text-decoration: none;">
                                <div class="room-title"><%# Eval("Title") %></div>
                                <div class="room-code" style="display: none;">HG0<%# Eval("RoomID") %></div>
                                <div class="room-price"><%# String.Format("{0:N0} đ/ đêm", Eval("PricePerNight")) %></div>
                            </a>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <!-- Chấm phân trang -->
            <div class="pagination-dots">
                <span class="dot active"></span>
                <span class="dot active"></span>
                <span class="dot"></span>
            </div>

        </main>

        <!-- FOOTER -->
        <footer>
            <a href="TrangChu.aspx" class="logo-box">
                <svg width="65" height="32" viewBox="0 0 80 40" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M10 30L40 8L70 30" stroke="#D68C94" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M22 25L45 14L62 28" stroke="#D68C94" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M55 12V19" stroke="#D68C94" stroke-width="3.5" stroke-linecap="round"/>
                </svg>
                <span>Hanoi</span>
                <span>Stay Nest</span>
            </a>

            <div class="footer-center">
                <div class="footer-links">
                    <a href="#">Giới thiệu</a>
                    <span>|</span>
                    <a href="#">Điều khoản</a>
                    <span>|</span>
                    <a href="#">Liên hệ</a>
                    <span>|</span>
                    <a href="#">Chính sách</a>
                </div>
                <div class="copyright">copyright@HanoiStayNest.com</div>
            </div>
        </footer>

        <!-- Script điều khiển đóng/mở menu Địa điểm & Giá -->
        <script>
            function toggleMenu(menuId) {
                event.stopPropagation();
                var menu = document.getElementById(menuId);
                var isShow = menu.classList.contains('show');
                closeAllMenus();
                if (!isShow) {
                    menu.classList.add('show');
                }
            }

            function chonDiaDiem(val) {
                document.getElementById('<%= txtDiaDiem.ClientID %>').value = val;
                closeAllMenus();
                document.getElementById('<%= btnTimKiem.ClientID %>').click();
            }

            function chonSapXepGia(sortType, labelText) {
                document.getElementById('<%= hfSapXepGia.ClientID %>').value = sortType;
                document.getElementById('<%= txtHienThiGia.ClientID %>').value = labelText;
                closeAllMenus();
    
    // Tự động kích hoạt lọc ngay sau khi chọn Giá
                document.getElementById('<%= btnTimKiem.ClientID %>').click();
            }

            function closeAllMenus() {
                var menus = document.querySelectorAll('.custom-dropdown-menu');
                menus.forEach(function (m) { m.classList.remove('show'); });
            }

            document.addEventListener('click', function () {
                closeAllMenus();
            });
        </script>
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                const grid = document.querySelector(".room-grid");
                const dotsContainer = document.querySelector(".pagination-dots");
                if (!grid || !dotsContainer) return;

                const cards = Array.from(grid.querySelectorAll(".room-card"));
                const perPage = 3; // Mỗi trang hiển thị 3 phòng
                const totalPages = Math.max(1, Math.ceil(cards.length / perPage));
                let currentPage = 0;
                let autoSlideTimer;

                // Tự động tạo đúng số dấu chấm tương ứng với số trang phòng
                dotsContainer.innerHTML = "";
                for (let i = 0; i < totalPages; i++) {
                    const dot = document.createElement("span");
                    dot.className = "dot" + (i === 0 ? " active" : "");
                    dot.addEventListener("click", function () {
                        goToPage(i);
                        resetAutoSlide();
                    });
                    dotsContainer.appendChild(dot);
                }

                const dots = Array.from(dotsContainer.querySelectorAll(".dot"));

                function renderPage(pageIndex) {
                    cards.forEach((card, idx) => {
                        const start = pageIndex * perPage;
                        const end = start + perPage;
                        card.style.display = (idx >= start && idx < end) ? "flex" : "none";
                    });

                    dots.forEach((d, idx) => {
                        d.classList.toggle("active", idx === pageIndex);
                    });
                }

                function goToPage(pageIndex) {
                    if (pageIndex === currentPage || totalPages <= 1) return;
                    grid.classList.add("slide-out");

                    setTimeout(() => {
                        currentPage = pageIndex;
                        renderPage(currentPage);
                        grid.classList.remove("slide-out");
                    }, 250);
                }

                function startAutoSlide() {
                    if (totalPages <= 1) return;
                    autoSlideTimer = setInterval(() => {
                        const nextPage = (currentPage + 1) % totalPages;
                        goToPage(nextPage);
                    }, 4000); // Tự động lướt sang trang tiếp theo sau mỗi 4 giây
                }

                function resetAutoSlide() {
                    clearInterval(autoSlideTimer);
                    startAutoSlide();
                }

                // Khởi tạo trang đầu tiên và bật chạy tự động
                renderPage(0);
                startAutoSlide();

                // Tạm dừng tự động chạy khi người dùng di chuột vào thẻ phòng
                grid.addEventListener("mouseenter", () => clearInterval(autoSlideTimer));
                grid.addEventListener("mouseleave", startAutoSlide);
            });
        </script>

    </form>
</body>
</html>