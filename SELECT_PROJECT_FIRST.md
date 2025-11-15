# ✅ You're on the Right Page! But Select Project First

## 🎯 Current Status:
- ✅ You're on: **APIs & services** → **Credentials** (CORRECT!)
- ⚠️ But: You need to select a project first

---

## 📋 Step-by-Step:

### 1. Select Project:
- **At the top of the page**, look for **"Select a project"** button
- Click it
- Select: **"My First Project"**

### 2. After Selecting Project:
- The Credentials page will load
- You'll see a **"+ Create Credentials"** button at the top
- Click it

### 3. Create OAuth Client:
- From the dropdown, select **"OAuth client ID"**
- Fill the form (see below)

---

## 📝 What to Fill in OAuth Client ID Form:

### Application Type:
- Select: **"Web application"**

### Name:
- Enter: `Medical Appointments Calendar`

### Authorized JavaScript origins:
Click **"+ Add URI"** and add:
- `https://api.medical-appointments.com`
- `http://localhost:3000`

### Authorized redirect URIs:
Click **"+ Add URI"** and add:
- `https://api.medical-appointments.com/api/v1/calendar/google/callback`
- `http://localhost:3000/api/v1/calendar/google/callback`

### Then:
- Click **"Create"**
- **Copy Client ID** (starts with numbers like `123456789-abc...`)
- **Copy Client Secret** (copy NOW - you won't see it again!)
- Click **"OK"**

---

## ✅ Quick Checklist:

- [ ] Click "Select a project" button (top)
- [ ] Select "My First Project"
- [ ] Click "+ Create Credentials"
- [ ] Select "OAuth client ID"
- [ ] Fill the form
- [ ] Copy Client ID and Secret

---

**After selecting the project, the page will load and you can create credentials!**

