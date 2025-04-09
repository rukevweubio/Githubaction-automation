#!/bin/bash

# Exit on any error
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    echo -e "${GREEN}[+] $1${NC}"
}

# Function to print errors
print_error() {
    echo -e "${RED}[-] $1${NC}"
}

# Update system
print_status "Updating package lists..."
sudo apt update || {
    print_error "Failed to update package lists"
    exit 1
}

print_status "Upgrading installed packages..."
sudo apt upgrade -y || {
    print_error "Failed to upgrade packages"
    exit 1
}

# Check machine name (hostname)
print_status "Current machine name is:"
hostname

# Install common packages
print_status "Installing essential packages..."
sudo apt install -y curl wget git vim || {
    print_error "Failed to install essential packages"
    exit 1
}

# Install MySQL Server
print_status "Installing MySQL Server..."
sudo apt install -y mysql-server || {
    print_error "Failed to install MySQL"
    exit 1
}

# Start MySQL service
print_status "Starting MySQL service..."
sudo systemctl start mysql || {
    print_error "Failed to start MySQL"
    exit 1
}

# Enable MySQL to start on boot
print_status "Enabling MySQL service on boot..."
sudo systemctl enable mysql || {
    print_error "Failed to enable MySQL service"
    exit 1
}

# Secure MySQL installation
print_status "Running MySQL secure installation..."
sudo mysql_secure_installation <<EOF

y
password123
password123
y
y
y
y
EOF

# Create a test database and user
print_status "Setting up test database and user..."
sudo mysql -u root -ppassword123 <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS test_db;
CREATE USER IF NOT EXISTS 'test_user'@'localhost' IDENTIFIED BY 'test_password';
GRANT ALL PRIVILEGES ON test_db.* TO 'test_user'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Check MySQL status
print_status "Checking MySQL status..."
if systemctl is-active mysql >/dev/null 2>&1; then
    echo "MySQL is running"
    mysqladmin -u root -ppassword123 version
else
    print_error "MySQL is not running!"
    exit 1
fi

print_status "Script completed successfully!"