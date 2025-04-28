#!/bin/bash
# Setup script for Store_Ecommerce
# Created: 2025-04-28

# Print colorful output for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Setting up Store_Ecommerce project ===${NC}"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed or not in PATH${NC}"
    echo "Please install Docker and try again."
    exit 1
fi

# Check if docker-compose is available
if ! docker compose version &> /dev/null; then
    if ! docker-compose version &> /dev/null; then
        echo -e "${RED}Error: Neither docker compose nor docker-compose found${NC}"
        echo "Please install Docker Compose and try again."
        exit 1
    else
        echo -e "${YELLOW}Using legacy docker-compose command${NC}"
        COMPOSE_CMD="docker-compose"
    fi
else
    COMPOSE_CMD="docker compose"
fi

echo "Starting database containers..."
$COMPOSE_CMD up -d

# Check if containers started successfully
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Success! Database containers are now running.${NC}"
    echo -e "\nYou can now start developing with Store_Ecommerce!"

    # Optional: Display running containers
    echo -e "\n${YELLOW}Running containers:${NC}"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -i store
else
    echo -e "${RED}Failed to start containers. Please check Docker logs for more information.${NC}"
    exit 1
fi

# Optional: Additional setup steps
echo -e "\n${YELLOW}Performing additional setup tasks...${NC}"
# Check if any database seeding or migrations need to be run
# For example:
# if [ -f "src/main/resources/db/migration/V1__init.sql" ]; then
#     echo "Database migration files found. These will run automatically."
# fi

echo -e "\n${GREEN}Setup complete! Your development environment is ready.${NC}"