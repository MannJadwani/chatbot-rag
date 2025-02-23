using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;

namespace GeminiChatBot
{
    public partial class Login : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Redirect if already logged in
            if (Session["Username"] != null)
            {
                
                Response.Redirect("/chat");
            }
        }

        protected void BtnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();
            // Compute the hash of the provided password
            string hashedPassword = ComputeHash(password);

            // Retrieve connection string from Web.config
            string connStr = ConfigurationManager.ConnectionStrings["MyConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // Instead of just counting rows, we SELECT the UserId if credentials match
                string query = @"
            SELECT UserId
            FROM Users
            WHERE Username = @Username AND PasswordHash = @PasswordHash";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Username", username);
                cmd.Parameters.AddWithValue("@PasswordHash", hashedPassword);

                conn.Open();
                object result = cmd.ExecuteScalar();

                // If result is null, it means no record matched
                if (result != null)
                {
                    int userId = Convert.ToInt32(result);

                    // Store both username and userId in session
                    Session["Username"] = username;
                    Session["UserId"] = userId;

                    Response.Redirect("/chat");
                }
                else
                {
                    lblErrorMessage.Text = "Invalid username or password.";
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
