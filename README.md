2WheelsInc
==========

To recreate the summary report for Geographical Penetration and Product Mix by Postal Code for US Territories perform the following steps:

1)  Create a view in the Data Warehouse and OLTP databases by executing:
- AdvWorksOLTP_vPostalCodePenetrationAndProductMix.sql
- AdvWorksDW_vPostalCodePenetrationAndProductMix.sql

2)  To execute the summary report in the Data Warehouse database, run the SQL in the file:
- AdvWorksDW_query.sql

3)  To execute the summary report in the OLTP database, run the SQL in the file:
- AdvWorksOLTP_query.sql
