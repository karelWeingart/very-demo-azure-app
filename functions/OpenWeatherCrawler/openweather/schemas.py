from pydantic import BaseModel
from typing import Literal

class DataSchema(BaseModel):

    timestamp: float
    location: str
    value_type: Literal["TEMP", "HUM"]
    value: float