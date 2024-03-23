from pydantic import BaseModel


class RandomIntsList(BaseModel):

    min: int = 0
    max: int = 100
    count: int = 10
    values: list[int]