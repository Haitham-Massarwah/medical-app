# Create .env file for development
# This script creates a .env file with Google Calendar credentials

$envContent = @"
# Environment Configuration
NODE_ENV=development

# Server Configuration
PORT=3000
API_VERSION=v1
BASE_URL=http://localhost:3000
BASE_URL_PRODUCTION=https://api.medical-appointments.com

# Database Configuration (PostgreSQL)
DB_HOST=localhost
DB_PORT=5432
DB_NAME=medical_appointments
DB_USER=postgres
DB_PASSWORD=Haitham@0412
DB_POOL_MIN=2
DB_POOL_MAX=10

# Redis Configuration
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

# JWT Configuration
JWT_SECRET=development-secret-key-change-in-production
JWT_REFRESH_SECRET=development-refresh-secret-key-change-in-production
JWT_EXPIRES_IN=1h
JWT_REFRESH_EXPIRES_IN=7d

# Multi-Tenant Configuration
DEFAULT_TENANT_ID=default
TENANT_HEADER=X-Tenant-ID

# Email Configuration (SMTP) - Gmail
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=hn.medicalapoointments@gmail.com
SMTP_PASSWORD=rglhqfxrgapnihuv
EMAIL_FROM=Medical Appointments <hn.medicalapoointments@gmail.com>

# SMS Configuration (Twilio)
TWILIO_ACCOUNT_SID=AC22fc8395b3e91855cf37fdcb48111d5b
TWILIO_AUTH_TOKEN=03c3053425a39802b291622555b8c669
TWILIO_PHONE_NUMBER=
TWILIO_WHATSAPP_NUMBER=

# Payment Configuration (Stripe)
STRIPE_SECRET_KEY=
STRIPE_PUBLISHABLE_KEY=
STRIPE_WEBHOOK_SECRET=
STRIPE_CURRENCY=usd

# Google Calendar OAuth Configuration
GOOGLE_CLIENT_ID=460829863462-cld9ijbevsa23fiphrbi1po9al23l0ae.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=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
GOOGLE_REDIRECT_URI=http://localhost:3000/api/v1/calendar/google/callback

# Outlook Calendar OAuth Configuration
OUTLOOK_CLIENT_ID=
OUTLOOK_CLIENT_SECRET=
OUTLOOK_REDIRECT_URI=http://localhost:3000/api/v1/calendar/outlook/callback

# CORS Configuration
CORS_ORIGIN=http://localhost:*
CORS_CREDENTIALS=true

# Frontend URL
FRONTEND_URL=http://localhost:8080

# Logging
LOG_LEVEL=debug
LOG_FILE=logs/app.log
"@

$envPath = Join-Path $PSScriptRoot "..\.env"

if (Test-Path $envPath) {
    Write-Host "⚠️  .env file already exists!" -ForegroundColor Yellow
    $overwrite = Read-Host "Overwrite? (Y/N)"
    if ($overwrite -ne "Y" -and $overwrite -ne "y") {
        Write-Host "Cancelled."
        exit
    }
}

$envContent | Out-File -FilePath $envPath -Encoding utf8 -NoNewline

Write-Host "✅ .env file created successfully!" -ForegroundColor Green
Write-Host "📁 Location: $envPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "🚀 Ready to start development server:" -ForegroundColor Green
Write-Host "   npm run dev" -ForegroundColor White

