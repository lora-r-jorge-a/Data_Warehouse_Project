# Data_Warehouse_Project

This is a Data Warehouse project using Medallion architecture as data model, ELT and a SQL Server for a analytics.

The project requires building a Data Warehouse intended to be used by data analysts to facilitate data-driven decisions.

The making of Data Warehouse project was under data engineering industry best practices.


### Building the Data Warehouse (Data Engineering)

#### Objective
Create a data warehouse which runs on SQL Server to gather business information regarding sales data in order to provide an environment for decision-making based on analytics.

#### Specifications
- **Data Sources**: Import data from two source systems (ERP and CRM) provided as CSV files.
- **Data Quality**: Cleanse and resolve data quality issues prior to analysis.
- **Integration**: Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope**: Focus on the latest dataset only; historization of data is not required.
- **Documentation**: Provide clear documentation of the data model to support both business stakeholders and analytics teams.

### BI: Analytics & Reporting (Data Analysis)

#### Objective
Develop SQL-based analytics to deliver detailed insights into:
- **Customer Behavior**
- **Product Performance**
- **Sales Trends**

These insights empower stakeholders with key business metrics, enabling strategic decision-making.  

## 📊 Datasets
On a real-world, datasets wouldn't be available unless working with public data. 
Since this is only for demonstration purposes the project includes 6 CSV files used to populate the Data Warehouse:
* `sales_details.csv`: Historical transaction records from CRM system.
* `prd_info.csv`: Product catalog and categories from CRM system.
* `cust_info.csv`: Customers information from CRM system.
* `CUST_AZ12.csv`: Customer information from ERP system.
* `LOC_A101.csv`: Customer country from ERP system.
* `PX_CAT_G1V2.csv`: Product catalog and categories from ERP system.

---

## 🏗️ Credits & Attribution

This project is a replication and personal implementation based on the **SQL Data Warehouse Project** originally created by **Baraa Khatib Salkini** (Data With Baraa).

* **Original Project:** [SQL Data Warehouse Project](https://github.com/DataWithBaraa/sql-data-warehouse-project)
* **Original Author:** [Baraa Khatib Salkini](https://linkedin.com/in/baraa-khatib-salkini) | [Data With Baraa](https://www.datawithbaraa.com)
* **Original License:** [MIT License](https://github.com/DataWithBaraa/sql-data-warehouse-project/blob/main/LICENSE)

I would like to express my gratitude to Baraa for his high-quality educational content and for sharing the foundations of this Data Warehouse architecture. 
You can find his tutorials and more data-related content on his [YouTube Channel](https://www.youtube.com/@DataWithBaraa).
