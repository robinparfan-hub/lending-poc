# GitHub Setup Guide for Lending POC

## Option 1: Automated Setup (Recommended)
Run the setup script:
```bash
./git-setup.sh
```

## Option 2: Manual Setup

### Step 1: Configure Git User
```bash
# Set your name and email
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Step 2: Initialize Git Repository
```bash
# Initialize git in the project
git init
```

### Step 3: Add Files and Create Initial Commit
```bash
# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Lending POC foundation with Week 1 planning and documentation"
```

### Step 4: Create GitHub Repository
1. Go to https://github.com/new
2. Create a new repository:
   - Repository name: `lending-poc`
   - Description: "Salesforce Consumer Lending Platform POC - 6-week sprint implementation"
   - Choose Public or Private
   - ⚠️ DON'T initialize with README
   - ⚠️ DON'T add .gitignore
   - ⚠️ DON'T choose a license

### Step 5: Connect to GitHub

#### Option A: HTTPS (Easier)
```bash
# Add remote origin (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/lending-poc.git

# Push to GitHub
git branch -M main
git push -u origin main
```

You'll need to authenticate with:
- Username: your GitHub username
- Password: your GitHub Personal Access Token (not password!)
  - Create token at: https://github.com/settings/tokens

#### Option B: SSH (More Secure)
```bash
# First, check if you have SSH keys
ls -la ~/.ssh

# If no keys, generate them
ssh-keygen -t ed25519 -C "your.email@example.com"

# Add SSH key to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copy public key
cat ~/.ssh/id_ed25519.pub

# Add to GitHub at: https://github.com/settings/keys

# Add remote origin (replace YOUR_USERNAME)
git remote add origin git@github.com:YOUR_USERNAME/lending-poc.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Branch Strategy Setup

### Create Development Branch
```bash
# Create and switch to develop branch
git checkout -b develop

# Push develop branch
git push -u origin develop
```

### Recommended Branch Structure
```
main (production)
  └── develop (integration)
       ├── feature/week1-foundation
       ├── feature/week2-core-objects
       ├── feature/week3-lwc-components
       └── feature/week4-portal
```

### Create Feature Branch for Week 1
```bash
# From develop branch
git checkout develop
git checkout -b feature/week1-foundation

# Push feature branch
git push -u origin feature/week1-foundation
```

## GitHub Repository Settings

### 1. Branch Protection (on GitHub.com)
1. Go to Settings → Branches
2. Add rule for `main`:
   - ✅ Require pull request reviews
   - ✅ Dismiss stale PR approvals
   - ✅ Require status checks
   - ✅ Include administrators
   - ✅ Restrict who can push

### 2. Add Collaborators
Settings → Manage access → Invite collaborators

### 3. Create Labels for Issues
Issues → Labels → New label:
- `week1`, `week2`, etc. (for sprint tracking)
- `enhancement`, `bug`, `documentation`
- `high-priority`, `medium-priority`, `low-priority`

## Commit Message Convention

Use conventional commits:
```
feat: Add loan application custom object
fix: Correct validation rule on income field
docs: Update Week 1 sprint documentation
chore: Configure CI/CD pipeline
test: Add unit tests for credit check service
```

## Daily Workflow

### Start of Day
```bash
# Get latest changes
git checkout develop
git pull origin develop

# Create/continue feature branch
git checkout -b feature/your-feature
# or
git checkout feature/your-feature
```

### During Development
```bash
# Check status
git status

# Add and commit changes
git add .
git commit -m "feat: Description of change"

# Push changes
git push origin feature/your-feature
```

### End of Day
```bash
# Push all changes
git push origin feature/your-feature

# Create Pull Request on GitHub
# Then merge to develop after review
```

## Useful Git Aliases

Add to ~/.gitconfig:
```ini
[alias]
    st = status
    co = checkout
    br = branch
    cm = commit -m
    pu = push
    pl = pull
    lg = log --oneline --graph --all
```

## Troubleshooting

### Authentication Failed
- For HTTPS: Create a Personal Access Token
- For SSH: Check SSH key is added to GitHub

### Permission Denied
```bash
# Check remote URL
git remote -v

# Change from HTTPS to SSH or vice versa
git remote set-url origin NEW_URL
```

### Merge Conflicts
```bash
# Pull latest changes
git pull origin develop

# Resolve conflicts in files
# Then:
git add .
git commit -m "fix: Resolve merge conflicts"
git push
```

## Next Steps After Setup

1. ✅ Git repository initialized
2. ✅ Connected to GitHub
3. 🔄 Set up CI/CD with GitHub Actions
4. 🔄 Configure branch protection rules
5. 🔄 Create project board for sprint tracking