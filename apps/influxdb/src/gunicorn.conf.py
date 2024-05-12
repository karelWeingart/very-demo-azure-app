# Gunicorn configuration file
import multiprocessing
import os

max_requests = 50
max_requests_jitter = 10

#Getting port from os
_app_port = os.getenv("APP_PORT")

log_file = "-"

#Listening on all network adapters
bind = f"0.0.0.0:{_app_port}"

worker_class = "uvicorn.workers.UvicornWorker"
workers = (multiprocessing.cpu_count() * 2) + 1