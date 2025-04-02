#!/bin/bash

# Configuration
REPO_URL="https://github.com/busbud/devops-challenge-apps"
CLONE_DIR="/home/sharmal/apps/devops-challenge-apps"

# Define the directories for api and web projects
API_DIR="$CLONE_DIR/api"
WEB_DIR="$CLONE_DIR/web"

# API Configuration
API_HOST="http://localhost:3000"

# Function to handle errors
handle_error() {
    echo "Error occurred during $1."
    exit 1
}

# Function to stop a running Node.js app
stop_app() {
    local APP_NAME=$1
    echo "Stopping any running $APP_NAME application..."

    # Kill any running instances of the app (if any)
    pkill -f "npm start" || true  # Ignore errors if no process is found
    echo "$APP_NAME application stopped."
}

# Check if the repository already exists
if [ -d "$CLONE_DIR" ]; then
  echo "Directory '$CLONE_DIR' already exists. Pulling the latest changes..."
  cd "$CLONE_DIR" || handle_error "cd $CLONE_DIR"
  git pull origin master || handle_error "git pull"
else
  echo "Cloning the repository..."
  git clone "$REPO_URL" "$CLONE_DIR" || handle_error "git clone"
fi

echo "Repository Clone complete!"

# Function to build and start a Node.js app
start_app() {
    local DIR=$1
    local PORT=$2
    local LOG_FILE=$3

    cd "$DIR" || handle_error "cd $DIR"
    echo "Checking for dependencies in $DIR..."

    # Install dependencies if not already installed
    if [ ! -d "node_modules" ]; then
        echo "Installing dependencies..."
        npm install || handle_error "npm install in $DIR"
    else
        echo "Dependencies already installed. Skipping npm install."
    fi

    echo "Starting the application on port $PORT..."
    nohup npm start >> "$LOG_FILE" 2>&1 &  # Start in the background

    echo "Application is up and running on port $PORT."
}

# Stop any running instances of API and Web apps before starting new ones
stop_app "API"
stop_app "Web"

# Start the API
start_app "$API_DIR" 3000 "/home/sharmal/apps/api.log"

# Start the Web
start_app "$WEB_DIR" 5000 "/home/sharmal/apps/web.log"

echo "Both applications are running in the background."

