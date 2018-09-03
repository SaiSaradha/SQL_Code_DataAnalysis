import pandas as pd
from pandas import ExcelWriter
from pandas import ExcelFile


class load_data:
    def __init__(self, filename):
        self.file_name = filename
        self.lab_data = []
        self.service_data = []
        self.cost_data = []
        self.load_all_data()

    def load_all_data(self):
        try:
            self.lab_data = pd.read_pickle("Pickled_Data/lab_data.pkl")
            self.service_data = pd.read_pickle("Pickled_Data/service_data.pkl")
            self.cost_data = pd.read_pickle("Pickled_Data/cost_data.pkl")

        except Exception:
            self.lab_data = pd.read_excel(self.file_name, sheetname='LabData',converters={'Received in Lab': str})
            self.service_data = pd.read_excel(self.file_name, sheetname='ServiceData')
            self.cost_data = pd.read_excel(self.file_name, sheetname='CostData')

            self.lab_data.to_pickle("Pickled_Data/lab_data.pkl")
            self.service_data.to_pickle("Pickled_Data/service_data.pkl")
            self.cost_data.to_pickle("Pickled_Data/cost_data.pkl")
        return

    def get_all_data(self):
        return self.lab_data, self.service_data, self.cost_data

    def get_lab_data(self):
        return self.lab_data

    def get_service_data(self):
        return self.service_data

    def get_cost_data(self):
        return self.cost_data

