// Real Payment Configuration
// This file will store your actual payment gateway credentials

class RealPaymentConfig {
  // SHVA Payment Gateway Configuration
  static const String SHVA_BASE_URL = 'https://api.shva.co.il';
  static const String SHVA_MERCHANT_ID = 'YOUR_SHVA_MERCHANT_ID'; // Replace with your actual merchant ID
  static const String SHVA_TERMINAL_ID = 'YOUR_SHVA_TERMINAL_ID'; // Replace with your actual terminal ID
  static const String SHVA_API_KEY = 'YOUR_SHVA_API_KEY'; // Replace with your actual API key
  
  // Alternative: Cardcom Payment Gateway Configuration
  static const String CARDCOM_BASE_URL = 'https://secure.cardcom.solutions';
  static const String CARDCOM_TERMINAL_NUMBER = 'YOUR_CARDCOM_TERMINAL'; // Replace with your actual terminal
  static const String CARDCOM_USERNAME = 'YOUR_CARDCOM_USERNAME'; // Replace with your actual username
  static const String CARDCOM_PASSWORD = 'YOUR_CARDCOM_PASSWORD'; // Replace with your actual password
  
  // Bank Account Information
  static const String BANK_ACCOUNT_NUMBER = 'YOUR_BANK_ACCOUNT'; // Replace with your actual bank account
  static const String BANK_NAME = 'YOUR_BANK_NAME'; // Replace with your actual bank name
  static const String BANK_BRANCH = 'YOUR_BANK_BRANCH'; // Replace with your actual branch number
  
  // Business Information
  static const String BUSINESS_NAME = 'Medical Appointment System';
  static const String BUSINESS_ADDRESS = 'תל אביב, ישראל';
  static const String TAX_ID = 'YOUR_TAX_ID'; // Replace with your actual tax ID
  static const String BUSINESS_LICENSE = 'YOUR_BUSINESS_LICENSE'; // Replace with your actual license
  
  // Email Configuration
  static const String SMTP_HOST = 'smtp.gmail.com'; // Or your email provider
  static const int SMTP_PORT = 587;
  static const String SMTP_USERNAME = 'YOUR_EMAIL@gmail.com'; // Replace with your actual email
  static const String SMTP_PASSWORD = 'YOUR_EMAIL_PASSWORD'; // Replace with your actual email password
  
  // System Configuration
  static const String DEVELOPER_EMAIL = 'developer@medicalapp.com'; // Replace with your developer email
  static const String SYSTEM_URL = 'https://your-domain.com'; // Replace with your actual domain
  
  // Payment Settings
  static const double VAT_RATE = 0.17; // 17% VAT
  static const String CURRENCY = 'ILS';
  static const double GATEWAY_COMMISSION_RATE = 0.025; // 2.5% commission
  
  // Security Settings
  static const String JWT_SECRET = 'YOUR_JWT_SECRET_KEY'; // Replace with a strong secret key
  static const int JWT_EXPIRY_HOURS = 24;
  
  // Database Configuration
  static const String DATABASE_URL = 'postgresql://username:password@localhost:5432/medical_appointments';
  static const String REDIS_URL = 'redis://localhost:6379';
  
  // Validation Methods
  static bool isConfigured() {
    return SHVA_MERCHANT_ID != 'YOUR_SHVA_MERCHANT_ID' &&
           SHVA_TERMINAL_ID != 'YOUR_SHVA_TERMINAL_ID' &&
           SHVA_API_KEY != 'YOUR_SHVA_API_KEY' &&
           TAX_ID != 'YOUR_TAX_ID' &&
           JWT_SECRET != 'YOUR_JWT_SECRET_KEY';
  }
  
  static Map<String, dynamic> getPaymentGatewayConfig() {
    return {
      'baseUrl': SHVA_BASE_URL,
      'merchantId': SHVA_MERCHANT_ID,
      'terminalId': SHVA_TERMINAL_ID,
      'apiKey': SHVA_API_KEY,
      'currency': CURRENCY,
      'vatRate': VAT_RATE,
      'commissionRate': GATEWAY_COMMISSION_RATE,
    };
  }
  
  static Map<String, dynamic> getBusinessInfo() {
    return {
      'name': BUSINESS_NAME,
      'address': BUSINESS_ADDRESS,
      'taxId': TAX_ID,
      'license': BUSINESS_LICENSE,
      'developerEmail': DEVELOPER_EMAIL,
      'systemUrl': SYSTEM_URL,
    };
  }
  
  static Map<String, dynamic> getEmailConfig() {
    return {
      'host': SMTP_HOST,
      'port': SMTP_PORT,
      'username': SMTP_USERNAME,
      'password': SMTP_PASSWORD,
    };
  }
}








