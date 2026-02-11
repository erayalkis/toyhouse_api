# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache git

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# Runtime stage
FROM alpine:latest

# Install Chromium and dependencies for headless browser
RUN apk add --no-cache \
    chromium \
    chromium-chromedriver \
    ca-certificates \
    tzdata \
    && rm -rf /var/cache/apk/*

# Set Chromium path for go-rod
ENV CHROMIUM_PATH=/usr/bin/chromium-browser
ENV CHROME_PATH=/usr/bin/chromium-browser

WORKDIR /app

# Copy the binary from builder
COPY --from=builder /app/main .

# Copy static files if needed
COPY --from=builder /app/static ./static

# Create directory for .env file
RUN mkdir -p /app/config

# Expose port
EXPOSE 8081

# Run the application
CMD ["./main"]

