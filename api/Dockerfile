#Use the official Node.js image as the base image
FROM node:latest

# Working directory
WORKDIR /app

# Copy package.json
COPY package.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application files
COPY . .

# Expose the application port
EXPOSE 3000

# Set environment variables
ENV PORT=3000
ENV DB="postgres://username:password@localhost/database"

# Command to run the application
CMD ["npm", "start"]
