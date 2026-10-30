using System;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Windows.Forms;

namespace projectGUI
{
    public class RegisterForm : Form
    {
        private readonly string connectionString;

        public RegisterForm(string connString)
        {
            this.connectionString = connString;
            InitializeUI();
        }

        private void InitializeUI()
        {
            this.Text = "Customer Registration";
            this.Size = new Size(350, 320);
            this.StartPosition = FormStartPosition.CenterParent;
            this.FormBorderStyle = FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;

            TableLayoutPanel tlp = new TableLayoutPanel { Dock = DockStyle.Fill, Padding = new Padding(20), ColumnCount = 2 };
            tlp.Controls.Add(new Label { Text = "Name:", AutoSize = true }, 0, 0);
            TextBox txtName = new TextBox { Width = 150 }; tlp.Controls.Add(txtName, 1, 0);

            tlp.Controls.Add(new Label { Text = "Email:", AutoSize = true }, 0, 1);
            TextBox txtEmail = new TextBox { Width = 150 }; tlp.Controls.Add(txtEmail, 1, 1);

            tlp.Controls.Add(new Label { Text = "Password:", AutoSize = true }, 0, 2);
            TextBox txtPass = new TextBox { Width = 150, PasswordChar = '●' }; tlp.Controls.Add(txtPass, 1, 2);

            tlp.Controls.Add(new Label { Text = "Phone:", AutoSize = true }, 0, 3);
            TextBox txtPhone = new TextBox { Width = 150 }; tlp.Controls.Add(txtPhone, 1, 3);

            Button btnRegister = new Button { Text = "Register Account", Dock = DockStyle.Bottom, Height = 40, BackColor = Color.LightBlue, Cursor = Cursors.Hand };

            btnRegister.Click += (s, e) => {
                if (string.IsNullOrWhiteSpace(txtName.Text) || string.IsNullOrWhiteSpace(txtEmail.Text) || string.IsNullOrWhiteSpace(txtPass.Text))
                {
                    MessageBox.Show("Name, Email, and Password are required.", "Validation Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                try
                {
                    using (SqlConnection conn = new SqlConnection(connectionString))
                    using (SqlCommand cmd = new SqlCommand("RegisterCustomer", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@name", txtName.Text.Trim());
                        cmd.Parameters.AddWithValue("@email", txtEmail.Text.Trim());
                        cmd.Parameters.AddWithValue("@password", txtPass.Text);
                        cmd.Parameters.AddWithValue("@phone", txtPhone.Text.Trim());

                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                    MessageBox.Show("Registration Successful! You can now log in.", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    this.Close();
                }
                catch (SqlException ex)
                {
                    if (ex.Number == 2627 || ex.Number == 2601)
                    {
                        MessageBox.Show("An account with this Email already exists.", "Registration Failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                    else
                    {
                        MessageBox.Show("Database Error: " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
            };

            this.Controls.Add(tlp);
            this.Controls.Add(btnRegister);
        }
    }
}