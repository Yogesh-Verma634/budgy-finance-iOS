# 🔐 Security Setup Guide

## ⚠️ IMPORTANT: Before Pushing to GitHub

This guide explains how to properly configure your BudgyFinance app without exposing sensitive information to version control.

## 🚨 Critical Security Issues Fixed

1. **OpenAI API Key**: Removed hardcoded API key from `ReceiptProcessor.swift`
2. **Firebase Config**: `GoogleService-Info.plist` is properly excluded from git
3. **Configuration Template**: Created `Config.template.swift` for secure key management

## 🔧 Setup Instructions

### 1. Create Configuration File

Copy the template and create your actual configuration:

```bash
# Copy the template
cp budgyfinance/Config.template.swift budgyfinance/Config.swift

# Edit Config.swift with your actual values
# NEVER commit Config.swift to version control!
```

### 2. Configure OpenAI API Key

**Option A: Environment Variable (Recommended for Production)**
```bash
export OPENAI_API_KEY="your_actual_api_key_here"
```

**Option B: Config.plist (For Development)**
Create `budgyfinance/Config.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.whatwg.org/specs/web-apps/current-work/#">
<plist version="1.0">
<dict>
    <key>OpenAIAPIKey</key>
    <string>your_actual_api_key_here</string>
</dict>
</plist>
```

**Option C: Hardcoded (Development Only)**
In `Config.swift`, uncomment and set:
```swift
return "your_actual_api_key_here"
```

### 3. Firebase Configuration

The `GoogleService-Info.plist` file is already properly excluded from git. Make sure it's in your project but not committed.

## 📁 Files to NEVER Commit

- `budgyfinance/Config.swift` (your actual configuration)
- `budgyfinance/Config.plist` (if you create one)
- `budgyfinance/GoogleService-Info.plist` (Firebase config)
- Any `.env` files
- `*.xcuserstate` files
- `xcuserdata/` directories

## ✅ Files Safe to Commit

- `budgyfinance/Config.template.swift` (template only)
- All source code files
- Project configuration files
- README and documentation

## 🔍 Verification Checklist

Before pushing to GitHub, verify:

- [ ] `Config.swift` is not in git tracking
- [ ] `GoogleService-Info.plist` is not in git tracking
- [ ] No hardcoded API keys in source code
- [ ] `.gitignore` properly excludes sensitive files
- [ ] `Config.template.swift` shows placeholder values

## 🚀 Production Deployment

For production apps:

1. Use environment variables for all API keys
2. Implement secure key management (Keychain, etc.)
3. Use Firebase App Check for additional security
4. Enable Firebase Security Rules
5. Use HTTPS for all API calls

## 🆘 If You Accidentally Committed Sensitive Data

1. **Immediately revoke/regenerate the exposed API key**
2. **Remove the file from git history:**
   ```bash
   git filter-branch --force --index-filter \
   'git rm --cached --ignore-unmatch path/to/sensitive/file' \
   --prune-empty --tag-name-filter cat -- --all
   ```
3. **Force push to remove from remote:**
   ```bash
   git push origin --force --all
   ```
4. **Update .gitignore to prevent future commits**

## 📞 Support

If you need help with security configuration, refer to:
- [Firebase Security Documentation](https://firebase.google.com/docs/rules)
- [OpenAI API Security Best Practices](https://platform.openai.com/docs/guides/security)
- [iOS Security Guidelines](https://developer.apple.com/security/)
