FROM python:3.11

ENV APP_PORT 8443

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade -r requirements.txt

COPY src .

EXPOSE $APP_PORT

# Run uvicorn server with our application
CMD ["gunicorn", "main:app"]