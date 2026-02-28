"""Tests for database models."""
import pytest
from datetime import datetime
from app.models import ItemModel, ItemCreate, ItemResponse


class TestItemModel:
    """Test cases for ItemModel."""
    
    def test_item_model_creation(self, db):
        """Test creating an item in database."""
        item = ItemModel(
            name="Test Item",
            description="Test Description",
            price=99.99,
            quantity=10
        )
        
        db.add(item)
        db.commit()
        db.refresh(item)
        
        assert item.id is not None
        assert item.name == "Test Item"
        assert item.description == "Test Description"
        assert item.price == 99.99
        assert item.quantity == 10
        assert isinstance(item.created_at, datetime)
        assert isinstance(item.updated_at, datetime)
    
    def test_item_model_defaults(self, db):
        """Test default values for item model."""
        item = ItemModel(
            name="Minimal Item",
            price=49.99
        )
        
        db.add(item)
        db.commit()
        db.refresh(item)
        
        assert item.quantity == 0  # Default quantity
        assert item.created_at is not None
        assert item.updated_at is not None


class TestItemCreateSchema:
    """Test cases for ItemCreate schema."""
    
    def test_item_create_valid(self):
        """Test valid item creation schema."""
        item = ItemCreate(
            name="Valid Item",
            description="Valid Description",
            price=99.99,
            quantity=10
        )
        
        assert item.name == "Valid Item"
        assert item.description == "Valid Description"
        assert item.price == 99.99
        assert item.quantity == 10
    
    def test_item_create_without_optional_fields(self):
        """Test item creation without optional fields."""
        item = ItemCreate(
            name="Minimal Item",
            price=49.99
        )
        
        assert item.name == "Minimal Item"
        assert item.price == 49.99
        assert item.quantity == 0
    
    def test_item_create_invalid_price(self):
        """Test item creation with invalid price."""
        with pytest.raises(ValueError):
            ItemCreate(
                name="Invalid Price",
                price=0,  # Price must be greater than 0
                quantity=5
            )
    
    def test_item_create_invalid_quantity(self):
        """Test item creation with invalid quantity."""
        with pytest.raises(ValueError):
            ItemCreate(
                name="Invalid Quantity",
                price=29.99,
                quantity=-5  # Quantity cannot be negative
            )


class TestItemResponseSchema:
    """Test cases for ItemResponse schema."""
    
    def test_item_response_from_model(self, db):
        """Test converting database model to response schema."""
        # Create item in database
        db_item = ItemModel(
            name="Response Test",
            description="Testing response",
            price=79.99,
            quantity=15
        )
        
        db.add(db_item)
        db.commit()
        db.refresh(db_item)
        
        # Convert to response schema
        response = ItemResponse.model_validate(db_item)
        
        assert response.id == db_item.id
        assert response.name == db_item.name
        assert response.description == db_item.description
        assert response.price == db_item.price
        assert response.quantity == db_item.quantity
        assert isinstance(response.created_at, datetime)
        assert isinstance(response.updated_at, datetime)
