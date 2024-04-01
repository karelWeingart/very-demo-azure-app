from fastapi import FastAPI
from randomized import router as randomized

app = FastAPI()
app.include_router(randomized.router)