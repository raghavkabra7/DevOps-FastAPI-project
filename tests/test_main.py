"""Tests for main API endpoints."""

import pytest
from fastapi import status
from fastapi.testclient import TestClient


class TestHealthEndpoint:
    """Test cases for health check endpoint."""

    def test_health_check_success(self, client: TestClient):
        """Test health check returns 200 OK."""
        response = client.get("/health")

        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["status"] == "healthy"
        assert "version" in data
        assert "environment" in data
        assert "timestamp" in data

    def test_health_check_structure(self, client: TestClient):
        """Test health check response structure."""
        response = client.get("/health")
        data = response.json()

        required_fields = ["status", "version", "environment", "timestamp"]
        for field in required_fields:
            assert field in data, f"Missing field: {field}"


class TestCreateItemEndpoint:
    """Test cases for create item endpoint."""

    def test_create_item_success(self, client: TestClient):
        """Test creating a new item."""
        item_data = {
            "name": "Test Item",
            "description": "Test Description",
            "price": 99.99,
            "quantity": 10,
        }

        response = client.post("/items", json=item_data)

        assert response.status_code == status.HTTP_201_CREATED
        data = response.json()
        assert data["name"] == item_data["name"]
        assert data["description"] == item_data["description"]
        assert data["price"] == item_data["price"]
        assert data["quantity"] == item_data["quantity"]
        assert "id" in data
        assert "created_at" in data
        assert "updated_at" in data

    def test_create_item_without_description(self, client: TestClient):
        """Test creating item without optional description."""
        item_data = {"name": "Minimal Item", "price": 49.99, "quantity": 5}

        response = client.post("/items", json=item_data)

        assert response.status_code == status.HTTP_201_CREATED
        data = response.json()
        assert data["name"] == item_data["name"]

    def test_create_item_missing_required_fields(self, client: TestClient):
        """Test creating item with missing required fields."""
        item_data = {"name": "Incomplete Item"}

        response = client.post("/items", json=item_data)

        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY

    def test_create_item_invalid_price(self, client: TestClient):
        """Test creating item with invalid price."""
        item_data = {"name": "Invalid Price Item", "price": -10.00, "quantity": 5}

        response = client.post("/items", json=item_data)

        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY

    def test_create_item_invalid_quantity(self, client: TestClient):
        """Test creating item with negative quantity."""
        item_data = {"name": "Negative Quantity Item", "price": 29.99, "quantity": -5}

        response = client.post("/items", json=item_data)

        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


class TestListItemsEndpoint:
    """Test cases for list items endpoint."""

    def test_list_items_empty(self, client: TestClient):
        """Test listing items when database is empty."""
        response = client.get("/items")

        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert isinstance(data, list)
        assert len(data) == 0

    def test_list_items_with_data(self, client: TestClient):
        """Test listing items with existing data."""
        # Create test items
        items = [
            {"name": "Item 1", "price": 10.00, "quantity": 5},
            {"name": "Item 2", "price": 20.00, "quantity": 10},
            {"name": "Item 3", "price": 30.00, "quantity": 15},
        ]

        for item in items:
            client.post("/items", json=item)

        response = client.get("/items")

        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert len(data) == 3

    def test_list_items_pagination(self, client: TestClient):
        """Test pagination with skip and limit."""
        # Create test items
        for i in range(10):
            item = {"name": f"Item {i}", "price": 10.00 * i, "quantity": i}
            client.post("/items", json=item)

        # Test with skip and limit
        response = client.get("/items?skip=2&limit=5")

        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert len(data) == 5


class TestGetItemByIdEndpoint:
    """Test cases for get item by ID endpoint."""

    def test_get_item_success(self, client: TestClient):
        """Test getting an existing item by ID."""
        # Create an item
        item_data = {"name": "Test Item", "price": 99.99, "quantity": 10}
        create_response = client.post("/items", json=item_data)
        created_item = create_response.json()
        item_id = created_item["id"]

        # Get the item
        response = client.get(f"/items/{item_id}")

        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["id"] == item_id
        assert data["name"] == item_data["name"]

    def test_get_item_not_found(self, client: TestClient):
        """Test getting non-existent item."""
        response = client.get("/items/99999")

        assert response.status_code == status.HTTP_404_NOT_FOUND
        data = response.json()
        assert "detail" in data

    def test_get_item_invalid_id(self, client: TestClient):
        """Test getting item with invalid ID format."""
        response = client.get("/items/invalid")

        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


class TestIntegrationScenarios:
    """Integration test scenarios."""

    def test_full_crud_flow(self, client: TestClient):
        """Test complete CRUD flow."""
        # Create
        item_data = {
            "name": "Integration Test Item",
            "description": "Full flow test",
            "price": 149.99,
            "quantity": 25,
        }
        create_response = client.post("/items", json=item_data)
        assert create_response.status_code == status.HTTP_201_CREATED
        item_id = create_response.json()["id"]

        # Read
        get_response = client.get(f"/items/{item_id}")
        assert get_response.status_code == status.HTTP_200_OK
        assert get_response.json()["name"] == item_data["name"]

        # List
        list_response = client.get("/items")
        assert list_response.status_code == status.HTTP_200_OK
        assert len(list_response.json()) >= 1


class TestUpdateItemEndpoint:
    """Test cases for update item endpoint."""

    def test_update_item_success(self, client: TestClient):
        """Test updating an existing item."""
        # Create an item
        item_data = {"name": "Original Item", "price": 50.00, "quantity": 10}
        create_response = client.post("/items", json=item_data)
        item_id = create_response.json()["id"]

        # Update the item
        update_data = {"name": "Updated Item", "price": 75.00}
        response = client.put(f"/items/{item_id}", json=update_data)

        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["name"] == "Updated Item"
        assert data["price"] == 75.00
        assert data["quantity"] == 10  # Unchanged

    def test_update_item_not_found(self, client: TestClient):
        """Test updating non-existent item."""
        update_data = {"name": "Updated Item"}
        response = client.put("/items/99999", json=update_data)

        assert response.status_code == status.HTTP_404_NOT_FOUND

    def test_update_item_partial(self, client: TestClient):
        """Test partial update of item."""
        # Create an item
        item_data = {"name": "Original Item", "price": 50.00, "quantity": 10}
        create_response = client.post("/items", json=item_data)
        item_id = create_response.json()["id"]

        # Update only quantity
        update_data = {"quantity": 20}
        response = client.put(f"/items/{item_id}", json=update_data)

        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["name"] == "Original Item"  # Unchanged
        assert data["quantity"] == 20  # Updated


class TestDeleteItemEndpoint:
    """Test cases for delete item endpoint."""

    def test_delete_item_success(self, client: TestClient):
        """Test deleting an existing item."""
        # Create an item
        item_data = {"name": "Item to Delete", "price": 50.00, "quantity": 10}
        create_response = client.post("/items", json=item_data)
        item_id = create_response.json()["id"]

        # Delete the item
        response = client.delete(f"/items/{item_id}")

        assert response.status_code == status.HTTP_204_NO_CONTENT

        # Verify item is deleted
        get_response = client.get(f"/items/{item_id}")
        assert get_response.status_code == status.HTTP_404_NOT_FOUND

    def test_delete_item_not_found(self, client: TestClient):
        """Test deleting non-existent item."""
        response = client.delete("/items/99999")

        assert response.status_code == status.HTTP_404_NOT_FOUND
