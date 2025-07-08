# GitHub CLI Installation & Setup

## Installation Options

### Option 1: Wait for Homebrew (Recommended)
The command `brew install gh` is already running. It may take a few minutes as it's installing dependencies.

### Option 2: Manual Download
1. Visit https://github.com/cli/cli/releases
2. Download the macOS binary for your architecture
3. Extract and move to /usr/local/bin

## After Installation

Once GitHub CLI is installed, authenticate and push:

```bash
# Authenticate with GitHub
gh auth login

# Follow the prompts:
# - Choose "GitHub.com"
# - Choose "HTTPS"
# - Authenticate with your web browser
# - It will open a browser window for authentication

# After authentication, push your changes
git push -u origin main
```

## Alternative: Use Personal Access Token

If you don't want to wait for gh installation:

1. Go to https://github.com/settings/tokens
2. Generate new token (classic) with 'repo' scope
3. Run:
```bash
git remote set-url origin https://Redsteban:YOUR_TOKEN@github.com/Redsteban/Invoicepatch_flutter.git
git push -u origin main
```

## Your Changes Ready to Push

The following fix has been committed and is ready to push:
- `lib/core/routing/app_router.gr.dart` - Contains the missing `$AppMainRouter` class that fixes the Xcode error