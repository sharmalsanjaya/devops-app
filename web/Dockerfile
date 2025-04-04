# Use an official Node.js runtime as a parent image
FROM node:latest

# Set the working directory in the container
WORKDIR /app

# Copy the package.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application files into the container
COPY . .

# Set environment variables
ENV PORT=5000
ENV API_HOST=http://localhost:3000

# Expose the port that the app will listen on
EXPOSE 5000


# Define the command to run the app
CMD ["npm", "start"]
