# Lightweight Node.js base image
FROM node:22-alpine

# Set working directory inside the container
WORKDIR /app

# Copy package.json (and package-lock.json if present) first,
# so dependencies are only reinstalled when they actually change
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# The app listens on port 3000
EXPOSE 3000

# Start the application
CMD ["node", "index.js"]
