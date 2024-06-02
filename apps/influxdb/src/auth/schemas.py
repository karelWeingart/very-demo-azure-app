from pydantic import BaseModel, ConfigDict

class UserAccess(BaseModel):
    model_config = ConfigDict(strict=True)
    
    token: str
    influx_org: str
    influx_host: str
    influx_bucket: str

class AllowedInfluxBuckets(BaseModel):

    token: str
    buckets: list[dict[str, str]]