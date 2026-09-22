import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.ml.model_loader import model_registry
from app.routers import diagnose, health

logging.basicConfig(level=logging.INFO)


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Load model sekali saat startup, bukan per-request (05-ml-pipeline.md).
    model_registry.load_all()
    yield


app = FastAPI(title="AgriVision ML Service", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[o.strip() for o in settings.allowed_origins.split(",")],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(diagnose.router)
app.include_router(health.router)
