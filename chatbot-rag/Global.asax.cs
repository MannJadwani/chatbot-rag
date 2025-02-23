using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Optimization;
using System.Web.Routing;
using System.Web.Security;
using System.Web.SessionState;
using System.Diagnostics;

namespace chatbot_rag
{
    public class Global : HttpApplication
    {
        void Application_Start(object sender, EventArgs e)
        {
            // Code that runs on application startup
            // Call the local RegisterRoutes method
            RegisterRoutes(RouteTable.Routes);

            // If you want to keep bundling
            BundleConfig.RegisterBundles(BundleTable.Bundles);
        }

        protected void Application_AcquireRequestState(object sender, EventArgs e)
        {
            // Ensure session is available
            if (HttpContext.Current.Session == null)
                return;

            // Check the current page
            string currentPage = HttpContext.Current.Request.AppRelativeCurrentExecutionFilePath.ToLowerInvariant();
            Debug.WriteLine(currentPage);

            // Exclude login and registration pages from the check
            if (currentPage != "~/login" && currentPage != "~/register")
            {
                // If session doesn't have "Username", redirect to Login
                if (HttpContext.Current.Session["Username"] == null)
                {
                    HttpContext.Current.Response.Redirect("login");
                }
            }
        }
        public static void RegisterRoutes(RouteCollection routes)
        {
            // /login -> Login.aspx
            routes.MapPageRoute(
                routeName: "LoginRoute",
                routeUrl: "login",
                physicalFile: "~/Login.aspx"
            );

            // /register -> Register.aspx
            routes.MapPageRoute(
                routeName: "RegisterRoute",
                routeUrl: "register",
                physicalFile: "~/Register.aspx"
            );

            // /user -> User.aspx
            routes.MapPageRoute(
                routeName: "UserRoute",
                routeUrl: "user",
                physicalFile: "~/User.aspx"
            );

            // /chat -> Chat.aspx (no chatId)
            routes.MapPageRoute(
                routeName: "ChatNoId",
                routeUrl: "chat",
                physicalFile: "~/Chat.aspx"
            );

            // /chat/{chatId} -> Chat.aspx
            routes.MapPageRoute(
                routeName: "ChatById",
                routeUrl: "chat/{chatId}",
                physicalFile: "~/Chat.aspx"
            );
        }


    }
}
