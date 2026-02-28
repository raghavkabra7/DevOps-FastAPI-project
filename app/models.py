"""Database models."""

from datetime import datetime
from sqlalchemy import Column, Integer, String, Float, DateTime
from pydantic import BaseModel, Field
from app.database import Base


# SQLAlchemy Model
class ItemModel(Base):
    """Item database model."""

    __tablename__ = "items"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    name = Column(String(255), nullable=False, index=True)
    description = Column(String(1000))
    price = Column(Float, nullable=False)
    quantity = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


# Pydantic Schemas
class ItemCreate(BaseModel):
    """Schema for creating an item."""

    name: str = Field(..., min_length=1, max_length=255, description="Item name")
    description: str = Field(None, max_length=1000, description="Item description")
    price: float = Field(..., gt=0, description="Item price")
    quantity: int = Field(0, ge=0, description="Item quantity")


class ItemUpdate(BaseModel):
    """Schema for updating an item."""

    name: str = Field(None, min_length=1, max_length=255, description="Item name")
    description: str = Field(None, max_length=1000, description="Item description")
    price: float = Field(None, gt=0, description="Item price")
    quantity: int = Field(None, ge=0, description="Item quantity")


class ItemResponse(BaseModel):
    """Schema for item response."""

    id: int
    name: str
    description: str | None
    price: float
    quantity: int
    created_at: datetime
    updated_at: datetime

    class Config:
        """Pydantic configuration."""

        from_attributes = True


class HealthResponse(BaseModel):
    """Schema for health check response."""

    status: str
    environment: str
    version: str
    timestamp: datetime
