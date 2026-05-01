from fastapi.testclient import TestClient

from main import app

client = TestClient(app)


def test_health_returns_200():
    response = client.get("/health")
    assert response.status_code == 200


def test_health_body():
    response = client.get("/health")
    body = response.json()
    assert body["status"] == "ok"
    assert body["service"] == "alpha"


def test_hello_returns_200():
    response = client.get("/api/v1/hello")
    assert response.status_code == 200


def test_hello_body():
    response = client.get("/api/v1/hello")
    body = response.json()
    assert "message" in body
    assert "version" in body
