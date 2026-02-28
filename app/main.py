"""Main FastAPI application."""

import logging
from datetime import datetime
from typing import List
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session

from app.config import settings
from app.database import get_db, init_db
from app.models import ItemModel, ItemCreate, ItemUpdate, ItemResponse, HealthResponse

# Configure logging
logging.basicConfig(
    level=getattr(logging, settings.log_level),
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager."""
    logger.info("Starting application...")
    init_db()
    logger.info("Database initialized successfully")
    yield
    logger.info("Shutting down application...")


# Create FastAPI application
app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    description="A production-ready Item Management API with complete DevOps pipeline",
    lifespan=lifespan,
)


@app.get("/health", response_model=HealthResponse, tags=["Health"])
async def health_check():
    """
    Health check endpoint.

    Returns:
        HealthResponse: Application health status
    """
    logger.info("Health check requested")
    return HealthResponse(
        status="healthy",
        environment=settings.environment,
        version=settings.app_version,
        timestamp=datetime.utcnow(),
    )


@app.post(
    "/items",
    response_model=ItemResponse,
    status_code=status.HTTP_201_CREATED,
    tags=["Items"],
)
async def create_item(item: ItemCreate, db: Session = Depends(get_db)):
    """
    Create a new item.

    Args:
        item: Item data
        db: Database session

    Returns:
        ItemResponse: Created item
    """
    try:
        logger.info(f"Creating new item: {item.name}")

        db_item = ItemModel(
            name=item.name,
            description=item.description,
            price=item.price,
            quantity=item.quantity,
        )

        db.add(db_item)
        db.commit()
        db.refresh(db_item)

        logger.info(f"Item created successfully with ID: {db_item.id}")
        return db_item

    except Exception as e:
        logger.error(f"Error creating item: {str(e)}")
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create item",
        )


@app.get("/items", response_model=List[ItemResponse], tags=["Items"])
async def list_items(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """
    List all items with pagination.

    Args:
        skip: Number of items to skip
        limit: Maximum number of items to return
        db: Database session

    Returns:
        List[ItemResponse]: List of items
    """
    try:
        logger.info(f"Fetching items with skip={skip}, limit={limit}")
        items = db.query(ItemModel).offset(skip).limit(limit).all()
        logger.info(f"Found {len(items)} items")
        return items

    except Exception as e:
        logger.error(f"Error fetching items: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch items",
        )


@app.get("/items/{item_id}", response_model=ItemResponse, tags=["Items"])
async def get_item(item_id: int, db: Session = Depends(get_db)):
    """
    Get item by ID.

    Args:
        item_id: Item ID
        db: Database session

    Returns:
        ItemResponse: Item details
    """
    try:
        logger.info(f"Fetching item with ID: {item_id}")
        item = db.query(ItemModel).filter(ItemModel.id == item_id).first()

        if not item:
            logger.warning(f"Item not found with ID: {item_id}")
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Item with ID {item_id} not found",
            )

        logger.info(f"Item found: {item.name}")
        return item

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching item: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch item",
        )


@app.put("/items/{item_id}", response_model=ItemResponse, tags=["Items"])
async def update_item(item_id: int, item: ItemUpdate, db: Session = Depends(get_db)):
    """
    Update item by ID.

    Args:
        item_id: Item ID
        item: Updated item data
        db: Database session

    Returns:
        ItemResponse: Updated item
    """
    try:
        logger.info(f"Updating item with ID: {item_id}")
        db_item = db.query(ItemModel).filter(ItemModel.id == item_id).first()

        if not db_item:
            logger.warning(f"Item not found with ID: {item_id}")
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Item with ID {item_id} not found",
            )

        # Update only provided fields
        update_data = item.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_item, field, value)

        db_item.updated_at = datetime.utcnow()
        db.commit()
        db.refresh(db_item)

        logger.info(f"Item updated successfully: {item_id}")
        return db_item

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating item: {str(e)}")
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update item",
        )


@app.delete("/items/{item_id}", status_code=status.HTTP_204_NO_CONTENT, tags=["Items"])
async def delete_item(item_id: int, db: Session = Depends(get_db)):
    """
    Delete item by ID.

    Args:
        item_id: Item ID
        db: Database session
    """
    try:
        logger.info(f"Deleting item with ID: {item_id}")
        db_item = db.query(ItemModel).filter(ItemModel.id == item_id).first()

        if not db_item:
            logger.warning(f"Item not found with ID: {item_id}")
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Item with ID {item_id} not found",
            )

        db.delete(db_item)
        db.commit()

        logger.info(f"Item deleted successfully: {item_id}")
        return None

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting item: {str(e)}")
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete item",
        )


@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    """Global exception handler."""
    logger.error(f"Unhandled exception: {str(exc)}")
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"detail": "Internal server error"},
    )


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app", host=settings.host, port=settings.port, reload=settings.debug
    )
