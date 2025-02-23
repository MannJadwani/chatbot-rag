using System;
using System.Web.UI;

namespace GeminiChatBot
{
    public partial class SiteMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Username"] != null)
            {
                // Logged in: show the user button, logout button, and hide login/register
                userNavLink.InnerText = "Hello, " + Session["Username"].ToString();
                userNavItem.Visible = true;
                logoutNavItem.Visible = true;
                loginNavItem.Visible = false;
                registerNavItem.Visible = false;
            }
            else
            {
                // Logged out: show login and register buttons, hide user and logout buttons.
                userNavItem.Visible = false;
                logoutNavItem.Visible = false;
                loginNavItem.Visible = true;
                registerNavItem.Visible = true;
            }
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            // Clear the session and redirect to login or home page.
            Session.Clear();
            Response.Redirect("~/Login.aspx");
        }
    }
}
