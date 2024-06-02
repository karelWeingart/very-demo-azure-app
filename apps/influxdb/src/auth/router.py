from fastapi import APIRouter, Depends
from auth.services import KeyVaultService
from auth.schemas import UserAccess
from typing import Annotated


router = APIRouter()

@router.post("/token")
async def login(user_access: Annotated[UserAccess, Depends(KeyVaultService.get_user_access)]) -> UserAccess:
    return user_access