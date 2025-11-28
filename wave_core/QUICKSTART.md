# Wave Romania Roleplay - Quick Start Guide

## 📦 Installation Steps

### Step 1: Prerequisites
- MTA Server (Multi Theft Auto)
- MariaDB or MySQL Server
- Basic knowledge of server configuration

### Step 2: Copy Resource
```bash
# Copy wave_core folder to your MTA server resources directory
cp -r wave_core /path/to/mta/server/resources/
```

### Step 3: Database Setup

#### Option A: Using Installation Script
```bash
cd wave_core
chmod +x install.sh
./install.sh
```

#### Option B: Manual Setup
```bash
# 1. Create database (if not exists)
mysql -u root -p
CREATE DATABASE wave_roleplay CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE wave_roleplay;

# 2. Import schema
SOURCE /path/to/wave_core/db/schema.sql;
EXIT;
```

### Step 4: Configure
Edit `wave_core/config/config.xml` and update:

```xml
<database>
    <host>localhost</host>
    <port>3306</port>
    <username>root</username>
    <password>your_password</password>
    <database>wave_roleplay</database>
</database>
```

### Step 5: Add to Server Config
Edit `mtaserver.conf`:

```xml
<!-- Add to resources section -->
<resource src="wave_core" startup="1" protected="0"/>
```

### Step 6: Start Server
```bash
./mta-server64
# Or for 32-bit
./mta-server
```

### Step 7: Verify Installation
- Check server logs for initialization messages
- Connect to server and type `/help`
- Check `/whoami` for player info

---

## ✅ Verification Checklist

- [ ] Resource folder copied to resources directory
- [ ] Database created and schema imported
- [ ] config/config.xml updated with DB credentials
- [ ] mtaserver.conf updated with resource entry
- [ ] Server started without errors
- [ ] `/help` command works in-game
- [ ] Player can use `/whoami`
- [ ] Admin commands available (/setgroup, /giveperm, etc)

---

## 🆘 Troubleshooting

### Server won't start
- Check mtaserver.conf syntax
- Look for XML errors in config files
- Verify database connection

### Commands not working
- Check `/debugscript 3` for Lua errors
- Verify admin has correct permissions
- Check config.xml groups exist

### Database errors
- Verify username/password
- Check database name is correct
- Ensure database server is running
- Verify port (usually 3306)

---

## 📞 Support
For issues, check:
1. Server console logs
2. `/debugscript 3` output
3. Database error logs
4. Configuration syntax

---

## 🎯 Next Steps
1. Create custom groups in config.xml
2. Add custom commands
3. Set up faction management
4. Configure VIP/Donator systems
5. Create admin commands
6. Set up player progression

---

## 📚 Documentation
See `README.md` for complete documentation on all systems and APIs.
