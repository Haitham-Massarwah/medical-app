# ============================================
# AUTOMATED DATABASE SETUP SCRIPT
# Medical Appointment System
# ============================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Medical Appointment System" -ForegroundColor Cyan
Write-Host "  Automated Database Setup" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check if PostgreSQL is installed
Write-Host "Checking for PostgreSQL installation..." -ForegroundColor Yellow

$psqlPath = Get-Command psql -ErrorAction SilentlyContinue

if (-not $psqlPath) {
    Write-Host ""
    Write-Host "❌ PostgreSQL is not installed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "OPTION 1: Install PostgreSQL Manually" -ForegroundColor Yellow
    Write-Host "  1. Visit: https://www.postgresql.org/download/windows/" -ForegroundColor White
    Write-Host "  2. Download PostgreSQL installer" -ForegroundColor White
    Write-Host "  3. Install with default settings" -ForegroundColor White
    Write-Host "  4. Remember the password you set for 'postgres' user" -ForegroundColor White
    Write-Host "  5. Run this script again" -ForegroundColor White
    Write-Host ""
    Write-Host "OPTION 2: Use Docker (Advanced)" -ForegroundColor Yellow
    Write-Host "  docker run --name medical-postgres -e POSTGRES_PASSWORD=yourpassword -p 5432:5432 -d postgres" -ForegroundColor White
    Write-Host ""
    
    $useDocker = Read-Host "Do you want to use Docker? (y/n)"
    
    if ($useDocker -eq "y") {
        Write-Host ""
        Write-Host "Setting up PostgreSQL with Docker..." -ForegroundColor Green
        
        $password = Read-Host "Enter a password for the database" -AsSecureString
        $passwordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
        
        docker run --name medical-postgres `
            -e POSTGRES_PASSWORD=$passwordPlain `
            -e POSTGRES_DB=medical_appointment_dev `
            -p 5432:5432 `
            -d postgres:15
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Docker container created successfully!" -ForegroundColor Green
            Write-Host "Waiting for PostgreSQL to start..." -ForegroundColor Yellow
            Start-Sleep -Seconds 5
        } else {
            Write-Host "❌ Failed to create Docker container. Please install Docker first." -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "Please install PostgreSQL manually and run this script again." -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "✅ PostgreSQL is installed!" -ForegroundColor Green
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Database Configuration" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Get database credentials
Write-Host "Please provide database credentials:" -ForegroundColor Yellow
Write-Host "(Press Enter for default values shown in brackets)" -ForegroundColor Gray
Write-Host ""

$dbHost = Read-Host "Database Host [localhost]"
if ([string]::IsNullOrWhiteSpace($dbHost)) { $dbHost = "localhost" }

$dbPort = Read-Host "Database Port [5432]"
if ([string]::IsNullOrWhiteSpace($dbPort)) { $dbPort = "5432" }

$dbName = Read-Host "Database Name [medical_appointment_dev]"
if ([string]::IsNullOrWhiteSpace($dbName)) { $dbName = "medical_appointment_dev" }

$dbUser = Read-Host "Database Username [postgres]"
if ([string]::IsNullOrWhiteSpace($dbUser)) { $dbUser = "postgres" }

$dbPassword = Read-Host "Database Password" -AsSecureString
$dbPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($dbPassword))

Write-Host ""
Write-Host "Testing database connection..." -ForegroundColor Yellow

# Test connection
$env:PGPASSWORD = $dbPasswordPlain
$testResult = psql -h $dbHost -p $dbPort -U $dbUser -d postgres -c "SELECT 1;" 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ Failed to connect to PostgreSQL!" -ForegroundColor Red
    Write-Host "Error: $testResult" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please check:" -ForegroundColor Yellow
    Write-Host "  1. PostgreSQL is running" -ForegroundColor White
    Write-Host "  2. Credentials are correct" -ForegroundColor White
    Write-Host "  3. Host and port are correct" -ForegroundColor White
    exit 1
}

Write-Host "✅ Database connection successful!" -ForegroundColor Green

Write-Host ""
Write-Host "Creating database '$dbName'..." -ForegroundColor Yellow

# Create database if it doesn't exist
$createDbResult = psql -h $dbHost -p $dbPort -U $dbUser -d postgres -c "CREATE DATABASE $dbName;" 2>&1

if ($createDbResult -like "*already exists*") {
    Write-Host "⚠️  Database already exists. Using existing database." -ForegroundColor Yellow
} elseif ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Database created successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to create database!" -ForegroundColor Red
    Write-Host "Error: $createDbResult" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Generating Configuration Files" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Generate JWT secret
$jwtSecret = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 64 | ForEach-Object {[char]$_})

# Create .env file
$envContent = @"
# ============================================
# MEDICAL APPOINTMENT SYSTEM - CONFIGURATION
# Auto-generated on $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
# ============================================

# ============================================
# SERVER CONFIGURATION
# ============================================
NODE_ENV=development
PORT=3000
API_VERSION=v1

# ============================================
# DATABASE CONFIGURATION
# ============================================
DB_HOST=$dbHost
DB_PORT=$dbPort
DB_NAME=$dbName
DB_USER=$dbUser
DB_PASSWORD=$dbPasswordPlain

# ============================================
# REDIS CONFIGURATION
# ============================================
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# ============================================
# JWT CONFIGURATION
# ============================================
JWT_SECRET=$jwtSecret
JWT_EXPIRY=7d

# ============================================
# FRONTEND URL
# ============================================
FRONTEND_URL=http://localhost:3001

# ============================================
# EMAIL CONFIGURATION (Optional - Configure Later)
# ============================================
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=
SMTP_PASSWORD=

EMAIL_FROM=noreply@medical-app.com
EMAIL_FROM_NAME=Medical Appointment System

# ============================================
# SMS CONFIGURATION (Optional - Configure Later)
# ============================================
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_PHONE_NUMBER=

# ============================================
# PAYMENT CONFIGURATION (Optional - Configure Later)
# ============================================
STRIPE_SECRET_KEY=
STRIPE_PUBLISHABLE_KEY=
STRIPE_WEBHOOK_SECRET=
STRIPE_CURRENCY=usd

# ============================================
# RATE LIMITING
# ============================================
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# ============================================
# LOGGING
# ============================================
LOG_LEVEL=info
LOG_FILE=./logs/app.log

# ============================================
# CORS
# ============================================
CORS_ORIGINS=http://localhost:3000,http://localhost:3001
"@

$envContent | Out-File -FilePath ".env" -Encoding UTF8

Write-Host "✅ Configuration file created: .env" -ForegroundColor Green

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Installing Dependencies" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path "node_modules")) {
    Write-Host "Installing Node.js packages..." -ForegroundColor Yellow
    npm install
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Dependencies installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to install dependencies!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ Dependencies already installed" -ForegroundColor Green
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Running Database Migrations" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Creating database tables..." -ForegroundColor Yellow

npm run migrate

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Database tables created successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to run migrations!" -ForegroundColor Red
    Write-Host "You can try running manually: npm run migrate" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  ✅ SETUP COMPLETE!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

Write-Host "Your database is ready! 🎉" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Configuration Summary:" -ForegroundColor Yellow
Write-Host "  Database: $dbName" -ForegroundColor White
Write-Host "  Host: ${dbHost}:${dbPort}" -ForegroundColor White
Write-Host "  User: $dbUser" -ForegroundColor White
Write-Host "  Config file: .env" -ForegroundColor White
Write-Host ""

Write-Host "🚀 Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Start the server:" -ForegroundColor White
Write-Host "     npm run dev" -ForegroundColor Cyan
Write-Host ""
Write-Host "  2. Test the API:" -ForegroundColor White
Write-Host "     http://localhost:3000/health" -ForegroundColor Cyan
Write-Host ""
Write-Host "  3. (Optional) Configure integrations in .env:" -ForegroundColor White
Write-Host "     - Email (SMTP_*)" -ForegroundColor Gray
Write-Host "     - SMS (TWILIO_*)" -ForegroundColor Gray
Write-Host "     - Payments (STRIPE_*)" -ForegroundColor Gray
Write-Host ""

Write-Host "Database setup completed!" -ForegroundColor Green

