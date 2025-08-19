# 🚀 Backend Deployment Guide

## 🎯 Quick Deploy Options

### **Option 1: Heroku (Easiest)**

```bash
# 1. Install Heroku CLI
brew install heroku/brew/heroku

# 2. Create new app
heroku create budgyfinance-backend

# 3. Set environment variables
heroku config:set OPENAI_API_KEY="your-openai-key"
heroku config:set GOOGLE_APPLICATION_CREDENTIALS="path-to-firebase-service-account.json"

# 4. Deploy
git add .
git commit -m "Deploy backend service"
git push heroku main

# 5. Your API is live at:
# https://budgyfinance-backend.herokuapp.com
```

### **Option 2: Vercel (Serverless)**

```bash
# 1. Install Vercel CLI
npm i -g vercel

# 2. Deploy
vercel --prod

# 3. Set environment variables in Vercel dashboard
# OPENAI_API_KEY=your-key
# FIREBASE_PROJECT_ID=your-project-id
```

### **Option 3: Railway (Modern)**

```bash
# 1. Connect GitHub repo at railway.app
# 2. Auto-deploys on git push
# 3. Set environment variables in dashboard
```

## 🔧 Environment Setup

### **Required Environment Variables**

```bash
# OpenAI Configuration
OPENAI_API_KEY=sk-proj-your-actual-openai-key

# Firebase Configuration  
GOOGLE_APPLICATION_CREDENTIALS=path/to/service-account.json
FIREBASE_PROJECT_ID=your-project-id

# Optional: Custom settings
NODE_ENV=production
PORT=3000
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=50
```

### **Firebase Service Account Setup**

1. **Go to Firebase Console**
2. **Project Settings → Service Accounts**
3. **Generate New Private Key**
4. **Download JSON file**
5. **Upload to your hosting platform**

## 📱 iOS App Configuration

Update your iOS app to use the backend:

### **1. Replace ReceiptProcessor**

```swift
// In CaptureButtonView.swift, replace:
ReceiptProcessor.processImage(imageData, forUser: userId) { result in
    // ...
}

// With:
BackendReceiptProcessor.processImage(imageData, forUser: userId) { result in
    // ...
}
```

### **2. Update Backend URL**

```swift
// In BackendReceiptProcessor.swift
private static let backendURL = "https://your-app.herokuapp.com/api"
```

### **3. Handle New Error Cases**

```swift
case .failure(let error):
    switch error {
    case .apiQuotaExceeded:
        showUpgradePrompt() // User needs subscription
    case .authenticationFailed:
        showLoginScreen()   // Re-auth required
    case .serverError:
        showRetryOption()   // Backend issue
    default:
        showGenericError()
    }
```

## 💰 Business Logic Implementation

### **Free Tier Limits**

```javascript
// In backend-service.js
async function checkUserQuota(userId) {
  const userDoc = await admin.firestore()
    .collection('users')
    .doc(userId)
    .get();
    
  const userData = userDoc.data();
  const subscription = userData?.subscription;
  
  // Check subscription status
  if (subscription?.status === 'active') {
    return true; // Unlimited for premium users
  }
  
  // Free tier: 10 receipts per month
  const usage = userData?.usage?.thisMonth || 0;
  return usage < 10;
}
```

### **Subscription Integration**

```swift
// iOS: Check subscription status
class SubscriptionManager {
    static func checkSubscriptionStatus() -> Bool {
        // Integrate with App Store Connect
        // or your payment processor
        return UserDefaults.standard.bool(forKey: "has_premium_subscription")
    }
    
    static func showUpgradePrompt() {
        // Present subscription screen
        let subscriptionVC = SubscriptionViewController()
        UIApplication.shared.windows.first?.rootViewController?.present(subscriptionVC, animated: true)
    }
}
```

## 📊 Monitoring & Analytics

### **Backend Monitoring**

```javascript
// Add to backend-service.js
const analytics = {
  async logProcessing(userId, success, processingTime) {
    await admin.firestore().collection('analytics').add({
      userId,
      action: 'receipt_processing',
      success,
      processingTime,
      timestamp: new Date()
    });
  }
};

// Usage tracking for billing
const billing = {
  async trackCost(userId, estimatedCost) {
    await admin.firestore()
      .collection('users')
      .doc(userId)
      .update({
        'billing.monthlyUsage': admin.firestore.FieldValue.increment(estimatedCost)
      });
  }
};
```

### **iOS Analytics**

```swift
// Track user interactions
Analytics.logEvent("receipt_processing_started", parameters: nil)
Analytics.logEvent("receipt_processing_completed", parameters: [
    "success": true,
    "processing_time": processingTime
])
```

## 🔒 Security Checklist

### **✅ Backend Security**
- [ ] API keys in environment variables (not code)
- [ ] Firebase authentication required
- [ ] Rate limiting enabled
- [ ] Request validation
- [ ] Error handling (no sensitive data in errors)
- [ ] HTTPS only
- [ ] CORS properly configured

### **✅ iOS Security**
- [ ] No API keys in app bundle
- [ ] Proper SSL certificate validation
- [ ] User authentication required
- [ ] Graceful error handling
- [ ] No sensitive data in logs

## 🚀 Production Deployment Steps

### **1. Backend Deployment**
```bash
# Deploy to production
git push heroku main

# Verify health
curl https://your-app.herokuapp.com/health

# Test processing endpoint
curl -X POST https://your-app.herokuapp.com/api/process-receipt \
  -H "Authorization: Bearer firebase-token" \
  -H "Content-Type: application/json" \
  -d '{"extractedText": "Test Store\n2023-12-01\nItem 1 $5.00"}'
```

### **2. iOS App Update**
```swift
// Update backend URL to production
private static let backendURL = "https://budgyfinance-backend.herokuapp.com/api"

// Test in app
// 1. Take photo of receipt
// 2. Verify processing works
// 3. Check Firestore for saved receipt
// 4. Test error cases (no network, invalid auth)
```

### **3. App Store Submission**
- Update app with backend integration
- Test thoroughly on TestFlight
- Submit for App Store review
- Monitor backend performance

## 📈 Scaling Considerations

### **Performance Optimization**
```javascript
// Cache frequent requests
const redis = require('redis');
const cache = redis.createClient(process.env.REDIS_URL);

// Batch process multiple receipts
app.post('/api/process-batch', async (req, res) => {
  const { receipts } = req.body;
  const results = await Promise.all(
    receipts.map(receipt => processWithOpenAI(receipt))
  );
  res.json(results);
});
```

### **Cost Management**
```javascript
// Smart model selection
const selectModel = (textLength, complexity) => {
  if (textLength < 500 && complexity === 'simple') {
    return 'gpt-3.5-turbo'; // Cheaper
  }
  return 'gpt-4'; // More accurate but expensive
};
```

## 🆘 Troubleshooting

### **Common Issues**

#### **"Authentication Failed"**
- Check Firebase token is valid
- Verify service account permissions
- Ensure user is logged in

#### **"Quota Exceeded"**
- Check user subscription status
- Verify billing limits
- Monitor OpenAI usage

#### **"Backend Unavailable"**
- Check Heroku logs: `heroku logs --tail`
- Verify environment variables
- Check database connections

### **Debugging Commands**

```bash
# Check backend logs
heroku logs --tail --app budgyfinance-backend

# Test health endpoint
curl https://your-app.herokuapp.com/health

# Check environment variables
heroku config --app budgyfinance-backend
```

---

## 🎯 **Summary**

With this backend approach:

✅ **Users get seamless experience** - No API key setup required  
✅ **You control costs** - Monitor and manage OpenAI spending  
✅ **Scalable business model** - Subscription/freemium options  
✅ **App Store ready** - No security concerns  
✅ **Professional architecture** - Industry best practices  

Your customers will love the "it just works" experience! 🚀
