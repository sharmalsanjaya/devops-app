
#!/bin/bash

# ------------------------------------------------------------------
# Script: setup_env.sh
# Description: This script automates the setup of Environment
    # Install Node.JS and NPM
    # Install Nginx
    # Setup Proxy for web and api
    # Install Certbot and provision SSL certificates
# ------------------------------------------------------------------

# Step 1: Install Node.JS and NPM
# Update package list and upgrade system
echo "Updating package list and upgrading system..."
sudo dnf update -y

# Install Node.js and NPM
echo "------------------------ Installing Node.js and NPM ------------------------"
curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
sudo dnf install -y nodejs

# Verify installation
echo "Verifying Node.js and NPM installation..."
node -v
npm -v

# Step 2: Install Nginx

# Install Nginx
echo "------------------------ Installing Nginx ------------------------"
sudo dnf install -y nginx

# Enable and start Nginx service
echo "Starting and enabling Nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

# Verify Nginx installation
echo "Verifying Nginx installation..."
nginx -v

# Show status of Nginx service
echo "Checking Nginx service status..."
sudo systemctl status nginx


# Step 3: Install Certbot for SSL Certificates

# Enable EPEL repository (needed for Certbot)
echo "------------------------ Install Certbot and Nginx plugin ------------------------"
sudo dnf install -y epel-release
sudo dnf install -y certbot python3-certbot-nginx

# Step 4: App configuration

#  web.example.com
echo "------------------------ Creating Nginx configuration for Web App ------------------------"
sudo tee /etc/nginx/conf.d/web.example.com.conf > /dev/null <<EOL
server {
    listen 80;
    server_name web.example.com;

    location / {
        proxy_pass http://localhost:3000;  # Assuming Web App runs on port 3000
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

# api.example.com
echo "------------------------ Creating Nginx configuration for API ------------------------"
sudo tee /etc/nginx/conf.d/api.example.com.conf > /dev/null <<EOL
server {
    listen 80;
    server_name api.example.com;

    location / {
        proxy_pass http://localhost:4000;  # Assuming API runs on port 4000
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

# Step 5: Obtain SSL certificates using Certbot for both Web App and API
echo "------------------------ Provisioning SSL certificates ------------------------"
# Use Certbot to obtain and configure SSL certificates for both domains
sudo certbot --nginx -d web.example.com -d api.example.com --non-interactive --agree-tos --email sharmalsanjaya4@gmail.com --redirect

# Test and reload Nginx configuration
echo "------------------------ Test and reload Nginx configuration ------------------------"
sudo nginx -t
sudo systemctl reload nginx

# Setup automatic SSL certificate renewal (Optional)
echo "------------------------ Setting up automatic SSL certificate renewal ------------------------"
echo "🕒 Adding cron job for Certbot auto-renewal..."
(crontab -l 2>/dev/null; echo "0 0,12 * * * certbot renew --quiet --nginx") | crontab -

# Test Certbot auto-renewal
echo "🔄 Testing Certbot renewal process..."
certbot renew --dry-run

echo "Installation complete!"
