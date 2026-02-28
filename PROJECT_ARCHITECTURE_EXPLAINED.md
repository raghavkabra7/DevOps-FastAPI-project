# Complete Project Architecture & Code Explanation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Technology Stack Justification](#technology-stack-justification)
3. [File-by-File Detailed Explanation](#file-by-file-detailed-explanation)
4. [Architecture Decisions](#architecture-decisions)
5. [Interview Q&A Guide](#interview-qa-guide)

---

## Project Overview

**Project Name:** DevOps FastAPI Project  
**Purpose:** Production-ready REST API with complete CI/CD pipeline and Kubernetes deployment  
**Architecture:** Microservices-based containerized application with automated deployment

**What This Project Does:**
- Provides REST API for managing items (CRUD operations)
- Stores data in PostgreSQL database
- Runs in Docker containers locally
- Automatically tests and builds code on every commit
- Deploys to Kubernetes clusters on AWS EKS
- Scales automatically based on traffic load

---

## Technology Stack Justification

### Why Python?
**Reason 1: Fast Development**
- Python allows rapid API development with minimal code
- Rich ecosystem of libraries (FastAPI, SQLAlchemy, pytest)
- Easy to read and maintain

**Reason 2: Modern Web Framework**
- FastAPI is one of the fastest Python frameworks (comparable to Node.js)
- Automatic API documentation (Swagger UI)
- Built-in data validation with Pydantic
- Asynchronous support for high performance

**Reason 3: Industry Standard**
- Used by Netflix, Uber, Instagram for backend services
- Large community support
- Excellent for microservices architecture

### Why FastAPI (Not Flask/Django)?
**FastAPI Advantages:**
- **Performance:** 3x faster than Flask, comparable to Go
- **Automatic Docs:** Generates interactive API documentation automatically
- **Type Safety:** Uses Python type hints for validation
- **Async Support:** Native async/await for concurrent requests
- **Modern:** Built on latest Python 3.7+ features

**Code Example:**
```python
@app.post("/items/", response_model=ItemResponse)
def create_item(item: ItemCreate, db: Session = Depends(get_db)):
    # FastAPI automatically validates 'item' matches ItemCreate schema
    # Returns validated ItemResponse automatically
```

### Why Docker?
**Reason 1: Consistent Environments**
- "Works on my machine" problem eliminated
- Same container runs on laptop, server, cloud
- Dependencies bundled inside container

**Reason 2: Easy Deployment**
- Single command to run entire application
- No need to install Python, PostgreSQL, libraries manually
- Isolated from host system

**Reason 3: Version Control**
- Docker images are versioned (like code)
- Can rollback to previous version instantly
- Testing uses same image as production

**Real-World Analogy:**
Docker is like shipping containers for code. Just as shipping containers standardize cargo transport (any container fits any ship/truck), Docker containers standardize application deployment (any container runs anywhere).

### Why Docker Compose?
**Purpose:** Orchestrate multiple containers locally

**Why We Need It:**
Our application has 2 services:
1. **FastAPI app** (Python application)
2. **PostgreSQL database** (data storage)

**Without Docker Compose:**
```bash
# Manual process - tedious and error-prone
docker network create app-network
docker run -d --name postgres --network app-network -e POSTGRES_PASSWORD=secret postgres
docker run -d --name fastapi-app --network app-network -p 8000:8000 myapp
```

**With Docker Compose:**
```bash
# Single command for everything
docker-compose up -d
```

**Benefits:**
- **Declarative:** Define all services in one YAML file
- **Networking:** Automatic network creation between containers
- **Dependencies:** Start database before app automatically
- **Volume Management:** Persistent data storage configured once

### Why Kubernetes?
**Reason 1: Production Orchestration**
- Docker runs containers, Kubernetes manages thousands of containers
- Auto-restarts failed containers
- Distributes load across multiple servers

**Reason 2: Scaling**
```yaml
replicas: 2  # Run 2 copies of the app
# Kubernetes automatically distributes traffic between them
```

**Reason 3: Zero-Downtime Deployments**
- Rolling updates: New version deployed gradually
- Old version keeps running until new version is healthy
- Automatic rollback if new version fails

**Reason 4: Self-Healing**
- Container crashes? Kubernetes restarts it automatically
- Node (server) dies? Kubernetes moves containers to healthy nodes

**Docker vs Kubernetes:**
| Docker | Kubernetes |
|--------|------------|
| Runs containers on single machine | Runs containers across cluster of machines |
| Manual restart if container dies | Automatic restart |
| Manual scaling (run more containers) | Automatic scaling based on load |
| Good for development | Essential for production |

### Why AWS EKS?
**EKS = Elastic Kubernetes Service**

**Reason 1: Managed Control Plane**
- AWS manages Kubernetes master nodes
- Automatic updates, backups, security patches
- High availability (99.95% uptime SLA)

**Reason 2: AWS Integration**
- Native integration with ELB (Load Balancer)
- EBS volumes for persistent storage
- IAM for security and access control
- CloudWatch for monitoring

**Reason 3: Enterprise Ready**
- Battle-tested by thousands of companies
- Compliance certifications (SOC, PCI-DSS, HIPAA)
- 24/7 AWS support

**Alternative Options:**
- **Self-managed Kubernetes:** More control, but 10x more work
- **GKE (Google):** Similar features, different cloud
- **AKS (Azure):** Similar features, different cloud

---

## File-by-File Detailed Explanation

### 1. `app/main.py` - Core Application Logic

**Location:** `/app/main.py`  
**Purpose:** Main FastAPI application with API endpoints  
**Why Created:** Entry point for all HTTP requests

**Code Breakdown:**

```python
from fastapi import FastAPI, Depends, HTTPException
```
**Why these imports?**
- `FastAPI`: Core framework class for creating the API
- `Depends`: Dependency injection (automatic database connection)
- `HTTPException`: To return HTTP error codes (404, 500, etc.)

```python
from fastapi.middleware.cors import CORSMiddleware
```
**Why CORS middleware?**
- Allows frontend applications (React, Vue) to call our API from different domains
- Without this, browsers block API calls due to security (same-origin policy)

```python
app = FastAPI(
    title="Items API",
    description="A simple REST API for managing items",
    version="1.0.0",
)
```
**Why these parameters?**
- `title/description/version`: Shows in automatic documentation at `/docs`
- Helps other developers understand what API does
- Professional API documentation standard

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact domains
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```
**Why allow all origins (`*`)?**
- Development/testing convenience
- **Production note:** Should restrict to specific domains like `["https://myapp.com"]`

**API Endpoints Explained:**

#### Root Endpoint
```python
@app.get("/")
def read_root():
    return {"message": "Welcome to Items API"}
```
**Why needed?**
- Basic health check - confirms server is running
- Common convention for APIs to have root endpoint
- LoadBalancer checks this endpoint to verify application health

#### Health Check Endpoint
```python
@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "environment": os.getenv("ENVIRONMENT", "development"),
        "version": "1.0.0",
        "timestamp": datetime.now().isoformat(),
    }
```
**Why detailed health check?**
- **status:** Kubernetes checks this to know if pod is healthy
- **environment:** Confirms running in correct environment (test/prod)
- **version:** Helps debug which code version is deployed
- **timestamp:** Confirms application is responding in real-time

**Real-world use:**
```bash
# Kubernetes runs this every 10 seconds
curl http://app:8000/health
# If it fails 3 times, Kubernetes kills and restarts the pod
```

#### Create Item Endpoint
```python
@app.post("/items/", response_model=ItemResponse, status_code=201)
def create_item(item: ItemCreate, db: Session = Depends(get_db)):
    db_item = Item(**item.dict())
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    return db_item
```

**Line-by-line explanation:**

**`@app.post("/items/", response_model=ItemResponse, status_code=201)`**
- `@app.post`: HTTP POST method (creating new resource)
- `/items/`: URL endpoint
- `response_model=ItemResponse`: FastAPI validates response matches schema
- `status_code=201`: HTTP standard for "Created" (not 200 "OK")

**`item: ItemCreate`**
- FastAPI automatically validates request body
- If client sends invalid data, returns 422 error automatically
- No need for manual `if/else` validation checks

**`db: Session = Depends(get_db)`**
- **Dependency Injection:** FastAPI automatically calls `get_db()` function
- Returns database connection
- Automatically closes connection after request finishes
- Prevents database connection leaks

**`db_item = Item(**item.dict())`**
- Converts Pydantic model to SQLAlchemy model
- `**item.dict()` unpacks dictionary: `Item(name="Laptop", description="Gaming", price=1499.99, quantity=5)`

**`db.commit()` and `db.refresh(db_item)`**
- `commit()`: Saves to PostgreSQL database permanently
- `refresh()`: Gets the auto-generated `id` from database
- Returns complete item with `id` to client

#### Get All Items Endpoint
```python
@app.get("/items/", response_model=List[ItemResponse])
def read_items(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    items = db.query(Item).offset(skip).limit(limit).all()
    return items
```

**Why `skip` and `limit` parameters?**
- **Pagination:** Database might have 1 million items
- Client requests items 100 at a time
- Example: `GET /items/?skip=0&limit=100` (items 1-100)
- Next page: `GET /items/?skip=100&limit=100` (items 101-200)

**Why default `limit=100`?**
- Prevents accidentally returning all items (could crash browser/app)
- Industry standard for API pagination

#### Get Single Item Endpoint
```python
@app.get("/items/{item_id}", response_model=ItemResponse)
def read_item(item_id: int, db: Session = Depends(get_db)):
    item = db.query(Item).filter(Item.id == item_id).first()
    if item is None:
        raise HTTPException(status_code=404, detail="Item not found")
    return item
```

**Why `{item_id}` in path?**
- RESTful convention: `/items/1`, `/items/2`, etc.
- FastAPI automatically converts to `int`
- If client sends `/items/abc`, FastAPI returns 422 error

**Why `raise HTTPException(status_code=404)`?**
- Standard HTTP error code for "not found"
- Better than returning `None` or empty response
- Client knows exactly what went wrong

#### Update Item Endpoint
```python
@app.put("/items/{item_id}", response_model=ItemResponse)
def update_item(item_id: int, item: ItemUpdate, db: Session = Depends(get_db)):
    db_item = db.query(Item).filter(Item.id == item_id).first()
    if db_item is None:
        raise HTTPException(status_code=404, detail="Item not found")
    
    for key, value in item.dict(exclude_unset=True).items():
        setattr(db_item, key, value)
```

**Why `PUT` not `POST`?**
- REST convention: `PUT` = update existing, `POST` = create new
- Clients know what to expect

**Why `exclude_unset=True`?**
- Client might only want to update `price`, not `name/description`
- Example request: `{"price": 1299.99}` (only update price)
- Without `exclude_unset`, would set `name=None`, `description=None` (bad!)

**Why `setattr(db_item, key, value)`?**
- Dynamically updates only fields client specified
- Equivalent to: `db_item.price = 1299.99` if only price sent

#### Delete Item Endpoint
```python
@app.delete("/items/{item_id}", status_code=204)
def delete_item(item_id: int, db: Session = Depends(get_db)):
    db_item = db.query(Item).filter(Item.id == item_id).first()
    if db_item is None:
        raise HTTPException(status_code=404, detail="Item not found")
    
    db.delete(db_item)
    db.commit()
    return None
```

**Why `status_code=204`?**
- HTTP 204 = "No Content" (standard for successful deletion)
- Indicates success but no data to return
- Client knows deletion worked

**Why `return None`?**
- 204 response has no body by definition
- Could also use `return {"message": "deleted"}` with 200 status

---

### 2. `app/models.py` - Database Schema

**Location:** `/app/models.py`  
**Purpose:** Define database tables and API data validation schemas  
**Why Created:** Separation of concerns - models separate from business logic

**Code Breakdown:**

```python
from sqlalchemy import Column, Integer, String, Float
from app.database import Base
```
**Why SQLAlchemy?**
- **ORM (Object-Relational Mapping):** Write Python code instead of SQL
- Example: `db.query(Item).all()` instead of `SELECT * FROM items`
- Database agnostic: Same code works for PostgreSQL, MySQL, SQLite

```python
class Item(Base):
    __tablename__ = "items"
    
    id = Column(Integer, primary_key=True, index=True)
```
**Why `primary_key=True`?**
- Makes `id` unique identifier for each row
- Database auto-generates values: 1, 2, 3, 4...
- Required for relational database integrity

**Why `index=True`?**
- Creates database index on `id` column
- Makes queries like `WHERE id = 5` super fast (milliseconds vs seconds)
- Technical: B-tree index structure for O(log n) lookups

```python
    name = Column(String, nullable=False)
```
**Why `nullable=False`?**
- Database enforces: column must have value
- Cannot create item without name
- Data integrity at database level (not just application level)

```python
    description = Column(String, nullable=True)
```
**Why `nullable=True` for description?**
- Optional field - item can exist without description
- Real-world: Many products have minimal info
- Flexibility for clients

```python
    price = Column(Float, nullable=False)
    quantity = Column(Integer, default=0)
```
**Why `Float` for price?**
- Supports decimal values: $19.99
- **Production note:** Use `Numeric/Decimal` for exact precision (float has rounding errors)

**Why `default=0` for quantity?**
- If client doesn't specify quantity, assumes 0
- Database automatically sets value
- Prevents `NULL` values in non-nullable column

**Pydantic Models (Schemas):**

```python
from pydantic import BaseModel, Field
from typing import Optional
```
**Why Pydantic?**
- **Data Validation:** Automatically validates client requests
- **Serialization:** Converts database objects to JSON
- **Documentation:** Auto-generates OpenAPI schema

```python
class ItemBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    description: Optional[str] = Field(None, max_length=500)
    price: float = Field(..., gt=0)
    quantity: int = Field(default=0, ge=0)
```

**Field validation explained:**

**`name: str = Field(..., min_length=1, max_length=100)`**
- `...`: Required field (cannot be missing)
- `min_length=1`: Cannot be empty string
- `max_length=100`: Prevents overly long names
- **Why?** Database protection + user experience

**`description: Optional[str] = Field(None, max_length=500)`**
- `Optional[str]`: Can be `None` or string
- `None`: Default value if not provided
- `max_length=500`: Longer than name (descriptions need more text)

**`price: float = Field(..., gt=0)`**
- `gt=0`: Greater than 0
- Prevents negative prices
- Prevents zero prices (business rule: everything has a cost)

**`quantity: int = Field(default=0, ge=0)`**
- `ge=0`: Greater than or equal to 0
- Cannot have negative quantity
- Default 0 (out of stock)

**Model Inheritance:**

```python
class ItemCreate(ItemBase):
    pass  # Inherits all fields from ItemBase
```
**Why separate `ItemCreate` model?**
- Future extensibility: Might add create-only fields
- Clear naming: Developers know this is for POST requests
- OpenAPI docs: Shows separate schema for create vs update

```python
class ItemUpdate(ItemBase):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    price: Optional[float] = Field(None, gt=0)
    quantity: Optional[int] = Field(None, ge=0)
```
**Why everything `Optional` in `ItemUpdate`?**
- Partial updates allowed
- Client can update just price without sending name/description
- REST PATCH convention

```python
class ItemResponse(ItemBase):
    id: int
    
    class Config:
        from_attributes = True
```
**Why separate `ItemResponse` model?**
- Responses include `id` (database generated)
- Clients cannot set `id` during creation

**Why `from_attributes = True`?**
- Allows Pydantic to read SQLAlchemy model attributes
- Converts: `Item(id=1, name="Laptop")` → `{"id": 1, "name": "Laptop"}`
- Without this, Pydantic only reads dictionaries

---

### 3. `app/database.py` - Database Connection

**Location:** `/app/database.py`  
**Purpose:** Manages PostgreSQL database connections  
**Why Created:** Centralized database configuration, connection pooling

**Code Breakdown:**

```python
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os
```

**Why these imports?**
- `create_engine`: Creates connection to database
- `declarative_base`: Base class for all models
- `sessionmaker`: Factory for database sessions (connections)

```python
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://itemsuser:itemspass@postgres:5432/itemsdb"
)
```

**Why `os.getenv()` with default?**
- **Environment Variable:** Different database per environment
  - Local: `postgres:5432` (Docker Compose)
  - Test: `postgres-service:5432` (Kubernetes)
  - Prod: `prod-postgres-service:5432` (Kubernetes)
- **Default:** Works for local development immediately
- **Security:** Password not hardcoded (can override with env var)

**Database URL format explained:**
```
postgresql://itemsuser:itemspass@postgres:5432/itemsdb
│          │         │          │       │    │
│          │         │          │       │    └─ Database name
│          │         │          │       └────── Port
│          │         │          └────────────── Hostname
│          │         └───────────────────────── Password
│          └─────────────────────────────────── Username
└────────────────────────────────────────────── Database type
```

**Why `postgres` as hostname?**
- In Docker Compose, service name = hostname
- Docker's internal DNS resolves `postgres` to postgres container IP
- Isolation: Not using `localhost` (that's the container itself)

```python
engine = create_engine(DATABASE_URL)
```
**What does `create_engine` do?**
- Creates connection pool (5-20 connections kept open)
- Reuses connections instead of creating new one per request
- **Performance:** Connection creation is slow (100ms), reuse is instant
- Thread-safe: Multiple requests use pool simultaneously

```python
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
```

**Why `autocommit=False`?**
- **Transactions:** Changes not saved until explicit `commit()`
- If error occurs, can `rollback()` all changes
- Example:
  ```python
  db.add(item1)
  db.add(item2)  # Error here!
  db.commit()    # Neither item saved (rollback automatic)
  ```

**Why `autoflush=False`?**
- Controls when SQLAlchemy sends SQL to database
- `False`: Only sends SQL on `commit()`
- **Performance:** Batches multiple operations into single database round-trip

```python
Base = declarative_base()
```
**What is `Base`?**
- Parent class for all models
- Provides ORM functionality automatically
- Tracks metadata (table names, columns, relationships)

```python
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

**Why use generator (`yield`)?**
- **Dependency Injection Pattern**
- `yield db`: Provides database connection
- `finally: db.close()`: Always closes connection (even if error)
- FastAPI calls this automatically via `Depends(get_db)`

**Execution flow:**
```python
# Request comes in
db = SessionLocal()        # Open connection
# ... endpoint code runs with db ...
db.close()                 # Close connection (automatic)
```

**Why this pattern?**
- **Connection Leak Prevention:** Guarantees connection closes
- **Resource Management:** Returns connection to pool
- Without this: Eventually run out of connections (deadlock)

---

### 4. `app/config.py` - Configuration Management

**Location:** `/app/config.py`  
**Purpose:** Centralized configuration for different environments  
**Why Created:** Follows 12-factor app methodology - configuration separate from code

**Code Breakdown:**

```python
from pydantic import BaseSettings
```
**Why `BaseSettings` not `BaseModel`?**
- Automatically reads environment variables
- Built-in validation for configuration
- Type conversion: `"5432"` → `5432` (int)

```python
class Settings(BaseSettings):
    app_name: str = "Items API"
    environment: str = "development"
    database_url: str = "postgresql://itemsuser:itemspass@postgres:5432/itemsdb"
    debug: bool = True
```

**Why default values?**
- Works immediately in development
- No configuration required to start
- Can override in production via environment variables

**Example usage:**
```bash
# Development (uses defaults)
python app/main.py

# Production (overrides via env vars)
export ENVIRONMENT=production
export DEBUG=false
export DATABASE_URL=postgresql://prod-user:complex-pwd@prod-db:5432/prod_db
python app/main.py
```

```python
    class Config:
        env_file = ".env"
```
**What does this do?**
- Reads configuration from `.env` file
- Example `.env` file:
  ```
  ENVIRONMENT=staging
  DEBUG=false
  DATABASE_URL=postgresql://...
  ```
- Convenient: Don't export variables manually
- git-ignored: Sensitive data not in version control

**Why this configuration approach?**
1. **Environment Parity:** Same code, different config per environment
2. **Security:** Secrets in environment variables, not code
3. **Flexibility:** Change config without changing code
4. **12-Factor App:** Industry standard methodology

---

### 5. `requirements.txt` - Python Dependencies

**Location:** `/requirements.txt`  
**Purpose:** Lists all Python packages application needs  
**Why Created:** Reproducible installations - everyone gets same versions

**Line-by-line explanation:**

```
fastapi==0.104.1
```
**Why pinned version (`==0.104.1`)?**
- **Reproducibility:** Same version everywhere (dev, test, prod)
- **Stability:** Prevents breaking changes from auto-updates
- **Debugging:** Know exactly which version if issues occur

```
uvicorn[standard]==0.24.0
```
**What is uvicorn?**
- **ASGI Server:** Runs FastAPI application
- Like Apache/Nginx but for Python async apps
- `[standard]`: Includes optional performance dependencies

**Why uvicorn not gunicorn?**
- Gunicorn: Traditional WSGI (Flask, Django)
- Uvicorn: Modern ASGI (async support)
- FastAPI requires ASGI

```
sqlalchemy==2.0.23
```
**What is SQLAlchemy?**
- **ORM:** Maps Python classes to database tables
- Write Python instead of SQL
- Database agnostic

```
psycopg2-binary==2.9.9
```
**What is psycopg2?**
- **PostgreSQL Adapter:** Allows SQLAlchemy to talk to PostgreSQL
- `-binary`: Pre-compiled (faster installation, no build tools needed)

**Why needed if using SQLAlchemy?**
- SQLAlchemy is high-level interface
- psycopg2 is low-level driver
- Analogy: SQLAlchemy is steering wheel, psycopg2 is engine

```
pydantic==2.5.0
```
**What is Pydantic?**
- **Data Validation:** Validates request/response data
- Automatic conversion: `"123"` → `123` (int)
- Used internally by FastAPI

```
python-dotenv==1.0.0
```
**What is python-dotenv?**
- Reads `.env` files
- Loads into `os.environ`
- Used by `Settings(BaseSettings)`

**Installation process:**
```bash
pip install -r requirements.txt
```
This installs all 6 packages with exact versions specified.

---

### 6. `requirements-dev.txt` - Development Dependencies

**Location:** `/requirements-dev.txt`  
**Purpose:** Additional tools for development/testing (not needed in production)  
**Why Created:** Keeps production image smaller, development tools separate

```
-r requirements.txt
```
**What does `-r` do?**
- Includes all packages from `requirements.txt`
- Then adds development-specific packages below
- Result: Dev environment has everything, prod environment only has prod packages

```
pytest==7.4.3
```
**What is pytest?**
- **Testing Framework:** Runs automated tests
- Finds files/functions starting with `test_`
- Better than Python's built-in `unittest`

**Why pytest?**
- Simple syntax: Just write functions starting with `test_`
- Rich plugin ecosystem
- Better error messages

```
pytest-cov==4.1.0
```
**What is pytest-cov?**
- **Code Coverage Tool:** Measures which lines were tested
- Example output: "87% of code is covered by tests"
- Identifies untested code paths

```
black==23.11.0
```
**What is black?**
- **Code Formatter:** Automatically formats Python code
- Opinionated: No configuration needed
- Consistent style across team

**Before black:**
```python
def create_item(item:ItemCreate,db:Session=Depends(get_db)):
    db_item=Item(**item.dict())
    db.add(db_item)
```

**After black:**
```python
def create_item(item: ItemCreate, db: Session = Depends(get_db)):
    db_item = Item(**item.dict())
    db.add(db_item)
```

```
pylint==3.0.2
```
**What is pylint?**
- **Linter:** Finds potential bugs and code issues
- Checks: Unused variables, missing docstrings, too many arguments, etc.
- Enforces code quality standards

**Example pylint findings:**
- "Variable 'x' defined but never used"
- "Function too complex (cyclomatic complexity 15)"
- "Missing function docstring"

```
httpx==0.25.1
```
**What is httpx?**
- **HTTP Client:** Used in tests to call API endpoints
- Async support (better than `requests`)
- Used by FastAPI's `TestClient`

**Usage in tests:**
```python
from fastapi.testclient import TestClient

client = TestClient(app)
response = client.get("/items/")  # Uses httpx internally
```

**Why separate dev dependencies?**
- **Production Image Size:** 150MB vs 300MB
- **Security:** Fewer packages = smaller attack surface
- **Performance:** Faster installation in CI/CD

---

### 7. `Dockerfile` - Container Build Instructions

**Location:** `/Dockerfile`  
**Purpose:** Instructions to build Docker image of the application  
**Why Created:** Defines how to package application into container

**Code Breakdown:**

```dockerfile
FROM python:3.11-slim
```
**Why `python:3.11-slim`?**
- `python:3.11`: Official Python 3.11 image
- `-slim`: Minimal Debian with Python (150MB vs 1GB for full Debian)
- Smaller size = faster downloads, less storage cost

**Alternatives:**
- `python:3.11`: Full Debian (1GB) - includes build tools, not needed
- `python:3.11-alpine`: Even smaller (50MB) - incompatible with some packages
- `python:3.11-slim`: Best balance (150MB)

```dockerfile
WORKDIR /code
```
**What does `WORKDIR` do?**
- Sets working directory inside container
- All subsequent commands run from `/code`
- Creates directory if doesn't exist

**Why `/code`?**
- Convention for application code
- Keeps files organized
- Separates app from system files (`/bin`, `/usr`, etc.)

```dockerfile
COPY requirements.txt /code/requirements.txt
```
**Why copy `requirements.txt` first (before app code)?**
- **Docker Layer Caching:** Each instruction creates a layer
- If `requirements.txt` unchanged, Docker reuses cached layer
- Skips slow `pip install` step (saves minutes)

**Without this optimization:**
```dockerfile
COPY . /code                      # Copy everything
RUN pip install -r requirements.txt  # Reinstall every time
```
Change one line of code → reinstall all packages (slow!)

**With optimization:**
```dockerfile
COPY requirements.txt /code/requirements.txt
RUN pip install -r requirements.txt  # Cached unless requirements change
COPY . /code                         # Copy code (fast)
```
Change one line of code → reuse cached packages (fast!)

```dockerfile
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt
```

**Why `--no-cache-dir`?**
- Pip normally caches downloaded packages (saves bandwidth for local development)
- In Docker: Cache useless (only used once during build)
- Saves ~100MB in image size

**Why `--upgrade pip`?**
- Ensures latest pip version
- Newer pip: Faster installs, better dependency resolution

**Why `&&` and `\`?**
- Combines both commands into single Docker layer
- `&&`: Run second command only if first succeeds
- `\`: Line continuation for readability

```dockerfile
COPY ./app /code/app
```
**Why copy only `/app` directory?**
- Minimal image: Only includes necessary files
- Excludes: Tests, docs, local config, git history
- Security: Reduces attack surface

```dockerfile
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**Command breakdown:**
- `uvicorn`: ASGI server
- `app.main:app`: Import `app` from `app/main.py`
- `--host 0.0.0.0`: Listen on all interfaces (required for Docker)
- `--port 8000`: Application port

**Why `0.0.0.0` not `127.0.0.1`?**
- `127.0.0.1`: Only accessible inside container (loopback)
- `0.0.0.0`: Accessible from outside container (required for Docker port mapping)

**Why `CMD` not `RUN`?**
- `RUN`: Executes during image build
- `CMD`: Executes when container starts
- `CMD` can be overridden: `docker run myimage python other-script.py`

**Image build process:**
```bash
docker build -t itemsapi:latest .

# Execution:
# 1. Download python:3.11-slim (if not cached)
# 2. Create /code directory
# 3. Copy requirements.txt
# 4. Install Python packages
# 5. Copy application code
# 6. Set default command
# Result: Image ready to run
```

---

### 8. `docker-compose.yml` - Multi-Container Orchestration

**Location:** `/docker-compose.yml`  
**Purpose:** Defines and runs two services (FastAPI + PostgreSQL) together  
**Why Created:** Simplifies local development - single command runs everything

**Code Breakdown:**

```yaml
services:
```
**What are services?**
- Containers to run
- This project: `fastapi-app` and `postgres`
- Docker Compose manages both together

#### PostgreSQL Service

```yaml
  postgres:
    image: postgres:15-alpine
```
**Why `postgres:15-alpine`?**
- `postgres:15`: PostgreSQL version 15 (latest stable)
- `-alpine`: Minimal Linux (30MB vs 200MB for Debian)
- Official image: Maintained by Docker + PostgreSQL team

```yaml
    container_name: itemsdb
```
**Why set `container_name`?**
- Easy identification: `docker ps` shows "itemsdb"
- Without this: Random names like "project_postgres_1"
- Simpler commands: `docker logs itemsdb`

```yaml
    environment:
      POSTGRES_USER: itemsuser
      POSTGRES_PASSWORD: itemspass
      POSTGRES_DB: itemsdb
```
**Why these environment variables?**
- PostgreSQL image reads these on first start
- Creates database, user, and sets password automatically
- Without these: Uses defaults (postgres/postgres)

**Security note:** 
- Development passwords simple for convenience
- Production: Use complex passwords from secrets management

```yaml
    volumes:
      - postgres_data:/var/lib/postgresql/data
```
**Why volume?**
- **Data Persistence:** Database survives container restarts
- Without volume: `docker-compose down` → all data lost
- Named volume: Docker manages storage location

**What is `/var/lib/postgresql/data`?**
- PostgreSQL's data directory inside container
- Stores databases, tables, indexes
- Mounted to named volume `postgres_data`

```yaml
    ports:
      - "5432:5432"
```
**Port mapping explained:**
- `host:container` format
- `5432` (left): Port on your laptop
- `5432` (right): Port inside container
- Access from laptop: `localhost:5432`

**Why expose port?**
- Connect with GUI tools (pgAdmin, DBeaver)
- Run database migrations from laptop
- Not required for app-to-database communication (use service name)

```yaml
    networks:
      - app-network
```
**Why networks?**
- Isolates containers
- Only containers in same network can communicate
- Security: Database not accessible to unrelated containers

```yaml
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U itemsuser"]
      interval: 10s
      timeout: 5s
      retries: 5
```

**Healthcheck explained:**

**`test: ["CMD-SHELL", "pg_isready -U itemsuser"]`**
- Runs `pg_isready` command inside container
- Checks if PostgreSQL accepting connections
- Returns 0 (success) or 1 (failure)

**`interval: 10s`**
- Runs check every 10 seconds
- Not too frequent (wastes CPU), not too slow (slow to detect issues)

**`timeout: 5s`**
- Wait max 5 seconds for command to complete
- Prevents hanging if database frozen

**`retries: 5`**
- Must fail 5 times before marking unhealthy
- Tolerates temporary issues (restart, heavy load)

**Why healthcheck matters:**
- `depends_on` with `condition: service_healthy` waits for this
- App doesn't start until database ready
- Prevents "connection refused" errors

#### FastAPI Service

```yaml
  fastapi-app:
    build:
      context: .
      dockerfile: Dockerfile
```
**Why `build` not `image`?**
- `build`: Build image from Dockerfile (development)
- `image`: Use pre-built image (production)
- `context: .`: Build using files in current directory

```yaml
    container_name: fastapi-app
    ports:
      - "8000:8000"
```
**Port 8000 explained:**
- FastAPI default port
- Access API: `http://localhost:8000`
- Swagger docs: `http://localhost:8000/docs`

```yaml
    environment:
      DATABASE_URL: postgresql://itemsuser:itemspass@postgres:5432/itemsdb
      ENVIRONMENT: development
```

**Why `@postgres` not `@localhost`?**
- Docker Compose creates internal DNS
- Service name `postgres` resolves to postgres container IP
- `localhost` would be the FastAPI container itself (wrong!)

**Container networking:**
```
laptop (localhost:8000) 
    → fastapi-app container (0.0.0.0:8000)
        → postgres container (postgres:5432)
```

```yaml
    depends_on:
      postgres:
        condition: service_healthy
```
**Why `depends_on`?**
- Ensures postgres starts before fastapi-app
- `condition: service_healthy`: Waits for healthcheck to pass
- Prevents FastAPI from crashing due to "database connection refused"

**Without healthcheck condition:**
```
postgres starting... (needs 2 seconds)
fastapi-app starts immediately → connection refused → crash
```

**With healthcheck condition:**
```
postgres starting... (needs 2 seconds)
healthcheck passes ✓
fastapi-app starts → connection succeeds ✓
```

```yaml
    networks:
      - app-network
```
**Why same network as postgres?**
- Required for `postgres:5432` hostname resolution
- Isolated from other Docker networks

```yaml
    restart: unless-stopped
```
**Restart policy explained:**
- `no`: Never restart (default)
- `always`: Always restart, even after manual stop
- `unless-stopped`: Restart unless manually stopped
- `on-failure`: Only restart if crashes

**Why `unless-stopped`?**
- Auto-restart after crashes (resilience)
- Starts automatically after laptop reboot
- Respects manual stops (`docker-compose down`)

#### Networks and Volumes

```yaml
networks:
  app-network:
    driver: bridge
```
**What is bridge network?**
- Default Docker network type
- Containers get private IPs (172.17.0.x)
- DNS resolution between containers
- Isolated from host network

```yaml
volumes:
  postgres_data:
```
**Named volume explained:**
- Docker manages storage location
- Survives `docker-compose down`
- Deleted only with `docker-compose down -v`

**Where is data stored?**
- Linux: `/var/lib/docker/volumes/`
- macOS: Inside Docker Desktop VM
- Windows: Inside WSL2 filesystem

**Full lifecycle example:**
```bash
# Start everything
docker-compose up -d
# Creates network, volumes, starts postgres, waits for healthy, starts app

# Check status
docker-compose ps
# Shows both containers running

# View logs
docker-compose logs -f

# Stop everything
docker-compose down
# Stops containers, removes network, KEEPS volume

# Delete everything including data
docker-compose down -v
# Stops containers, removes network, DELETES volume
```

---

### 9. `pytest.ini` - Test Configuration

**Location:** `/pytest.ini`  
**Purpose:** Configures pytest behavior  
**Why Created:** Consistent test settings across team

**Code Breakdown:**

```ini
[pytest]
```
**What is this section?**
- Configuration section for pytest
- INI file format (Windows-style config)

```ini
testpaths = tests
```
**What does `testpaths` do?**
- Tells pytest where to find tests
- Only looks in `tests/` directory
- Faster: Doesn't scan entire project

**Without this:**
```bash
pytest  # Scans all directories for test_*.py
```

**With this:**
```bash
pytest  # Only scans tests/ directory
```

```ini
python_files = test_*.py
python_classes = Test*
python_functions = test_*
```
**Test discovery patterns:**
- `test_*.py`: Files named `test_main.py`, `test_models.py`
- `Test*`: Classes named `TestItem`, `TestDatabase`
- `test_*`: Functions named `test_create_item`, `test_health_check`

**Example test file:**
```python
# tests/test_main.py - ✓ Found (matches test_*.py)

class TestItem:  # ✓ Found (matches Test*)
    def test_create(self):  # ✓ Found (matches test_*)
        pass
    
    def helper_function(self):  # ✗ Skipped (doesn't match)
        pass
```

```ini
addopts = -v --cov=app --cov-report=html --cov-report=term-missing --cov-fail-under=80
```

**Option breakdown:**

**`-v` (verbose)**
- Shows each test name and result
- Easier debugging: Know exactly which test failed

**`--cov=app`**
- Measure code coverage for `app/` directory
- Tracks which lines executed during tests

**`--cov-report=html`**
- Generates HTML coverage report
- Opens in browser: Shows covered/uncovered lines highlighted
- Location: `htmlcov/index.html`

**`--cov-report=term-missing`**
- Terminal report showing uncovered line numbers
- Example output:
  ```
  app/main.py    87%    Lines 45-48, 62
  ```
  Lines 45-48 and 62 not tested

**`--cov-fail-under=80`**
- **Quality Gate:** Fails if coverage < 80%
- Enforces testing standards
- CI/CD blocks merge if coverage drops

**Why 80% threshold?**
- Industry standard balance
- 100% impractical (error handlers, edge cases)
- <80% indicates under-tested code

---

### 10. `.github/workflows/ci-cd.yml` - CI/CD Pipeline

**Location:** `.github/workflows/ci-cd.yml`  
**Purpose:** Automates testing, building, and deployment on every code push  
**Why Created:** Ensures code quality, automates repetitive tasks, enables continuous delivery

**What is GitHub Actions?**
- CI/CD platform built into GitHub
- Runs workflows on GitHub's servers
- Triggered by events (push, pull request, schedule)

**Code Breakdown:**

```yaml
name: CI/CD Pipeline
```
**Why name workflow?**
- Shows in GitHub UI
- Easier to identify among multiple workflows
- Professional appearance

```yaml
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
```

**Trigger conditions:**

**`push: branches: [main]`**
- Runs when code pushed to `main` branch
- Typical flow: Developer pushes → workflow runs → deployment
- Protects main branch: Code must pass tests

**`pull_request: branches: [main]`**
- Runs when PR created targeting `main`
- Tests changes before merging
- Prevents broken code from reaching main

**Why both triggers?**
- Draft PRs: Test before merging
- Direct pushes: Test after merging
- Coverage: All code changes tested

```yaml
env:
  DOCKER_IMAGE: raghavkabra7/itemsapi
```
**Why global environment variables?**
- DRY principle: Define once, use everywhere
- Easy updates: Change one place affects all jobs
- Type safety: Variables autocomplete in editors

#### Job 1: Lint and Format

```yaml
  lint-and-format:
    runs-on: ubuntu-latest
```
**What is `runs-on`?**
- Specifies runner (server) for job
- `ubuntu-latest`: GitHub-hosted Ubuntu VM
- Free for public repos: 2000 minutes/month

**Why Ubuntu?**
- Matches production environment (most servers run Linux)
- Fast startup (seconds)
- Most Docker images based on Linux

```yaml
    steps:
      - uses: actions/checkout@v3
```
**What does `checkout` action do?**
- Clones repository into runner
- Downloads all code from current commit
- Required first step in almost all workflows

```yaml
      - uses: actions/setup-python@v4
        with:
          python-version: '3.11'
```
**What does `setup-python` do?**
- Installs Python 3.11 on runner
- Sets up pip, venv
- Caches pip packages (speeds up subsequent runs)

```yaml
      - name: Install dependencies
        run: |
          pip install black pylint
```
**Why install only `black` and `pylint`?**
- Linting doesn't need full application dependencies
- Faster: Installs in 10 seconds vs 60 seconds
- Isolated: Linting errors not masked by import errors

```yaml
      - name: Check code formatting with Black
        run: black --check app/ tests/
```
**What does `--check` do?**
- Check-only mode: Doesn't modify files
- Exits 1 if files need formatting
- Fails workflow if code not formatted

**Why fail on formatting?**
- Enforces code style consistency
- Easier code reviews (no style debates)
- Professional codebase appearance

```yaml
      - name: Lint with Pylint
        run: pylint app/ --fail-under=8.0
```
**What is `--fail-under=8.0`?**
- Score threshold: 0 (worst) to 10 (perfect)
- Fails if score < 8.0
- Quality gate: Blocks low-quality code

**What pylint checks:**
- Syntax errors
- Unused variables
- Missing docstrings
- Complex functions
- Code smells

#### Job 2: Test

```yaml
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15-alpine
        env:
          POSTGRES_USER: testuser
          POSTGRES_PASSWORD: testpass
          POSTGRES_DB: testdb
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
```

**Why `services` section?**
- Starts PostgreSQL container before tests
- Accessible to test job
- Automatically cleaned up after job

**Why separate test database?**
- Isolation: Tests don't affect production data
- Safety: Can drop/recreate tables freely
- Reproducibility: Fresh database per test run

**Why health checks?**
- Waits for database ready
- Tests don't start until PostgreSQL accepting connections
- Prevents "connection refused" errors

```yaml
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.11'
          cache: 'pip'
```
**What is `cache: 'pip'`?**
- Caches downloaded pip packages
- First run: 60 seconds to download
- Subsequent runs: 5 seconds (restored from cache)
- Saves CI/CD minutes

```yaml
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install -r requirements-dev.txt
```
**Why both files?**
- `requirements.txt`: Application dependencies
- `requirements-dev.txt`: Test tools (pytest, coverage)

```yaml
      - name: Run tests with coverage
        env:
          DATABASE_URL: postgresql://testuser:testpass@localhost:5432/testdb
        run: pytest
```

**Why set `DATABASE_URL` environment variable?**
- Overrides default database connection
- Points to test database
- Prevents accidentally testing against production

**Why `@localhost` in CI vs `@postgres` in Docker Compose?**
- CI: PostgreSQL runs directly on runner (not separate container)
- Docker Compose: PostgreSQL in separate container (need service name)

```yaml
      - name: Upload coverage reports
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml
```
**What is Codecov?**
- Coverage visualization service
- Shows coverage trends over time
- Adds coverage badge to README

#### Job 3: Build and Push

```yaml
  build-and-push:
    runs-on: ubuntu-latest
    needs: [lint-and-format, test]
```
**Why `needs` dependency?**
- Only runs if lint and test succeed
- Prevents building broken images
- Logical workflow: Test → Build → Deploy

```yaml
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
```
**What is Docker Buildx?**
- Enhanced Docker build tool
- Features: Multi-platform builds, caching, parallel builds
- Faster builds: 2-3x speedup

```yaml
      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
```

**What are GitHub Secrets?**
- Encrypted variables stored in repository settings
- Never printed in logs (shows *** instead)
- Access: Settings → Secrets → Actions

**Why use secrets?**
- **Security:** Passwords not in code
- **Access Control:** Only specific workflows use secrets
- **Audit:** GitHub logs secret usage

```yaml
      - name: Build and push Docker image
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: |
            ${{ env.DOCKER_IMAGE }}:latest
            ${{ env.DOCKER_IMAGE }}:${{ github.sha }}
```

**Tag explanation:**

**`latest` tag:**
- Conventional: Points to most recent build
- Used by: `kubectl set image` for manual deployment
- Mutable: Changes on every push

**`${{ github.sha }}` tag:**
- Unique commit hash (e.g., `abc123def456`)
- Immutable: Specific version forever
- Rollback-friendly: Deploy exact previous version

**Example tags:**
```
raghavkabra7/itemsapi:latest
raghavkabra7/itemsapi:a1b2c3d4e5f6
```

```yaml
          cache-from: type=registry,ref=${{ env.DOCKER_IMAGE }}:buildcache
          cache-to: type=registry,ref=${{ env.DOCKER_IMAGE }}:buildcache,mode=max
```
**What is Docker layer caching?**
- Reuses unchanged layers from previous builds
- Unchanged `pip install` → skip (saves 2 minutes)
- Only rebuilds changed layers

#### Job 4: Deploy (Disabled)

```yaml
  deploy-test:
    runs-on: ubuntu-latest
    needs: build-and-push
    if: false  # Disabled due to AWS session policy restrictions
```

**Why disabled?**
- AWS credentials have session policy restrictions
- Works locally, fails in GitHub Actions
- Common with AWS Academy/learning accounts

**What would this job do?**
```yaml
- name: Deploy to EKS
  run: |
    aws eks update-kubeconfig --name itemsapi-test-cluster --region us-east-1
    kubectl set image deployment/itemsapi-app fastapi-app=${{ env.DOCKER_IMAGE }}:latest -n itemsapi-test
    kubectl rollout status deployment/itemsapi-app -n itemsapi-test
```

**Deployment steps:**
1. **Update kubeconfig:** Connect to EKS cluster
2. **Update image:** Tell Kubernetes to use new Docker image
3. **Rollout status:** Wait for deployment complete

**Why kept in workflow if disabled?**
- Educational: Shows complete CI/CD pattern
- Future: Can enable when AWS permissions fixed
- Documentation: Explains intended architecture

---

### 11. Kubernetes Manifests - Production Orchestration

#### `kubernetes/test/namespace.yaml`

**Purpose:** Isolates test environment resources  
**Why Created:** Multi-tenancy - separate test and production in same cluster

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: itemsapi-test
```

**What is a namespace?**
- Logical cluster subdivision
- Like folders for Kubernetes resources
- Resources in different namespaces don't conflict

**Why use namespaces?**
- **Isolation:** Test pods won't interfere with prod pods
- **Access Control:** Different teams can have different permissions
- **Resource Quotas:** Limit test environment resource usage

**Real-world analogy:**
Kubernetes cluster = apartment building
Namespaces = apartments
Pods = people in apartments

```bash
# Commands are namespace-specific
kubectl get pods -n itemsapi-test  # Only test pods
kubectl get pods -n itemsapi-prod  # Only prod pods
kubectl get pods                   # Default namespace (nothing here)
```

#### `kubernetes/test/configmap.yaml`

**Purpose:** Non-sensitive configuration data  
**Why Created:** Configuration separate from code (12-factor methodology)

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: itemsapi-config
  namespace: itemsapi-test
data:
  ENVIRONMENT: "test"
  DATABASE_HOST: "postgres-service"
  DATABASE_PORT: "5432"
  DATABASE_NAME: "itemsdb"
```

**What is a ConfigMap?**
- Key-value storage for configuration
- Injected into pods as environment variables
- Can be updated without rebuilding image

**Why use ConfigMap not hardcode?**
```python
# ❌ Bad: Hardcoded
DATABASE_HOST = "postgres-service"

# ✅ Good: From environment
DATABASE_HOST = os.getenv("DATABASE_HOST")
```

**Benefits:**
1. **Reusability:** Same image, different config per environment
2. **Updates:** Change config without rebuilding image
3. **Visibility:** Config visible in cluster, not buried in code

**ConfigMap vs Environment Variables in Deployment:**
- **ConfigMap:** Shared across multiple deployments
- **Env in Deployment:** Specific to one deployment

**Example usage:**
```yaml
# In deployment.yaml
env:
  - name: ENVIRONMENT
    valueFrom:
      configMapKeyRef:
        name: itemsapi-config
        key: ENVIRONMENT
```

#### `kubernetes/test/secret.yaml`

**Purpose:** Sensitive data (passwords, tokens)  
**Why Created:** Security - secrets separate from code

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: itemsapi-secret
  namespace: itemsapi-test
type: Opaque
stringData:
  DATABASE_USER: "itemsuser"
  DATABASE_PASSWORD: "itemspass"
  POSTGRES_PASSWORD: "itemspass"
```

**What is a Secret?**
- Base64-encoded key-value storage
- Encrypted at rest (if cluster configured)
- Access controlled by RBAC

**Why Secrets not ConfigMaps?**
- **Visibility:** Secrets require explicit container access
- **Encryption:** Can be encrypted in etcd
- **Audit:** Access logged for compliance

**`type: Opaque` explained:**
- Generic secret type
- Other types: `kubernetes.io/tls`, `kubernetes.io/dockerconfigjson`
- Opaque: No special handling

**`stringData` vs `data`:**
```yaml
# stringData: Plain text (automatically base64-encoded)
stringData:
  password: "mysecret"

# data: Manual base64 encoding required
data:
  password: "bXlzZWNyZXQ="
```

**Security note:**
- **This is not secure:** Secret in git repository
- **Production:** Use AWS Secrets Manager, HashiCorp Vault, or sealed-secrets
- **Best practice:** Secrets injected via external tools, not checked into git

#### `kubernetes/test/postgres-deployment.yaml`

**Purpose:** Deploy PostgreSQL database  
**Why Created:** Application needs persistent data storage

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: itemsapi-test
spec:
  replicas: 1
```

**Why `replicas: 1` for database?**
- **Stateful Application:** Multiple replicas need replication setup
- **Simplicity:** Single replica sufficient for test environment
- **Production:** Would use StatefulSet with replication

```yaml
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
```

**What are labels?**
- Key-value tags on resources
- Service uses labels to find pods
- Example: `app: postgres` label connects Service to Pods

**Why `selector.matchLabels` must match `template.metadata.labels`?**
- Deployment manages pods with matching labels
- If mismatch: Deployment doesn't control any pods
- Error: "Deployment has no pods"

```yaml
    spec:
      containers:
        - name: postgres
          image: postgres:15-alpine
          ports:
            - containerPort: 5432
```

**What is `containerPort`?**
- Port application listens on inside container
- Documentation: Helps others understand which port to use
- Not security: Doesn't restrict access (use NetworkPolicy for that)

```yaml
          env:
            - name: POSTGRES_USER
              valueFrom:
                secretKeyRef:
                  name: itemsapi-secret
                  key: DATABASE_USER
```

**Environment variable from Secret:**
- Reads `DATABASE_USER` from `itemsapi-secret`
- Injected as `POSTGRES_USER` environment variable
- Secure: Secret not in deployment YAML

```yaml
            - name: PGDATA
              value: "/var/lib/postgresql/data/pgdata"
```

**Why `PGDATA` subdirectory?**
- **EBS Volume Issue:** AWS EBS volumes have `lost+found/` directory
- PostgreSQL refuses to initialize if data directory not empty
- Solution: Use subdirectory (`/data/pgdata` instead of `/data`)

**Without this:**
```
postgres container starts
PostgreSQL: ERROR: /var/lib/postgresql/data is not empty (has lost+found/)
container crashes
CrashLoopBackOff
```

```yaml
          volumeMounts:
            - name: postgres-storage
              mountPath: /var/lib/postgresql/data
```

**What is `volumeMounts`?**
- Mounts volume into container filesystem
- `mountPath`: Where volume appears inside container
- Persistent: Data survives pod restarts

```yaml
      volumes:
        - name: postgres-storage
          persistentVolumeClaim:
            claimName: postgres-pvc
```

**Volume from PersistentVolumeClaim:**
- Pod requests storage via PVC
- Kubernetes binds PVC to actual storage (EBS volume)
- Pod doesn't care about storage details (abstraction)

```yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
  namespace: itemsapi-test
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: gp2
  resources:
    requests:
      storage: 5Gi
```

**PVC explained:**

**`accessModes: ReadWriteOnce`**
- **ReadWriteOnce:** Single node can read/write
- Alternatives: ReadOnlyMany, ReadWriteMany
- Why RWO: PostgreSQL not designed for concurrent writes

**`storageClassName: gp2`**
- **gp2:** AWS EBS General Purpose SSD
- Required: Tells EBS CSI driver to provision EBS volume
- Without this: PVC stays Pending (no storage provisioned)

**`storage: 5Gi`**
- Requests 5 GB volume
- Actual allocation: Minimum 5 GB (could be more)
- Cost: ~$0.50/month in AWS

**How PVC works:**
```
1. Create PVC → requests 5 GB storage
2. EBS CSI driver sees PVC
3. CSI driver calls AWS API to create EBS volume
4. EBS volume created (vol-abc123)
5. CSI driver binds PVC to EBS volume
6. Pod starts → mounts PVC → uses EBS volume
```

#### `kubernetes/test/postgres-service.yaml`

**Purpose:** Stable network endpoint for PostgreSQL  
**Why Created:** Pods have changing IPs, service provides constant DNS name

```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
  namespace: itemsapi-test
spec:
  selector:
    app: postgres
```

**How does selector work?**
- Service finds pods with label `app: postgres`
- Automatically routes traffic to those pods
- Load balancing: If multiple pods, distributes traffic

```yaml
  ports:
    - protocol: TCP
      port: 5432
      targetPort: 5432
```

**Port mapping:**
- `port: 5432` - Port service listens on
- `targetPort: 5432` - Port on pod

**Access patterns:**
```bash
# From inside cluster
DATABASE_URL=postgresql://user:pass@postgres-service:5432/db

# Kubernetes DNS resolution:
postgres-service → 10.100.200.50 (service ClusterIP)
Service → Pod 10.1.2.3 (random pod with label app:postgres)
```

```yaml
  type: ClusterIP
```

**Service types:**
- **ClusterIP:** Internal only (default)
- **NodePort:** Exposes on each node IP
- **LoadBalancer:** Creates cloud load balancer (ELB)

**Why ClusterIP for database?**
- Database should never be public
- Only accessible within cluster
- Security: External attackers cannot reach database

#### `kubernetes/test/app-deployment.yaml`

**Purpose:** Deploy FastAPI application  
**Why Created:** Runs application with scaling and self-healing

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: itemsapi-app
  namespace: itemsapi-test
spec:
  replicas: 2
```

**Why 2 replicas?**
- **High Availability:** One pod crashes, other keeps serving traffic
- **Load Distribution:** Traffic split across 2 pods
- **Zero Downtime:** Rolling update keeps 1 pod running

```yaml
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
```

**RollingUpdate strategy:**

**`maxSurge: 1`**
- Can create 1 extra pod during update
- With 2 replicas: Temporarily have 3 pods
- Faster updates: New pods start before old ones stop

**`maxUnavailable: 0`**
- No pods can be unavailable
- Ensures always 2 pods running
- Zero downtime: Traffic never drops

**Update process:**
```
Initial: Pod A, Pod B (version 1)
1. Create Pod C (version 2) - now 3 pods
2. Wait for Pod C healthy
3. Delete Pod A - now 2 pods (B, C)
4. Create Pod D (version 2) - now 3 pods
5. Wait for Pod D healthy
6. Delete Pod B - now 2 pods (C, D)
Complete: Pod C, Pod D (version 2)
```

```yaml
  selector:
    matchLabels:
      app: itemsapi-app
  template:
    metadata:
      labels:
        app: itemsapi-app
```

**Why labels matter?**
- Service finds pods via labels
- HPA (autoscaler) finds pods via labels
- Deployment manages pods via labels

```yaml
    spec:
      containers:
        - name: fastapi-app
          image: raghavkabra7/itemsapi:latest
          imagePullPolicy: Always
```

**Why `imagePullPolicy: Always`?**
- `latest` tag can change
- Always pulls newest `:latest` image
- Without this: Might use cached old image

**Alternatives:**
- `IfNotPresent`: Use cache if available
- `Never`: Never pull (uses local only)

```yaml
          ports:
            - containerPort: 8000
          env:
            - name: DATABASE_URL
              value: "postgresql://$(DATABASE_USER):$(DATABASE_PASSWORD)@postgres-service:5432/$(DATABASE_NAME)"
```

**Environment variable substitution:**
- `$(DATABASE_USER)` replaced with actual value
- Allows composing URL from multiple secrets/configs
- Kubernetes performs substitution before container starts

```yaml
            - name: DATABASE_USER
              valueFrom:
                secretKeyRef:
                  name: itemsapi-secret
                  key: DATABASE_USER
```

**Secret injection:**
- Reads from Secret, not hardcoded
- Secure: Secret managed separately
- Updateable: Change secret without changing deployment

```yaml
          livenessProbe:
            httpGet:
              path: /health
              port: 8000
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 3
```

**Liveness probe explained:**

**Purpose:** Detect if pod is alive  
**Action:** Kill and restart pod if fails

**`initialDelaySeconds: 30`**
- Wait 30 seconds before first check
- Gives app time to start
- Too short: False failures during startup

**`periodSeconds: 10`**
- Check every 10 seconds
- Balance: Frequent enough to detect issues, not wasteful

**`timeoutSeconds: 5`**
- Wait 5 seconds for response
- If no response: Consider failed

**`failureThreshold: 3`**
- Must fail 3 times consecutively
- Tolerates temporary issues (database hiccup, heavy load)
- After 3 failures: Pod killed and restarted

```yaml
          readinessProbe:
            httpGet:
              path: /health
              port: 8000
            initialDelaySeconds: 10
            periodSeconds: 5
            timeoutSeconds: 3
            failureThreshold: 2
```

**Readiness probe explained:**

**Purpose:** Detect if pod ready to serve traffic  
**Action:** Remove from service endpoints if fails

**Liveness vs Readiness:**
| Liveness | Readiness |
|----------|-----------|
| Is pod alive? | Is pod ready for traffic? |
| Kill if fails | Remove from load balancer if fails |
| Restarts pod | Doesn't restart, just waits |

**Use case:**
```
Pod starting...
Readiness fails → Not added to service
App finishes startup
Readiness passes → Added to service → receives traffic
```

```yaml
          resources:
            requests:
              memory: "256Mi"
              cpu: "250m"
            limits:
              memory: "512Mi"
              cpu: "500m"
```

**Resources explained:**

**`requests`:** Guaranteed resources
- Kubernetes schedules pod on node with available resources
- Example: Node must have 256 MB free RAM

**`limits`:** Maximum resources
- Pod cannot exceed these limits
- Exceeding memory: Pod killed (OOM)
- Exceeding CPU: Throttled (slower)

**CPU units:**
- `250m` = 0.25 CPU cores = 25% of one core
- `1000m` or `1` = 1 full CPU core

**Why set both?**
- **requests:** Ensures minimum performance
- **limits:** Prevents one pod from starving others

**Example scenario:**
```
Node has 4 GB RAM, 2 CPUs
Can schedule: 
- 15 pods with 256 MB requests (15 * 256 = 3.84 GB < 4 GB)
- Limit: Each pod can burst to 512 MB if available
```

#### `kubernetes/test/app-service.yaml`

**Purpose:** Expose FastAPI application to internet  
**Why Created:** Users need to access the API

```yaml
apiVersion: v1
kind: Service
metadata:
  name: itemsapi-service
  namespace: itemsapi-test
spec:
  type: LoadBalancer
```

**Why LoadBalancer type?**
- Creates AWS Elastic Load Balancer (ELB)
- Public IP address assigned automatically
- Traffic distributed across pods

**How LoadBalancer works:**
```
User browser (example.com)
    ↓
AWS ELB (public IP: 52.123.45.67)
    ↓
Kubernetes Service (ClusterIP: 10.100.50.25)
    ↓
Pod 1 (10.1.2.3)  OR  Pod 2 (10.1.2.4)
```

```yaml
  selector:
    app: itemsapi-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8000
```

**Port mapping:**
- `port: 80` - LoadBalancer listens on port 80 (HTTP standard)
- `targetPort: 8000` - FastAPI listens on port 8000

**User experience:**
```bash
# User accesses
curl http://load-balancer-url/items/

# Translated to
curl http://pod-ip:8000/items/
```

**Why different ports?**
- Users expect HTTP on port 80
- FastAPI runs on 8000 (Python convention)
- Service translates between them

#### `kubernetes/test/app-hpa.yaml`

**Purpose:** Auto-scaling based on CPU usage  
**Why Created:** Handle traffic spikes automatically

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: itemsapi-hpa
  namespace: itemsapi-test
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: itemsapi-app
```

**What does HPA do?**
- Watches deployment's pod CPU usage
- Increases replicas if CPU high
- Decreases replicas if CPU low
- Automatically adjusts to demand

```yaml
  minReplicas: 2
  maxReplicas: 5
```

**Replica bounds:**
- **minReplicas: 2** - Always at least 2 pods (high availability)
- **maxReplicas: 5** - Never more than 5 pods (cost control)

**Why minimum 2?**
- High availability: Service continues if one pod crashes
- Load distribution: Better user experience
- Rolling updates: Can update without downtime

```yaml
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```

**Scaling trigger:**
- Target: 70% average CPU usage across all pods
- Above 70%: Scale up (add pods)
- Below 70%: Scale down (remove pods)

**Example scenario:**
```
Current: 2 pods, each 80% CPU
Average: 80% > 70% target
HPA: Scale up to 3 pods
Result: 3 pods, each 53% CPU (under target)

Traffic drops
Current: 3 pods, each 30% CPU
Average: 30% < 70% target
HPA: Scale down to 2 pods
Result: 2 pods, each 45% CPU
```

**Why 70% not 50% or 90%?**
- **50%:** Too aggressive scaling (expensive)
- **70%:** Good balance (headroom for spikes)
- **90%:** Too late (users already experiencing slowness)

**Scaling behavior:**
```yaml
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
```
**Why 5-minute window?**
- Prevents flapping (rapid scale up/down)
- Waits 5 minutes before scaling down
- Cost-effective: Doesn't immediately remove pods after traffic drop

---

## Architecture Decisions

### Why Microservices Architecture?

**Our Setup:**
- FastAPI application (stateless)
- PostgreSQL database (stateful)
- Separated into different pods

**Benefits:**
1. **Independent Scaling:** Scale app and database separately
2. **Technology Flexibility:** Different languages for different services
3. **Fault Isolation:** Database crash doesn't kill app (and vice versa)
4. **Deployment Independence:** Update app without touching database

**Alternative (Monolith):**
- Single container with app + database
- Simpler for tiny projects
- Doesn't scale well

### Why REST API not GraphQL?

**REST Advantages:**
- **Simplicity:** Easier to learn and implement
- **Caching:** HTTP caching works naturally
- **Tooling:** Every language has HTTP libraries
- **Standards:** Well-understood patterns (GET, POST, PUT, DELETE)

**When to use GraphQL:**
- Mobile apps (reduce data transfer)
- Complex relationships between data
- Multiple frontend applications with different data needs

### Why PostgreSQL not MySQL/MongoDB?

**PostgreSQL Advantages:**
- **ACID Compliance:** Guaranteed data consistency
- **Advanced Features:** JSON support, full-text search, GIS
- **Open Source:** No licensing costs
- **Reliability:** Battle-tested in production

**Why not MongoDB:**
- Our data has structured schema (items with defined fields)
- Need ACID transactions
- PostgreSQL can store JSON when needed

### Why AWS EKS not Self-Managed Kubernetes?

**EKS Advantages:**
- **Managed Control Plane:** AWS handles master nodes
- **Integration:** Native AWS services (ELB, EBS, IAM)
- **High Availability:** 99.95% SLA
- **Security:** Automatic security patches

**Self-Managed Trade-offs:**
- **Cost:** Cheaper (no $73/month control plane fee)
- **Learning:** Deep Kubernetes knowledge gained
- **Effort:** 10x more time maintaining

### Why GitHub Actions not Jenkins/GitLab CI?

**GitHub Actions Advantages:**
- **Built-in:** No separate server to maintain
- **Free:** 2000 minutes/month for public repos
- **Marketplace:** Thousands of pre-built actions
- **Integration:** Tight GitHub integration (PR comments, status checks)

**When to use Jenkins:**
- Complex pipelines with many stages
- Need self-hosted (security requirements)
- Already invested in Jenkins infrastructure

---

## Interview Q&A Guide

### General Questions

**Q: What is this project?**  
**A:** Production-ready REST API for managing items (CRUD operations) with PostgreSQL database, containerized with Docker, deployed on Kubernetes in AWS EKS, with fully automated CI/CD pipeline using GitHub Actions.

**Q: What is your role?**  
**A:** Full-stack DevOps engineer - designed architecture, developed API, containerized application, set up Kubernetes cluster, configured CI/CD, managed AWS infrastructure.

**Q: How did you handle database migrations?**  
**A:** Currently using SQLAlchemy ORM with `Base.metadata.create_all()` for automatic schema creation. In production, would use Alembic for version-controlled migrations with rollback capability.

**Q: How do you ensure application reliability?**  
**A:** Multiple layers:
1. **Health checks:** Kubernetes restarts unhealthy pods
2. **Replication:** Minimum 2 pod replicas
3. **Auto-scaling:** HPA scales based on load
4. **Resource limits:** Prevents resource exhaustion
5. **Rolling updates:** Zero-downtime deployments

### Python/FastAPI Questions

**Q: Why FastAPI over Flask/Django?**  
**A:** FastAPI offers:
- **Performance:** 3x faster than Flask (async support)
- **Automatic Documentation:** Swagger UI generated automatically
- **Type Safety:** Pydantic validation catches errors early
- **Modern:** Built on Python 3.7+ features

**Q: How does dependency injection work in FastAPI?**  
**A:** `Depends(get_db)` in endpoint parameters. FastAPI calls `get_db()` automatically, passes result to endpoint, closes connection via `finally` block. Prevents connection leaks.

**Q: What is Pydantic and why use it?**  
**A:** Data validation library. Validates request data matches expected schema, converts types automatically, generates API documentation. Catches invalid data before database operations.

**Q: How do you handle database connections?**  
**A:** Connection pooling via SQLAlchemy's `create_engine()`. Maintains 5-20 open connections, reuses them across requests. Generator pattern with `try/finally` ensures connections always closed.

### Docker Questions

**Q: What is Docker and why use it?**  
**A:** Containerization platform. Packages application with all dependencies (Python, libraries) into single unit. Benefits: Consistent environments (dev/test/prod identical), easy deployment, isolation from host system.

**Q: What is the difference between Docker image and container?**  
**A:** 
- **Image:** Blueprint/template (like a class). Built from Dockerfile. Immutable.
- **Container:** Running instance of image (like an object). Mutable state.
Analogy: Image is recipe, container is cooked meal.

**Q: How do you optimize Docker image size?**  
**A:** 
1. Use slim base images (`python:3.11-slim` not `python:3.11`)
2. Multi-stage builds (not used here, but would for compiled languages)
3. `--no-cache-dir` in pip install
4. Copy requirements.txt before app code (layer caching)
5. `.dockerignore` to exclude unnecessary files

**Q: What is Docker Compose?**  
**A:** Tool for defining multi-container applications. Single `docker-compose.yml` file describes all services (app + database), networks, volumes. Single command (`docker-compose up`) starts everything.

**Q: How do containers communicate in Docker Compose?**  
**A:** Docker Compose creates bridge network automatically. Service names become hostnames (DNS). Example: FastAPI connects to `postgres:5432` (not `localhost:5432`).

### Kubernetes Questions

**Q: What is Kubernetes?**  
**A:** Container orchestration platform. Manages thousands of containers across multiple servers. Auto-scaling, self-healing, load balancing, rolling updates, service discovery.

**Q: What is the difference between Deployment and Pod?**  
**A:** 
- **Pod:** Smallest unit, one or more containers running together
- **Deployment:** Manages pods, ensures desired number running, handles updates
Deployment is controller for pods.

**Q: What is a Service in Kubernetes?**  
**A:** Stable network abstraction for pods. Pods have changing IPs, Service provides constant DNS name. Load balances traffic across pod replicas.

**Q: What are the different types of Services?**  
**A:** 
- **ClusterIP:** Internal only (default) - use for databases
- **NodePort:** Exposed on every node's IP - rarely used
- **LoadBalancer:** Cloud load balancer (ELB in AWS) - use for public APIs

**Q: What is a PersistentVolumeClaim?**  
**A:** Request for storage. Pod doesn't care about storage implementation (EBS, NFS, local). PVC is abstraction between pod and actual storage.

**Q: How does Kubernetes achieve zero-downtime deployment?**  
**A:** RollingUpdate strategy:
1. Create new pod with new version
2. Wait for health checks to pass
3. Add to service endpoints (starts receiving traffic)
4. Remove old pod
5. Repeat for each replica
Always maintains minimum replicas running.

**Q: What is the difference between liveness and readiness probes?**  
**A:** 
- **Liveness:** Is pod alive? If fails, kill and restart.
- **Readiness:** Is pod ready for traffic? If fails, remove from service (don't restart).

**Q: How does HorizontalPodAutoscaler work?**  
**A:** Watches pod CPU metrics (via metrics-server). Calculates: `desiredReplicas = ceil(currentReplicas * currentCPU / targetCPU)`. Adjusts deployment replica count. Respects min/max bounds.

**Q: What is a Namespace?**  
**A:** Virtual cluster within cluster. Isolates resources (pods, services, configmaps). Used for: Multi-tenancy, environments (test/prod), teams.

**Q: What is the difference between ConfigMap and Secret?**  
**A:** 
- **ConfigMap:** Non-sensitive config (database host, port)
- **Secret:** Sensitive data (passwords, tokens), base64-encoded, can be encrypted
Both injected as environment variables or files.

### AWS Questions

**Q: What is EKS?**  
**A:** Elastic Kubernetes Service - managed Kubernetes on AWS. AWS manages control plane (master nodes), you manage worker nodes (EC2 instances). Benefits: High availability, automatic upgrades, AWS integration.

**Q: What is EBS CSI driver?**  
**A:** Container Storage Interface driver for AWS Elastic Block Store. Allows Kubernetes to provision EBS volumes dynamically. When PVC created, CSI driver calls AWS API to create EBS volume, attaches to EC2 node.

**Q: How does LoadBalancer Service work in EKS?**  
**A:** Service with `type: LoadBalancer` triggers AWS Cloud Controller Manager. CCM creates Classic/Network Load Balancer, configures target group pointing to nodes, returns public DNS/IP to Service.

**Q: What is IAM role for service account?**  
**A:** Maps Kubernetes ServiceAccount to AWS IAM role. Pods assume IAM role, can access AWS services (S3, RDS) without hardcoded credentials. Security best practice.

**Q: How do you secure EKS cluster?**  
**A:** 
1. Private node group (nodes in private subnet)
2. Public endpoint disabled (kubectl only from VPN/bastion)
3. NetworkPolicy (pod-to-pod communication rules)
4. IRSA (IAM roles for service accounts)
5. Secrets encryption at rest
6. RBAC (role-based access control)

### CI/CD Questions

**Q: What is CI/CD?**  
**A:** 
- **Continuous Integration:** Automatically test code on every commit
- **Continuous Deployment:** Automatically deploy passing code to production
Benefits: Fast feedback, fewer bugs in production, faster releases.

**Q: What stages are in your pipeline?**  
**A:** 
1. **Lint & Format:** Check code style with Black and Pylint
2. **Test:** Run unit tests with pytest, measure coverage
3. **Build & Push:** Build Docker image, push to Docker Hub
4. **Deploy:** Update Kubernetes deployment (currently manual)

**Q: How does GitHub Actions work?**  
**A:** YAML workflow file (`.github/workflows/`) defines jobs. Triggered by events (push, PR). Runs on GitHub-hosted runners (Ubuntu VMs). Each job runs independent steps (checkout code, install dependencies, run commands).

**Q: Why use secrets in CI/CD?**  
**A:** Store sensitive data (Docker Hub password, AWS credentials) securely. Encrypted by GitHub, injected as environment variables. Never printed in logs.

**Q: How do you handle deployment failures?**  
**A:** Kubernetes rolling update automatically rolls back if new pods fail health checks. Manual rollback: `kubectl rollout undo deployment/itemsapi-app`.

**Q: What is Docker layer caching in CI/CD?**  
**A:** Reuses unchanged layers from previous builds. If `pip install` dependencies haven't changed, skip reinstall (saves 2-3 minutes). Uses Docker registry as cache backend.

### Testing Questions

**Q: What types of tests do you have?**  
**A:** 
- **Unit Tests:** Test individual functions (`test_create_item`)
- **Integration Tests:** Test API endpoints with database
Coverage: 80%+ required to pass CI/CD.

**Q: How do you test API endpoints?**  
**A:** FastAPI's `TestClient` - sends HTTP requests to app without starting server. Uses in-memory database or separate test database. Tests full request/response cycle including validation.

**Q: What is code coverage?**  
**A:** Percentage of code lines executed during tests. 80% coverage means 80% of lines tested. Identifies untested code paths. Not perfect metric (100% coverage ≠ bug-free).

**Q: Why 80% coverage threshold?**  
**A:** Industry standard balance. 100% impractical (error handlers, edge cases difficult to test). <80% indicates under-tested code. Quality gate: Blocks PR if coverage drops.

---

## Summary

This document explained:
1. **Why Python/FastAPI:** Fast, modern, automatic docs
2. **Why Docker:** Consistent environments, easy deployment
3. **Why Docker Compose:** Local multi-container orchestration
4. **Why Kubernetes:** Production-scale orchestration, auto-scaling, self-healing
5. **Why AWS EKS:** Managed Kubernetes, less operational burden
6. **Every file:** Purpose, code explanation, design decisions
7. **Interview prep:** Questions you'll likely face with detailed answers

**Key Takeaways:**
- Each technology solves specific problem
- Separation of concerns (app code, infrastructure, configuration)
- Industry best practices (12-factor app, security, testing)
- Production-ready patterns (health checks, auto-scaling, zero-downtime)

This is a portfolio-worthy project demonstrating full DevOps lifecycle from code to production deployment.
