from pydantic import BaseModel, Field
from typing import Optional
from fastapi import Form, Query, Cookie, Body

from dataclasses import dataclass

@dataclass
class UploadAttributes:

    influx_host: str = Cookie()
    influx_database: str = Form(...)
    influx_org: str = Form(...)
    measurement: str = Form(...)
    properties_to_tags: Optional[str] = None

class QueryParams(BaseModel):

    influx_database: str
    influx_org: str
    measurement: str
    plotly_graph_type: str
    interval: int
    x_axis: str
    field: str
    aggregate_function: str
    group_by: str
