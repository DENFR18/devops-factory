from fastapi import FastAPI

app = FastAPI(title="service-alpha", version="1.0.0")


@app.get("/health")
def health() -> dict:
    return {"status": "ok", "service": "alpha"}


@app.get("/api/v1/hello")
def hello() -> dict:
    return {"message": "Hello from service-alpha", "version": "1.0.0"}
