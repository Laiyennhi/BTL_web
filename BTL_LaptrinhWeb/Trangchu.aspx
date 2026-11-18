<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TrangChu.aspx.cs" Inherits="BTL_Web.TrangChu" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang chủ | Hanoi Stay Nest</title>
    <link rel="stylesheet" href="stylesheet/style.css?v=7" />
</head>
<body>
    <form id="form1" runat="server" style="display: flex; flex-direction: column; min-height: 100vh;">

        <!-- HEADER ĐÃ ĐỒNG BỘ PHÂN QUYỀN -->
        <header>
            <a href="TrangChu.aspx" class="logo-box">
                <svg width="65" height="32" viewBox="0 0 80 40" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M10 30L40 8L70 30" stroke="#D68C94" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round" />
                    <path d="M22 25L45 14L62 28" stroke="#D68C94" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" />
                    <path d="M55 12V19" stroke="#D68C94" stroke-width="3.5" stroke-linecap="round" />
                </svg>
                <span>Hanoi</span>
                <span>Stay Nest</span>
            </a>

            <ul class="nav-menu">
                <li><a href="TrangChu.aspx" class="active">Trang chủ</a></li>
                <% if (Session["UserID"] != null)
                    { %>
                <li><a href="Favorites.aspx">Yêu Thích</a></li>
                <li><a href="Bookings.aspx">Hoạt động</a></li>
                <% }
                    else
                    { %>
                <li><a href="Profile.aspx">Yêu Thích</a></li>
                <li><a href="Profile.aspx">Hoạt động</a></li>
                <% } %>
            </ul>

            <div class="avatar-menu-wrapper">
                <button type="button" class="header-avatar-btn" onclick="toggleAccountMenu(event)" title="Tài khoản">
                    <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
                        <circle cx="50" cy="50" r="50" fill="#F8B8BE" />
                        <circle cx="50" cy="38" r="17" fill="#FFFFFF" />
                        <path d="M20 88C20 68 33 58 50 58C67 58 80 68 80 88" fill="#FFFFFF" />
                    </svg>
                </button>

                <div id="accountPopover" class="account-popover-menu">
                    <% if (Session["UserID"] != null)
                        { %>
                    <a href="Account.aspx" class="popover-user-header">
                        <div class="popover-mini-avatar">
                            <%= (Session["FullName"] != null && Session["FullName"].ToString().Length > 0)
                                    ? Session["FullName"].ToString().Substring(0, 1).ToUpper() : "U" %>
                        </div>
                        <div class="popover-user-info">
                            <div class="popover-user-name"><%= Session["FullName"] ?? "Thành viên" %></div>
                            <div class="popover-user-sub"><%= Session["Email"] ?? Session["UserEmail"] ?? "Khách thuê phòng" %></div>
                        </div>
                        <span class="popover-chevron">›</span>
                    </a>

                    <div class="popover-divider"></div>

                    <a href="Account.aspx" class="popover-menu-row"><span>👤 Thông tin cá nhân</span></a>
                    <a href="Bookings.aspx" class="popover-menu-row"><span>📅 Hoạt động đặt phòng</span></a>
                    <a href="Favorites.aspx" class="popover-menu-row"><span>❤️ Danh sách yêu thích</span></a>

                    <div class="popover-divider"></div>

                    <% 
                        string currentRole = Session["Role"] != null ? Session["Role"].ToString() : "Guest";
                        if (currentRole == "Admin")
                        {
                    %>
                    <a href="AdminDashboard.aspx?tab=users" class="popover-menu-row" style="color: #b83b5e; font-weight: 600;">
                        <span>🛡️ Quản trị hệ thống (Admin)</span>
                    </a>
                    <% }
                        else if (currentRole == "Host")
                        { %>
                    <a href="HostDashboard.aspx?tab=bookings" class="popover-menu-row" style="color: #d66b76; font-weight: 600;">
                        <span>📋 Kênh Chủ phòng (Đơn đặt)</span>
                    </a>
                    <a href="HostDashboard.aspx?tab=rooms" class="popover-menu-row">
                        <span>🏠 Phòng của tôi</span>
                    </a>
                    <% }
                        else
                        { %>
                    <a href="HostDashboard.aspx?tab=rooms" class="popover-menu-row" style="color: #d66b76; font-weight: 600;"
                        onclick="return confirm('Chuyển sang chế độ Chủ phòng (Host) ngay bây giờ?');">
                        <span>🏠 Chuyển sang chế độ Host</span>
                    </a>
                    <% } %>

                    <div class="popover-divider"></div>

                    <a href="#" class="popover-menu-row"><span style="flex: 1;">🛟 Trợ giúp</span><span class="popover-chevron">›</span></a>
                    <a href="Logout.aspx" class="popover-menu-row" onclick="return confirm('Bạn có chắc chắn muốn đăng xuất?');"><span>🚪 Đăng xuất</span></a>
                    <% }
                        else
                        { %>
                    <div class="popover-user-header" style="cursor: default;">
                        <div class="popover-mini-avatar" style="background-color: #f8b8be;">?</div>
                        <div class="popover-user-info">
                            <div class="popover-user-name">Khách</div>
                            <div class="popover-user-sub">Chưa đăng nhập</div>
                        </div>
                    </div>
                    <div class="popover-divider"></div>
                    <a href="Profile.aspx" class="popover-menu-row"><span>🔑 <strong>Đăng nhập / Đăng ký</strong></span></a>
                    <div class="popover-divider"></div>
                    <a href="#" class="popover-menu-row"><span style="flex: 1;">🛟 Trợ giúp</span><span class="popover-chevron">›</span></a>
                    <% } %>
                </div>
            </div>
        </header>

        <!-- MAIN CONTENT -->
        <main style="flex: 1; display: flex; flex-direction: column;">

            <!-- Thanh tìm kiếm & Lọc giá -->
            <div class="search-bar-container">
                <div class="filter-box-wrapper">
                    <asp:TextBox ID="txtDiaDiem" runat="server" CssClass="search-select"
                        placeholder="Khu vực Hà Nội..." autocomplete="off"
                        onclick="toggleMenu('menuDiaDiem')"
                        onkeyup="filterDiaDiem()"></asp:TextBox>
                    <button type="button" class="dropdown-arrow-btn" onclick="toggleMenu('menuDiaDiem')">v</button>

                    <div id="menuDiaDiem" class="custom-dropdown-menu">
                        <div class="dropdown-item-row" onclick="chonDiaDiem('')" style="font-weight: 500; color: #d68c94;">
                            <span>Tất cả khu vực Hà Nội</span>
                        </div>

                        <asp:Repeater ID="rptDiaDiem" runat="server">
                            <ItemTemplate>
                                <div class="dropdown-item-row" onclick="chonDiaDiem('<%# Eval("Value") %>')">
                                    <span><%# Eval("Value") %></span>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>

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
                                <a href='ChitietPhong.aspx?id=<%# Eval("RoomID") %>'>
                                    <img src='<%# Eval("ImageUrl") %>' alt='<%# Eval("Title") %>'
                                        onerror="this.src='https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=600&q=80'" />
                                </a>

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
            </div>

            <!-- Khu vực Địa điểm phổ biến tại Hà Nội -->
            <section class="popular-destinations-section">
                <div class="section-heading-row">
                    <div>
                        <h3 class="section-heading-title">Địa điểm phổ biến tại Hà Nội</h3>
                        <p class="section-heading-sub">Chọn nhanh khu vực bạn muốn dừng chân để lọc phòng ngay</p>
                    </div>
                </div>

                <div class="destinations-grid">
                    <div class="destination-card" onclick="chonDiaDiem('Hoàn Kiếm')">
                        <img src="https://images.unsplash.com/photo-1583417319070-4a69db38a482?auto=format&fit=crop&w=600&q=80" alt="Hoàn Kiếm" />
                        <div class="destination-overlay">
                            <div class="destination-name">Quận Hoàn Kiếm</div>
                            <div class="destination-desc">Phố Cổ & Hồ Gươm sôi động</div>
                        </div>
                    </div>

                    <div class="destination-card" onclick="chonDiaDiem('Tây Hồ')">
                        <img src="https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&w=600&q=80" alt="Tây Hồ" />
                        <div class="destination-overlay">
                            <div class="destination-name">Quận Tây Hồ</div>
                            <div class="destination-desc">View hồ thoáng mát, chill cuối tuần</div>
                        </div>
                    </div>

                    <div class="destination-card" onclick="chonDiaDiem('Ba Đình')">
                        <img src="https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=600&q=80" alt="Ba Đình" />
                        <div class="destination-overlay">
                            <div class="destination-name">Quận Ba Đình</div>
                            <div class="destination-desc">Trung tâm hành chính, yên tĩnh</div>
                        </div>
                    </div>

                    <div class="destination-card" onclick="chonDiaDiem('Đống Đa')">
                        <img src="https://images.unsplash.com/photo-1554995207-c18c203602cb?auto=format&fit=crop&w=600&q=80" alt="Đống Đa" />
                        <div class="destination-overlay">
                            <div class="destination-name">Quận Đống Đa</div>
                            <div class="destination-desc">Ẩm thực phong phú, giá mềm</div>
                        </div>
                    </div>
                </div>
            </section>

        </main>

        <!-- FOOTER -->
        <footer>
            <a href="TrangChu.aspx" class="logo-box">
                <svg width="65" height="32" viewBox="0 0 80 40" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M10 30L40 8L70 30" stroke="#D68C94" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round" />
                    <path d="M22 25L45 14L62 28" stroke="#D68C94" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" />
                    <path d="M55 12V19" stroke="#D68C94" stroke-width="3.5" stroke-linecap="round" />
                </svg>
                <span>Hanoi</span>
                <span>Stay Nest</span>
            </a>

            <div class="footer-center">
                <div class="footer-links">
                    <a href="javascript:void(0)" onclick="openFooterInfo('about')">Giới thiệu</a> |
                    <a href="javascript:void(0)" onclick="openFooterInfo('terms')">Điều khoản</a> |
                    <a href="javascript:void(0)" onclick="openFooterInfo('contact')">Liên hệ</a> |
                    <a href="javascript:void(0)" onclick="openFooterInfo('policy')">Chính sách</a>
                </div>
                <div class="copyright">copyright@HanoiStayNest.com</div>
            </div>
        </footer>

        <script>
            function removeVietnameseTones(str) {
                return str.normalize('NFD')
                    .replace(/[\u0300-\u036f]/g, '')
                    .replace(/đ/g, 'd').replace(/Đ/g, 'D')
                    .toLowerCase()
                    .trim();
            }

            function filterDiaDiem() {
                var input = document.getElementById('<%= txtDiaDiem.ClientID %>');
                var menu = document.getElementById('menuDiaDiem');
                if (!input || !menu) return;

                closeAllMenus();
                menu.classList.add('show');

                var keyword = removeVietnameseTones(input.value);
                var rows = menu.querySelectorAll('.dropdown-item-row');
                var visibleCount = 0;

                rows.forEach(function (row, index) {
                    if (index === 0) {
                        row.style.display = (keyword === '') ? 'flex' : 'none';
                        return;
                    }

                    var text = removeVietnameseTones(row.innerText || row.textContent);
                    if (text.indexOf(keyword) > -1) {
                        row.style.display = 'flex';
                        visibleCount++;
                    } else {
                        row.style.display = 'none';
                    }
                });

                var emptyMsg = document.getElementById('noLocationMatch');
                if (visibleCount === 0 && keyword !== '') {
                    if (!emptyMsg) {
                        emptyMsg = document.createElement('div');
                        emptyMsg.id = 'noLocationMatch';
                        emptyMsg.className = 'dropdown-item-row';
                        emptyMsg.style.color = '#999999';
                        emptyMsg.style.fontStyle = 'italic';
                        emptyMsg.style.cursor = 'default';
                        emptyMsg.innerText = 'Không tìm thấy khu vực phù hợp...';
                        menu.appendChild(emptyMsg);
                    }
                    emptyMsg.style.display = 'flex';
                } else if (emptyMsg) {
                    emptyMsg.style.display = 'none';
                }
            }

            function toggleMenu(menuId) {
                event.stopPropagation();
                var menu = document.getElementById(menuId);
                var isShow = menu.classList.contains('show');
                closeAllMenus();
                if (!isShow) {
                    menu.classList.add('show');
                    if (menuId === 'menuDiaDiem') {
                        filterDiaDiem();
                    }
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
                document.getElementById('<%= btnTimKiem.ClientID %>').click();
            }

            function closeAllMenus() {
                var menus = document.querySelectorAll('.custom-dropdown-menu');
                menus.forEach(function (m) { m.classList.remove('show'); });
            }

            document.addEventListener('DOMContentLoaded', function () {
                var txtDiaDiem = document.getElementById('<%= txtDiaDiem.ClientID %>');
                if (txtDiaDiem) {
                    txtDiaDiem.addEventListener('click', function (e) {
                        e.stopPropagation();
                    });
                }
            });

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
                const perPage = 6;
                const totalPages = Math.max(1, Math.ceil(cards.length / perPage));
                let currentPage = 0;
                let autoSlideTimer;

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
                    }, 4000);
                }

                function resetAutoSlide() {
                    clearInterval(autoSlideTimer);
                    startAutoSlide();
                }

                renderPage(0);
                startAutoSlide();

                grid.addEventListener("mouseenter", () => clearInterval(autoSlideTimer));
                grid.addEventListener("mouseleave", startAutoSlide);
            });
        </script>

        <script>
            function toggleAccountMenu(event) {
                event.stopPropagation();
                var menu = document.getElementById("accountPopover");
                if (menu) menu.classList.toggle("show");
            }

            document.addEventListener("click", function (e) {
                var menu = document.getElementById("accountPopover");
                var wrapper = document.querySelector(".avatar-menu-wrapper");
                if (menu && wrapper && !wrapper.contains(e.target)) {
                    menu.classList.remove("show");
                }
            });
        </script>
        <!-- MODAL THÔNG TIN FOOTER -->
        <div id="footerInfoModal" style="display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.45); z-index: 99999; align-items: center; justify-content: center;" onclick="if(event.target===this) this.style.display='none'">
            <div style="background: #fff; max-width: 480px; width: 90%; border-radius: 16px; padding: 24px; box-shadow: 0 10px 30px rgba(0,0,0,0.15); position: relative;">
                <button type="button" onclick="document.getElementById('footerInfoModal').style.display='none'"
                    style="position: absolute; right: 16px; top: 14px; border: none; background: none; font-size: 22px; cursor: pointer; color: #666;">
                    ×
                </button>
                <h3 id="footerModalTitle" style="color: #d66b76; margin: 0 0 12px 0; font-size: 19px;"></h3>
                <p id="footerModalBody" style="color: #444; font-size: 14.5px; line-height: 1.6; margin: 0;"></p>
            </div>
        </div>

        <script>
            function openFooterInfo(type) {
                const data = {
                    about: {
                        title: "Giới thiệu Hanoi Stay Nest",
                        body: "Hanoi Stay Nest là nền tảng kết nối khách du lịch với các căn hộ, homestay chất lượng tại trung tâm Hà Nội, hỗ trợ đặt phòng nhanh chóng và minh bạch."
                    },
                    terms: {
                        title: "Điều khoản sử dụng",
                        body: "Khách thuê cần cung cấp thông tin chính xác khi đặt phòng và tuân thủ nội quy của chủ nhà. Chủ phòng cam kết hình ảnh và giá niêm yết đúng thực tế."
                    },
                    contact: {
                        title: "Thông tin liên hệ",
                        body: "Hotline hỗ trợ: 1900 6868 | Email: support@hanoistaynest.com | Địa chỉ: Quận Hoàn Kiếm, Hà Nội."
                    },
                    policy: {
                        title: "Chính sách bảo mật & Hoàn hủy",
                        body: "Thông tin cá nhân của khách hàng được bảo mật tuyệt đối. Hỗ trợ hủy miễn phí trước 24 giờ so với thời điểm nhận phòng."
                    }
                };
                document.getElementById('footerModalTitle').innerText = data[type].title;
                document.getElementById('footerModalBody').innerText = data[type].body;
                document.getElementById('footerInfoModal').style.display = 'flex';
            }
        </script>

    </form>
</body>
</html>
