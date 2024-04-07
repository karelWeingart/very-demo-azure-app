
from openweather.client import OpenWeatherClient
from openweather.schemas import DataSchema

class OpenWeatherService:

    _client: OpenWeatherClient

    _json_data_root = "current"

    _cache: dict = {}

    def __init__(self, token: str):
        self._client = OpenWeatherClient(token=token)
    

    def get_current_temp(self, lat: float, lon: float) -> DataSchema:
        _cache_key = self._build_cache_key(lat, lon)
        
        if f"{_cache_key}" not in self._cache:
            self._put_in_cache(_cache_key,self._client.get_data(lat, lon))
        
        _raw_data =  self._cache[_cache_key]
        _current_weather = _raw_data[self._json_data_root]
        
        _d = DataSchema(timestamp = _current_weather["dt"], location=_cache_key, value_type="TEMP", value=_current_weather["temp"])
        return _d

        
        


    def _build_cache_key(self, lat: float, lon: float) -> str:
        return f"{lat}-{lon}"
    
    def _put_in_cache(self, key: str, data: dict[any]) -> None:
        self._cache[key] = data