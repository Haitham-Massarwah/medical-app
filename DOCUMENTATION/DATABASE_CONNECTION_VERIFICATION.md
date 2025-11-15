# 🗄️ DATABASE CONNECTION VERIFICATION

## ✅ HOW TO CHECK DATABASE CONNECTION

### Method 1: Quick Test (Recommended)
```bash
# In the backend folder:
cd backend
npm run test:db
```

### Method 2: Direct Connection Test
```bash
# Test PostgreSQL connection:
psql -h localhost -U postgres -d medical_appointments -c "SELECT 1;"
```

### Method 3: Using Backend Script
```bash
cd backend
node test-db-connection.js
```

---

## 📋 DATABASE ACCESS METHODS

### Option 1: pgAdmin (GUI - Easiest)
```
1. Download: https://www.pgadmin.org/
2. Install and open pgAdmin
3. Right-click "Servers" → Create → Server
4. General tab:
   - Name: Medical App DB
5. Connection tab:
   - Host: localhost
   - Port: 5432
   - Database: medical_appointments
   - Username: postgres
   - Password: [your password]
6. Click "Save"
7. Browse tables in left sidebar
```

### Option 2: DBeaver (Free, Cross-Platform)
```
1. Download: https://dbeaver.io/
2. New Database Connection
3. Select: PostgreSQL
4. Enter connection details
5. Click "Test Connection"
6. View and edit data
```

### Option 3: Command Line (psql)
```bash
# Connect:
psql -h localhost -U postgres -d medical_appointments

# List tables:
\dt

# View table structure:
\d appointments

# Run query:
SELECT * FROM users LIMIT 10;

# Exit:
\q
```

### Option 4: VS Code Extension
```
1. Install: PostgreSQL by Chris Kolkman
2. Press F1 → "PostgreSQL: Add Connection"
3. Enter details
4. Browse tables in sidebar
```

---

## 🗄️ DATABASE CREDENTIALS

### Default Configuration:
```
Host: localhost
Port: 5432 (default) or 5433 (if custom)
Database: medical_appointments
Username: postgres
Password: [configured in .env file]
```

### Check Configuration:
```bash
cd backend
cat .env
# Or
cat env.example
```

---

## 📊 DATABASE STRUCTURE

**Total Tables:** 17

### Core Business Tables:
1. `tenants` - Clinic/organization information
2. `users` - All system users (all roles)
3. `doctors` - Medical professional details
4. `patients` - Patient medical information
5. `services` - Treatment types (duration, price)
6. `appointments` - Appointment records ⭐
7. `availability` - Doctor working hours
8. `availability_exceptions` - Holidays/special dates
9. `payments` - Payment transactions
10. `medical_records` - Medical history
11. `notifications` - System notifications
12. `audit_logs` - Security audit trail
13. `reviews` - Doctor reviews
14. `cancellation_policies` - Cancellation rules

### Subscription Tables:
15. `subscription_plans` - Plan definitions
16. `doctor_subscriptions` - Active subscriptions
17. `subscription_transactions` - Payment records
18. `subscription_usage` - Usage tracking

---

## 🔗 TABLE RELATIONSHIPS

**Complete documentation:** `DOCUMENTATION/DATABASE_GUIDE.md`

Key Relationships:
- tenants → users (1:many)
- users → doctors (1:1)
- users → patients (1:1)
- doctors → appointments (1:many)
- patients → appointments (1:many)
- appointments → payments (1:many)
- doctors → services (1:many)
- doctors → availability (1:many)

---

## ✅ VERIFICATION CHECKLIST

- [ ] PostgreSQL installed
- [ ] Database created
- [ ] Migrations run
- [ ] Connection tested
- [ ] Can view tables
- [ ] Can query data
- [ ] Admin access working

---

**See:** `DOCUMENTATION/DATABASE_GUIDE.md` for complete documentation

