from xml.etree import ElementTree
from fastapi import UploadFile
from influxdb_client_3 import Point

class XmlService:

    def __init__(self, xml_file: UploadFile, measurement_name: str) -> None:
        self._xml_file_object = xml_file
        #self._xml_content = xml_file.file.readlines()
        self._xml_root = ElementTree.parse(xml_file.file)
        self._measurement_name = measurement_name

    def get_data(self) -> list[dict]:
        raise NotImplemented
    
class JUnitTestResultsService(XmlService):

    TESTSUITE_XPATH: str = ".//testsuite"
    TESTCASE_XPATH: str = "./testcase"
    CLASS_ATTRIBUTE: str = "classname"
    FAILURE_XPATH: str = "./failure"
    SKIPPED_XPATH: str = "./failure"
    TESTCASE_PROPERTIES_XPATH: str = ".//property" 


    def get_data(self) -> list[Point]:
        _testsuites: list[ElementTree.Element] = self._xml_root.findall(self.TESTSUITE_XPATH)
        _ret_list: list = []
        for __testsuite in _testsuites:            
            for __test_case in __testsuite.findall(self.TESTCASE_XPATH):
                _p = (Point(measurement_name=self._measurement_name)
                  .time(__testsuite.attrib.get("timestamp"))
                  .tag("test_suite", __testsuite.attrib.get("name"))
                )
                _p.tag("test_class_name", __test_case.get(self.CLASS_ATTRIBUTE))
                _p.tag("test_case_name", __test_case.attrib.get("name"))                
                if __test_case.find(self.FAILURE_XPATH):
                    _p.field("failure", 1)
                elif __test_case.find(self.SKIPPED_XPATH):
                    _p.field("skipped", 1)
                else:
                    _p.field("success", 1)
                _p.field("duration", __test_case.attrib.get("time"))
                
                _ret_list.append(_p)
            

        
        return _ret_list           

        