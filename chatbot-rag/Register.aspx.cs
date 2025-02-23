using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;

namespace GeminiChatBot
{
    public partial class Register : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Optionally, redirect if already logged in
            if (Session["Username"] != null)
            {
                Response.Redirect("/chat");
            }
        }

        protected void BtnRegister_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text.Trim();
            string confirmPassword = txtConfirmPassword.Text.Trim();

            if (password != confirmPassword)
            {
                lblErrorMessage.Text = "Passwords do not match.";
                lblErrorMessage.Visible = true;
                return;
            }

            string hashedPassword = ComputeHash(password);
            string connStr = ConfigurationManager.ConnectionStrings["MyConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = "INSERT INTO Users (Username, Email, PasswordHash) VALUES (@Username, @Email, @PasswordHash)";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Username", username);
                cmd.Parameters.AddWithValue("@Email", email);
                cmd.Parameters.AddWithValue("@PasswordHash", hashedPassword);

                try
                {
                    conn.Open();
                    int result = cmd.ExecuteNonQuery();
                    if (result > 0)
                    {
                        // Registration successful; redirect to Login page.
                        Response.Redirect("Login.aspx");
                    }
                    else
                    {
                        lblErrorMessage.Text = "Registration failed. Please try again.";
                        lblErrorMessage.Visible = true;
                    }
                }
                catch (SqlException ex)
                {
                    lblErrorMessage.Text = "Error: " + ex.Message;
                    lblErrorMessage.Visible = true;
                }
            }
        }

        private string ComputeHash(string input)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = Encoding.UTF8.GetBytes(input);
                byte[] hashBytes = sha256.ComputeHash(bytes);
                return Convert.ToBase64String(hashBytes);
            }
        }
    }
}
