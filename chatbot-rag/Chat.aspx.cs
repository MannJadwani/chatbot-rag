using System;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web;
using Newtonsoft.Json;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Configuration;
using System.Collections.Generic;
using System.IO;
using UglyToad.PdfPig;
using PdfPage = UglyToad.PdfPig.Content.Page; // Alias to avoid conflict with System.Web.UI.Page
using System.Net.Http.Headers;

namespace GeminiChatBot
{
    public partial class ChatPage : System.Web.UI.Page
    {
        private static readonly HttpClient client = new HttpClient();
        public bool IsChatActive { get; private set; }

        // In this simplified version, PDF text is stored as context in Session
        // and a PDF upload message is inserted with IsPDF = true.

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            if (!IsPostBack && Session["ChatHistory"] == null)
            {
                Session["ChatHistory"] = "";
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            Debug.WriteLine("Page_Load triggered.");
            // Ensure user is logged in
            if (Session["UserId"] == null)
            {
                Debug.WriteLine("User not logged in; redirecting to Login.aspx.");
                Response.Redirect("~/Login.aspx");
                return;
            }

            int userId = (int)Session["UserId"];
            Debug.WriteLine("Loading chat list for user: " + userId);
            // Always load chat list
            LoadChatList(userId);

            // Always attempt to load chat messages and update IsChatActive
            object chatIdValue = Page.RouteData.Values["chatId"];
            if (chatIdValue != null && int.TryParse(chatIdValue.ToString(), out int chatId) && UserBelongsToChat(userId, chatId))
            {
                Debug.WriteLine("User belongs to chat " + chatId + ". Loading messages.");
                LoadChatMessages(chatId);
                IsChatActive = true;
            }
            else
            {
                IsChatActive = false;
            }
        }

        // Helper method to retrieve the current chat ID from the route data.
        private int GetCurrentChatId()
        {
            object chatIdValue = Page.RouteData.Values["chatId"];
            if (chatIdValue != null && int.TryParse(chatIdValue.ToString(), out int chatId))
            {
                Debug.WriteLine("GetCurrentChatId: Found chat ID = " + chatId);
                return chatId;
            }
            Debug.WriteLine("GetCurrentChatId: No valid chat ID found.");
            throw new Exception("No valid chat ID available.");
        }

        // Extracts text from the PDF using UglyToad.PdfPig.
        private string ExtractTextFromPdf(byte[] pdfData)
        {
            Debug.WriteLine("ExtractTextFromPdf: Starting PDF extraction using PdfPig.");
            using (var stream = new MemoryStream(pdfData))
            {
                using (var document = PdfDocument.Open(stream))
                {
                    StringBuilder sb = new StringBuilder();
                    foreach (PdfPage page in document.GetPages())
                    {
                        string pageText = page.Text;
                        Debug.WriteLine($"ExtractTextFromPdf: Extracted {pageText.Length} characters from page {page.Number}.");
                        sb.Append(pageText);
                    }
                    string finalText = sb.ToString();
                    Debug.WriteLine("ExtractTextFromPdf: Total extracted text length: " + finalText.Length);
                    return finalText;
                }
            }
        }

        // Loads all chats for the current user and displays them in litChatList.
        private void LoadChatList(int userId)
        {
            Debug.WriteLine("LoadChatList: Loading chats for user " + userId);
            try
            {
                string connStr = ConfigurationManager.ConnectionStrings["MyConnectionString"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    string query = @"
                        SELECT c.ChatId, c.CreatedDate
                        FROM Chats c
                        JOIN UserChats uc ON c.ChatId = uc.ChatId
                        WHERE uc.UserId = @UserId
                        ORDER BY c.CreatedDate DESC";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            StringBuilder sb = new StringBuilder();
                            sb.AppendLine("<div class='chat-list'>");
                            while (reader.Read())
                            {
                                int chatId = (int)reader["ChatId"];
                                DateTime createdDate = (DateTime)reader["CreatedDate"];
                                sb.AppendLine($@"
                                    <a class='chat-list-item glass-panel' href='/chat/{chatId}'>
                                        <div class='chat-list-title'>
                                            <i class='bi bi-chat-left-text me-2'></i>
                                            Chat #{chatId}
                                        </div>
                                        <div class='chat-list-subtext'>
                                            Created on {createdDate:MMM dd, yyyy h:mm tt}
                                        </div>
                                    </a>");
                            }
                            sb.AppendLine("</div>");
                            litChatList.Text = sb.ToString();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine("LoadChatList Error: " + ex.Message);
                litChatList.Text = "<div class='text-danger'>Error loading chats</div>";
            }
        }

        protected void btnNewChat_Click(object sender, EventArgs e)
        {
            Debug.WriteLine("btnNewChat_Click triggered.");
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }
            int userId = (int)Session["UserId"];
            int newChatId = CreateNewChat(userId);
            Debug.WriteLine("New chat created with ChatId: " + newChatId);
            Response.RedirectToRoute("ChatById", new { chatId = newChatId });
        }

        private int CreateNewChat(int userId)
        {
            Debug.WriteLine("CreateNewChat: Inserting record into Chats and UserChats for user " + userId);
            string connStr = ConfigurationManager.ConnectionStrings["MyConnectionString"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string insertChatSql = "INSERT INTO Chats DEFAULT VALUES; SELECT SCOPE_IDENTITY();";
                using (SqlCommand cmd = new SqlCommand(insertChatSql, conn))
                {
                    int newChatId = Convert.ToInt32(cmd.ExecuteScalar());
                    string insertUserChatSql = "INSERT INTO UserChats (UserId, ChatId) VALUES (@UserId, @ChatId)";
                    using (SqlCommand cmd2 = new SqlCommand(insertUserChatSql, conn))
                    {
                        cmd2.Parameters.AddWithValue("@UserId", userId);
                        cmd2.Parameters.AddWithValue("@ChatId", newChatId);
                        cmd2.ExecuteNonQuery();
                    }
                    Debug.WriteLine("CreateNewChat: Chat created with ID " + newChatId);
                    return newChatId;
                }
            }
        }

        private bool UserBelongsToChat(int userId, int chatId)
        {
            Debug.WriteLine($"UserBelongsToChat: Checking if user {userId} belongs to chat {chatId}");
            string connStr = ConfigurationManager.ConnectionStrings["MyConnectionString"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string checkSql = @"
                    SELECT COUNT(*)
                    FROM UserChats
                    WHERE UserId = @UserId AND ChatId = @ChatId";
                using (SqlCommand cmd = new SqlCommand(checkSql, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@ChatId", chatId);
                    int count = (int)cmd.ExecuteScalar();
                    Debug.WriteLine($"UserBelongsToChat: Count = {count}");
                    return (count > 0);
                }
            }
        }

        protected async void btnSend_Click(object sender, EventArgs e)
        {
            Debug.WriteLine("btnSend_Click triggered.");
            object chatIdValue = Page.RouteData.Values["chatId"];
            if (chatIdValue == null || !int.TryParse(chatIdValue.ToString(), out int chatId))
            {
                AppendMessage("No chat selected. Please create or select a chat.", false);
                return;
            }
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }
            int userId = (int)Session["UserId"];
            if (!UserBelongsToChat(userId, chatId))
            {
                AppendMessage("You do not have access to this chat.", false);
                return;
            }
            string userInput = txtUserInput.Text.Trim();
            Debug.WriteLine("User input: " + userInput);
            if (string.IsNullOrEmpty(userInput))
                return;
            try
            {
                InsertMessageToDB(chatId, userId, userInput, false, isPDF: false);
                Debug.WriteLine($"btnSend_Click: Inserted user message for chat {chatId}");
                AppendMessage(HttpUtility.HtmlEncode(userInput), true);
                txtUserInput.Text = string.Empty;
                litChatHistory.Text += @"
                    <div class='message assistant-message loading-message'>
                        <div class='loading'>
                            <span></span>
                            <span></span>
                            <span></span>
                        </div>
                    </div>";
                Debug.WriteLine("btnSend_Click: Loading indicator added.");
                string pdfContext = Session["PdfContext"] as string;
                string pdfName = Session["PdfFileName"] as string;
                string promptWithContext = !string.IsNullOrWhiteSpace(pdfContext)
                    ? $"PDF Content from \"{pdfName}\":\n{pdfContext}\n\nUser Query: {userInput}"
                    : userInput;
                if (!string.IsNullOrWhiteSpace(pdfContext))
                    Debug.WriteLine("btnSend_Click: PDF context found and added to prompt.");
                else
                    Debug.WriteLine("btnSend_Click: No PDF context found; using user query only.");
                string botResponse = await GetGeminiResponseAsync(promptWithContext);
                Debug.WriteLine("btnSend_Click: Received AI response.");
                RemoveLoadingIndicator();
                InsertMessageToDB(chatId, 0, botResponse, true, isPDF: false);
                AppendMessage(HttpUtility.HtmlEncode(botResponse), false);
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"btnSend_Click: Error - {ex.Message}");
                RemoveLoadingIndicator();
                AppendMessage("I encountered an error processing your request. Please try again.", false);
            }
        }

        // InsertMessageToDB now accepts a bool parameter isPDF.
        private void InsertMessageToDB(int chatId, int senderUserId, string content, bool isAssistant, bool isPDF)
        {
            Debug.WriteLine("InsertMessageToDB: Inserting message into DB for chat " + chatId);
            try
            {
                string connStr = ConfigurationManager.ConnectionStrings["MyConnectionString"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    string checkUserSql = "SELECT COUNT(*) FROM Users WHERE UserId = @UserId";
                    using (SqlCommand checkCmd = new SqlCommand(checkUserSql, conn))
                    {
                        checkCmd.Parameters.AddWithValue("@UserId", senderUserId);
                        int userExists = (int)checkCmd.ExecuteScalar();
                        if (userExists == 0)
                        {
                            throw new Exception($"User with ID {senderUserId} does not exist.");
                        }
                    }
                    string insertSql = @"
                        INSERT INTO Messages (ChatId, UserId, MessageContent, IsAssistant, IsPDF, CreatedDate)
                        VALUES (@ChatId, @UserId, @MessageContent, @IsAssistant, @IsPDF, GETDATE())";
                    using (SqlCommand cmd = new SqlCommand(insertSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@ChatId", chatId);
                        cmd.Parameters.AddWithValue("@UserId", senderUserId);
                        cmd.Parameters.AddWithValue("@MessageContent", content);
                        cmd.Parameters.AddWithValue("@IsAssistant", isAssistant);
                        cmd.Parameters.AddWithValue("@IsPDF", isPDF);
                        cmd.ExecuteNonQuery();
                        Debug.WriteLine("InsertMessageToDB: Message inserted successfully.");
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine("InsertMessageToDB Error: " + ex.Message);
                throw;
            }
        }

        private void LoadChatMessages(int chatId)
        {
            Debug.WriteLine("LoadChatMessages: Loading messages for chat " + chatId);
            litChatHistory.Text = "";
            string connStr = ConfigurationManager.ConnectionStrings["MyConnectionString"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string query = @"
                    SELECT MessageContent, IsAssistant, IsPDF
                    FROM Messages
                    WHERE ChatId = @ChatId
                    ORDER BY MessageId ASC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@ChatId", chatId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string content = (string)reader["MessageContent"];
                            bool isAssistant = (bool)reader["IsAssistant"];
                            bool isPDF = (bool)reader["IsPDF"];
                            // For PDF messages, show only a truncated preview.
                            if (isPDF)
                            {
                                if (content.Length > 10)
                                    content = content.Substring(0, 10) + "... .pdf";
                                else
                                    content = content + "... .pdf";
                            }
                            AppendMessage(HttpUtility.HtmlEncode(content), !isAssistant);
                        }
                    }
                }
            }
        }

        private void RemoveLoadingIndicator()
        {
            Debug.WriteLine("RemoveLoadingIndicator: Removing loading indicator.");
            ScriptManager.RegisterStartupScript(this, this.GetType(),
                "removeLoading", "document.querySelector('.loading-message')?.remove();", true);
        }

        private void AppendMessage(string message, bool isUser)
        {
            string messageClass = isUser ? "user-message" : "assistant-message";
            string icon = isUser ? "bi-person-circle" : "bi-robot";
            message = FormatCodeBlocks(message);
            string newMessage = $@"
                <div class='message {messageClass}'>
                    <div class='d-flex gap-3'>
                        <div class='message-icon'>
                            <i class='bi {icon}'></i>
                        </div>
                        <div class='message-content'>{message}</div>
                    </div>
                </div>";
            litChatHistory.Text += newMessage;
            Session["ChatHistory"] = litChatHistory.Text;
            Debug.WriteLine("AppendMessage: Message appended to chat history.");
        }

        private string FormatCodeBlocks(string message)
        {
            if (message.Contains("```"))
            {
                bool isInCodeBlock = false;
                StringBuilder sb = new StringBuilder();
                string[] lines = message.Split(new[] { "\n" }, StringSplitOptions.None);
                foreach (string line in lines)
                {
                    if (line.StartsWith("```"))
                    {
                        if (isInCodeBlock)
                        {
                            sb.Append("</pre>");
                            isInCodeBlock = false;
                        }
                        else
                        {
                            sb.Append("<pre><code>");
                            isInCodeBlock = true;
                        }
                    }
                    else
                    {
                        sb.AppendLine(line);
                    }
                }
                if (isInCodeBlock)
                    sb.Append("</pre>");
                return sb.ToString();
            }
            return message;
        }

        private async Task<string> GetGeminiResponseAsync(string prompt)
        {
            Debug.WriteLine("GetGeminiResponseAsync: Sending prompt to Gemini API.");
            string apiKey = "AIzaSyAT2XDiRjfZvOVcL4UNpi6hNeiOENHH7Kg";
            string endpoint = $"https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key={apiKey}";
            try
            {
                var payload = new
                {
                    contents = new[]
                    {
                        new { parts = new[] { new { text = prompt } } }
                    },
                    generationConfig = new
                    {
                        temperature = 0.7,
                        topK = 40,
                        topP = 0.95,
                        maxOutputTokens = 1024
                    },
                    safetySettings = new[]
                    {
                        new { category = "HARM_CATEGORY_HARASSMENT", threshold = "BLOCK_MEDIUM_AND_ABOVE" },
                        new { category = "HARM_CATEGORY_HATE_SPEECH", threshold = "BLOCK_MEDIUM_AND_ABOVE" },
                        new { category = "HARM_CATEGORY_SEXUALLY_EXPLICIT", threshold = "BLOCK_MEDIUM_AND_ABOVE" },
                        new { category = "HARM_CATEGORY_DANGEROUS_CONTENT", threshold = "BLOCK_MEDIUM_AND_ABOVE" }
                    }
                };

                string jsonPayload = JsonConvert.SerializeObject(payload);
                Debug.WriteLine("GetGeminiResponseAsync: Payload - " + jsonPayload);
                var content = new StringContent(jsonPayload, Encoding.UTF8, "application/json");
                HttpResponseMessage response = await client.PostAsync(endpoint, content);
                response.EnsureSuccessStatusCode();
                string jsonResponse = await response.Content.ReadAsStringAsync();
                Debug.WriteLine("GetGeminiResponseAsync: Response - " + jsonResponse);
                dynamic result = JsonConvert.DeserializeObject(jsonResponse);
                string reply = result.candidates[0].content.parts[0].text;
                if (string.IsNullOrEmpty(reply))
                {
                    return "I apologize, but I couldn't generate a response. Please try again.";
                }
                return reply;
            }
            catch (Exception ex)
            {
                Debug.WriteLine("GetGeminiResponseAsync Error: " + ex.Message);
                throw;
            }
        }

        // --- PDF Upload Handler ---
        // When a PDF is uploaded, extract its text, store the context in Session,
        // and insert a message flagged as a PDF message (with IsPDF = true).
        protected async void btnUploadPdf_Click(object sender, EventArgs e)
        {
            Debug.WriteLine("btnUploadPdf_Click triggered.");
            if (pdfFileUpload.HasFile)
            {
                try
                {
                    Debug.WriteLine("btnUploadPdf_Click: File found. Reading file bytes.");
                    byte[] pdfData = pdfFileUpload.FileBytes;
                    Debug.WriteLine("btnUploadPdf_Click: PDF file size = " + pdfData.Length + " bytes.");

                    // Extract text from the PDF using PdfPig.
                    string pdfText = ExtractTextFromPdf(pdfData);
                    Debug.WriteLine("btnUploadPdf_Click: Extracted text length = " + pdfText.Length);

                    // Store the extracted text and file name in Session.
                    Session["PdfContext"] = pdfText;
                    string fileName = Path.GetFileName(pdfFileUpload.FileName);
                    Session["PdfFileName"] = fileName;
                    lblPdfInfo.Text = "Uploaded PDF: " + fileName;
                    Debug.WriteLine("btnUploadPdf_Click: PDF context stored in Session.");

                    lblUploadStatus.Text = "PDF uploaded successfully.";

                    // Insert a message into the chat representing the PDF content.
                    // Here we store the full extracted text as the message content.
                    int chatId = GetCurrentChatId();
                    int userId = (int)Session["UserId"];
                    InsertMessageToDB(chatId, userId, pdfText, false, isPDF: true);
                }
                catch (Exception ex)
                {
                    Debug.WriteLine("btnUploadPdf_Click Error: " + ex.Message);
                    lblUploadStatus.Text = "Error uploading PDF: " + ex.Message;
                }
            }
            else
            {
                Debug.WriteLine("btnUploadPdf_Click: No file selected.");
                lblUploadStatus.Text = "Please select a PDF file to upload.";
            }
        }
    }
}
