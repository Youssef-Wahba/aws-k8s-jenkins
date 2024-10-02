# Use the official Node.js 16 base image
FROM node:20-alpine

# Create and set the working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Copy the application code
COPY . .

# Expose the application port
EXPOSE 3000

# Run the Node.js application
CMD ["npm", "start"]
