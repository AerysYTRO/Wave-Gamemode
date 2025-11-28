#!/bin/bash

# Wave Romania Roleplay - Installation Script
# This script helps set up the Wave Core resource

echo "========================================"
echo "Wave Core - Installation Script"
echo "========================================"
echo ""

# Check if in correct directory
if [ ! -f "meta.xml" ]; then
    echo "ERROR: meta.xml not found!"
    echo "Please run this script from the wave_core directory."
    exit 1
fi

echo "[✓] Found Wave Core resource"
echo ""

# Check database connection
echo "Checking database connection..."
read -p "Enter database host (default: localhost): " DB_HOST
DB_HOST=${DB_HOST:-localhost}

read -p "Enter database port (default: 3306): " DB_PORT
DB_PORT=${DB_PORT:-3306}

read -p "Enter database username (default: root): " DB_USER
DB_USER=${DB_USER:-root}

read -sp "Enter database password: " DB_PASS
echo ""

read -p "Enter database name (default: wave_roleplay): " DB_NAME
DB_NAME=${DB_NAME:-wave_roleplay}

echo ""
echo "Testing database connection..."

# Try to connect (requires mysql-client)
if command -v mysql &> /dev/null; then
    mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -e "USE $DB_NAME; SELECT 1;" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "[✓] Database connection successful!"
        
        # Ask if user wants to import schema
        read -p "Import database schema? (y/n): " IMPORT_SCHEMA
        if [ "$IMPORT_SCHEMA" = "y" ]; then
            echo "Importing schema..."
            mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < db/schema.sql
            
            if [ $? -eq 0 ]; then
                echo "[✓] Schema imported successfully!"
            else
                echo "[!] Failed to import schema"
            fi
        fi
    else
        echo "[!] Database connection failed"
        echo "Please check your credentials and try again"
    fi
else
    echo "[!] mysql-client not found. Skipping database test."
    echo "Please manually import db/schema.sql to your database"
fi

echo ""
echo "========================================"
echo "Configuration Notes:"
echo "========================================"
echo "1. Update config/config.xml with your database credentials:"
echo "   <host>$DB_HOST</host>"
echo "   <port>$DB_PORT</port>"
echo "   <username>$DB_USER</username>"
echo "   <password>****</password>"
echo "   <database>$DB_NAME</database>"
echo ""
echo "2. Add this to your mtaserver.conf:"
echo "   <resource src=\"wave_core\" startup=\"1\" protected=\"0\"/>"
echo ""
echo "3. Restart your MTA server"
echo ""
echo "4. Check server logs for any errors"
echo ""
echo "[✓] Installation preparation complete!"
echo "========================================"
