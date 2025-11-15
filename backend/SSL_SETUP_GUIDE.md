# SSL Certificate Setup Guide for medical-appointments.com

## Problem
You're seeing `NET::ERR_CERT_COMMON_NAME_INVALID` error, which means:
1. The SSL certificate doesn't match the domain `medical-appointments.com`
2. The certificate might be for a different domain
3. The certificate might be self-signed or expired

## Solutions

### Option 1: Let's Encrypt (Free, Recommended for Production)
Best for production deployment with your own server.

**Requirements:**
- Domain pointing to your server IP
- Server with root/administrator access
- Port 80 and 443 open

**Steps:**
```bash
# Install Certbot (Let's Encrypt client)
# On Ubuntu/Debian:
sudo apt-get update
sudo apt-get install certbot

# On Windows (using WSL or Linux):
# Use Certbot in WSL or use Certbot for Windows

# Get certificate
sudo certbot certonly --standalone -d medical-appointments.com -d www.medical-appointments.com

# Certificates will be in:
# /etc/letsencrypt/live/medical-appointments.com/
#   - fullchain.pem (certificate)
#   - privkey.pem (private key)
```

**For Node.js/Express:**
```typescript
import https from 'https';
import fs from 'fs';
import app from './app';

const options = {
  key: fs.readFileSync('/etc/letsencrypt/live/medical-appointments.com/privkey.pem'),
  cert: fs.readFileSync('/etc/letsencrypt/live/medical-appointments.com/fullchain.pem'),
};

const PORT = 443;
https.createServer(options, app).listen(PORT, () => {
  console.log(`HTTPS Server running on port ${PORT}`);
});
```

### Option 2: Cloudflare SSL (Free, Easy)
If your domain is using Cloudflare DNS:

1. **Sign up for Cloudflare** (free)
2. **Add your domain** to Cloudflare
3. **Update nameservers** at your domain registrar
4. **Enable SSL/TLS:**
   - Go to SSL/TLS settings
   - Set encryption mode to "Full" or "Full (strict)"
   - Cloudflare will provide a free SSL certificate automatically
5. **Use Cloudflare's proxy** (orange cloud icon) for automatic HTTPS

**Note:** This provides SSL from visitor → Cloudflare. For Cloudflare → your server, you can use a self-signed certificate or Cloudflare Origin Certificate.

### Option 3: Self-Signed Certificate (Development Only)
⚠️ **Warning:** This will still show a warning in browsers. Use only for development.

**Generate self-signed certificate:**
```bash
# Using OpenSSL
openssl req -x509 -newkey rsa:4096 -nodes -keyout key.pem -out cert.pem -days 365 \
  -subj "/CN=medical-appointments.com"

# Or create a script
```

**For Node.js:**
```typescript
import https from 'https';
import fs from 'fs';
import app from './app';

const options = {
  key: fs.readFileSync('./key.pem'),
  cert: fs.readFileSync('./cert.pem'),
};

https.createServer(options, app).listen(443, () => {
  console.log('HTTPS Server running (self-signed)');
});
```

### Option 4: Commercial SSL Certificate
Purchase from providers like:
- **DigiCert**
- **GlobalSign**
- **Comodo**
- **GoDaddy SSL**

**Typical cost:** $50-200/year

---

## DNS Configuration

Before SSL will work, ensure DNS is set up:

### A Record (IPv4):
```
medical-appointments.com  →  YOUR_SERVER_IP
www.medical-appointments.com  →  YOUR_SERVER_IP
```

### AAAA Record (IPv6 - optional):
```
medical-appointments.com  →  YOUR_SERVER_IPV6
www.medical-appointments.com  →  YOUR_SERVER_IPV6
```

### Verify DNS:
```bash
# Check A record
nslookup medical-appointments.com

# Check using dig
dig medical-appointments.com

# Or online: https://dnschecker.org
```

---

## Testing SSL

### Check Certificate:
```bash
openssl s_client -connect medical-appointments.com:443 -servername medical-appointments.com
```

### Online Tools:
- **SSL Labs:** https://www.ssllabs.com/ssltest/
- **SSL Checker:** https://www.sslshopper.com/ssl-checker.html

---

## CORS Configuration After SSL

Once SSL is set up, update your `.env`:

```env
CORS_ORIGIN=https://medical-appointments.com,https://www.medical-appointments.com
CORS_CREDENTIALS=true
```

---

## Quick Fix for Development

If you're just testing locally and don't need production SSL yet:

1. **Use HTTP locally:** `http://localhost:3000`
2. **Use HTTP on domain:** `http://medical-appointments.com` (before SSL is configured)
3. **Our CORS config allows HTTP** for development

**Browser warning workaround:**
- For development, accept the self-signed certificate warning (not recommended for production)
- Use a tool like `mkcert` to create locally-trusted certificates

---

## mkcert (Local Development - Trusted Certificates)

**Install mkcert:**
```bash
# Windows (using Chocolatey)
choco install mkcert

# Or download from: https://github.com/FiloSottile/mkcert/releases
```

**Create trusted certificate:**
```bash
# Install local CA
mkcert -install

# Create certificate for localhost
mkcert localhost 127.0.0.1 ::1

# This creates:
# - localhost+2.pem (certificate)
# - localhost+2-key.pem (private key)
```

**Use in Node.js:**
```typescript
const options = {
  key: fs.readFileSync('./localhost+2-key.pem'),
  cert: fs.readFileSync('./localhost+2.pem'),
};
```

---

## Production Checklist

- [ ] Domain DNS configured and pointing to server
- [ ] SSL certificate installed (Let's Encrypt or commercial)
- [ ] HTTPS server configured on port 443
- [ ] HTTP redirects to HTTPS (optional but recommended)
- [ ] CORS updated to use HTTPS URLs
- [ ] Firewall allows port 443
- [ ] Certificate auto-renewal configured (for Let's Encrypt)

---

## Need Help?

Common issues:
1. **Certificate not matching domain:** Ensure certificate CN matches your domain exactly
2. **Mixed content:** Make sure all resources (images, scripts) use HTTPS
3. **Certificate chain incomplete:** Ensure full certificate chain is provided
4. **Port 443 blocked:** Check firewall settings

For Let's Encrypt auto-renewal:
```bash
# Add to crontab (runs monthly)
0 0 1 * * certbot renew --quiet
```


