#!/bin/bash
# Fix JWT_SECRET Issue on Production Server
# Run this on the production server

cd /var/www/medical-backend

echo "🔧 Fixing JWT_SECRET Issue..."
echo ""

# Check if source code has the fix
if grep -q "dotenv.config({ path: '.env.production' })" src/server.ts; then
    echo "✅ Source code already has the fix"
else
    echo "⚠️  Source code needs update"
    echo "Please update src/server.ts manually or upload from local machine"
    exit 1
fi

# Rebuild TypeScript
echo "📦 Building TypeScript..."
npm run build

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build successful"
echo ""

# Verify compiled code
echo "🔍 Verifying compiled code..."
if grep -q "dotenv.config({ path: '.env.production' })" dist/server.js; then
    echo "✅ Compiled code has the fix"
else
    echo "⚠️  Compiled code might not have the fix"
fi

# Restart server
echo ""
echo "🔄 Restarting server..."
pm2 restart medical-api --update-env

# Check logs
echo ""
echo "📋 Recent logs:"
pm2 logs medical-api --lines 20 --nostream

echo ""
echo "✅ Done! Test login endpoint to verify fix."

