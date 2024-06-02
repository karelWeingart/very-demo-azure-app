from junit_endpoints  import router as uploader_router
from auth import router as auth_router
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles


app = FastAPI()

app.mount("/html", StaticFiles(directory="html"), name="static")
app.include_router(uploader_router.router)
app.include_router(auth_router.router)

