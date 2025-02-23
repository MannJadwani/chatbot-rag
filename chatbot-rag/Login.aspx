<%@ Page Title="Login" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="GeminiChatBot.Login" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <!-- Modern fonts and icons -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #6366f1;
            --primary-hover: #4f46e5;
            --dark-bg: #0f172a;
            --card-bg: #1e293b;
            --text-primary: #e2e8f0;
            --text-secondary: #94a3b8;
            --input-bg: #2a3649;
            --input-border: #3f495e;
        }

        body {
            background: var(--dark-bg);
            font-family: 'Plus Jakarta Sans', sans-serif;
            color: var(--text-primary);
            min-height: 100vh;
            margin: 0;
            overflow-x: hidden;
        }

        .page-container {
            display: flex;
            min-height: 100vh;
        }

        .brand-section {
            flex: 1;
            background: linear-gradient(135deg, rgba(99, 102, 241, 0.1) 0%, rgba(99, 102, 241, 0.05) 100%);
            padding: 2rem;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            position: relative;
            overflow: hidden;
            border-right: 1px solid rgba(255, 255, 255, 0.1);
        }

        .brand-content {
            text-align: center;
            position: relative;
            z-index: 2;
        }

        .brand-title {
            font-size: 2.5rem;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 1rem;
            line-height: 1.2;
        }

        .brand-subtitle {
            color: var(--text-secondary);
            font-size: 1.1rem;
            max-width: 400px;
            margin: 0 auto;
        }

        .geometric-shapes {
            position: absolute;
            width: 100%;
            height: 100%;
            top: 0;
            left: 0;
            opacity: 0.1;
            background: 
                radial-gradient(circle at 20% 20%, var(--primary-color) 0%, transparent 20%),
                radial-gradient(circle at 80% 80%, var(--primary-color) 0%, transparent 20%),
                radial-gradient(circle at 50% 50%, var(--primary-color) 0%, transparent 30%);
        }

        .login-section {
            flex: 1;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 1.5rem;
            background: radial-gradient(circle at top right, rgba(99, 102, 241, 0.05) 0%, transparent 60%);
        }

        .login-card {
            width: 100%;
            max-width: 520px;
            background: var(--card-bg);
            padding: 3.5rem;
            border-radius: 20px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .login-header {
            text-align: center;
            margin-bottom: 3.5rem;
        }

        .login-header h2 {
            font-size: 2.2rem;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 1rem;
        }

        .login-header p {
            color: var(--text-secondary);
            font-size: 1.1rem;
        }

        .form-control {
            background-color: var(--input-bg);
            border: 1px solid var(--input-border);
            color: var(--text-primary);
            padding: 0.75rem 1rem;
            border-radius: 8px;
            font-size: 0.95rem;
            transition: all 0.3s ease;
        }

        .form-control:focus {
            background-color: var(--input-bg);
            border-color: var(--primary-color);
            color: var(--text-primary);
            box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.1);
        }

        .input-group {
            position: relative;
            margin-bottom: 2.5rem;
        }

        .input-group i {
            position: absolute;
            left: 1.25rem;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-secondary);
            font-size: 1.3rem;
        }

        .input-group .form-control {
            padding: 1rem 1.25rem 1rem 3.25rem;
            font-size: 1.1rem;
            height: auto;
        }

        .btn-login {
            background: var(--primary-color);
            border: none;
            color: white;
            padding: 1.125rem;
            border-radius: 12px;
            font-weight: 600;
            width: 100%;
            font-size: 1.125rem;
            transition: all 0.3s ease;
            margin-top: 1rem;
        }

        .btn-login:hover {
            background: var(--primary-hover);
            transform: translateY(-1px);
        }

        .alert {
            background: rgba(239, 68, 68, 0.1);
            border: 1px solid rgba(239, 68, 68, 0.2);
            color: #fecaca;
            border-radius: 8px;
            padding: 1rem;
            margin-bottom: 1.5rem;
        }

        /* Responsive Design */
        @media (max-width: 992px) {
            .page-container {
                flex-direction: column;
            }
            
            .brand-section {
                padding: 3rem 1rem;
            }
            
            .brand-title {
                font-size: 2rem;
            }
            
            .login-section {
                padding: 2rem 1rem;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-container">
        <div class="brand-section">
            <div class="geometric-shapes"></div>
            <div class="brand-content">
                <h1 class="brand-title">AI - RAG in .NET</h1>
                <p class="brand-subtitle">Experience the power of Retrieval Augmented Generation with our advanced .NET implementation</p>
            </div>
        </div>
        
        <div class="login-section">
            <div class="login-card">
                <div class="login-header">
                    <h2>Welcome Back</h2>
                    <p>Enter your credentials to access your account</p>
                </div>
                
                <asp:Label ID="lblErrorMessage" runat="server" EnableViewState="false" Visible="false" CssClass="alert"></asp:Label>
                
                <div class="input-group">
                    <i class="bi bi-person"></i>
                    <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" placeholder="Username"></asp:TextBox>
                </div>
                
                <div class="input-group">
                    <i class="bi bi-lock"></i>
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="Password"></asp:TextBox>
                </div>
                
                <asp:Button ID="btnLogin" runat="server" Text="Sign In" CssClass="btn-login" OnClick="BtnLogin_Click" />
            </div>
        </div>
    </div>
</asp:Content>