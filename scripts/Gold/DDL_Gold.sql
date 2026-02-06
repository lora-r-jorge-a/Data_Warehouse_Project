
/*
	=============================================
	DDL Script: Create Gold Layer Views
	*********************************************

	Description:
		The following script creates views on Gold Schema.
		
		The views are created from clean data in Silver Layer.
		
		Views on Gold layer form a fact table and two dimensions 
		which are part of a star schema business-ready dataset in 
		the Datawarehouse.
		
		Gold Schema views can be queried for sales analytics and reporting.

	=============================================
*/

IF OBJECT_ID ('Gold.dim_customers', 'V') IS NOT NULL
	DROP VIEW Gold.dim_customers;
GO

CREATE OR ALTER VIEW Gold.dim_customers
	AS SELECT 
		ROW_NUMBER () OVER (ORDER BY cst_id) customer_key, --surrogate key
		cst_id customer_id,
		cst_key customer_number,
		cst_firstname first_name,
		cst_lastname last_name,
		la.cntry country,
		cst_marital_status marital_status,
		CASE 
			WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr  --CRM is the master table for gender value
			ELSE COALESCE(ca.gen, 'n/a') 
		END AS gender,
		ca.bdate birthdate,
		cst_create_date create_date
	FROM Silver.crm_cust_info ci
	LEFT JOIN Silver.erp_cust_az12 ca
	ON ci.cst_key = ca.cid
	LEFT JOIN Silver.erp_loc_a101 la
	ON ci.cst_key = la.cid;
GO

IF OBJECT_ID ('Gold.dim_products', 'V') IS NOT NULL
	DROP VIEW Gold.dim_products;
GO

CREATE VIEW Gold.dim_products AS
	SELECT 
		ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) product_key, --surrogate key
		pn.prd_id product_id,
		pn.prd_key product_number,
		pn.prd_nm product_name,
		pn.cat_id category_id,
		pc.cat category,
		pc.subcat subcategory,
		pc.maintenance,
		pn.prd_cost cost,
		pn.prd_line product_line,
		pn.prd_start_dt 'start_date'
	FROM Silver.crm_prd_info pn
	LEFT JOIN Silver.erp_px_cat_g1v2 pc
	ON pn.cat_id = pc.id
	WHERE prd_end_dt IS NULL; --Filter out historical data, only products currently active 
GO

IF OBJECT_ID ('Gold.fact_sales', 'V') IS NOT NULL
	DROP VIEW Gold.fact_sales;
GO

CREATE OR ALTER VIEW Gold.fact_sales AS 
	SELECT
		sd.sls_ord_num order_number,
		dp.product_key, --dimension key (surrogate) from dimension dim_products
		dc.customer_key, --dimension key (surrogate) from dimension dim_customers
		sd.sls_order_dt order_date,
		sd.sls_ship_dt shipping_date,
		sd.sls_due_dt due_date,
		sd.sls_sales sales_amount,
		sd.sls_quantity quantity,
		sd.sls_price price
	FROM Silver.crm_sales_details sd
	LEFT JOIN Gold.dim_products dp
	ON sd.sls_prd_key = dp.product_number
	LEFT JOIN Gold.dim_customers dc
	ON sd.sls_cust_id = dc.customer_id;
GO
