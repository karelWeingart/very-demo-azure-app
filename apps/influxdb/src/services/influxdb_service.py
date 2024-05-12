from datetime import datetime
from influxdb_client_3 import InfluxDBClient3, Point
from uploader.schemas import UploadAttributes



class InfluxDbService:

    def __init__(self, attributes: UploadAttributes, token: str):
        self._attributes = attributes
        self.__client = InfluxDBClient3(host=attributes.influx_host, token=token, org=attributes.influx_org)

    def write(self, points: list[Point]) -> None:
        for _point in points:
            self.__client.write(database=self._attributes.influx_database, record=_point)
