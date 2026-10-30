using System;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Windows.Forms;

namespace projectGUI
{
    public partial class Form1 : Form
    {
        public readonly string connectionString = "Server=localhost;Database=EcommerceDB;Trusted_Connection=True;";
        private int? currentUserId;
        private int? currentCartId;

        public Form1()
        {
            InitializeComponent();
            InitializeUI();
        }

        private void InitializeUI()
        {
            this.Text = "E-Commerce Management System";
            this.Size = new Size(1150, 850);
            this.MinimumSize = new Size(900, 700);

            TabControl tabControl = new TabControl { Dock = DockStyle.Fill, Padding = new Point(10, 5) };
            TabPage tabAuth = new TabPage("Account & Profile");
            TabPage tabProducts = new TabPage("Shop Products");
            TabPage tabOrders = new TabPage("Cart & My Orders");

            Panel pnlLogin = new Panel { Dock = DockStyle.Fill, Padding = new Padding(50) };
            pnlLogin.Controls.Add(new Label { Text = "Customer Login", Font = new Font(this.Font, FontStyle.Bold), Location = new Point(50, 20), AutoSize = true });
            pnlLogin.Controls.Add(new Label { Text = "Email:", Location = new Point(50, 60) });
            TextBox txtEmail = new TextBox { Location = new Point(150, 57), Width = 200 };
            pnlLogin.Controls.Add(new Label { Text = "Password:", Location = new Point(50, 90) });
            TextBox txtPass = new TextBox { Location = new Point(150, 87), Width = 200, PasswordChar = '●' };
            Button btnLogin = new Button { Text = "Login", Location = new Point(150, 120), Width = 90, BackColor = Color.LightGreen, Cursor = Cursors.Hand };
            Button btnReg = new Button { Text = "Register", Location = new Point(260, 120), Width = 90, BackColor = Color.LightBlue, Cursor = Cursors.Hand };
            pnlLogin.Controls.AddRange(new Control[] { txtEmail, txtPass, btnLogin, btnReg });



            Panel pnlProfile = new Panel { Dock = DockStyle.Fill, Padding = new Padding(30), Visible = false };
            pnlProfile.Controls.Add(new Label { Text = "Manage My Profile", Font = new Font(this.Font, FontStyle.Bold), Location = new Point(30, 10), AutoSize = true });
            TableLayoutPanel tlpProf = new TableLayoutPanel { Location = new Point(30, 50), Size = new Size(400, 200), ColumnCount = 2 };
            tlpProf.Controls.Add(new Label { Text = "Email:" }, 0, 0); TextBox txtPnlEmail = new TextBox { Width = 200 }; tlpProf.Controls.Add(txtPnlEmail, 1, 0);
            tlpProf.Controls.Add(new Label { Text = "City:" }, 0, 1); TextBox txtPnlCity = new TextBox { Width = 200 }; tlpProf.Controls.Add(txtPnlCity, 1, 1);
            tlpProf.Controls.Add(new Label { Text = "Street:" }, 0, 2); TextBox txtPnlStreet = new TextBox { Width = 200 }; tlpProf.Controls.Add(txtPnlStreet, 1, 2);
            tlpProf.Controls.Add(new Label { Text = "Building:" }, 0, 3); NumericUpDown numPnlBuild = new NumericUpDown { Maximum = 9999 }; tlpProf.Controls.Add(numPnlBuild, 1, 3);
            tlpProf.Controls.Add(new Label { Text = "Apartment:" }, 0, 4); NumericUpDown numPnlApt = new NumericUpDown { Maximum = 9999 }; tlpProf.Controls.Add(numPnlApt, 1, 4);

            Button btnSaveProfile = new Button { Text = "Update Profile", Location = new Point(30, 270), Width = 110, BackColor = Color.LightSkyBlue, Cursor = Cursors.Hand };
            Button btnLogout = new Button { Text = "Logout", Location = new Point(160, 270), Width = 100, Cursor = Cursors.Hand };
            pnlProfile.Controls.AddRange(new Control[] { tlpProf, btnSaveProfile, btnLogout });

            tabAuth.Controls.AddRange(new Control[] { pnlProfile, pnlLogin });

            
            Panel pnlProdTop = new Panel { Dock = DockStyle.Top, Height = 60, Padding = new Padding(10) };
            ComboBox cmbCat = new ComboBox { Location = new Point(10, 18), Width = 150, DropDownStyle = ComboBoxStyle.DropDownList };
            cmbCat.Items.AddRange(new string[] { "Electronics", "Clothing", "Home Appliances", "Books", "Sports" });
            if (cmbCat.Items.Count > 0) cmbCat.SelectedIndex = 0;

            Button btnFilter = new Button { Text = "Filter Category", Location = new Point(170, 15), Width = 110, Cursor = Cursors.Hand };
            Button btnAllProd = new Button { Text = "View All", Location = new Point(290, 15), Width = 80, Cursor = Cursors.Hand };
            Button btnViewRv = new Button { Text = "View Reviews", Location = new Point(380, 15), Width = 110, Cursor = Cursors.Hand };
            Button btnAddToCart = new Button { Text = "🛒 Add to Cart", Location = new Point(500, 15), Width = 120, BackColor = Color.Gold, Cursor = Cursors.Hand };
            pnlProdTop.Controls.AddRange(new Control[] { cmbCat, btnFilter, btnAllProd, btnViewRv, btnAddToCart });

            DataGridView gridProducts = new DataGridView { Dock = DockStyle.Fill, ReadOnly = true, SelectionMode = DataGridViewSelectionMode.FullRowSelect, AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill, BackgroundColor = Color.WhiteSmoke };
            tabProducts.Controls.AddRange(new Control[] { gridProducts, pnlProdTop });


            SplitContainer splitOrders = new SplitContainer { Dock = DockStyle.Fill, Orientation = Orientation.Horizontal, SplitterDistance = 300 };

            // Cart Section
            GroupBox grpCart = new GroupBox { Text = "My Shopping Cart", Dock = DockStyle.Fill, Font = new Font(this.Font, FontStyle.Bold) };
            DataGridView gridCart = new DataGridView { Dock = DockStyle.Fill, ReadOnly = true, SelectionMode = DataGridViewSelectionMode.FullRowSelect, AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill, Font = new Font(this.Font, FontStyle.Regular) };
            Panel pnlCartBtn = new Panel { Dock = DockStyle.Bottom, Height = 50 };
            Button btnRemCart = new Button { Text = "Remove Item", Location = new Point(10, 10), Width = 110, BackColor = Color.LightCoral };
            Button btnCheckout = new Button { Text = "💳 Checkout & Create Order", Location = new Point(130, 10), Width = 200, BackColor = Color.Orange, Cursor = Cursors.Hand };
            pnlCartBtn.Controls.AddRange(new Control[] { btnRemCart, btnCheckout });
            grpCart.Controls.AddRange(new Control[] { gridCart, pnlCartBtn });

            // Order History & Review Section
            GroupBox grpHistory = new GroupBox { Text = "Order History & Management", Dock = DockStyle.Fill, Font = new Font(this.Font, FontStyle.Bold) };
            DataGridView gridOrders = new DataGridView { Dock = DockStyle.Fill, ReadOnly = true, SelectionMode = DataGridViewSelectionMode.FullRowSelect, AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill, Font = new Font(this.Font, FontStyle.Regular) };
            Panel pnlHistoryBtn = new Panel { Dock = DockStyle.Bottom, Height = 120 };

            // Row 1: Status & Navigation
            Button btnDetails = new Button { Text = "View Details", Location = new Point(10, 10), Width = 100, Cursor = Cursors.Hand };
            Button btnBackHistory = new Button { Text = "⬅ Back to History", Location = new Point(10, 10), Width = 120, Visible = false, BackColor = Color.LightCyan, Cursor = Cursors.Hand };
            Button btnStatus = new Button { Text = "Payment Status", Location = new Point(130, 10), Width = 110, Cursor = Cursors.Hand };
            Button btnCancel = new Button { Text = "Cancel Order", Location = new Point(250, 10), Width = 100, BackColor = Color.MistyRose, Cursor = Cursors.Hand };
            Button btnShip = new Button { Text = "Simulate Shipment", Location = new Point(360, 10), Width = 130, BackColor = Color.LightSteelBlue, Cursor = Cursors.Hand };

            // Row 2: Payments
            Label lblPaySelect = new Label { Text = "Payment Method:", Location = new Point(10, 48), AutoSize = true, Font = new Font(this.Font, FontStyle.Regular) };
            ComboBox cmbPayment = new ComboBox { Location = new Point(130, 45), Width = 120, DropDownStyle = ComboBoxStyle.DropDownList };
            cmbPayment.Items.AddRange(new string[] { "Credit Card", "PayPal", "Cash" });
            if (cmbPayment.Items.Count > 0) cmbPayment.SelectedIndex = 0;
            Button btnPay = new Button { Text = "Pay Selected Order", Location = new Point(260, 43), Width = 150, BackColor = Color.LightGreen, Cursor = Cursors.Hand };

            // Row 3: Product Reviews
            Label lblRate = new Label { Text = "Rating (1-5):", Location = new Point(10, 83), AutoSize = true, Font = new Font(this.Font, FontStyle.Regular) };
            NumericUpDown numRate = new NumericUpDown { Location = new Point(90, 80), Width = 50, Minimum = 1, Maximum = 5, Value = 5 };
            Label lblComment = new Label { Text = "Review:", Location = new Point(150, 83), AutoSize = true, Font = new Font(this.Font, FontStyle.Regular) };
            TextBox txtComment = new TextBox { Location = new Point(210, 80), Width = 200 };
            Button btnSubmitReview = new Button { Text = "⭐ Submit Review", Location = new Point(420, 78), Width = 130, BackColor = Color.LightYellow, Cursor = Cursors.Hand };

            pnlHistoryBtn.Controls.AddRange(new Control[] {
                btnDetails, btnBackHistory, btnStatus, btnCancel, btnShip,
                lblPaySelect, cmbPayment, btnPay,
                lblRate, numRate, lblComment, txtComment, btnSubmitReview
            });
            grpHistory.Controls.AddRange(new Control[] { gridOrders, pnlHistoryBtn });

            splitOrders.Panel1.Controls.Add(grpCart);
            splitOrders.Panel2.Controls.Add(grpHistory);
            tabOrders.Controls.Add(splitOrders);

           

            btnLogin.Click += (s, e) => {
                DataTable res = Login(txtEmail.Text, txtPass.Text);
                if (res.Rows.Count > 0)
                {
                    currentUserId = Convert.ToInt32(res.Rows[0]["customerID"]);
                    currentCartId = GetOrCreateCart(currentUserId.Value);

                    pnlLogin.Visible = false; pnlProfile.Visible = true;

                    DataTable prof = GetProfile(currentUserId.Value);
                    if (prof.Rows.Count > 0)
                    {
                        txtPnlEmail.Text = prof.Rows[0]["Email"].ToString();
                        txtPnlCity.Text = prof.Rows[0]["city"].ToString();
                        txtPnlStreet.Text = prof.Rows[0]["street"].ToString();
                        numPnlBuild.Value = prof.Rows[0]["buildingNo"] != DBNull.Value ? Convert.ToDecimal(prof.Rows[0]["buildingNo"]) : 0;
                        numPnlApt.Value = prof.Rows[0]["apartmentNo"] != DBNull.Value ? Convert.ToDecimal(prof.Rows[0]["apartmentNo"]) : 0;
                    }

                    gridOrders.DataSource = GetMyOrders(currentUserId.Value);
                    gridCart.DataSource = GetCartItems(currentCartId.Value);
                    gridProducts.DataSource = GetInStockProducts();
                }
                else MessageBox.Show("Invalid Email or Password.", "Login Failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
            };

            btnLogout.Click += (s, e) => {
                currentUserId = currentCartId = null;
                pnlLogin.Visible = true; pnlProfile.Visible = false;
                gridOrders.DataSource = gridCart.DataSource = gridProducts.DataSource = null;
                txtEmail.Clear(); txtPass.Clear();
            };

            btnSaveProfile.Click += (s, e) => {
                UpdateCustomerProfile(currentUserId.Value, txtPnlEmail.Text, txtPnlCity.Text, txtPnlStreet.Text, (int)numPnlBuild.Value, (int)numPnlApt.Value);
                MessageBox.Show("Profile Updated Successfully!", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
            };

            btnReg.Click += (s, e) => {
                using (RegisterForm rf = new RegisterForm(connectionString)) { rf.ShowDialog(); }
            };

            // --- PRODUCTS ---
            btnAllProd.Click += (s, e) => { gridProducts.DataSource = GetInStockProducts(); };
            btnFilter.Click += (s, e) => { gridProducts.DataSource = GetProductsByCategory(cmbCat.Text); };

            btnViewRv.Click += (s, e) => {
                if (gridProducts.SelectedRows.Count > 0)
                {
                    DataGridViewRow row = gridProducts.SelectedRows[0];
                    int pid = -1;

                    
                    foreach (DataGridViewColumn col in gridProducts.Columns)
                    {
                        string cName = col.Name.ToLower().Replace(" ", "").Replace("_", "");
                        if (cName == "productid" || cName == "id")
                        {
                            pid = Convert.ToInt32(row.Cells[col.Name].Value);
                            break;
                        }
                    }

                    if (pid != -1)
                    {
                        DataTable reviews = GetReviewsByProduct(pid);
                        if (reviews.Rows.Count > 0)
                        {
                            gridProducts.DataSource = reviews;
                            MessageBox.Show("Displaying reviews in the grid. Click 'View All' to return to products.");
                        }
                        else MessageBox.Show("No reviews found for this product.");
                    }
                    else MessageBox.Show("Please select a valid product first.");
                }
                else MessageBox.Show("Please select a product first.");
            };

            btnAddToCart.Click += (s, e) => {
                if (!currentCartId.HasValue) return;
                if (gridProducts.SelectedRows.Count > 0)
                {
                    DataGridViewRow row = gridProducts.SelectedRows[0];
                    int pid = -1;

                    foreach (DataGridViewColumn col in gridProducts.Columns)
                    {
                        string cName = col.Name.ToLower().Replace(" ", "").Replace("_", "");
                        if (cName == "productid" || cName == "id")
                        {
                            pid = Convert.ToInt32(row.Cells[col.Name].Value);
                            break;
                        }
                    }

                    if (pid != -1)
                    {
                        AddOrUpdateCartItem(currentCartId.Value, pid, 1);
                        gridCart.DataSource = GetCartItems(currentCartId.Value);
                        MessageBox.Show("Item added to cart!");
                    }
                    else MessageBox.Show("Could not find the Product ID. Ensure you are viewing the product list.");
                }
                else MessageBox.Show("Please select a product first.");
            };

            // --- CART & ORDERS ---
            btnRemCart.Click += (s, e) => {
                if (currentCartId.HasValue && gridCart.SelectedRows.Count > 0)
                {
                    DataGridViewRow row = gridCart.SelectedRows[0];
                    int pid = -1;
                    foreach (DataGridViewColumn col in gridCart.Columns)
                    {
                        string cName = col.Name.ToLower().Replace(" ", "").Replace("_", "");
                        if (cName == "productid" || cName == "id")
                        {
                            pid = Convert.ToInt32(row.Cells[col.Name].Value);
                            break;
                        }
                    }
                    if (pid != -1)
                    {
                        RemoveFromCart(currentCartId.Value, pid);
                        gridCart.DataSource = GetCartItems(currentCartId.Value);
                    }
                }
            };

            btnCheckout.Click += (s, e) => {
                if (!currentCartId.HasValue || gridCart.Rows.Count == 0) return;

                int orderId = CreateOrderFromCart(currentCartId.Value);
                if (orderId > 0)
                {
                    decimal total = CalculateOrderTotal(orderId);
                    MessageBox.Show($"Checkout Successful!\nOrder #{orderId} placed.\nGrand Total (w/ Tax & Shipping): ${total:0.00}", "Checkout Complete", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    gridCart.DataSource = GetCartItems(currentCartId.Value);
                    gridOrders.DataSource = GetMyOrders(currentUserId.Value);
                }
            };

            btnDetails.Click += (s, e) => {
                if (gridOrders.SelectedRows.Count > 0)
                {
                    DataGridViewRow row = gridOrders.SelectedRows[0];
                    int oid = -1;

                    foreach (DataGridViewColumn col in gridOrders.Columns)
                    {
                        string cName = col.Name.ToLower().Replace(" ", "").Replace("_", "");
                        if (cName == "ordernumber" || cName == "orderid")
                        {
                            oid = Convert.ToInt32(row.Cells[col.Name].Value);
                            break;
                        }
                    }

                    if (oid != -1)
                    {
                        gridOrders.DataSource = GetOrderDetails(oid);
                        btnDetails.Visible = false; btnBackHistory.Visible = true;
                        grpHistory.Text = $"Order Details: #{oid}";
                    }
                }
            };

            btnBackHistory.Click += (s, e) => {
                gridOrders.DataSource = GetMyOrders(currentUserId.Value);
                btnBackHistory.Visible = false; btnDetails.Visible = true;
                grpHistory.Text = "Order History & Management";
            };

            btnStatus.Click += (s, e) => {
                if (gridOrders.SelectedRows.Count > 0 && btnDetails.Visible)
                {
                    DataGridViewRow row = gridOrders.SelectedRows[0];
                    int oid = -1;
                    foreach (DataGridViewColumn col in gridOrders.Columns)
                    {
                        string cName = col.Name.ToLower().Replace(" ", "").Replace("_", "");
                        if (cName == "ordernumber" || cName == "orderid")
                        {
                            oid = Convert.ToInt32(row.Cells[col.Name].Value);
                            break;
                        }
                    }

                    if (oid != -1)
                    {
                        DataTable ps = GetPaymentStatus(oid);
                        if (ps.Rows.Count > 0)
                            MessageBox.Show($"Status: {ps.Rows[0]["PaymentStatus"]}\nAmount Paid: ${ps.Rows[0]["Amount"]}", "Payment Status");
                        else
                            MessageBox.Show("No payment records found for this order.", "Payment Status");
                    }
                }
                else MessageBox.Show("Please select an order from the main history view.");
            };

            btnPay.Click += (s, e) => {
                if (gridOrders.SelectedRows.Count > 0 && btnDetails.Visible)
                {
                    DataGridViewRow row = gridOrders.SelectedRows[0];
                    int oid = -1;

                    foreach (DataGridViewColumn col in gridOrders.Columns)
                    {
                        string cName = col.Name.ToLower().Replace(" ", "").Replace("_", "");
                        if (cName == "ordernumber" || cName == "orderid")
                        {
                            oid = Convert.ToInt32(row.Cells[col.Name].Value);
                            break;
                        }
                    }

                    if (oid != -1)
                    {
                        DataTable ps = GetPaymentStatus(oid);
                        if (ps.Rows.Count > 0 && ps.Rows[0]["PaymentStatus"].ToString() == "Completed")
                        {
                            MessageBox.Show("This order has already been paid in full.", "Already Paid", MessageBoxButtons.OK, MessageBoxIcon.Information);
                            return;
                        }

                        decimal totalAmount = CalculateOrderTotal(oid);
                        if (totalAmount > 0)
                        {
                            ProcessPayment(oid, cmbPayment.Text, totalAmount);
                            MessageBox.Show($"Payment of ${totalAmount:0.00} via {cmbPayment.Text} Processed Successfully!", "Payment Complete");
                            gridOrders.DataSource = GetMyOrders(currentUserId.Value);
                        }
                    }
                }
                else MessageBox.Show("Please select an order from the main history view to pay.");
            };

            btnCancel.Click += (s, e) => {
                if (gridOrders.SelectedRows.Count > 0 && btnDetails.Visible)
                {
                    DataGridViewRow row = gridOrders.SelectedRows[0];
                    int oid = -1;
                    foreach (DataGridViewColumn col in gridOrders.Columns)
                    {
                        string cName = col.Name.ToLower().Replace(" ", "").Replace("_", "");
                        if (cName == "ordernumber" || cName == "orderid")
                        {
                            oid = Convert.ToInt32(row.Cells[col.Name].Value);
                            break;
                        }
                    }

                    if (oid != -1)
                    {
                        CancelOrder(oid);
                        MessageBox.Show($"Order #{oid} Cancelled. Stock has been restored.");
                        gridOrders.DataSource = GetMyOrders(currentUserId.Value);
                    }
                }
                else MessageBox.Show("Please select an order from the main history view to cancel.");
            };

            // Shipment Handler
            btnShip.Click += (s, e) => {
                if (gridOrders.SelectedRows.Count > 0 && btnDetails.Visible)
                {
                    DataGridViewRow row = gridOrders.SelectedRows[0];
                    int oid = -1;
                    foreach (DataGridViewColumn col in gridOrders.Columns)
                    {
                        string cName = col.Name.ToLower().Replace(" ", "").Replace("_", "");
                        if (cName == "ordernumber" || cName == "orderid")
                        {
                            oid = Convert.ToInt32(row.Cells[col.Name].Value);
                            break;
                        }
                    }

                    if (oid != -1)
                    {
                        string trk = "TRK-" + Guid.NewGuid().ToString().Substring(0, 8).ToUpper();
                        AssignShipment(oid, trk);
                        MessageBox.Show($"Order #{oid} marked as Shipped!\nTracking ID: {trk}\n\nYou can now view order details to submit product reviews.", "Shipment Assigned", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    }
                }
                else MessageBox.Show("Please select an order from the main history view to ship.");
            };

            
            btnSubmitReview.Click += (s, e) => {
                if (btnDetails.Visible)
                {
                    MessageBox.Show("Please click 'View Details' first to open the order, then select a specific product line-item to review.", "Action Required", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    return;
                }

                if (gridOrders.SelectedRows.Count > 0)
                {
                    DataGridViewRow row = gridOrders.SelectedRows[0];
                    int pid = -1;
                    string pName = "Selected Product";

                    // 1. the Product ID or Name natively in the grid
                    foreach (DataGridViewColumn col in gridOrders.Columns)
                    {
                        string cName = col.Name.ToLower().Replace(" ", "").Replace("_", "");

                        if (cName == "productid" || cName == "id")
                        {
                            if (row.Cells[col.Name].Value != null && row.Cells[col.Name].Value != DBNull.Value)
                                pid = Convert.ToInt32(row.Cells[col.Name].Value);
                        }

                        if (cName == "productname" || cName == "name" || cName == "product")
                        {
                            if (row.Cells[col.Name].Value != null && row.Cells[col.Name].Value != DBNull.Value)
                                pName = row.Cells[col.Name].Value.ToString();
                        }
                    }

                    // 2.  If the SQL function hides the ProductID entirely, grab it from the DB using the Name
                    if (pid == -1 && pName != "Selected Product")
                    {
                        DataTable dtLookup = GetData("SELECT ProductID FROM Product WHERE Name = @n", false, new[] { new SqlParameter("@n", pName) });
                        if (dtLookup.Rows.Count > 0)
                        {
                            pid = Convert.ToInt32(dtLookup.Rows[0][0]);
                        }
                    }

                    // 3. Submit
                    if (pid != -1)
                    {
                        if (string.IsNullOrWhiteSpace(txtComment.Text))
                        {
                            MessageBox.Show("Please type a comment for your review.", "Validation Error");
                            return;
                        }

                        try
                        {
                            AddProductReview(currentUserId.Value, pid, (int)numRate.Value, txtComment.Text);
                            MessageBox.Show($"Review submitted successfully for {pName}!", "Success");
                            txtComment.Clear();
                            numRate.Value = 5;
                        }
                        catch (Exception ex)
                        {
                            MessageBox.Show("Failed to submit review. Ensure the order has been shipped first.\n\nDatabase returned: " + ex.Message, "Review Failed");
                        }
                    }
                    else
                    {
                        MessageBox.Show("Could not identify the Product ID from the details screen. The product may no longer exist.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
                else
                {
                    MessageBox.Show("Please select a specific product row to review.");
                }
            };

            tabControl.TabPages.AddRange(new TabPage[] { tabAuth, tabProducts, tabOrders });
            this.Controls.Add(tabControl);
        }

        
        private DataTable GetData(string commandText, bool isStoredProc = false, SqlParameter[] parameters = null)
        {
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(commandText, conn))
                {
                    cmd.CommandType = isStoredProc ? CommandType.StoredProcedure : CommandType.Text;
                    if (parameters != null) cmd.Parameters.AddRange(parameters);
                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd)) { adapter.Fill(dt); }
                }
            }
            catch (Exception ex) { MessageBox.Show("DB Error: " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error); }
            return dt;
        }

        private int ExecuteAction(string commandText, bool isStoredProc = false, SqlParameter[] parameters = null)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(commandText, conn))
                {
                    cmd.CommandType = isStoredProc ? CommandType.StoredProcedure : CommandType.Text;
                    if (parameters != null) cmd.Parameters.AddRange(parameters);
                    conn.Open(); return cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex) { MessageBox.Show("DB Error: " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error); return 0; }
        }

       

        public DataTable Login(string email, string password) =>
            GetData("SELECT customerID, Username FROM Customer WHERE Email = @Email AND [Password] = @Password", false, new[] { new SqlParameter("@Email", email), new SqlParameter("@Password", password) });

        public DataTable GetProfile(int userId) =>
            GetData(@"SELECT c.Username, c.Email, c.PhoneNumber, ca.city, ca.street, ca.buildingNo, ca.apartmentNo 
                      FROM Customer c LEFT JOIN Customer_Address ca ON c.customerID = ca.customerID 
                      WHERE c.customerID = @CustomerID", false, new[] { new SqlParameter("@CustomerID", userId) });

        public void UpdateCustomerProfile(int customerId, string email, string city, string street, int buildingNo, int? apartmentNo)
        {
            var parameters = new System.Collections.Generic.List<SqlParameter> {
                new SqlParameter("@customer_id", customerId),
                new SqlParameter("@new_email", email),
                new SqlParameter("@new_city", city),
                new SqlParameter("@new_street", street),
                new SqlParameter("@new_buildingNo", buildingNo),
                new SqlParameter("@new_apartmentNo", (object)apartmentNo ?? DBNull.Value)
            };
            ExecuteAction("UpdateCustomerProfile", true, parameters.ToArray());
        }

        public DataTable GetInStockProducts() => GetData("GetAllInStockProducts", true);

        public DataTable GetProductsByCategory(string categoryName) =>
            GetData("SELECT * FROM dbo.GetProductsByCategory(@CategoryName)", false, new[] { new SqlParameter("@CategoryName", categoryName) });

        public DataTable GetReviewsByProduct(int productId) =>
            GetData("SELECT * FROM dbo.GetReviewsByProduct(@ProductID)", false, new[] { new SqlParameter("@ProductID", productId) });

        public int GetOrCreateCart(int userId)
        {
            DataTable dt = GetData("GetOrCreateCart", true, new[] { new SqlParameter("@CustomerID", userId) });
            return dt.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0]["ActiveCartID"]) : -1;
        }

        public DataTable GetCartItems(int cartId) => GetData("GetCartDetails", true, new[] { new SqlParameter("@CartID", cartId) });

        public void AddOrUpdateCartItem(int cartId, int productId, int qty) =>
            ExecuteAction("AddOrUpdateCartItem", true, new[] { new SqlParameter("@CartID", cartId), new SqlParameter("@ProductID", productId), new SqlParameter("@QuantityToAdd", qty) });

        public void RemoveFromCart(int cartId, int productId) =>
            ExecuteAction("RemoveCartItem", true, new[] { new SqlParameter("@CartID", cartId), new SqlParameter("@ProductID", productId) });

        public int CreateOrderFromCart(int cartId)
        {
            if (!currentUserId.HasValue) return -1;
            DataTable dt = GetData("PlaceOrder", true, new[] { new SqlParameter("@CustomerID", currentUserId.Value), new SqlParameter("@CartID", cartId) });
            return dt.Rows.Count > 0 && dt.Rows[0]["OrderID"] != DBNull.Value ? Convert.ToInt32(dt.Rows[0]["OrderID"]) : -1;
        }

        public decimal CalculateOrderTotal(int orderId)
        {
            DataTable dt = GetData("SELECT dbo.CalculateOrderTotal(@OrderID)", false, new[] { new SqlParameter("@OrderID", orderId) });
            return dt.Rows.Count > 0 && dt.Rows[0][0] != DBNull.Value ? Convert.ToDecimal(dt.Rows[0][0]) : 0;
        }

        public DataTable GetMyOrders(int userId)
        {
            DataTable dt = GetData("SELECT * FROM dbo.GetCustomerOrderHistory(@customer_id)", false, new[] { new SqlParameter("@customer_id", userId) });
            dt.DefaultView.Sort = "orderDate DESC"; return dt.DefaultView.ToTable();
        }

        public DataTable GetOrderDetails(int orderId) =>
            GetData("SELECT * FROM dbo.GetOrderDetails(@OrderID)", false, new[] { new SqlParameter("@OrderID", orderId) });

        public DataTable GetPaymentStatus(int orderId) =>
            GetData("SELECT * FROM dbo.GetPaymentStatus(@OrderNumber)", false, new[] { new SqlParameter("@OrderNumber", orderId) });

        public void ProcessPayment(int orderId, string paymentMethod, decimal amount) =>
            ExecuteAction("ProcessPayment", true, new[] { new SqlParameter("@OrderNumber", orderId), new SqlParameter("@Method", paymentMethod), new SqlParameter("@Amount", amount) });

        public void CancelOrder(int orderId) =>
            ExecuteAction("CancelOrder", true, new[] { new SqlParameter("@OrderID", orderId) });

        public void AssignShipment(int orderId, string trackingNumber) =>
            ExecuteAction("AssignShipment", true, new[] { new SqlParameter("@OrderID", orderId), new SqlParameter("@TrackingNumber", trackingNumber) });

        public void AddProductReview(int customerId, int productId, int rating, string comment) =>
            ExecuteAction("AddProductReview", true, new[] {
                new SqlParameter("@customer_id", customerId), new SqlParameter("@product_id", productId),
                new SqlParameter("@rating", rating), new SqlParameter("@comment", comment) });
    }
}