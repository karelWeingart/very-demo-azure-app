import random
from fastapi import APIRouter
from randomized.service import RandomNumbers
from randomized.schemas import RandomIntsList


router = APIRouter()


@router.get("/random")
async def get_random() -> RandomIntsList:
    _rand_service = RandomNumbers()
    _ret = _rand_service.get_random_numbers()
    return _ret