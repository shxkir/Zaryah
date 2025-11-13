# 🔐 Update PostgreSQL Password

## The Issue

The signup error happens because the PostgreSQL password in `.env` is not correct.

## How to Fix

### Step 1: Find Your PostgreSQL Password

Your PostgreSQL password is the password you set when you installed PostgreSQL. If you don't remember it:

**Option A: Reset Password (if you forgot)**
1. Open pgAdmin 4
2. Right-click on "PostgreSQL 18"
3. Click "Properties"
4. Go to "Definition" tab
5. Enter a new password
6. Click "Save"

**Option B: Create New SuperUser**
1. Open pgAdmin 4
2. Expand "PostgreSQL 18" → "Login/Group Roles"
3. Right-click "Login/Group Roles" → "Create" → "Login/Group Role"
4. Name: `zaryah_admin`
5. Go to "Definition" tab → Set password
6. Go to "Privileges" tab → Enable "Can login?" and "Superuser?"
7. Click "Save"

Then update `.env` to use:
```
DATABASE_URL="postgresql://zaryah_admin:your_password@localhost:5432/zaryah?schema=public"
```

### Step 2: Update .env File

Open `c:\Users\ismai\Downloads\Zaryah\.env` and change line 2:

**Current:**
```
DATABASE_URL="postgresql://postgres:password@localhost:5432/zaryah?schema=public"
```

**Update to:**
```
DATABASE_URL="postgresql://postgres:YOUR_ACTUAL_PASSWORD@localhost:5432/zaryah?schema=public"
```

Replace `YOUR_ACTUAL_PASSWORD` with your real PostgreSQL password.

### Step 3: After Updating Password

Run these commands in order:

```powershell
# 1. Generate Prisma client (already done, but run again to be safe)
npx prisma generate

# 2. Create and run migrations
npx prisma migrate dev --name init

# 3. Seed database with 30 users
npm run seed

# 4. Start backend
npm start
```

### Step 4: In a New Terminal, Start Flutter

```powershell
cd flutter-app
flutter pub get
flutter run
```

## Quick Test

After all servers are running, open the Flutter app and try to signup:

1. Enter your details in the 5-step signup form
2. Click "Complete Signup"
3. You should see "User created successfully"
4. You'll be redirected to the chatbot screen

**Or login with test user:**
- Email: `sarah.johnson@example.com`
- Password: `password123`

## What Happens Next

Once the password is correct:
- ✅ Prisma will connect to PostgreSQL
- ✅ Database tables will be created
- ✅ 30 mock users will be seeded
- ✅ Pinecone will sync the users
- ✅ Backend server will start successfully
- ✅ Signup and login will work
- ✅ Chatbot will have access to all 30 users

## Still Having Issues?

If you're still getting errors after updating the password:

1. **Verify PostgreSQL is running:**
   - Open Services (Win+R → services.msc)
   - Look for "postgresql-x64-18"
   - Make sure Status is "Running"

2. **Test database connection:**
   ```powershell
   npx prisma studio
   ```
   If this opens a browser window, your connection works!

3. **Check if database exists:**
   - Open pgAdmin 4
   - Expand "PostgreSQL 18" → "Databases"
   - If you don't see "zaryah", create it:
     - Right-click "Databases" → "Create" → "Database"
     - Name: `zaryah`
     - Click "Save"
