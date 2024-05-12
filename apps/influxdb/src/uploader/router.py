from fastapi import APIRouter, Depends, UploadFile, Header
from services.xml_service import JUnitTestResultsService
from services.influxdb_service import InfluxDbService
from uploader.schemas import UploadAttributes
from typing import Annotated



router = APIRouter()

@router.post("/unit-tests-xml")
async def post_unit_tests(file: UploadFile, authorization: Annotated[str, Header()], attributes: UploadAttributes = Depends()) -> dict:
    _token = authorization.split(" ")[1]
    _xml_service = JUnitTestResultsService(file, measurement_name=attributes.measurement)
    _influx_service = InfluxDbService(attributes=attributes, token=_token)
    _points = _xml_service.get_data()
    _influx_service.write(_points)

    return {}