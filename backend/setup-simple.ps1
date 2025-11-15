# Simple Database Setup Script
Write-Host "Starting PostgreSQL Database Setup..." -ForegroundColor Yellow

# Database configuration
$dbHost = "localhost"
$dbPort = "5433"
$dbName = "medical_app_db"
$dbUser = "postgres"
$dbPassword = "Haitham@0412"

Write-Host "Connecting to PostgreSQL on port $dbPort..." -ForegroundColor Cyan

# Test connection
$env:PGPASSWORD = $dbPassword
$testResult = psql -h $dbHost -p $dbPort -U $dbUser -d postgres -c "SELECT version();" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "PostgreSQL connection successful!" -ForegroundColor Green
    
    # Create database
    Write-Host "Creating database '$dbName'..." -ForegroundColor Cyan
    $createResult = psql -h $dbHost -p $dbPort -U $dbUser -d postgres -c "CREATE DATABASE $dbName;" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Database '$dbName' created successfully!" -ForegroundColor Green
        
        # Create .env file
        Write-Host "Creating .env configuration file..." -ForegroundColor Cyan
        $envContent = @"
# Database Configuration
DB_HOST=localhost
DB_PORT=5433
DB_NAME=medical_app_db
DB_USER=postgres
DB_PASSWORD=Haitham@0412
DB_URL=postgresql://postgres:Haitham@0412@localhost:5433/medical_app_db

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRES_IN=7d

# Server Configuration
PORT=3000
NODE_ENV=development

# Redis Configuration (optional)
REDIS_HOST=localhost
REDIS_PORT=6379

# Email Configuration (optional)
SMTP_HOST=
SMTP_PORT=587
SMTP_USER=
SMTP_PASS=
SMTP_FROM=

# SMS Configuration (optional)
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_PHONE_NUMBER=

# Payment Configuration (optional)
STRIPE_SECRET_KEY=
STRIPE_PUBLISHABLE_KEY=

# WhatsApp Configuration (optional)
WHATSAPP_TOKEN=
WHATSAPP_PHONE_ID=
"@
        
        $envContent | Out-File -FilePath ".env" -Encoding UTF8
        Write-Host ".env file created successfully!" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "Database setup completed!" -ForegroundColor Green
        Write-Host "Database: $dbName on ${dbHost}:${dbPort}" -ForegroundColor White
        Write-Host "Configuration saved to: .env" -ForegroundColor White
        
    } else {
        Write-Host "Error creating database: $createResult" -ForegroundColor Red
    }
} else {
    Write-Host "Error connecting to PostgreSQL: $testResult" -ForegroundColor Red
    Write-Host "Please check that PostgreSQL is running on port $dbPort" -ForegroundColor Yellow
}













