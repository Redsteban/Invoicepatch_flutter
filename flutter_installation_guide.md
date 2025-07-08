# Flutter Installation Guide for macOS

Since the automated download is timing out due to the large file size (~1.5GB), please follow these manual steps:

## Option 1: Install via Homebrew (Recommended)

1. First, install Homebrew by opening Terminal and running:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
   
2. After Homebrew is installed, install Flutter:
   ```bash
   brew install --cask flutter
   ```

## Option 2: Manual Installation

1. Visit https://flutter.dev/docs/get-started/install/macos
2. Download the Flutter SDK for your system (ARM64 for Apple Silicon or x64 for Intel)
3. Extract the zip file to a location like `~/development/`
4. Add Flutter to your PATH by adding this to your `~/.zshrc` or `~/.bash_profile`:
   ```bash
   export PATH="$PATH:$HOME/development/flutter/bin"
   ```
5. Run `source ~/.zshrc` (or `source ~/.bash_profile`)

## Option 3: Install Xcode Command Line Tools and use Git

1. Install Xcode Command Line Tools (will prompt when you run git)
2. Clone Flutter:
   ```bash
   git clone https://github.com/flutter/flutter.git -b stable ~/development/flutter
   ```
3. Add to PATH as shown in Option 2

## After Installation

Once Flutter is installed, come back and run:
```bash
cd /Users/ricardoesteban/Invoicepatch_flutter
flutter pub get
```

This will install all the dependencies for the InvoicePatch project.