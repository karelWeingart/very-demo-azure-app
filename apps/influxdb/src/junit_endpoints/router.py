from fastapi import APIRouter, Depends, UploadFile, Header
from services.xml_service import JUnitTestResultsService
from services.influxdb_service import PandasProcessor, PandasProcessorFactory
from junit_endpoints.schemas import UploadAttributes
from typing import Annotated
from auth.services import AuthService



router = APIRouter()


@router.post("/unit-tests")
async def post_unit_tests(file: UploadFile, access_data: Annotated[str, Depends(AuthService.authorize)], attributes: UploadAttributes = Depends()) -> dict:
    
    _xml_service = JUnitTestResultsService(file, measurement_name=attributes.measurement)
    #_influx_service = InfluxDbService(attributes=attributes, token=access_data.token)
    _points = _xml_service.get_influx_points()
    #_influx_service.write(_points)

    return {}

@router.post("/report")
async def report(data: list[dict] = Depends(PandasProcessor.get_data)) -> list[dict]:
    return data

