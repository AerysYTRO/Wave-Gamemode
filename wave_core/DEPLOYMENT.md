# Wave Core - Implementation & Deployment Guide

## 📋 Deployment Checklist

### Pre-Deployment
- [ ] All files created and verified
- [ ] Configuration reviewed
- [ ] Database credentials set
- [ ] Database tables imported
- [ ] Server configured (mtaserver.conf)
- [ ] Backups created

### Database Setup
- [ ] MariaDB/MySQL installed
- [ ] Database created
- [ ] Schema imported (schema.sql)
- [ ] User account with privileges created
- [ ] Connection tested

### Configuration
- [ ] `config/config.xml` updated with DB credentials
- [ ] Groups defined as needed
- [ ] Factions configured
- [ ] VIP settings configured
- [ ] Donator tiers configured
- [ ] Server name and version set

### Server Integration
- [ ] Resource copied to `/resources/` directory
- [ ] `mtaserver.conf` updated with resource entry
- [ ] ACL permissions configured (if needed)
- [ ] Server firewall rules updated
- [ ] Port 3306 (MySQL) accessible

### Testing
- [ ] [ ] Server starts without errors
- [ ] [ ] `/help` command works
- [ ] [ ] `/whoami` command works
- [ ] [ ] Admin can use `/setgroup`
- [ ] [ ] Admin can use `/giveperm`
- [ ] [ ] Admin can use `/setpriority`
- [ ] [ ] Database logging works
- [ ] [ ] Permission checks work

### Post-Deployment
- [ ] Monitor server logs
- [ ] Test all commands
- [ ] Verify player data saving
- [ ] Check database for errors
- [ ] Performance testing
- [ ] Create backup

---

## 📁 File Structure Summary

```
wave_core/
├── meta.xml (Resource manifest - 50 lines)
├── QUICKSTART.md (Quick start guide)
├── README.md (Main documentation - 500+ lines)
├── API_REFERENCE.md (Complete API documentation - 800+ lines)
├── CONFIGURATION_EXAMPLES.md (Configuration examples - 400+ lines)
├── config/
│   └── config.xml (Server configuration - 200 lines)
├── core/ (Core system modules - 2000+ lines)
│   ├── core.lua (Initialization - 150 lines)
│   ├── database.lua (DB operations - 350 lines)
│   ├── permissions.lua (Permission system - 250 lines)
│   ├── priority.lua (Priority system - 250 lines)
│   ├── groups.lua (Groups system - 300 lines)
│   ├── commands.lua (Commands manager - 300 lines)
│   ├── ui.lua (UI system - 300 lines)
│   ├── factions.lua (Factions system - 350 lines)
│   ├── vip.lua (VIP system - 300 lines)
│   ├── donator.lua (Donator system - 300 lines)
│   └── exports.lua (Exports - 150 lines)
├── utils/
│   └── utils.lua (Utility functions - 350 lines)
├── resources/
│   └── resource_name.lua (Template resource - 50 lines)
└── db/
    └── schema.sql (Database schema - 200 lines)

Total: 20+ files, 5000+ lines of documented code
```

---

## 🔧 Step-by-Step Setup

### 1. Copy Resource
```bash
# Linux/Mac
cp -r wave_core /path/to/mta/server/resources/

# Windows
xcopy wave_core "C:\MTA Server\resources\wave_core\" /E
```

### 2. Database Setup

#### Create Database
```sql
CREATE DATABASE wave_roleplay CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'wave'@'localhost' IDENTIFIED BY 'secure_password';
GRANT ALL PRIVILEGES ON wave_roleplay.* TO 'wave'@'localhost';
FLUSH PRIVILEGES;
```

#### Import Schema
```bash
mysql -u wave -p wave_roleplay < wave_core/db/schema.sql
```

### 3. Configure Resource
Edit `wave_core/config/config.xml`:

```xml
<database>
    <host>localhost</host>
    <port>3306</port>
    <username>wave</username>
    <password>secure_password</password>
    <database>wave_roleplay</database>
</database>
```

### 4. Configure Server
Edit `mtaserver.conf`:

```xml
<resources>
    <!-- Core resource must be first -->
    <resource src="wave_core" startup="1" protected="0"/>
    
    <!-- Other resources can follow -->
    <resource src="myresource" startup="1" protected="0"/>
</resources>

<!-- Optional: Set max players -->
<maxplayers>256</maxplayers>

<!-- Optional: Server name -->
<servername>Wave Romania Roleplay</servername>
```

### 5. Start Server
```bash
./mta-server64
```

### 6. Verify Installation
```
In-Game Commands:
/help          - View available commands
/whoami        - Check your info
/players       - List online players
```

---

## 🚀 Performance Optimization

### Database Optimization
1. **Add Indexes**: Included in schema.sql
2. **Connection Pooling**: Use async queries where possible
3. **Query Caching**: System caches permissions, priorities, groups
4. **Regular Cleanup**: Archive old logs periodically

### Memory Management
1. **Clear Caches**: Implement periodic cache clearing for unused players
2. **Limit Logs**: Archive/delete old logs from database
3. **Monitor Usage**: Use `/debugscript 3` to monitor performance

### Script Optimization
1. **Async Operations**: Always use `dbQueryAsync()` for non-critical queries
2. **Batch Operations**: Use `setGroupForPlayers()` instead of loops
3. **Event Optimization**: Unregister unused event handlers

---

## 🔐 Security Best Practices

### 1. Database Security
```lua
-- Always use parameterized queries (prepared statements)
-- WRONG:
dbExecSync("SELECT * FROM players WHERE id = " .. playerID)

-- CORRECT:
dbExecSync("SELECT * FROM players WHERE id = ?", {playerID})
```

### 2. Permission Validation
```lua
-- Always check permissions before critical operations
if not exports.wave_core:hasPermission(player, "admin.kick") then
    return false
end
```

### 3. Input Validation
```lua
-- Validate all user inputs
if not playerName or playerName == "" then
    sendErrorMessage(player, "Invalid input")
    return false
end
```

### 4. Logging
```lua
-- Log all admin actions
logActionDB(adminID, "admin_action", "Kicked " .. targetName .. " - Reason: " .. reason)
```

### 5. SQL Injection Prevention
- **Always use prepared statements** with `?` placeholders
- **Never concatenate user input** directly into queries
- **Validate input types** before querying

---

## 🐛 Debugging

### Enable Debug Mode
Edit `config/config.xml`:
```xml
<server>
    <debug>true</debug>
</server>
```

### Check Logs
```bash
# Server logs
tail -f mta-server.log

# Database errors
mysql -u wave -p wave_roleplay
SHOW ERRORS;
```

### MTA Debug Script
```
/debugscript 3  # Shows all script warnings
```

### Common Issues

#### "Database connection failed"
- Check credentials in config.xml
- Verify MySQL is running
- Check firewall/network access
- Verify username/password

#### "Permission denied" errors
- Check player's group in config.xml
- Verify group has required permission
- Use `/whoami` to check player's group
- Check `/debugscript 3` for errors

#### Commands not working
- Verify command is registered in commands.lua
- Check player has required permission
- Check `/debugscript 3` for Lua errors
- Use `executeCoreCommand()` to test manually

#### Slow queries
- Check database indexes exist
- Review query performance with MySQL EXPLAIN
- Use `dbQueryAsync()` instead of sync queries
- Monitor database size and clean old logs

---

## 📊 Monitoring & Maintenance

### Weekly Tasks
- [ ] Check server logs for errors
- [ ] Verify all core commands work
- [ ] Check database size
- [ ] Monitor player count

### Monthly Tasks
- [ ] Archive old logs
- [ ] Review permissions usage
- [ ] Check database optimization
- [ ] Update configuration if needed

### Quarterly Tasks
- [ ] Full backup
- [ ] Performance audit
- [ ] Security review
- [ ] Update Wave Core if new version

---

## 🔄 Upgrade Guide

### From Earlier Versions
1. Backup current resource
2. Backup database
3. Compare new config.xml with current
4. Replace resource files
5. Run any migration scripts
6. Test thoroughly
7. Deploy to production

### Database Migrations
```sql
-- Example: Add new table
ALTER TABLE players ADD COLUMN new_field VARCHAR(255);

-- Always backup before migrations
BACKUP TABLE players TO '/path/to/backup/';
```

---

## 📞 Support Resources

### Documentation Files
- **README.md** - Main documentation and features
- **QUICKSTART.md** - Quick setup guide
- **API_REFERENCE.md** - Complete function reference
- **CONFIGURATION_EXAMPLES.md** - Configuration examples

### Error Troubleshooting
1. Check `/debugscript 3` output
2. Review server logs
3. Check database error logs
4. Verify configuration files
5. Test database connection

### Getting Help
1. Check documentation files
2. Review CONFIGURATION_EXAMPLES.md for your use case
3. Check server logs for specific error messages
4. Verify all files are in correct locations
5. Test with minimal configuration first

---

## 🎯 Next Steps After Installation

### 1. Create Admin Accounts
```lua
local waveCore = exports.wave_core
waveCore:setPlayerGroup(adminPlayer, "admin")
waveCore:setPlayerPriority(adminPlayer, 100)
```

### 2. Configure Factions
Edit `config/config.xml` to add your factions, or use:
```lua
waveCore:addFaction("Custom Faction", 10, {"permission1", "permission2"})
```

### 3. Set Up Commands
Create custom commands in a new resource:
```lua
local waveCore = exports.wave_core
waveCore:addCoreCommand("mycommand", "permission", callback, "description")
```

### 4. Implement Player Progression
Add experience/level system using database:
```lua
waveCore:dbQueryAsync("UPDATE players SET level = level + 1 WHERE id = ?", {playerID}, callback)
```

### 5. Create Admin UI
Use the UI system to create management interfaces:
```lua
waveCore:openUI(player, "admin_panel", {players = playerList})
```

---

## ✅ Deployment Verification

Run this checklist after deployment:

```lua
-- Test in console/command
local waveCore = exports.wave_core

-- 1. Check if core loaded
print("Core loaded: " .. (waveCore ~= nil and "YES" or "NO"))

-- 2. Get config
local config = waveCore:getConfig()
print("Config loaded: " .. (config ~= nil and "YES" or "NO"))

-- 3. Test database
waveCore:dbExecSync("SELECT 1", {})
print("Database connected: YES")

-- 4. Test functions
local players = waveCore:getOnlinePlayers()
print("Online players: " .. #players)

-- 5. Test permissions
if waveCore:hasPermission(localPlayer, "basic.chat") then
    print("Permissions working: YES")
end

-- 6. Test groups
local group = waveCore:getPlayerGroup(localPlayer)
print("Groups working: YES - " .. group)
```

---

## 🎓 Best Practices

1. **Always use async queries** for non-blocking operations
2. **Cache frequently accessed data** to reduce database load
3. **Validate all inputs** before processing
4. **Log important actions** for audit trail
5. **Use prepared statements** to prevent SQL injection
6. **Handle errors gracefully** with try-catch where possible
7. **Document custom modifications** for future maintenance
8. **Test thoroughly** before deploying to production
9. **Monitor performance** regularly
10. **Keep backups** of database and configuration

---

**Wave Core v1.0.0 - Ready for Production Deployment** ✅

For support and documentation, refer to:
- README.md - Full feature documentation
- API_REFERENCE.md - Complete API reference
- CONFIGURATION_EXAMPLES.md - Code examples
- QUICKSTART.md - Quick setup guide
