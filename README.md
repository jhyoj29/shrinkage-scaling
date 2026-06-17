This Dataset and Analysis Code
This dataset and analysis code were used in the paper "Scaling patterns of resilience and collapse in population-declining cities."

[0_DATA] Dataset
- "dataset.xlsx": Metadata and comprehensive compiled data of variables used in the paper
- DataList: Description and sources of variables collected from 6 countries
- Organized by cleaned data sheets for each variable

- Korea (10 variables): All data(GRDP, Wholesale & Retail establishments, Food & Accommodation establishments, Employees, High-tech industry, University graduates, Elementary school students, Hospital beds, Human health establishments, Culture & Entertainment establishments) were obtained from the Korean Statistical Information Service (KOSIS, https://kosis.kr/index/index.do) 
- Japan (8 variables): Data(Wholesale & Retail establishments, Food & Accommodation establishments, Employees, High-tech industry, University graduates, Elementary school students, Hospital beds, Human health establishments) were collected from the Statistics Bureau of Japan (e-stat, https://www.e-stat.go.jp/en/)
- Thailand (5 variables): Data(GRDP, Employees, Hospital beds, Human health establishments, Culture & Entertainment establishments) were collected from the National Statistics Office, NSO(https://www.nso.go.th/nsoweb/index?set_lang=en#gsc.tab=0)
- Hong Kong (5 variables): Data(Wholesale & Retail establishments, Food & Accommodation establishments, High-tech industry, Hospital beds, Human health establishments, Culture & Entertainment establishments) were obtained from the Census and Statistics Department(https://www.censtatd.gov.hk/en/)
- Taiwan (5 variables): Data(Wholesale & Retail establishments, Food & Accommodation establishments, High-tech industry, University graduates, Human health establishments) were collected from the DGBAS Statistical Database(DGBAS, https://eng.stat.gov.tw/cl.aspx?n=4015)
- Vietnam (3 variables): Data(Employees, University graduates, Elementary school students) were collected from the National Statistics Office(https://www.nso.gov.vn/en/homepage/)

[1_Cross-section_Scaling] Cross-sectional Scaling Analysis for 2010 and 2020
- Data: Individual CSV files by variable used in the research, starting with 'Scaling_XXX.csv'
- Code: Stata-based cross-sectional scaling analysis code (do-files) for population and each variable

[2_Pannel_Scaling] Panel Scaling Analysis
- Data: 'Scaling_Pannel.csv', comprehensive compiled data for panel analysis
- Code: Stata-based random effects panel scaling analysis code (do-files) for population and each variable
