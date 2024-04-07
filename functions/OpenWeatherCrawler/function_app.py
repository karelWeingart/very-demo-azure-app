import os
import logging
from config.service import FunctionConfig
import azure.functions as func
from openweather.service import OpenWeatherService


app = func.FunctionApp()

@app.schedule(schedule="0 30 * * * *", arg_name="myTimer", run_on_startup=True,
              use_monitor=False) 
def OpenWeatherCrawler(myTimer: func.TimerRequest) -> None:
    if myTimer.past_due:
        logging.info('The timer is past due!')

    _config = FunctionConfig.get_config()

    _o_service = OpenWeatherService(_config.openweather_token)


    #data = _o_client.get_data(lat="49.453825817301116", lon="18.19461679998658")
    data = _o_service.get_current_temp(lat="49.453825817301116", lon="18.19461679998658")




    logging.info('Python timer trigger function executed.')


