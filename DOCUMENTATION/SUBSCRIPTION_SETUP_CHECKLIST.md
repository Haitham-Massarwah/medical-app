# 🚀 Subscription System Setup - Quick Checklist

## ✅ 5-Minute Setup Guide

Follow these steps to activate the monthly subscription system for doctors:

---

## Step 1: Get Stripe Account (5 minutes)

1. Go to https://stripe.com
2. Click "Start now" (or login if you have account)
3. Complete registration
4. Verify your email
5. Complete business profile

---

## Step 2: Get API Keys (2 minutes)

1. Go to Stripe Dashboard → Developers → API keys
2. Copy these keys:
   - **Publishable key** (starts with `pk_test_...`)
   - **Secret key** (starts with `sk_test_...`)

---

## Step 3: Configure Environment (1 minute)

Edit `backend/.env` file:

```env
STRIPE_SECRET_KEY=sk_test_YOUR_KEY_HERE
STRIPE_PUBLISHABLE_KEY=pk_test_YOUR_KEY_HERE
STRIPE_WEBHOOK_SECRET=whsec_YOUR_SECRET_HERE
```

---

## Step 4: Run Database Migration (1 minute)

```bash
cd backend
npm run migrate
```

This creates:
- `subscription_plans` table
- `doctor_subscriptions` table
- `subscription_transactions` table
- `subscription_usage` table
- 3 default plans (Basic, Professional, Enterprise)

---

## Step 5: Setup Webhook (3 minutes)

### For Development (Local Testing):

1. Install Stripe CLI: https://stripe.com/docs/stripe-cli
2. Run:
```bash
stripe login
stripe listen --forward-to localhost:3000/api/v1/subscriptions/webhook
```
3. Copy the webhook secret (starts with `whsec_`)
4. Add to `.env` file

### For Production:

1. Go to Stripe Dashboard → Developers → Webhooks
2. Click "Add endpoint"
3. URL: `https://your-domain.com/api/v1/subscriptions/webhook`
4. Select events:
   - `invoice.paid`
   - `invoice.payment_failed`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
5. Copy webhook secret to `.env`

---

## Step 6: Test the System (5 minutes)

### Start your servers:

```bash
# Terminal 1: Backend
cd backend
npm run dev

# Terminal 2: Frontend
flutter run -d chrome
```

### Test as a doctor:

1. **Register** as a doctor
2. **Navigate** to subscriptions page
3. **Select** a plan (use Basic for testing)
4. **Enter test card**: `4242 4242 4242 4242`
   - Expiry: Any future date
   - CVC: Any 3 digits
5. **Complete** subscription
6. **Verify** you have access

### Verify in Stripe:

1. Go to Stripe Dashboard
2. Click "Customers" - you should see the doctor
3. Click "Subscriptions" - you should see active subscription
4. Click "Payments" - you should see successful payment

---

## 🎉 Done! Your Subscription System is Live!

---

## 💰 What Happens Next?

### Automatic Processes:

1. **Monthly Billing**
   - Stripe charges doctors automatically every month
   - Invoices sent via email
   - Failed payments retry automatically

2. **Usage Tracking**
   - System counts appointments per month
   - Limits enforced based on plan
   - Warning at 80% usage

3. **Access Control**
   - Active subscription = full access
   - Past due = limited access
   - Canceled = no access

4. **Webhook Updates**
   - Payment success → Record transaction
   - Payment failure → Update status
   - Subscription changes → Sync automatically

---

## 📊 Monitor Your Revenue

### Stripe Dashboard Shows:

- **Total revenue** (today, week, month)
- **Active subscriptions** count
- **Monthly Recurring Revenue (MRR)**
- **Failed payments** to follow up
- **Customer list** with details
- **Payment history** and invoices

Access: https://dashboard.stripe.com

---

## 🧪 Test Cards

Use these for testing (no real charges):

| Card Number | Result |
|-------------|--------|
| `4242 4242 4242 4242` | Success |
| `4000 0000 0000 0002` | Declined |
| `4000 0025 0000 3155` | 3D Secure required |

**Any future expiry + any 3-digit CVC**

---

## 🔧 Customization

### Change Plan Prices:

```sql
-- Connect to your database
UPDATE subscription_plans 
SET price = 149.00 
WHERE name = 'Professional';
```

### Change Trial Period:

```sql
-- Set to 30 days
UPDATE subscription_plans 
SET trial_days = 30;

-- Remove trial
UPDATE subscription_plans 
SET trial_days = 0;
```

### Change Appointment Limits:

```sql
-- Unlimited
UPDATE subscription_plans 
SET max_appointments_per_month = -1 
WHERE name = 'Enterprise';

-- Set to 100
UPDATE subscription_plans 
SET max_appointments_per_month = 100 
WHERE name = 'Professional';
```

---

## ⚠️ Important: Go Live

When ready for production:

1. **Get Live API Keys**
   - Stripe Dashboard → toggle "View test data" OFF
   - Copy live keys (start with `pk_live_` and `sk_live_`)

2. **Update .env**
   ```env
   STRIPE_SECRET_KEY=sk_live_YOUR_LIVE_KEY
   STRIPE_PUBLISHABLE_KEY=pk_live_YOUR_LIVE_KEY
   ```

3. **Update Webhook**
   - Point to production URL
   - Get new webhook secret
   - Update in `.env`

4. **Verify Business Details**
   - Bank account for payouts
   - Business verification complete
   - Tax information submitted

---

## 📞 Need Help?

### Common Issues:

**"Webhook signature verification failed"**
- Check `STRIPE_WEBHOOK_SECRET` in `.env`
- Make sure webhook URL matches exactly
- Verify endpoint is accessible

**"No subscription plans showing"**
- Run database migration: `npm run migrate`
- Check backend logs for errors
- Verify API is running on port 3000

**"Payment not going through"**
- In test mode? Use test cards only
- Check Stripe Dashboard → Logs
- Verify API keys are correct

**"Subscription not activating"**
- Check webhook is configured
- Verify webhook events are being received
- Check backend logs for webhook errors

### Resources:

- **Stripe Docs**: https://stripe.com/docs
- **Stripe Support**: https://support.stripe.com
- **Test Cards**: https://stripe.com/docs/testing

---

## 🎯 Success Checklist

Before going live, verify:

- [ ] Stripe account verified
- [ ] Live API keys configured
- [ ] Webhook configured and working
- [ ] Database migration completed
- [ ] Test subscription successful
- [ ] Payment flow working
- [ ] Cancel flow working
- [ ] Usage limits enforcing
- [ ] Email notifications working
- [ ] Stripe Dashboard accessible
- [ ] Bank account connected for payouts
- [ ] Terms of service includes subscription info
- [ ] Privacy policy updated
- [ ] Customer support email set up

---

## 💡 Pro Tips

1. **Start with Test Mode**
   - Use test keys for first week
   - Test all scenarios
   - Switch to live when confident

2. **Monitor Daily**
   - Check Stripe Dashboard daily
   - Watch for failed payments
   - Respond to customer issues quickly

3. **Offer Annual Billing**
   - 10-20% discount for annual
   - Improves cash flow
   - Reduces churn

4. **Follow Up on Failed Payments**
   - Email doctors immediately
   - Offer to update payment method
   - Prevent involuntary churn

5. **Collect Feedback**
   - Ask why they cancel
   - Improve based on feedback
   - Offer to help before they leave

---

## 📈 Growth Projections

### Conservative Estimate:

| Month | Doctors | MRR | Total |
|-------|---------|-----|-------|
| Month 1 | 10 | ₪1,500 | ₪1,500 |
| Month 3 | 30 | ₪4,500 | ₪13,500 |
| Month 6 | 60 | ₪9,000 | ₪40,500 |
| Month 12 | 100 | ₪15,000 | ₪135,000 |

**Year 1 Revenue: ~₪135,000**

### With Marketing:

| Month | Doctors | MRR | Total |
|-------|---------|-----|-------|
| Month 1 | 20 | ₪3,000 | ₪3,000 |
| Month 3 | 75 | ₪11,250 | ₪33,750 |
| Month 6 | 150 | ₪22,500 | ₪101,250 |
| Month 12 | 250 | ₪37,500 | ₪270,000 |

**Year 1 Revenue: ~₪270,000**

---

## 🚀 Ready to Launch!

Your subscription system is complete and professional-grade!

**Next step:** Get your Stripe API keys and start accepting subscriptions! 💰

---

*Good luck with your medical appointment platform!* 🏥✨


