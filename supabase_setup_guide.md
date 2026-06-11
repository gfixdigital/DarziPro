# 🚀 Supabase Integration & Setup Guide

This guide walks you through connecting the Flutter app to your Supabase project, setting up the tables, and configuring your authentication settings so that manual shop logins work seamlessly.

---

## 1. Credentials Applied
We have successfully updated `lib/core/constants/supabase_config.dart` with your credentials:
* **Project URL:** `https://axfwupyfcthaolstuqip.supabase.co`
* **Anon Key:** `eyJhbGciOi...`

---

## 2. Setting Up Database Tables (SQL Editor)

To create all the tables, Row Level Security (RLS) policies, indexes, and automatic timestamp updates:
1. Go to your **Supabase Dashboard**.
2. Click on the **SQL Editor** in the left sidebar.
3. Click **New Query**.
4. Open the file `supabase_schema.sql` (located in the root of your `DarziPro` project folder).
5. Copy all the content of `supabase_schema.sql` and paste it into the query editor.
6. Click **Run** at the bottom right.

---

## 3. Configuring Authentication (For Manual Login)

Since this app is a B2B app where each tailor shop gets credentials manually (no self-signup), you need to configure Supabase Auth to allow phone+password logins without requiring SMS verification.

### Step A: Enable Phone Login with Passwords
1. Go to your **Supabase Dashboard**.
2. Click on **Authentication** (User icon) in the left sidebar.
3. Go to **Providers** (under Settings).
4. Expand the **Phone** provider.
5. Make sure it is toggled **ON**.
6. Turn **ON** the setting: **"Enable Phone Password Signup/Login"** (if available).
7. Turn **OFF** the setting: **"Enable Phone Verification"** (this disables the requirement for SMS OTP codes so users can sign in immediately using just phone & password).
8. Click **Save**.

### Step B: Create a Tailor Shop & Admin User
Because of Row Level Security (RLS), every table record is isolated by a `shop_id`.
To add a new shop manually:
1. Go to **Table Editor** > `shops` table.
2. Click **Insert Row** and add your shop details (name, owner_name, phone).
3. Copy the generated `id` (this is the `shop_id`).

Now, create the authentication user:
1. Go to **Authentication** > **Users** tab.
2. Click **Add User** > **Create User**.
3. Choose **Phone** authentication.
4. Enter the phone number (with country code, e.g. `+923001234567`) and a secure password.
5. In the **User Metadata** (JSON) field, add the `shop_id` you copied in Step 2:
   ```json
   {
     "shop_id": "YOUR_COPIED_SHOP_UUID"
   }
   ```
6. Click **Save / Create User**.

Now, when that user logs in on the app with their phone and password, they will be authenticated, and their local database (Hive) will pull their shop's custom data automatically!

---

## 4. Monitoring Flutter Installation
The Flutter SDK installer is actively running in the background and resuming your download.
You can monitor the live download progress in PowerShell:
```powershell
Get-Content -Path "C:\src\install_log.txt" -Tail 20
```
Once the download hits 100%, the script will extract it, initialize `flutter doctor`, and prepare all platforms.
