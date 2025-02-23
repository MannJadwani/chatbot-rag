<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="GeminiChatBot.Default" Async="true" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>AI Chatbot</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --sidebar-width: 260px;
            --primary-bg: #343541;
            --secondary-bg: #202123;
            --message-bg: #444654;
            --input-bg: #40414f;
            --border-color: #4a4a55;
            --text-primary: #ececf1;
            --text-secondary: #acacbe;
        }

        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--primary-bg);
            color: var(--text-primary);
            overflow: hidden;
            height: 100vh;
        }

        /* Sidebar Styles */
        .sidebar {
            width: var(--sidebar-width);
            background-color: var(--secondary-bg);
            height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            overflow-y: auto;
            transition: transform 0.3s ease;
            z-index: 1000;
        }

        .new-chat-btn {
            background-color: #2d2d33;
            border: 1px solid var(--border-color);
            transition: background-color 0.2s;
            color: var(--text-primary);
        }

        .new-chat-btn:hover {
            background-color: #3a3a44;
            color: var(--text-primary);
        }

        /* Main Chat Area */
        .main-content {
            margin-left: var(--sidebar-width);
            height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .chat-container {
            flex-grow: 1;
            overflow-y: auto;
            padding: 2rem 0;
            scroll-behavior: smooth;
        }

        .message {
            max-width: 800px;
            margin: 0 auto;
            padding: 1rem;
            animation: fadeIn 0.5s ease;
            width: 100%;
        }

        .user-message {
            background-color: var(--primary-bg);
        }

        .assistant-message {
            background-color: var(--message-bg);
        }

        .message-content {
            flex: 1;
            line-height: 1.6;
            white-space: pre-wrap;
            font-size: 1rem;
        }

        .message-icon {
            font-size: 1.5rem;
            color: var(--text-secondary);
            padding-top: 0.25rem;
            width: 40px;
            flex-shrink: 0;
        }

        /* Input Area */
        .input-area {
            background-color: var(--primary-bg);
            border-top: 1px solid var(--border-color);
            padding: 1.5rem;
            position: relative;
        }

        .input-container {
            max-width: 800px;
            margin: 0 auto;
            position: relative;
        }

        .message-input {
            background-color: var(--input-bg);
            border: 1px solid var(--border-color);
            color: var(--text-primary);
            resize: none;
            padding-right: 50px;
            transition: border-color 0.2s;
            min-height: 44px;
            max-height: 200px;
        }

        .message-input:focus {
            background-color: var(--input-bg);
            border-color: #6b6c7b;
            color: var(--text-primary);
            box-shadow: none;
        }

        .send-button {
            position: absolute;
            right: 10px;
            bottom: 10px;
            background: none;
            border: none;
            color: var(--text-secondary);
            transition: color 0.2s;
            padding: 5px 10px;
        }

        .send-button:hover:not(:disabled) {
            color: var(--text-primary);
        }

        .send-button:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        /* Suggested Messages */
        .suggested-messages {
            display: flex;
            gap: 1rem;
            flex-wrap: wrap;
            justify-content: center;
            margin-top: 2rem;
        }

        .suggested-message {
            background-color: #2d2d33;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 0.75rem 1rem;
            cursor: pointer;
            transition: background-color 0.2s;
            color: var(--text-primary);
        }

        .suggested-message:hover {
            background-color: #3a3a44;
        }

        /* Code Blocks */
        .message-content pre {
            background-color: #2d2d33;
            padding: 1rem;
            border-radius: 0.5rem;
            overflow-x: auto;
            margin: 0.5rem 0;
        }

        .message-content code {
            font-family: 'Courier New', Courier, monospace;
            background-color: #2d2d33;
            padding: 0.2rem 0.4rem;
            border-radius: 0.25rem;
        }

        /* Loading Animation */
        .loading {
            display: flex;
            gap: 0.5rem;
            align-items: center;
            color: var(--text-secondary);
            padding: 1rem;
        }

        .loading span {
            width: 8px;
            height: 8px;
            background-color: currentColor;
            border-radius: 50%;
            display: inline-block;
            animation: bounce 1.4s infinite ease-in-out both;
        }

        .loading span:nth-child(1) { animation-delay: -0.32s; }
        .loading span:nth-child(2) { animation-delay: -0.16s; }

        @keyframes bounce {
            0%, 80%, 100% { transform: scale(0); }
            40% { transform: scale(1); }
        }

        /* Animations */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Mobile Responsiveness */
        @media (max-width: 768px) {
            .sidebar {
                transform: translateX(-100%);
            }
            .main-content {
                margin-left: 0;
            }
            .sidebar.show {
                transform: translateX(0);
            }
            .suggested-messages {
                flex-direction: column;
                padding: 0 1rem;
            }
            .message {
                padding: 1rem;
            }
        }

        /* Scrollbar Styling */
        ::-webkit-scrollbar {
            width: 8px;
        }

        ::-webkit-scrollbar-track {
            background: var(--primary-bg);
        }

        ::-webkit-scrollbar-thumb {
            background: var(--border-color);
            border-radius: 4px;
        }

        ::-webkit-scrollbar-thumb:hover {
            background: #6b6c7b;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        This is the default
      </form>
</body>
</html>