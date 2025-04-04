#!/bin/bash

# ------------------------------------------------------------------
# Script: setup_env.sh
# Description: This script automates the setup of Environment
#     - Install Node.JS and NPM
#     - Install Nginx
#     - Setup Proxy for web and API
#     - Install Certbot and provision SSL certificates
# ------------------------------------------------------------------

# Step 1: Install Node.JS and NPM
# Update package list and upgrade system
echo "Updating package list and upgrading system..."
sudo apt update -y && sudo apt upgrade -y

# Install Node.js and NPM (Node.js 16 LTS)
echo "------------------------ Installing Node.js and NPM ------------------------"
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install -y nodejs

# Verify installation
echo "Verifying Node.js and NPM installation..."
node -v
npm -v

# Step 2: Install Nginx
echo "------------------------ Installing Nginx ------------------------"
sudo apt install -y nginx

# Enable and start Nginx service
echo "Starting and enabling Nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

# Verify Nginx installation
echo "Verifying Nginx installation..."
nginx -v

# Show status of Nginx service
echo "Checking Nginx service status..."
sudo systemctl status nginx --no-pager

# Step 3: Install Certbot for SSL Certificates
echo "------------------------ Installing Certbot and Nginx plugin ------------------------"
sudo apt install -y certbot python3-certbot-nginx

# Step 4: App configuration

# Web app configuration (web.example.com)
echo "------------------------ Creating Nginx configuration for Web App ------------------------"
sudo tee /etc/nginx/sites-available/web.example.com > /dev/null <<EOL
server {
    listen 80;
    server_name web.example.com;

    location / {
        proxy_pass http://localhost:5000;  # Assuming Web App runs on port 5000
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

# API configuration (api.example.com)
echo "------------------------ Creating Nginx configuration for API ------------------------"
sudo tee /etc/nginx/sites-available/api.example.com > /dev/null <<EOL
server {
    listen 80;
    server_name api.example.com;

    location / {
        proxy_pass http://localhost:3000;  # Assuming API runs on port 3000
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

# Enable configurations
sudo ln -s /etc/nginx/sites-available/web.example.com /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/api.example.com /etc/nginx/sites-enabled/

# Step 5: Obtain SSL certificates using Certbot for both Web App and API
echo "------------------------ Provisioning SSL certificates ------------------------"
sudo certbot --nginx -d web.example.com -d api.example.com --non-interactive --agree-tos --email sharmalsanjaya4@gmail.com --redirect

# Test and reload Nginx configuration
echo "------------------------ Testing and reloading Nginx configuration ------------------------"
sudo nginx -t
sudo systemctl reload nginx

# Setup automatic SSL certificate renewal (Optional)
echo "------------------------ Setting up automatic SSL certificate renewal ------------------------"
echo "Adding cron job for Certbot auto-renewal..."
(crontab -l 2>/dev/null; echo "0 0,12 * * * certbot renew --quiet --nginx") | crontab -

# Test Certbot auto-renewal
echo "Testing Certbot renewal process..."
certbot renew --dry-run

echo "Installation complete!"
