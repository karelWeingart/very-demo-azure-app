import requests
from typing import Any

class OpenWeatherClient:

    _API_ENDPOINT = "https://api.openweathermap.org/data/3.0/onecall"
    _DEFAULT_PARAMS = {
        "units": "metrics",
        "exclude": "minutely,hourly,daily"
    }

    def __init__(self, token: str) -> None:
        self._token = token

    def get_data(self, lat: float, lon: float) -> dict[Any]:
        _params = {**{"lat": lat, "lon": lon, "appid": self._token}, **self._DEFAULT_PARAMS}
        _data = requests.get(url=self._API_ENDPOINT, params = _params, verify=False)
        return _data.json()