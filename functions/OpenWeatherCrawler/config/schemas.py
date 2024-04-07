from pydantic import BaseModel

class Config(BaseModel):

    openweather_token: str