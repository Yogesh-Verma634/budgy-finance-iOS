# BudgyFinance - Smart Finance Management App

A professional iOS finance management application with robust security features, receipt capture, and intelligent spending analytics.

## 🚀 Features

### 🔐 Enhanced Security & Authentication
- **Email Verification System**: Mandatory email verification for all new accounts
- **Strong Password Requirements**: Enforces 8+ characters with uppercase, lowercase, numbers, and special characters
- **Biometric Authentication**: Face ID and Touch ID support for secure access
- **Session Management**: Configurable session timeouts with automatic logout
- **Security Logging**: Comprehensive security event tracking and monitoring
- **Account Security Scoring**: Real-time security assessment and recommendations
- **Password Reset**: Secure password recovery via email
- **Account Deletion**: Secure account removal with data cleanup

### 📱 Core Features
- **Receipt Capture**: Camera-based receipt scanning with OCR
- **Smart Processing**: AI-powered receipt data extraction using GPT
- **Category Detection**: Automatic spending categorization
- **Budget Tracking**: Real-time budget monitoring by categories
- **Spending Analytics**: Detailed spending trends and insights
- **Search & Filter**: Advanced receipt search and sorting
- **Data Export**: Secure data backup and export capabilities

### 🎨 Modern UI/UX
- **Professional Design**: Modern, clean interface with glassmorphism effects
- **Animated Splash Screen**: Engaging app launch experience
- **Responsive Layout**: Optimized for all iOS devices
- **Dark Mode Support**: Automatic theme adaptation
- **Accessibility**: Full VoiceOver and accessibility support

## 🔒 Security Architecture

### Authentication Flow
1. **Registration**: Email + strong password with real-time validation
2. **Email Verification**: Mandatory verification before account activation
3. **Login**: Secure authentication with biometric option
4. **Session Management**: Automatic timeout and re-authentication
5. **Password Reset**: Secure email-based recovery

### Security Features
- **Biometric Authentication**: Face ID/Touch ID integration
- **Session Timeouts**: Configurable from 5 minutes to never
- **Security Logging**: All security events tracked and stored
- **Account Security Score**: Real-time security assessment
- **Suspicious Activity Detection**: Failed login monitoring
- **Data Encryption**: All sensitive data encrypted at rest and in transit

### Privacy & Compliance
- **GDPR Compliant**: User data control and deletion
- **Privacy Policy**: Comprehensive privacy documentation
- **Terms of Service**: Clear usage terms and conditions
- **Data Minimization**: Only necessary data collection
- **User Consent**: Explicit consent for data processing

## 🛠 Technical Stack

### Frontend
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for data flow
- **LocalAuthentication**: Biometric authentication
- **Core Data**: Local data persistence

### Backend & Services
- **Firebase Authentication**: Secure user management
- **Firestore**: Cloud database with real-time sync
- **Firebase Storage**: Secure file storage
- **OpenAI GPT**: AI-powered receipt processing

### Security
- **Firebase Security Rules**: Database access control
- **HTTPS**: Encrypted data transmission
- **Keychain**: Secure credential storage
- **App Transport Security**: Network security enforcement

## 📋 Requirements

### iOS Requirements
- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

### Device Capabilities
- Camera (for receipt capture)
- Biometric authentication (Face ID/Touch ID)
- Internet connection (for cloud sync)

## 🚀 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/budgyfinance.git
   cd budgyfinance
   ```

2. **Install dependencies**
   ```bash
   pod install
   ```

3. **Configure Firebase**
   - Add your `GoogleService-Info.plist` to the project
   - Configure Firebase Authentication
   - Set up Firestore database
   - Configure Firebase Storage

4. **Configure OpenAI**
   - Add your OpenAI API key to the project
   - Configure GPT model settings

5. **Build and run**
   ```bash
   open budgyfinance.xcworkspace
   ```

## 🔧 Configuration

### Firebase Setup
1. Create a new Firebase project
2. Enable Authentication with Email/Password
3. Create Firestore database
4. Configure Security Rules
5. Enable Storage for receipt images

### OpenAI Configuration
1. Get API key from OpenAI
2. Configure GPT model (gpt-4 or gpt-3.5-turbo)
3. Set up rate limiting and usage monitoring

### Security Settings
1. Configure biometric authentication
2. Set session timeout preferences
3. Enable security logging
4. Configure password policies

## 📱 Usage

### Getting Started
1. **Download and install** the app from the App Store
2. **Create account** with email and strong password
3. **Verify email** by clicking the verification link
4. **Enable biometric authentication** (optional but recommended)
5. **Start capturing receipts** and managing your finances

### Receipt Management
1. **Capture**: Use camera to scan receipts
2. **Review**: Edit extracted data if needed
3. **Categorize**: Automatic or manual categorization
4. **Track**: Monitor spending by categories
5. **Analyze**: View spending trends and insights

### Security Management
1. **Access Security Settings** from Profile tab
2. **Enable Biometric Authentication** for quick access
3. **Configure Session Timeout** based on preferences
4. **Monitor Security Score** and follow recommendations
5. **Review Security Logs** for account activity

## 🔒 Security Best Practices

### For Users
- Use strong, unique passwords
- Enable biometric authentication
- Verify email address immediately
- Set appropriate session timeouts
- Regularly review security logs
- Keep app updated

### For Developers
- Follow OWASP security guidelines
- Implement proper input validation
- Use secure coding practices
- Regular security audits
- Keep dependencies updated
- Monitor for vulnerabilities

## 📊 Analytics & Insights

### Spending Analytics
- **Category Breakdown**: Visual spending by category
- **Trend Analysis**: Monthly/quarterly spending trends
- **Budget Tracking**: Real-time budget vs actual spending
- **Receipt History**: Complete transaction history
- **Export Capabilities**: Data export for external analysis

### Security Analytics
- **Security Score**: Real-time account security assessment
- **Login History**: Track successful and failed logins
- **Session Monitoring**: Active session tracking
- **Biometric Usage**: Biometric authentication statistics

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new features
5. Submit a pull request

### Development Guidelines
- Follow Swift style guidelines
- Add comprehensive documentation
- Include unit tests for new features
- Ensure security best practices
- Test on multiple devices

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Documentation
- [User Guide](docs/user-guide.md)
- [API Documentation](docs/api.md)
- [Security Guide](docs/security.md)

### Contact
- **Email**: support@budgyfinance.com
- **Website**: https://budgyfinance.com
- **Support Portal**: https://support.budgyfinance.com

## 🔄 Version History

### v1.0.0 (Current)
- Initial release with core features
- Enhanced security system
- Professional UI/UX
- Biometric authentication
- Email verification
- Comprehensive analytics

### Planned Features
- Multi-currency support
- Receipt sharing
- Advanced reporting
- Integration with banking APIs
- Family account management
- Expense approval workflows

## 🙏 Acknowledgments

- Firebase for backend services
- OpenAI for AI-powered processing
- Apple for iOS development tools
- SwiftUI community for UI components
- Security researchers for best practices

---

**BudgyFinance** - Making personal finance management secure, smart, and simple.
