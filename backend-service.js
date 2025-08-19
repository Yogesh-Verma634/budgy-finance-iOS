// 🌐 Simple Backend Service for BudgyFinance
// This handles OpenAI API calls securely on your server

const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const admin = require('firebase-admin');

const app = express();

// Initialize Firebase Admin (for user authentication)
admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});

// Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 50, // limit each IP to 50 requests per windowMs
  message: 'Too many requests, please try again later.'
});
app.use('/api/', limiter);

// Verify Firebase token middleware
const verifyToken = async (req, res, next) => {
  const token = req.headers.authorization?.split('Bearer ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'No authentication token provided' });
  }
  
  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid authentication token' });
  }
};

// 📱 Main endpoint: Process receipt
app.post('/api/process-receipt', verifyToken, async (req, res) => {
  try {
    const { extractedText } = req.body;
    const userId = req.user.uid;
    
    console.log(`📋 Processing receipt for user: ${userId}`);
    
    // Validate request
    if (!extractedText || extractedText.trim().length === 0) {
      return res.status(400).json({ 
        error: 'No text provided for processing' 
      });
    }
    
    // Check user quota (implement your business logic)
    const hasQuota = await checkUserQuota(userId);
    if (!hasQuota) {
      return res.status(429).json({ 
        error: 'Processing quota exceeded. Please upgrade your plan.' 
      });
    }
    
    // Process with OpenAI
    const receipt = await processWithOpenAI(extractedText);
    
    // Track usage
    await trackUsage(userId, extractedText.length);
    
    // Save to user's Firestore
    await saveReceiptToFirestore(userId, receipt);
    
    console.log(`✅ Receipt processed successfully for user: ${userId}`);
    res.json(receipt);
    
  } catch (error) {
    console.error('❌ Error processing receipt:', error);
    res.status(500).json({ 
      error: 'Failed to process receipt',
      details: error.message 
    });
  }
});

// 🤖 OpenAI Integration
async function processWithOpenAI(extractedText) {
  const OPENAI_API_KEY = process.env.OPENAI_API_KEY;
  
  if (!OPENAI_API_KEY) {
    throw new Error('OpenAI API key not configured');
  }
  
  const prompt = `
Extract receipt information from this text and return ONLY a valid JSON object with this exact structure:

{
  "storeName": "Store Name",
  "date": "YYYY-MM-DD",
  "items": [
    {
      "name": "Item Name",
      "price": 0.00,
      "quantity": 1.0,
      "category": "Food & Dining"
    }
  ]
}

Receipt text:
${extractedText}

Return only the JSON object, no other text.`;

  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${OPENAI_API_KEY}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      model: 'gpt-3.5-turbo',
      messages: [{ role: 'user', content: prompt }],
      max_tokens: 2000,
      temperature: 0.1
    })
  });
  
  if (!response.ok) {
    throw new Error(`OpenAI API error: ${response.status}`);
  }
  
  const result = await response.json();
  const content = result.choices[0]?.message?.content;
  
  if (!content) {
    throw new Error('No content received from OpenAI');
  }
  
  // Parse JSON response
  try {
    const receipt = JSON.parse(content.trim());
    
    // Add required fields
    receipt.id = generateReceiptId();
    receipt.scannedTime = new Date().toISOString();
    receipt.category = receipt.category || 'Other';
    
    // Ensure items have IDs
    if (receipt.items) {
      receipt.items = receipt.items.map(item => ({
        ...item,
        id: generateItemId()
      }));
    }
    
    return receipt;
    
  } catch (parseError) {
    console.error('Failed to parse OpenAI response:', content);
    throw new Error('Invalid response format from AI service');
  }
}

// 💰 Business Logic
async function checkUserQuota(userId) {
  // Implement your subscription/quota logic here
  // For example, check if user has premium subscription
  
  const userDoc = await admin.firestore()
    .collection('users')
    .doc(userId)
    .get();
    
  const userData = userDoc.data();
  const isPremium = userData?.subscription?.status === 'active';
  const freeUsageThisMonth = userData?.usage?.thisMonth || 0;
  
  // Free users: 10 receipts per month
  // Premium users: unlimited
  return isPremium || freeUsageThisMonth < 10;
}

async function trackUsage(userId, textLength) {
  const usage = {
    userId,
    timestamp: new Date(),
    textLength,
    estimatedCost: (textLength / 1000) * 0.002 // Rough estimate
  };
  
  await admin.firestore()
    .collection('usage')
    .add(usage);
    
  // Update user's monthly usage counter
  const userRef = admin.firestore().collection('users').doc(userId);
  await userRef.update({
    'usage.thisMonth': admin.firestore.FieldValue.increment(1),
    'usage.lastUsed': new Date()
  });
}

async function saveReceiptToFirestore(userId, receipt) {
  await admin.firestore()
    .collection('users')
    .doc(userId)
    .collection('receipts')
    .doc(receipt.id)
    .set(receipt);
}

// 🔧 Utility functions
function generateReceiptId() {
  return 'receipt_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
}

function generateItemId() {
  return 'item_' + Math.random().toString(36).substr(2, 9);
}

// 📊 Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    service: 'budgyfinance-backend'
  });
});

// 🚀 Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🌐 BudgyFinance Backend running on port ${PORT}`);
  console.log(`📋 Receipt processing endpoint: /api/process-receipt`);
  console.log(`💡 Health check: /health`);
});

module.exports = app;
