# 🔐 API Key Setup Guide

## ⚠️ IMPORTANT SECURITY NOTICE

**Never commit API keys to version control!** This app requires an OpenAI API key to process receipts. Follow these steps to set it up securely.

## 🚀 Quick Setup (Development)

### Option 1: Environment Variable (Recommended)

1. **Get your OpenAI API Key:**
   - Go to [OpenAI Platform](https://platform.openai.com/api-keys)
   - Create a new API key
   - Copy the key (starts with `sk-`)

2. **Set Environment Variable:**
   ```bash
   # Add to your shell profile (~/.bashrc, ~/.zshrc, etc.)
   export OPENAI_API_KEY="your-actual-api-key-here"
   
   # Or set for current session only:
   export OPENAI_API_KEY="sk-proj-your-key-here"
   ```

3. **Run Xcode from Terminal:**
   ```bash
   # Open Xcode with environment variables
   open /Applications/Xcode.app
   ```

### Option 2: Xcode Scheme (Alternative)

1. **Open Xcode**
2. **Go to Product → Scheme → Edit Scheme**
3. **Select "Run" → "Arguments"**
4. **Add Environment Variable:**
   - Name: `OPENAI_API_KEY`
   - Value: `your-actual-api-key-here`

## 🔒 Production Deployment

For App Store deployment, consider these secure options:

### iOS Keychain (Recommended)
Store the API key in iOS Keychain for maximum security.

### Configuration Service
Use a secure configuration service or backend API.

### User Input
Let users enter their own API key in app settings.

## 🧪 Testing Setup

To test if your API key is configured correctly:

1. **Run the app**
2. **Try to scan a receipt**
3. **Check Xcode console for messages:**
   - ✅ `"Processing receipt with OpenAI..."` = Working
   - ❌ `"OPENAI_API_KEY environment variable not set"` = Not configured
   - ❌ `"Invalid OPENAI_API_KEY format"` = Invalid key format

## 🚨 Security Best Practices

### ✅ DO:
- Use environment variables for development
- Use iOS Keychain for production
- Validate API key format
- Monitor API usage and costs
- Rotate keys regularly

### ❌ DON'T:
- Hardcode keys in source code
- Commit keys to version control
- Share keys in plain text
- Use the same key across multiple projects
- Ignore API usage monitoring

## 🛠️ Troubleshooting

### "Invalid API Key" Error
- Check key format starts with `sk-`
- Verify key is not expired
- Ensure no extra spaces or characters

### "Environment Variable Not Set"
- Restart Xcode after setting environment variable
- Check shell profile is loaded
- Try setting in Xcode scheme instead

### "API Quota Exceeded"
- Check OpenAI account billing
- Monitor API usage in OpenAI dashboard
- Consider usage limits in app

## 📱 App Store Preparation

Before submitting to App Store:

1. **Remove all hardcoded keys** ✅ (Already done)
2. **Implement secure key storage** (iOS Keychain)
3. **Add user settings** for API key management
4. **Test with production keys**
5. **Monitor API costs** and usage

## 💡 Alternative Solutions

If you don't want to manage OpenAI keys:

1. **Backend API**: Create your own server to handle OpenAI requests
2. **Alternative OCR**: Use Apple's Vision framework (free, but less accurate)
3. **Manual Entry**: Allow users to enter receipt data manually
4. **Subscription Model**: Include API costs in app subscription

---

## 🆘 Need Help?

If you're having trouble with API key setup:

1. Check the Xcode console for error messages
2. Verify your OpenAI account has available credits
3. Test the API key with a simple curl command:

```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
     -H "Content-Type: application/json" \
     https://api.openai.com/v1/models
```

Remember: **Keep your API keys secure!** 🔐
