<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Chat.aspx.cs" 
    Inherits="GeminiChatBot.ChatPage" 
    Async="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
  <title>AI Chatbot</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600&display=swap" rel="stylesheet" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet" />
  <style>
    :root {
      --sidebar-width: 280px;
      --primary-bg: #0a0a0f;
      --secondary-bg: rgba(16, 16, 24, 0.7);
      --message-bg: rgba(28, 28, 35, 0.6);
      --input-bg: rgba(32, 32, 40, 0.6);
      --border-color: rgba(255, 255, 255, 0.1);
      --text-primary: #ffffff;
      --text-secondary: rgba(255, 255, 255, 0.7);
      --accent-color: #6366f1;
      --accent-hover: #4f46e5;
      --glass-gradient: linear-gradient(135deg, rgba(255, 255, 255, 0.1), rgba(255, 255, 255, 0.05));
    }
    body {
      font-family: 'Plus Jakarta Sans', sans-serif;
      background: radial-gradient(circle at top right, #1a1a2e, #0a0a0f);
      color: var(--text-primary);
      overflow: hidden;
      height: 100vh;
      position: relative;
      padding-bottom: 80px;  /* space for fixed input bar */
    }
    body::before {
      content: '';
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      backdrop-filter: blur(20px);
      pointer-events: none;
      z-index: -1;
    }
    .centered-new-chat {
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      text-align: center;
    }
    .big-new-chat-btn {
      padding: 1.5rem 3rem;
      font-size: 1.5rem;
      border-radius: 16px;
      background: var(--accent-color);
      border: none;
      color: white;
      transition: all 0.3s ease;
      backdrop-filter: blur(8px);
      border: 1px solid var(--border-color);
    }
    .big-new-chat-btn:hover {
      background: var(--accent-hover);
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(99, 102, 241, 0.2);
    }
    .glass-panel {
      background: var(--glass-gradient);
      backdrop-filter: blur(12px);
      border: 1px solid var(--border-color);
      border-radius: 16px;
    }
    .sidebar {
      width: var(--sidebar-width);
      background: var(--secondary-bg);
      height: 100vh;
      position: fixed;
      left: 0;
      top: 0;
      overflow-y: auto;
      transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      z-index: 1000;
      backdrop-filter: blur(12px);
      border-right: 1px solid var(--border-color);
    }
    .new-chat-btn {
      background: var(--glass-gradient);
      border: 1px solid var(--border-color);
      backdrop-filter: blur(8px);
      transition: all 0.3s ease;
      color: var(--text-primary);
      border-radius: 12px;
      padding: 12px;
      font-weight: 500;
      display: inline-block;
      text-align: center;
    }
    .new-chat-btn:hover {
      background: var(--accent-color);
      border-color: var(--accent-hover);
      transform: translateY(-1px);
      box-shadow: 0 4px 12px rgba(99, 102, 241, 0.2);
      color: var(--text-primary);
    }
    @media (min-width: 768px) { .new-chat-btn { display: inline-block; } }
    .main-content {
      margin-left: var(--sidebar-width);
      height: 100vh;
      display: flex;
      flex-direction: column;
      background: transparent;
    }
    .chat-container {
      flex-grow: 1;
      overflow-y: auto;
      padding: 2rem 0;
      scroll-behavior: smooth;
    }
    .chat-list {
      display: flex;
      flex-direction: column;
      gap: 1rem;
      margin-top: 1rem;
    }
    .chat-list-item {
      display: block;
      padding: 1rem;
      border: 1px solid var(--border-color);
      border-radius: 12px;
      color: var(--text-primary);
      background: var(--glass-gradient);
      backdrop-filter: blur(8px);
      transition: all 0.3s ease;
      text-decoration: none;
      box-shadow: 0 2px 5px rgba(0, 0, 0, 0.15);
    }
    .chat-list-item:hover {
      background: var(--accent-color);
      border-color: var(--accent-hover);
      color: #fff;
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(99, 102, 241, 0.2);
      text-decoration: none;
    }
    .chat-list-title {
      font-size: 1.1rem;
      font-weight: 600;
      display: flex;
      align-items: center;
    }
    .chat-list-subtext {
      margin-top: 0.25rem;
      font-size: 0.85rem;
      color: var(--text-secondary);
    }
    .message {
      max-width: 800px;
      margin: 1rem auto;
      padding: 1.5rem;
      animation: messageSlideIn 0.5s ease forwards;
      opacity: 0;
      transform: translateY(20px);
      border-radius: 16px;
      background: var(--message-bg);
      backdrop-filter: blur(8px);
      border: 1px solid var(--border-color);
    }
    .user-message {
      background: var(--glass-gradient), var(--message-bg);
    }
    .assistant-message {
      background: var(--glass-gradient), rgba(99, 102, 241, 0.1);
    }
    /* Style for PDF messages */
    .pdf-message {
      border: 1px dashed var(--accent-color);
      background: var(--input-bg);
      color: var(--accent-color);
      padding: 10px;
      font-style: italic;
      display: flex;
      align-items: center;
      gap: 8px;
      border-radius: 8px;
    }
    .pdf-message i {
      font-size: 1.2rem;
    }
    /* Input Area & File Upload - fixed at the bottom */
    .input-area {
      background: var(--secondary-bg);
      backdrop-filter: blur(16px);
      border-top: 1px solid var(--border-color);
      padding: 0.5rem 1rem;
      position: fixed;
      bottom: 0;
      left: var(--sidebar-width);
      right: 0;
      display: flex;
      align-items: center;
      gap: 10px;
      z-index: 1100;
    }
    .input-container {
      flex-grow: 1;
      position: relative;
    }
    .file-upload {
      display: flex;
      align-items: center;
      gap: 5px;
    }
    .message-input {
      background: var(--input-bg);
      border: 1px solid var(--border-color);
      color: var(--text-primary);
      resize: none;
      padding: 1rem;
      border-radius: 12px;
      transition: all 0.3s ease;
      font-size: 1rem;
      line-height: 1.6;
      width: 100%;
    }
    .message-input:focus {
      background: var(--input-bg);
      border-color: var(--accent-color);
      box-shadow: 0 0 0 2px rgba(99, 102, 241, 0.2);
      outline: none;
    }
    .send-button {
      background: var(--accent-color);
      border: none;
      color: white;
      padding: 8px 16px;
      border-radius: 8px;
      transition: all 0.3s ease;
    }
    .send-button:hover:not(:disabled) {
      background: var(--accent-hover);
      transform: translateY(-1px);
    }
    .send-button:disabled {
      opacity: 0.5;
      cursor: not-allowed;
    }
    .suggested-messages {
      display: flex;
      gap: 1rem;
      flex-wrap: wrap;
      justify-content: center;
      margin-top: 2rem;
    }
    .suggested-message {
      background: var(--glass-gradient);
      backdrop-filter: blur(8px);
      border: 1px solid var(--border-color);
      border-radius: 12px;
      padding: 1rem 1.5rem;
      cursor: pointer;
      transition: all 0.3s ease;
      color: var(--text-primary);
    }
    .suggested-message:hover {
      background: var(--accent-color);
      border-color: var(--accent-hover);
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(99, 102, 241, 0.2);
    }
    .message-content pre {
      background: rgba(0, 0, 0, 0.3);
      backdrop-filter: blur(4px);
      padding: 1rem;
      border-radius: 8px;
      border: 1px solid var(--border-color);
      margin: 1rem 0;
    }
    .message-content code {
      font-family: 'JetBrains Mono', monospace;
      color: #a5b4fc;
    }
    @keyframes messageSlideIn {
      0% { opacity: 0; transform: translateY(20px); }
      100% { opacity: 1; transform: translateY(0); }
    }
    @keyframes pulseGlow {
      0% { box-shadow: 0 0 0 0 rgba(99, 102, 241, 0.4); }
      70% { box-shadow: 0 0 0 10px rgba(99, 102, 241, 0); }
      100% { box-shadow: 0 0 0 0 rgba(99, 102, 241, 0); }
    }
    .loading {
      display: flex;
      gap: 0.5rem;
      align-items: center;
      padding: 1rem;
    }
    .loading span {
      width: 8px;
      height: 8px;
      background: var(--accent-color);
      border-radius: 50%;
      display: inline-block;
      animation: loadingBounce 1.4s infinite ease-in-out both;
    }
    .loading span:nth-child(1) { animation-delay: -0.32s; }
    .loading span:nth-child(2) { animation-delay: -0.16s; }
    @keyframes loadingBounce {
      0%, 80%, 100% { transform: scale(0); }
      40% { transform: scale(1); }
    }
    @media (max-width: 768px) {
      .sidebar { transform: translateX(-100%); }
      .main-content { margin-left: 0; }
      .sidebar.show { transform: translateX(0); }
      .message { margin: 1rem; padding: 1rem; }
    }
    ::-webkit-scrollbar { width: 6px; }
    ::-webkit-scrollbar-track { background: transparent; }
    ::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.2); border-radius: 3px; }
    ::-webkit-scrollbar-thumb:hover { background: rgba(255, 255, 255, 0.3); }
  </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
  <!-- Sidebar -->
  <div class="sidebar">
    <div class="p-3">
      <asp:Button ID="btnNewChat" runat="server" CssClass="new-chat-btn w-100 mb-3" 
          OnClick="btnNewChat_Click" Text="New Chat" />
      <div class="chat-history">
        <asp:Literal ID="litChatList" runat="server"></asp:Literal>
      </div>
    </div>
  </div>

  <!-- Main Content -->
  <div class="main-content">
    <% if (IsChatActive) { %>
      <div class="chat-container" id="chatContainer">
        <asp:Literal ID="litChatHistory" runat="server"></asp:Literal>
        <% if (string.IsNullOrEmpty(litChatHistory.Text)) { %>
          <div class="message text-center">
            <h4>How can I help you today?</h4>
            <div class="suggested-messages">
              <div class="suggested-message">Tell me about quantum computing</div>
              <div class="suggested-message">Write a professional email</div>
              <div class="suggested-message">Explain machine learning concepts</div>
              <div class="suggested-message">Help me debug my code</div>
            </div>
          </div>
        <% } %>
      </div>
      
      <!-- Fixed Input Bar at Bottom -->
      <div class="input-area">
        <div class="input-container">
          <asp:TextBox ID="txtUserInput" runat="server" CssClass="form-control message-input" 
              TextMode="MultiLine" Rows="1" placeholder="Message AI assistant..." />
        </div>
          <asp:Label ID="lblUploadStatus" runat="server" CssClass="ms-2 text-info"></asp:Label>
<asp:Label ID="lblPdfInfo" runat="server" CssClass="ms-2 text-info"></asp:Label>
        <div class="file-upload">
          <asp:FileUpload ID="pdfFileUpload" runat="server" Accept=".pdf" />
          <asp:Button ID="btnUploadPdf" runat="server" CssClass="btn btn-primary" 
              OnClick="btnUploadPdf_Click" Text="Attach PDF" />
        </div>
        <asp:Button ID="btnSend" runat="server" CssClass="send-button" 
            OnClick="btnSend_Click" Text="Send" />
      </div>
      
      <!-- PDF Box Display (if a PDF was uploaded, this message is shown as a file attachment) -->
      <% if (Session["PdfFileName"] != null) { %>
        <div class="pdf-box">
          <i class="bi bi-file-earmark-pdf-fill"></i>
          <% 
             string fileName = Session["PdfFileName"].ToString();
             string displayName = fileName.Length > 10 ? fileName.Substring(0, 10) + "... .pdf" : fileName + "... .pdf";
          %>
          <%= displayName %>
        </div>
      <% } %>
      
    <% } else { %>
      <div class="centered-new-chat">
        <asp:Button ID="btnNewChatCenter" runat="server" CssClass="big-new-chat-btn" 
            OnClick="btnNewChat_Click" Text="Start New Chat" />
      </div>
    <% } %>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    // Auto-resize textarea
    const textarea = document.querySelector('.message-input');
    const sendButton = document.querySelector('.send-button');

    function updateTextarea() {
      textarea.style.height = 'auto';
      textarea.style.height = Math.min(textarea.scrollHeight, 200) + 'px';
      sendButton.disabled = textarea.value.trim().length === 0;
    }

    textarea.addEventListener('input', updateTextarea);

    // Handle suggested messages
    document.querySelectorAll('.suggested-message').forEach(btn => {
      btn.addEventListener('click', function() {
        textarea.value = this.textContent;
        textarea.focus();
        updateTextarea();
      });
    });

    // Submit on Enter (Shift+Enter for new line)
    textarea.addEventListener('keydown', function(e) {
      if (e.key === 'Enter' && !e.shiftKey && !sendButton.disabled) {
        e.preventDefault();
        document.getElementById('<%= btnSend.ClientID %>').click();
        }
    });

      // Scroll handling
      const chatContainer = document.getElementById('chatContainer');

      function scrollToBottom() {
          chatContainer.scrollTop = chatContainer.scrollHeight;
      }

      // Scroll on new messages
      const observer = new MutationObserver(mutations => {
          mutations.forEach(mutation => {
              if (mutation.addedNodes.length) {
                  scrollToBottom();
              }
          });
      });

      observer.observe(chatContainer, { childList: true, subtree: true });

      // Mobile sidebar toggle
      const toggleSidebar = () => {
          document.querySelector('.sidebar').classList.toggle('show');
      };

      // Initial setup
      updateTextarea();
      scrollToBottom();
  </script>
</asp:Content>
