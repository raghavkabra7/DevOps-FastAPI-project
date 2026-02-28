#!/bin/bash

# Local Development Setup Script
# This script sets up the local development environment

set -e

echo "🚀 Setting up local development environment..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Python $(python3 --version) found${NC}"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    echo "Install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

echo -e "${GREEN}✅ Docker found${NC}"

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed${NC}"
    echo "Install Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

echo -e "${GREEN}✅ Docker Compose found${NC}"

# Create virtual environment
echo -e "\n${YELLOW}🐍 Creating Python virtual environment...${NC}"
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo -e "${GREEN}✅ Virtual environment created${NC}"
else
    echo -e "${YELLOW}⚠️  Virtual environment already exists${NC}"
fi

# Activate virtual environment
echo -e "\n${YELLOW}📦 Installing Python dependencies...${NC}"
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements-dev.txt
echo -e "${GREEN}✅ Dependencies installed${NC}"

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo -e "\n${YELLOW}📝 Creating .env file...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✅ .env file created. Please update it with your configuration.${NC}"
else
    echo -e "${YELLOW}⚠️  .env file already exists${NC}"
fi

# Start Docker Compose
echo -e "\n${YELLOW}🐳 Starting services with Docker Compose...${NC}"
docker-compose up -d

# Wait for services to be ready
echo -e "${YELLOW}⏳ Waiting for services to be ready...${NC}"
sleep 10

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    echo -e "${GREEN}✅ Services are running${NC}"
else
    echo -e "${RED}❌ Some services failed to start${NC}"
    docker-compose ps
    exit 1
fi

# Run database migrations (if needed)
echo -e "\n${YELLOW}🗄️  Initializing database...${NC}"
sleep 5

# Test API health
echo -e "\n${YELLOW}🏥 Testing API health...${NC}"
for i in {1..10}; do
    if curl -f -s http://localhost:8000/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ API is healthy!${NC}"
        break
    else
        if [ $i -eq 10 ]; then
            echo -e "${RED}❌ API health check failed after 10 attempts${NC}"
            echo -e "${YELLOW}Check logs: docker-compose logs app${NC}"
            exit 1
        fi
        echo -e "${YELLOW}⏳ Waiting for API... (attempt $i/10)${NC}"
        sleep 3
    fi
done

# Run tests
echo -e "\n${YELLOW}🧪 Running tests...${NC}"
pytest tests/ -v --cov=app --cov-report=term-missing

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}✅ Local development setup complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\n${YELLOW}Available commands:${NC}"
echo "  - Run tests:           pytest tests/ -v"
echo "  - Run with coverage:   pytest tests/ --cov=app --cov-report=html"
echo "  - Format code:         black app/ tests/"
echo "  - Lint code:           pylint app/"
echo "  - View logs:           docker-compose logs -f"
echo "  - Stop services:       docker-compose down"
echo "  - Restart services:    docker-compose restart"
echo ""
echo -e "${YELLOW}URLs:${NC}"
echo "  - API:                 http://localhost:8000"
echo "  - Swagger Docs:        http://localhost:8000/docs"
echo "  - ReDoc:               http://localhost:8000/redoc"
echo "  - PostgreSQL:          localhost:5432"
echo ""
echo -e "${GREEN}Happy coding! 🎉${NC}"
