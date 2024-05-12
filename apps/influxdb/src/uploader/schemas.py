from pydantic import BaseModel
from typing import Optional
from fastapi import Form

from dataclasses import dataclass

@dataclass
class UploadAttributes:

    influx_host: str = Form(...)
    influx_database: str = Form(...)
    influx_org: str = Form(...)
    measurement: str = Form(...)
    properties_to_tags: Optional[str] = None