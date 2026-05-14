# Database Setup

A step-by-step guide for new contributors (Linux/macOS **and** Windows) to
get a working local database seeded with test data so they can run the app
end-to-end.

Time required: ~5 minutes.

> **Conventions in this doc**
> - Commands prefixed `🐧 Linux/macOS:` run in **bash / zsh**.
> - Commands prefixed `🪟 Windows:` run in **PowerShell**. If you prefer
>   Command Prompt (`cmd.exe`), the same commands work unless noted.
> - Commands with no prefix work on every platform.

---

## 1. Prerequisites

- **PostgreSQL 14+** running locally
- **Node.js 18+** and **npm**
- A clone of this repo

Check the tools (works on all platforms):

```bash
psql --version
node --version
npm --version
```

If `psql` isn't on your PATH on Windows, the easiest fix is to either
install postgres with the option to "add to PATH" checked, or add
`C:\Program Files\PostgreSQL\<version>\bin` to your PATH manually.

Confirm postgres is running:

🐧 **Linux/macOS:**
```bash
sudo systemctl status postgresql        # Linux (systemd)
brew services list | grep postgres      # macOS (homebrew)
```

🪟 **Windows:** open *Services* (`services.msc`) and check that the
`postgresql-x64-<version>` service is **Running**. Or in PowerShell:
```powershell
Get-Service postgresql*
```

---

## 2. Create the `.env` file

The backend reads its config from `cafeteria_app/backend/.env`. This file is
**git-ignored** — it doesn't ship with the repo, you create your own.

```bash
cd cafeteria_app/backend
```

🐧 **Linux/macOS:**
```bash
cp .env.example .env
```

🪟 **Windows (PowerShell):**
```powershell
Copy-Item .env.example .env
```

Open `.env` in your editor and fill in your local values:

```env
PORT=3000
DB_USER=postgres
DB_HOST=localhost
DB_NAME=cafeteria_db
DB_PASSWORD=cafeteria          # <- whatever your local postgres user password is
DB_PORT=5432
JWT_SECRET=                    # <- fill this in (next step)
```

Generate a JWT secret:

🐧 **Linux/macOS:**
```bash
echo "JWT_SECRET=$(openssl rand -hex 32)" >> .env
```

🪟 **Windows (PowerShell):**
```powershell
$secret = -join ((1..64) | ForEach-Object { '{0:x}' -f (Get-Random -Max 16) })
Add-Content .env "JWT_SECRET=$secret"
```

If the resulting file has two `JWT_SECRET=` lines, delete the empty one.

> ⚠ **Never commit `.env` to git.** It contains your DB password and a signing
> secret. Confirm it's in `.gitignore` before any push.

---

## 3. Make sure the postgres password matches `.env`

The `DB_PASSWORD` in `.env` must actually authenticate against your local
postgres. The easiest way is to set the password to whatever you put in
`.env`.

🐧 **Linux/macOS:**
```bash
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'cafeteria';"
```

🪟 **Windows (PowerShell):** there's no `sudo -u postgres` on Windows — you
connect with the password set during install. Either remember that password
and put it in `.env`, or change it:
```powershell
psql -U postgres -c "ALTER USER postgres WITH PASSWORD 'cafeteria';"
```
(psql will prompt for the *current* postgres password before running.)

Replace `'cafeteria'` if you used something else in `.env`.

Verify the password works:

🐧 **Linux/macOS:**
```bash
PGPASSWORD=cafeteria psql -U postgres -h localhost -c '\q' && echo OK
```

🪟 **Windows (PowerShell):**
```powershell
$env:PGPASSWORD = "cafeteria"; psql -U postgres -h localhost -c "\q"; echo OK
```

---

## 4. Create the `cafeteria_db` database

🐧 **Linux/macOS:**
```bash
sudo -u postgres createdb cafeteria_db
```

🪟 **Windows (PowerShell):**
```powershell
createdb -U postgres cafeteria_db
```

If it already exists you'll get a "database already exists" error — that's
fine, move on.

Confirm it's there:

🐧 **Linux/macOS:**
```bash
sudo -u postgres psql -lqt | cut -d '|' -f1 | grep -w cafeteria_db
```

🪟 **Windows (PowerShell):**
```powershell
psql -U postgres -lqt | Select-String "cafeteria_db"
```

---

## 5. Apply the schema migration

The migration is `cafeteria_app/backend/models/update_db.sql`. It's
**idempotent** — safe to run on a fresh DB or on an existing DB at any
older version. It will:

- Add `balance`, `reset_code`, `reset_code_expires` to `users`
- Ensure the `users.role` check allows `cashier`
- Add `qr_code_token` to `orders` and update the status check to allow
  `pending / paid / preparing / ready / served / cancelled`
- Add `is_available` to `menu_items`
- Create the `wallet_transactions` table

Run it. On Linux/macOS we pipe via stdin because the `postgres` user can't
read files inside `/home/<you>` directly. Windows doesn't have that
restriction.

🐧 **Linux/macOS:**
```bash
sudo -u postgres psql -d cafeteria_db < models/update_db.sql
```

🪟 **Windows (PowerShell):**
```powershell
psql -U postgres -d cafeteria_db -f models\update_db.sql
```

Expected output: several `ALTER TABLE`, possibly `NOTICE: ... already exists, skipping`
lines (harmless), one `DO`, one `UPDATE 0`, and a `CREATE TABLE`. **No errors.**

Verify the result:

🐧 **Linux/macOS:**
```bash
sudo -u postgres psql -d cafeteria_db -c "\d orders" -c "\d users" -c "\d wallet_transactions"
```

🪟 **Windows (PowerShell):**
```powershell
psql -U postgres -d cafeteria_db -c "\d orders" -c "\d users" -c "\d wallet_transactions"
```

You should see:

- `orders` with a `qr_code_token` column and status check listing all six values
- `users` with `balance`, `reset_code`, `reset_code_expires`, and role check including `cashier`
- `wallet_transactions` table present

---

## 6. Install backend dependencies

```bash
npm install
```

---

## 7. Seed test users and menu items

```bash
npm run seed
```

This creates three accounts (idempotent — re-running skips existing rows):

- **admin** — username `admin` / password `admin123` — manage menu items
- **cashier** — username `cashier` / password `cashier123` — scan QR codes, serve orders
- **student** — username `student` / password `student123` — starts with **Tsh 25,000** wallet balance

And a starter menu:

- **Meals**: Beef Burger (5,000), Rice + Beans (4,500), Chicken Wrap (6,000), Pizza Slice (3,500), Garden Salad (4,000)
- **Drinks**: Soda 350ml (1,000), Bottled Water (500), Coffee (2,000), Fresh Juice (2,500)

---

## 8. Start the backend

```bash
npm run dev
```

You should see `Server running on port 3000`. Curl-test from another terminal:

```bash
curl http://localhost:3000/api/menu
```

🪟 **Windows note:** `curl` in PowerShell is aliased to `Invoke-WebRequest`,
which works but prints a different format. For the same output as bash:
```powershell
curl.exe http://localhost:3000/api/menu
```

You should get JSON with the nine seeded menu items.

---

## 9. Run the Flutter app

From `cafeteria_app/`:

**Android device** (USB-tethered, recommended — works on any network):

```bash
adb reverse tcp:3000 tcp:3000
flutter run
```

**Real device on Wi-Fi (no USB)**: pass your laptop's LAN IP:

```bash
flutter run --dart-define=API_HOST=192.168.1.42
```

Find your laptop's LAN IP:

🐧 **Linux/macOS:**
```bash
hostname -I | awk '{print $1}'      # Linux
ipconfig getifaddr en0              # macOS Wi-Fi
```

🪟 **Windows (PowerShell):**
```powershell
(Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notmatch '^(127|169)' } | Select-Object -First 1).IPAddress
```

Log in with any of the three accounts from Step 7.

---

## Resetting / re-running

The migration and seed scripts are both idempotent. If you want a **clean
slate**:

🐧 **Linux/macOS:**
```bash
sudo -u postgres dropdb cafeteria_db
sudo -u postgres createdb cafeteria_db
sudo -u postgres psql -d cafeteria_db < models/update_db.sql
npm run seed
```

🪟 **Windows (PowerShell):**
```powershell
dropdb -U postgres cafeteria_db
createdb -U postgres cafeteria_db
psql -U postgres -d cafeteria_db -f models\update_db.sql
npm run seed
```

> ⚠ Dropping the DB destroys all data. Only do this if you're certain you
> don't need the existing orders / users.

---

## Troubleshooting

**`psql: Permission denied` when running `psql -f` (Linux/macOS)**
- The `postgres` system user can't read files in your home directory. Use
  `psql -d cafeteria_db < models/update_db.sql` (stdin redirect) instead of
  `-f`.

**`psql` is not recognized as an internal or external command (Windows)**
- Postgres isn't on your PATH. Add
  `C:\Program Files\PostgreSQL\<version>\bin` to your PATH (System
  Properties → Environment Variables) and open a new terminal.

**`FATAL: password authentication failed for user "postgres"`**
- The password in `.env` doesn't match the actual postgres password. Re-run
  Step 3 to align them.

**Backend starts but every API call hangs / times out from the phone**
- The phone can't reach `localhost` — either set up `adb reverse tcp:3000 tcp:3000`
  (USB) or pass `--dart-define=API_HOST=<laptop-LAN-IP>`.
- On Windows, also check that the **Windows Defender Firewall** isn't
  blocking incoming connections on port 3000. When you first run
  `npm run dev`, Windows usually pops a permission dialog — click *Allow*.
- Check the backend terminal: if nothing logs when you trigger a request
  from the phone, the request never arrived.

**`null value in column "qr_code_token" of relation "orders" violates not-null constraint`**
- Your DB is missing the column. The schema migration didn't run. Repeat Step 5.

**Seed says `(already exists)` for everything**
- That's expected on re-run. The script skips rows already present. To force
  a re-seed, do the "clean slate" reset above.

**JWT auth errors (`Token is not valid`) after a few hours**
- The token expires after 2 hours. Log out and back in.

**`Copy-Item : Cannot find path '.env.example'` (Windows)**
- Make sure you're in `cafeteria_app/backend`, not the repo root.

**The `<` redirect doesn't work in `cmd.exe`**
- Use PowerShell, or use the `-f` flag in cmd:
  `psql -U postgres -d cafeteria_db -f models\update_db.sql`
