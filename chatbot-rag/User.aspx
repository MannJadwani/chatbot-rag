<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" 
    CodeBehind="User.aspx.cs" Inherits="GeminiChatBot.UserPage" Async="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <title>User Profile</title>
    <style>
        :root {
            --glass-bg: rgba(255, 255, 255, 0.05);
            --border-color: rgba(255, 255, 255, 0.1);
            --text-primary: #f8f9fa;
            --text-secondary: #adb5bd;
            --primary-accent: #7c4dff;
            --hover-accent: #6e40e6;
        }

        .user-background {
            min-height: 100vh;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            position: relative;
            color: var(--text-primary);
        }

        .user-wrapper {
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            padding: 2rem;
        }

        .glass-panel {
            background: var(--glass-bg);
            backdrop-filter: blur(16px) saturate(180%);
            border: 1px solid var(--border-color);
            border-radius: 1.5rem;
            padding: 2.5rem;
            width: 100%;
            max-width: 600px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s ease;
        }

        .glass-panel:hover {
            transform: translateY(-2px);
        }

        .profile-title {
            font-size: 2.2rem;
            font-weight: 600;
            margin-bottom: 1.5rem;
            background: linear-gradient(45deg, var(--text-primary), var(--text-secondary));
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
        }

        .profile-field {
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid var(--border-color);
            border-radius: 0.75rem;
            padding: 1rem;
            margin-bottom: 1.5rem;
            transition: all 0.2s ease;
        }

        .profile-field:hover {
            background: rgba(255, 255, 255, 0.05);
            border-color: rgba(255, 255, 255, 0.2);
        }

        .profile-label {
            color: var(--text-secondary);
            font-size: 0.9rem;
            font-weight: 500;
            margin-bottom: 0.25rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .profile-value {
            color: var(--text-primary);
            font-size: 1.1rem;
            font-weight: 500;
            margin: 0;
        }

        .action-btns .btn {
            width: 100%;
            padding: 0.75rem;
            border-radius: 0.75rem;
            font-weight: 600;
            transition: all 0.2s ease;
        }

        @@media (max-width: 768px) {
            .user-wrapper {
                padding: 1rem;
            }
            
            .glass-panel {
                padding: 1.5rem;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="user-background">
        <div class="user-wrapper">
            <div class="glass-panel">
                <h2 class="profile-title text-center mb-4">User Profile</h2>
                
                <div class="profile-field">
                    <div class="profile-label">Username</div>
                    <asp:Label ID="lblUsername" runat="server" CssClass="profile-value d-block" />
                </div>

                <div class="profile-field">
                    <div class="profile-label">Email Address</div>
                    <asp:Label ID="lblEmail" runat="server" CssClass="profile-value d-block" />
                </div>

                
            </div>
        </div>
    </div>
</asp:Content>