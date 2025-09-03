#!/bin/bash

# Script to quickly create a new service from template

SERVICE_NAME=$1
PORT=$2

if [ -z "$SERVICE_NAME" ] || [ -z "$PORT" ]; then
    echo "Usage: ./create-service.sh <service-name> <port>"
    echo "Example: ./create-service.sh identity-verification-service 3003"
    exit 1
fi

echo "Creating $SERVICE_NAME on port $PORT..."

# Create directory structure
mkdir -p "$SERVICE_NAME/src/{routes,controllers,services,config,middleware,utils}"

# Copy common files from income-verification-service
cp -r income-verification-service/src/middleware "$SERVICE_NAME/src/"
cp -r income-verification-service/src/utils "$SERVICE_NAME/src/"
cp income-verification-service/src/routes/health.js "$SERVICE_NAME/src/routes/"

# Update service name in logger
sed -i '' "s/income-verification-service/$SERVICE_NAME/g" "$SERVICE_NAME/src/utils/logger.js"

# Update service name in health routes
sed -i '' "s/income-verification/$SERVICE_NAME/g" "$SERVICE_NAME/src/routes/health.js"

# Create package.json
cat > "$SERVICE_NAME/package.json" << EOF
{
  "name": "$SERVICE_NAME",
  "version": "1.0.0",
  "description": "Mock $SERVICE_NAME for lending POC",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js",
    "test": "jest --coverage",
    "test:watch": "jest --watch",
    "lint": "eslint src/",
    "lint:fix": "eslint src/ --fix"
  },
  "keywords": ["lending", "api", "mock"],
  "author": "Lending POC Team",
  "license": "MIT",
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "compression": "^1.7.4",
    "dotenv": "^16.3.1",
    "express-rate-limit": "^7.1.5",
    "express-validator": "^7.0.1",
    "winston": "^3.11.0",
    "uuid": "^9.0.1",
    "swagger-ui-express": "^5.0.0",
    "swagger-jsdoc": "^6.2.8",
    "morgan": "^1.10.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.2",
    "jest": "^29.7.0",
    "supertest": "^6.3.3",
    "eslint": "^8.55.0",
    "@jest/globals": "^29.7.0"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF

# Create .env
cat > "$SERVICE_NAME/.env" << EOF
NODE_ENV=development
PORT=$PORT
SERVICE_NAME=$SERVICE_NAME
MOCK_MODE=true
LOG_LEVEL=info
API_KEY=test_key_development_2025
RATE_LIMIT=200
CORS_ORIGIN=*
EOF

echo "✅ Created $SERVICE_NAME structure"
echo "Next steps:"
echo "1. Create src/index.js"
echo "2. Create src/config/swagger.js"
echo "3. Create src/routes/<service-specific>.js"
echo "4. Create src/controllers/<service-specific>Controller.js"
echo "5. Create src/services/mockDataService.js"
echo "6. Run: cd $SERVICE_NAME && npm install"