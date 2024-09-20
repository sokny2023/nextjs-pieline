# Use an official Node.js runtime as a parent image
FROM node:18-alpine AS builder

RUN apk add --no-cache libc6-compat

# Set the working directory to /app
WORKDIR /app

# Copy package.json and package-lock.json
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy all other project files to the working directory
COPY . .

# Build the Next.js app
RUN npm run build

# Multi-stage build process
FROM node:18-alpine

# Update and install latest dependencies, add dumb-init package, and create a non-root user
RUN apk update && apk upgrade && apk add dumb-init && adduser -D nextuser

# Set the working directory for the final image
WORKDIR /app

# Copy public folder from the project
COPY --chown=nextuser:nextuser --from=builder /app/public ./public

# Copy the standalone folder inside the .next folder generated from the build process
COPY --chown=nextuser:nextuser --from=builder /app/.next/standalone ./standalone

# Copy the static folder inside the .next folder generated from the build process
COPY --chown=nextuser:nextuser --from=builder /app/.next/static ./.next/static

# Set the non-root user
USER nextuser

EXPOSE 3000

# Set environment variables
ENV HOST=0.0.0.0 PORT=3000 NODE_ENV=production

# Start the application
CMD ["dumb-init", "node", "server.js"]
