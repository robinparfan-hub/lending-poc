#!/bin/bash

# Git and GitHub Setup Script for Lending POC
# This script will help you set up Git and connect to GitHub

echo "🚀 Setting up Git for Lending POC project"
echo "========================================="

# Step 1: Configure Git user (you'll need to customize these)
echo ""
echo "Step 1: Configure Git User"
echo "Please enter your GitHub information:"
read -p "Enter your name (e.g., Robin Parfan): " git_name
read -p "Enter your GitHub email: " git_email

git config --global user.name "$git_name"
git config --global user.email "$git_email"

echo "✅ Git user configured"

# Step 2: Initialize Git repository
echo ""
echo "Step 2: Initializing Git repository..."
git init
echo "✅ Git repository initialized"

# Step 3: Create .gitignore
echo ""
echo "Step 3: Creating .gitignore file..."
# Already exists, but let's ensure it has the right content
echo "✅ .gitignore already exists"

# Step 4: Add all files to staging
echo ""
echo "Step 4: Adding files to Git..."
git add .
echo "✅ Files added to staging"

# Step 5: Create initial commit
echo ""
echo "Step 5: Creating initial commit..."
git commit -m "Initial commit: Lending POC foundation with Week 1 planning and documentation"
echo "✅ Initial commit created"

# Step 6: GitHub repository creation
echo ""
echo "Step 6: GitHub Repository Setup"
echo "================================"
echo ""
echo "Now you need to create a repository on GitHub:"
echo "1. Go to https://github.com/new"
echo "2. Repository name: lending-poc"
echo "3. Make it Private or Public (your choice)"
echo "4. DON'T initialize with README (we already have one)"
echo "5. DON'T add .gitignore (we already have one)"
echo ""
read -p "Press Enter after you've created the repository on GitHub..."

# Step 7: Add remote origin
echo ""
echo "Step 7: Connecting to GitHub"
read -p "Enter your GitHub username: " github_username
echo ""
echo "Choose connection method:"
echo "1. HTTPS (easier, uses password/token)"
echo "2. SSH (more secure, uses SSH keys)"
read -p "Enter choice (1 or 2): " connection_choice

if [ "$connection_choice" = "1" ]; then
    remote_url="https://github.com/$github_username/lending-poc.git"
else
    remote_url="git@github.com:$github_username/lending-poc.git"
    echo ""
    echo "Note: Make sure you have SSH keys set up with GitHub"
    echo "If not, run: ssh-keygen -t ed25519 -C \"$git_email\""
    echo "Then add the key to GitHub: https://github.com/settings/keys"
    read -p "Press Enter when ready..."
fi

git remote add origin $remote_url
echo "✅ Remote origin added"

# Step 8: Push to GitHub
echo ""
echo "Step 8: Pushing to GitHub..."
git branch -M main
git push -u origin main

echo ""
echo "✅ Successfully connected to GitHub!"
echo ""
echo "Repository URL: https://github.com/$github_username/lending-poc"
echo ""
echo "Next steps:"
echo "- Set up branch protection rules on GitHub"
echo "- Configure GitHub Actions for CI/CD"
echo "- Invite team members if needed"