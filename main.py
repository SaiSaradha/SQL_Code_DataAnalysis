from load_data import *
import time
import xlwt
import dateutil.parser


class UM_LabDataAnalysis:
    def __init__(self):
        tic = time.time()
        filename = 'Data/DQHI Data Scientist Exercise Data.xlsx'
        self.ld = load_data(filename)
        self.inap_sno = []
        self.inap_orderno=[]
        self.run_analysis()
        self.ldata, self.sdata, self.cdata = [], [], []
        toc = time.time() - tic
        print("Running time : " + str(toc))


    def get_data(self):
        return self.ld.get_all_data()

    def demographic_analysis(self):

        # count num of patients by gender
        m_f_count = self.ldata.groupby('Sex').size()
        male_count = m_f_count['F']
        female_count = m_f_count['M']
        n_count = m_f_count['N']
        u_count = m_f_count['U']
        print('# of male patients', male_count)
        print('# of female patients', female_count)
        print('# of neutral patients', n_count)
        print('# of unknown patients', u_count)

        # Male Female Ratio :
        m_f_ratio = male_count/female_count
        print('Male to Female Ratio : ', m_f_ratio)

        # Count by Patient type :
        patient_type_count = self.ldata.groupby('Patient Type').size()
        inp_count = patient_type_count['Inpatient']
        outp_count = patient_type_count['Outpatient']
        consult_count = patient_type_count['Consult']
        print('Inpatient - Outpatient - Consult count - ', inp_count, outp_count, consult_count)

        # count # of patients
        group_patients = self.ldata.groupby('Patient ID').size()
        unique_patients = self.ldata['Patient ID'].nunique()
        print('Total # of patients ', unique_patients)

        # of physicians
        group_physicians = self.ldata.groupby('Physician ID').size()
        unique_physicians = self.ldata['Physician ID'].nunique()
        print('Total # of physicians', unique_physicians)

        # of stay wards
        group_wards = self.ldata.groupby('Stay Ward').size()
        unique_wards = self.ldata['Stay Ward'].nunique()
        print('Total # of stay wards', unique_wards)

    def time_extraction(self):
        # t_lab_rcvd = self.ldata['Received in Lab'].apply(pd.Timestamp)
        # print(type(t_lab_rcvd[0]))
        # print(type(self.ldata['Received in Lab'][0]))
        # print(type(self.ldata['Specimen Collected'][0]))

        # extract the time from each of the columns
        t_order_rel = self.ldata['Order Released'].dt.time
        t_scheduled_coll = self.ldata['Scheduled Collection'].dt.time
        t_specimen_clctd = self.ldata['Specimen Collected'].dt.time
        t_lab_rcvd = self.ldata['Received in Lab'].apply(pd.Timestamp).dt.time
        t_test_complte = self.ldata['Testing Complete'].dt.time

        # extract the date from each of the datetime columns
        d_order_rel = self.ldata['Order Released'].dt.date
        d_scheduled_coll = self.ldata['Scheduled Collection'].dt.date
        d_specimen_clctd = self.ldata['Specimen Collected'].dt.date
        d_lab_rcvd = self.ldata['Received in Lab'].apply(pd.Timestamp).dt.date
        d_test_complte = self.ldata['Testing Complete'].dt.date

        # add the new separated date and time columns
        self.ldata['Order Released D'] = d_order_rel
        self.ldata['Scheduled COllection D'] = d_scheduled_coll
        self.ldata['Specimen Collected D'] = d_specimen_clctd
        self.ldata['Received in Lab D'] = d_lab_rcvd
        self.ldata['Testing Complete D'] = d_test_complte

        self.ldata['Order Released T'] = t_order_rel
        self.ldata['Scheduled COllection T'] = t_scheduled_coll
        self.ldata['Specimen Collected T'] = t_specimen_clctd
        self.ldata['Received in Lab T'] = t_lab_rcvd
        self.ldata['Testing Complete T'] = t_test_complte

        # remove the old columns
        self.ldata.drop(['Order Released', 'Scheduled Collection', 'Specimen Collected', 'Received in Lab', 'Testing Complete'], axis=1)
        return

    def ical_abga_analysis(self):
        gtc = ['ICAL', 'ABGA']
        ical_data = self.ldata.loc[self.ldata['Group Test Code'].isin(gtc)]
        # got 115596 rows
        # now groupby patients :
        ical_by_patients = ical_data.groupby('Patient ID')
        # for each patient, apply the rule :
        for name, group in ical_by_patients:
            ical_sub = group.loc[group['Group Test Code'] == 'ICAL']
            for iname, igroup in ical_sub:
                print(iname, igroup)
        return

    def cbc_analysis(self):
        # first filter inpatients and those with CBC results
        cbc_data = self.ldata.loc[(self.ldata['Patient Type'] == 'Inpatient') & (self.ldata['Group Test Code']=='CBC')]
        # now groupby patients :
        cbc_by_patients = cbc_data.groupby('Patient ID')
        for name, group in cbc_by_patients:
            num_cbc = group['Order Number'].nunique()
            if num_cbc >= 3:
                group = group.sort_values(by=['Order Released D', 'Order Released T'])
                # print(name)
                # print(name, num_cbc, group)
                # each order should have 3 records (Hgb, Plt and WBC)
                # get unique orders in this set :
                order_extract = group['Order Number'].unique()
                '''for order in order_extract:
                    sub_group = group[group['Order Number'] == order]
                    order_count = len(group[group['Order Number'] == order])
                    if order_count > 3:
                        print(order, ' Error, number of CBC Tests done is greater than 3')
                    elif order_count < 3:
                        print(order, ' Error, some test is missing, only ', order_count, ' # of tests')
                        hgb_count = len(sub_group[group['Test Code'] == 'HGB'])
                        wbc_count = len(sub_group[group['Test Code'] == 'WBC'])
                        plt_count = len(sub_group[group['Test Code'] == 'PLT'])
                        if hgb_count < 1:
                            print('Missing hgb')
                        if wbc_count < 1:
                            print('Missing wbc')
                        if plt_count < 1:
                            print('Missing plt')'''
                j = 0
                for i in range(num_cbc-3):
                    # TODO: Get data of that 3 order numbers
                    order_values = order_extract[j:j+3]
                    sub_data = group.loc[group['Order Number'].isin(order_values)]
                    # sub_data = group[j:j+9]
                    j += 1
                    self.check_cbc(sub_data)
        print('Creating Excel Sheet!')
        print(len(self.inap_sno))
        print(self.inap_sno)
        book = xlwt.Workbook(encoding="utf-8")
        sheet1 = book.add_sheet("Sheet 1")
        print('Entering loop to load data in excel sheet')
        for i in range(len(self.inap_sno)):
            sheet1.write(i, 0, str(self.inap_sno[i]))
            sheet1.write(i, 1, str(self.inap_orderno[i]))
        book.save("output.xls")
        return

    def check_cbc(self, data):
        try:
            data = data.sort_values(by=['Order Released D', 'Order Released T', 'Test Code'])
            t_ordered, hgb, plt, wbc, wbc_norm, plt_norm = [], [], [], [], [], []
            # print(data)
            r1, r2, r3 = [], [], []
            j=0
            for i in range(3):
                r1 = data.iloc[j]
                r2 = data.iloc[j+1]
                r3 = data.iloc[j+2]
                t_ordered.append((r1['Order Released']))
                hgb.append((r1['Result']))
                plt.append((r2['Result']))
                wbc.append((r3['Result']))
                plt_norm.append((r2['Norm/Abnorm']))
                wbc_norm.append((r3['Norm/Abnorm']))
                j+=3
            first_time_diff = (t_ordered[1]-t_ordered[0]).seconds//3600
            second_time_diff = (t_ordered[2] - t_ordered[0]).seconds // 3600
            if first_time_diff <= 72:
                if second_time_diff <= 72:
                    if hgb[0] > 10 and hgb[1] > 10 and hgb[1]-hgb[0] >= -1.5 and wbc_norm[0] == 'N' and plt_norm[0]=='N' and wbc_norm[1]=='N' and plt_norm[1]=='N':
                        self.inap_sno.append(r3['s_no'])
                        self.inap_orderno.append(r3['Order Number'])
                        #print('Inappropriate')
        except Exception:
            ax=0
            # print('Exception')
        return

    def tacro_analysis(self):
        pass

    def hcab_qhcv_analysis(self):
        pass

    def tsh_ft4_analysis(self):
        pass

    def inappropriate_testing(self):
        # functions for each of the 5 guidelines :
        # self.ical_abga_analysis()
        self.tacro_analysis()
        self.hcab_qhcv_analysis()
        self.tsh_ft4_analysis()
        self.cbc_analysis()
        return

    def run_analysis(self):
        print('Loading data')
        self.ldata, self.sdata, self.cdata = self.get_data()
        print('Loaded data and running demographic analysis')
        self.demographic_analysis()
        print('extracting date and time from datetime entries')
        self.time_extraction()
        print('Now finding inappropriate tests')
        self.inappropriate_testing()
