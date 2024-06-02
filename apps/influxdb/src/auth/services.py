from auth.schemas import AllowedInfluxBuckets, UserAccess
from typing import Annotated, Union
from fastapi import Depends, HTTPException, Cookie, status
from fastapi.security import OAuth2PasswordBearer
from fastapi.security import OAuth2PasswordRequestForm
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential
import requests
import json
from config import settings

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

class AuthService:

    @staticmethod
    def authorize(token: Annotated[str, Depends(oauth2_scheme)], influx_host: Union[str, None] = Cookie(None)) -> AllowedInfluxBuckets:
        
        _response: requests.Response = None
        try:
            _response = requests.get(url=f"{influx_host}/api/v2/buckets", 
                                headers={"Authorization": f"Token {token}"}
                             )
        except requests.RequestException:
            raise HTTPException(
                status_code=_response.status_code,
                detail=_response.content
            )
    
        if _response.status_code != 200:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect Authorization token"
            )
    
        _data = _response.json()
        _buckets = [{bucket.get("orgID"): bucket.get("name")} for bucket in  _data.get("buckets")]
        return AllowedInfluxBuckets(token=token, buckets=_buckets)
    

class KeyVaultService:
    KEY_VAULT_ITEM_PREFIX = "influx-user"

    @staticmethod
    def get_user_access(form_data: OAuth2PasswordRequestForm = Depends()) -> UserAccess:
        _credential = DefaultAzureCredential()
        _client = SecretClient(vault_url=settings.KEYVAULT_ENDPOINT, credential=_credential)        
        _retrieved_secret = _client.get_secret(f"{KeyVaultService.KEY_VAULT_ITEM_PREFIX}-{form_data.username}")
        if KeyVaultService._validate_login(form_data.password, _retrieved_secret.value):
            return UserAccess.model_validate_json(_retrieved_secret.value)
        else:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect credentials provided"
            )
    
    @staticmethod
    def _validate_login(password: str, secret: str) -> bool:
        _json = json.loads(secret)
        if password == _json.get("password"):
            return True
        return False
    
