from datetime import datetime, timedelta
from influxdb_client_3 import InfluxDBClient3, Point
from junit_endpoints.schemas import QueryParams
from typing import Any, Annotated
from fastapi import Depends, Cookie
from auth.services import oauth2_scheme
import pandas
from pyinfluxql import Engine, Query, functions
from pydantic import BaseModel

class QueryAttributes(BaseModel): 
    pass

class InfluxDbService:
    
    def write(self, points: list[Point]) -> None:
        _req_point = (Point(measurement_name="requirements")
                      .tag("req_name", "third per test case")
                      .field("approved", 1))
        for _point in points:
            self._client.write(database=self._attributes.influx_database, record=_point)
        self._client.write(database=self._attributes.influx_database, record=_req_point)

    @staticmethod
    def query(token: Annotated[str, Depends(oauth2_scheme)], params: QueryParams, influx_host: str = Cookie()) -> Any:
        
        _aggregate_function = getattr(functions, params.aggregate_function)
        _client = InfluxDBClient3(host=influx_host, token=token, org=params.influx_org, database=params.influx_database)

        _engine = Engine(_client)
        _query = (Query(_aggregate_function(params.field).as_(params.field),
                        params.group_by,
                        f"date_trunc('day', time) AS {params.x_axis}"
                        )
                  .from_(params.measurement)
                  .date_range(start=datetime.now() - timedelta(days=params.interval), end=datetime.now())
                  .group_by(params.group_by, params.x_axis)
                  .order(params.x_axis, "desc")
                )
        _data = _engine.execute(_query)
        
        #_pandas = PandasProcessor()
      
        return _data #_pandas.process(_dataframe, params.plotly_graph_type, _x_axis_data, params.x_axis, params.field,group_by=params.group_by)
  

class PandasProcessor:

    @staticmethod
    def get_data(data: Annotated[Any, Depends(InfluxDbService.query)], params: QueryParams) -> list[dict]:
        if isinstance(params.group_by, str):
            return PandasProcessorOneLevel.get_data(data=data, params=params)

class PandasProcessorOneLevel(PandasProcessor):

    @staticmethod
    def get_data(data: Annotated[Any, Depends(InfluxDbService.query)], params: QueryParams) -> list[dict]:
        _dataframe = data.to_pandas()
        _x_axis_data = pandas.unique(_dataframe[params.x_axis].values.astype(str).tolist()).tolist()
        _gr_list = [params.group_by, params.x_axis]
        if params.aggregate_function == "Sum":
            _df = _dataframe.groupby(_gr_list).sum()
        elif params.aggregate_function == "Min":
            _df = _dataframe.groupby(_gr_list).min()
        elif params.aggregate_function == "Max":
            _df = _dataframe.groupby(_gr_list).max()
        _ret_list = []
        _prev_index: tuple = ("","")
        for index, row in _df.iterrows():
            if index[0] == _prev_index[0]:
                _ret_list[len(_ret_list)-1]['y'].append(float(row[params.field]))
            else:
                _trace = {
                    "x": _x_axis_data,
                    "y": [float(row[params.field])],
                    "type": "scatter",
                    "name": index[0]
                }
                _ret_list.append(_trace)
            _prev_index = index
        return _ret_list


class PandasProcessorFactory:

    @staticmethod
    def get_data(data: Annotated[Any, Depends(InfluxDbService.query)], params: QueryParams) -> PandasProcessor:
        ...



