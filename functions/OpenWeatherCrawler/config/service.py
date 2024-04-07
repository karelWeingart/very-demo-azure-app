import os
from config.schemas import Config



class FunctionConfig:


    @staticmethod
    def get_config() -> Config:

        return Config(openweather_token=os.getenv("OPENWEATHER_TOKEN"))    
