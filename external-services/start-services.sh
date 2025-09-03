#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}==================================${NC}"
echo -e "${GREEN}  Lending POC External Services  ${NC}"
echo -e "${GREEN}==================================${NC}"
echo ""

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo -e "${RED}Error: Docker is not running${NC}"
        echo "Please start Docker Desktop and try again"
        exit 1
    fi
    echo -e "${GREEN}✓ Docker is running${NC}"
}

# Function to check if port is available
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        echo -e "${YELLOW}Warning: Port $port is already in use${NC}"
        return 1
    fi
    return 0
}

# Main execution
main() {
    echo "Checking prerequisites..."
    check_docker
    echo ""

    # Check if .env exists
    if [ ! -f .env ]; then
        echo -e "${YELLOW}Creating .env file from template...${NC}"
        cp .env.example .env
        echo -e "${GREEN}✓ .env file created${NC}"
    fi

    # Check ports
    echo "Checking port availability..."
    ports=(3001 3002 3003 3004 3005)
    services=("Credit Bureau" "Income Verification" "Identity Verification" "Document Processing" "Notification")
    
    all_clear=true
    for i in "${!ports[@]}"; do
        if ! check_port "${ports[$i]}"; then
            echo -e "${YELLOW}  Port ${ports[$i]} (${services[$i]} Service) is in use${NC}"
            all_clear=false
        else
            echo -e "${GREEN}  ✓ Port ${ports[$i]} (${services[$i]} Service) is available${NC}"
        fi
    done
    
    if [ "$all_clear" = false ]; then
        echo ""
        echo -e "${YELLOW}Some ports are in use. Services may not start properly.${NC}"
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    echo ""
    echo -e "${GREEN}Starting services with Docker Compose...${NC}"
    
    # Start only the services that have been created
    if [ -d "credit-bureau-service/src" ]; then
        echo "Starting Credit Bureau Service..."
        docker-compose up -d credit-bureau 2>/dev/null || echo -e "${YELLOW}Credit Bureau Service not ready yet${NC}"
    fi
    
    if [ -d "income-verification-service/src" ]; then
        echo "Starting Income Verification Service..."
        docker-compose up -d income-verification 2>/dev/null || echo -e "${YELLOW}Income Verification Service not ready yet${NC}"
    fi
    
    if [ -d "identity-verification-service/src" ]; then
        echo "Starting Identity Verification Service..."
        docker-compose up -d identity-verification 2>/dev/null || echo -e "${YELLOW}Identity Verification Service not ready yet${NC}"
    fi
    
    if [ -d "document-processing-service/src" ]; then
        echo "Starting Document Processing Service..."
        docker-compose up -d document-processing 2>/dev/null || echo -e "${YELLOW}Document Processing Service not ready yet${NC}"
    fi
    
    if [ -d "notification-service/src" ]; then
        echo "Starting Notification Service..."
        docker-compose up -d notification 2>/dev/null || echo -e "${YELLOW}Notification Service not ready yet${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}Waiting for services to be healthy...${NC}"
    sleep 5
    
    # Check health of services
    echo ""
    echo "Checking service health..."
    for i in "${!ports[@]}"; do
        response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${ports[$i]}/health 2>/dev/null)
        if [ "$response" = "200" ]; then
            echo -e "${GREEN}  ✓ ${services[$i]} Service is healthy${NC}"
        else
            echo -e "${YELLOW}  ⚠ ${services[$i]} Service is not responding${NC}"
        fi
    done
    
    echo ""
    echo -e "${GREEN}==================================${NC}"
    echo -e "${GREEN}Services are running!${NC}"
    echo ""
    echo "API Documentation available at:"
    echo "  • Credit Bureau: http://localhost:3001/api-docs"
    echo "  • Income Verification: http://localhost:3002/api-docs"
    echo "  • Identity Verification: http://localhost:3003/api-docs"
    echo "  • Document Processing: http://localhost:3004/api-docs"
    echo "  • Notification: http://localhost:3005/api-docs"
    echo ""
    echo "To view logs: docker-compose logs -f [service-name]"
    echo "To stop services: docker-compose down"
    echo -e "${GREEN}==================================${NC}"
}

# Handle script arguments
case "$1" in
    stop)
        echo "Stopping all services..."
        docker-compose down
        echo -e "${GREEN}All services stopped${NC}"
        ;;
    logs)
        docker-compose logs -f "${2:-}"
        ;;
    restart)
        echo "Restarting all services..."
        docker-compose restart
        echo -e "${GREEN}All services restarted${NC}"
        ;;
    status)
        docker-compose ps
        ;;
    *)
        main
        ;;
esac