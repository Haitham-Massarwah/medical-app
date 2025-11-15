# 💳 Doctor Subscription System - Complete Guide

## Overview

A comprehensive monthly subscription system for doctors has been implemented in your Medical Appointment System. Doctors now pay a monthly fee to use the platform, providing you with recurring revenue.

---

## 📋 What Was Implemented

### ✅ Backend (Node.js/Express + PostgreSQL)

1. **Database Schema**
   - `subscription_plans` - Predefined subscription tiers (Basic, Professional, Enterprise)
   - `doctor_subscriptions` - Tracks doctor subscriptions
   - `subscription_transactions` - Payment history
   - `subscription_usage` - Monthly usage tracking
   - Updated `doctors` table with subscription fields

2. **Subscription Service** (`backend/src/services/subscription.service.ts`)
   - Full Stripe payment integration
   - Subscription lifecycle management (create, cancel, resume, upgrade)
   - Webhook handling for automated updates
   - Usage tracking and limits enforcement
   - Invoice management

3. **API Endpoints** (`backend/src/routes/subscription.routes.ts`)
   - `GET /api/v1/subscriptions/plans` - List all plans
   - `POST /api/v1/subscriptions/subscribe` - Create subscription
   - `GET /api/v1/subscriptions/current` - Get current subscription
   - `POST /api/v1/subscriptions/cancel` - Cancel subscription
   - `POST /api/v1/subscriptions/resume` - Resume subscription
   - `POST /api/v1/subscriptions/change-plan` - Upgrade/downgrade
   - `GET /api/v1/subscriptions/invoices` - View payment history
   - `GET /api/v1/subscriptions/usage` - Check usage statistics
   - `POST /api/v1/subscriptions/webhook` - Stripe webhook handler

4. **Middleware** (`backend/src/middleware/subscription.middleware.ts`)
   - `requireActiveSubscription` - Blocks access without subscription
   - `checkAppointmentLimit` - Enforces usage limits
   - `warnIfNoSubscription` - Graceful degradation for non-critical features

### ✅ Frontend (Flutter)

1. **Data Models** (`lib/features/subscriptions/data/models/subscription_models.dart`)
   - `SubscriptionPlan` - Plan information
   - `DoctorSubscription` - Subscription state
   - `SubscriptionTransaction` - Payment records
   - `SubscriptionUsage` - Usage statistics

2. **API Integration** (`lib/features/subscriptions/data/datasources/subscription_remote_datasource.dart`)
   - Complete API client for all subscription endpoints

3. **UI Screens**
   - `SubscriptionPlansScreen` - Beautiful plan selection page
   - `SubscriptionManagementScreen` - Dashboard with 3 tabs:
     - Overview: Current plan and status
     - Usage: Appointment usage tracking
     - Invoices: Payment history

---

## 💰 Subscription Plans

### Basic Plan
- **Price**: ₪99/month
- **Trial**: 14 days free
- **Limit**: 50 appointments/month
- **Features**:
  - Email notifications
  - Basic calendar integration
  - Patient management
  - Mobile app access

### Professional Plan (POPULAR)
- **Price**: ₪199/month
- **Trial**: 14 days free
- **Limit**: 200 appointments/month
- **Features**:
  - Email & SMS notifications
  - Full calendar integration
  - Patient management
  - Mobile app access
  - WhatsApp notifications
  - Priority support
  - Custom availability rules

### Enterprise Plan
- **Price**: ₪399/month
- **Trial**: 14 days free
- **Limit**: Unlimited appointments
- **Features**:
  - All notification channels
  - Advanced calendar integration
  - Patient management
  - Mobile app access
  - WhatsApp notifications
  - Priority 24/7 support
  - Custom availability rules
  - Analytics dashboard
  - Multiple staff accounts
  - API access
  - Custom branding

---

## 🔧 Setup Instructions

### 1. Database Migration

Run the subscription migration:

```bash
cd backend
npm run migrate
```

This will create all subscription tables and insert the default plans.

### 2. Stripe Configuration

#### Get Stripe API Keys:
1. Go to [Stripe Dashboard](https://dashboard.stripe.com/)
2. Get your API keys from Developers → API keys
3. Get your webhook secret from Developers → Webhooks

#### Update `.env` file:

```env
# Stripe Configuration
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key_here
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key_here
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here
```

⚠️ **Important**: Use test keys for development, live keys for production!

### 3. Stripe Webhook Setup

Configure Stripe to send webhook events to your server:

1. Go to Stripe Dashboard → Developers → Webhooks
2. Click "Add endpoint"
3. Enter URL: `https://your-domain.com/api/v1/subscriptions/webhook`
4. Select these events:
   - `invoice.paid`
   - `invoice.payment_failed`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
5. Copy the webhook signing secret to your `.env` file

### 4. Test the System

#### Start the backend:
```bash
cd backend
npm run dev
```

#### Test API endpoints:

```bash
# Get subscription plans
curl http://localhost:3000/api/v1/subscriptions/plans

# Get current subscription (requires authentication)
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     http://localhost:3000/api/v1/subscriptions/current
```

---

## 💳 How It Works

### For Doctors:

1. **Registration**
   - Doctor registers as usual
   - After registration, they must subscribe to access features

2. **Subscription Selection**
   - Doctors browse plans on `SubscriptionPlansScreen`
   - All plans include 14-day free trial
   - Select plan and enter payment details

3. **Trial Period**
   - 14 days of full access
   - No charges during trial
   - Can cancel anytime

4. **Active Subscription**
   - Full access to all features
   - Monthly billing automatically
   - Usage tracking based on plan

5. **Usage Limits**
   - System tracks appointments per month
   - Warning when approaching limit (80%)
   - Blocked when limit reached (except unlimited plans)

6. **Subscription Management**
   - View current plan and usage
   - Upgrade/downgrade plans
   - Cancel subscription
   - View invoice history

### For You (Platform Owner):

1. **Automatic Revenue**
   - Stripe handles all billing automatically
   - Monthly recurring payments
   - Automatic retry on failed payments

2. **Webhook Automation**
   - Payment success → Record transaction
   - Payment failed → Update status to "past_due"
   - Subscription canceled → Disable access
   - All handled automatically

3. **Dashboard Visibility**
   - View all subscriptions in Stripe Dashboard
   - Track MRR (Monthly Recurring Revenue)
   - Monitor churn rate
   - Export financial reports

---

## 🔒 Access Control

The subscription middleware is applied to appointment booking:

```typescript
// backend/src/routes/appointment.routes.ts
router.post(
  '/',
  requireActiveSubscription,      // Must have active subscription
  checkAppointmentLimit,           // Must not exceed plan limits
  appointmentController.bookAppointment
);
```

### Subscription Statuses:

- **active**: Full access
- **trialing**: Full access (trial period)
- **past_due**: Payment failed, limited access
- **canceled**: Subscription ended
- **unpaid**: Payment required
- **incomplete**: Setup not completed

---

## 📊 Revenue Model

### Monthly Recurring Revenue (MRR):

| Plan | Price | Assumed Doctors | Monthly Revenue |
|------|-------|----------------|-----------------|
| Basic | ₪99 | 50 | ₪4,950 |
| Professional | ₪199 | 100 | ₪19,900 |
| Enterprise | ₪399 | 30 | ₪11,970 |
| **Total** | | **180** | **₪36,820/month** |

### Annual Recurring Revenue (ARR):
- **₪441,840/year** with these numbers

---

## 🎨 Customization

### Change Plan Prices:

Update the database:

```sql
UPDATE subscription_plans 
SET price = 149.00 
WHERE name = 'Professional';
```

### Add New Plan:

```sql
INSERT INTO subscription_plans (
  name, description, price, currency, interval,
  max_appointments_per_month, features, is_active
) VALUES (
  'Premium',
  'For large clinics',
  599.00,
  'ILS',
  'monthly',
  500,
  '["Feature 1", "Feature 2", "Feature 3"]',
  true
);
```

### Modify Features:

Edit `backend/src/database/migrations/002_subscription_system.ts` and re-run migration.

---

## 🧪 Testing

### Test Stripe Integration:

Use Stripe test card numbers:
- **Success**: `4242 4242 4242 4242`
- **Decline**: `4000 0000 0000 0002`
- **3D Secure**: `4000 0025 0000 3155`

Any future expiry date and any 3-digit CVC.

### Test Webhook Locally:

Use Stripe CLI:

```bash
# Install Stripe CLI
# https://stripe.com/docs/stripe-cli

# Login
stripe login

# Forward webhooks to local server
stripe listen --forward-to localhost:3000/api/v1/subscriptions/webhook
```

---

## 📝 Frontend Integration

### Navigate to Subscription Plans:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SubscriptionPlansScreen(
      datasource: subscriptionDatasource,
    ),
  ),
);
```

### View Subscription Dashboard:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SubscriptionManagementScreen(
      datasource: subscriptionDatasource,
    ),
  ),
);
```

---

## ⚠️ Important Notes

1. **Trial Period**
   - All plans include 14-day free trial
   - No payment method required during trial
   - Automatic conversion to paid after trial

2. **Payment Failures**
   - Stripe retries failed payments automatically
   - 4 retry attempts over 2 weeks
   - Status changes to "past_due" on failure
   - Email notifications sent automatically

3. **Cancellation**
   - Doctors can cancel anytime
   - Access continues until end of billing period
   - No refunds for partial months

4. **Prorations**
   - Upgrades are prorated automatically
   - Downgrades take effect at next billing cycle
   - Handled by Stripe

5. **Security**
   - Payment details stored in Stripe (PCI compliant)
   - Only tokens/IDs stored in your database
   - Never store raw card numbers

---

## 🚀 Next Steps

1. **Configure Stripe Account**
   - Add your API keys to `.env`
   - Set up webhook endpoint
   - Test in development mode

2. **Run Database Migration**
   - Creates subscription tables
   - Inserts default plans

3. **Test Subscription Flow**
   - Register as doctor
   - Try subscribing to each plan
   - Test trial period
   - Test cancellation

4. **Go Live**
   - Switch to Stripe live keys
   - Update webhook URL to production
   - Monitor Stripe dashboard

5. **Optional Enhancements**
   - Add annual billing (20% discount)
   - Implement referral system
   - Add promotional codes
   - Create affiliate program

---

## 📞 Support

### For Doctors:
- Email: support@your-app.com
- In-app chat support
- FAQ page: /help/subscriptions

### For You:
- Stripe Dashboard: https://dashboard.stripe.com
- Stripe Support: https://support.stripe.com
- Documentation: https://stripe.com/docs

---

## 📈 Monitoring

### Key Metrics to Track:

1. **MRR (Monthly Recurring Revenue)**
2. **Churn Rate** (% of cancellations)
3. **Conversion Rate** (trial → paid)
4. **Average Revenue Per User (ARPU)**
5. **Customer Lifetime Value (LTV)**

All available in Stripe Dashboard!

---

## ✅ Checklist

Before launching:

- [ ] Stripe account created and verified
- [ ] API keys added to `.env`
- [ ] Database migration run successfully
- [ ] Webhook endpoint configured in Stripe
- [ ] Test subscription flow completed
- [ ] Payment success tested
- [ ] Payment failure handled correctly
- [ ] Cancellation flow tested
- [ ] Usage limits enforced correctly
- [ ] Email notifications configured
- [ ] Terms of service updated
- [ ] Privacy policy updated
- [ ] Customer support ready

---

## 🎉 Congratulations!

Your subscription system is complete and ready to generate recurring revenue! 💰

Doctors will now pay monthly to use your platform, and everything is automated through Stripe.

**Expected Revenue**: Start with 10 doctors, grow to 100+ = ₪20,000+/month!

---

*Built with ❤️ for your Medical Appointment System*
*Last Updated: October 2025*


