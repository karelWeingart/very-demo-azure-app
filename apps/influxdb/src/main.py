import os
from datetime import datetime
from influxdb_client_3 import InfluxDBClient3, Point
from uploader  import router as uploader_router


from fastapi import FastAPI


app = FastAPI()
app.include_router(uploader_router.router)
