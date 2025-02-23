using System;
using System.Web.UI;

namespace GeminiChatBot
{
    public partial class UserPage : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // You can populate the user info from session, a database, etc.
                if (Session["Username"] != null)
                {
                    lblUsername.Text = Session["Username"].ToString();
                    // If you stored an email in session or a DB call, set that too
                    lblEmail.Text = Session["Email"] != null ? Session["Email"].ToString() : "Email not found";
                }
                else
                {
                    // If no user is logged in, redirect to login, or show a message
                    Response.Redirect("~/Login.aspx");
                }
            }
        }
    }
}
