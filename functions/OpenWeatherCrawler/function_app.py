import os
import logging
from config.service import FunctionConfig
import azure.functions as func
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient 
import sys
from openweather.service import OpenWeatherService




app = func.FunctionApp()
logger = logging.getLogger("azure")
logger.setLevel(logging.DEBUG)
handler = logging.StreamHandler(stream=sys.stdout)
logger.addHandler(handler)

@app.schedule(schedule="0 30 * * * *", arg_name="myTimer", run_on_startup=True,
              use_monitor=False) 
def OpenWeatherCrawler(myTimer: func.TimerRequest) -> None:
    if myTimer.past_due:
        logger.info('The timer is past due!')
    
    credential = DefaultAzureCredential()

    client = SecretClient(vault_url="https://testcommonvault.vault.azure.net/",
        credential=credential,connection_verify = False ) 

    secret = client.get_secret("function-OpenWeatherCrawler-apiToken")

    _config = FunctionConfig.get_config()

    _o_service = OpenWeatherService(_config.openweather_token)


    #data = _o_client.get_data(lat="49.453825817301116", lon="18.19461679998658")
    data = _o_service.get_current_temp(lat="49.453825817301116", lon="18.19461679998658")




    logger.warning('Python timer trigger function executed.')


