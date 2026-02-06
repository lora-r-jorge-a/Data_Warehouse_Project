
/*
	===================================================
	Data Quality Script: Validates quality of data to be inserted into Silver Schema tables
	***************************************************

	Description:
		This script performs checks on data loaded into Gold Layer views.	
	
		Views will be created to fullfill the sales analytics and repoting needs.
		
		It combines tables from Silver layer to create views which display
		full information regarding customers, products and sales.
		
		It runs several queries for the following scenarios:
			-Null or duplicate Primary Key values 
			-Standarize data and consistency
			-Integration of data among tables and common columns
			
		Run this script to confirm data quality in Gold Layer views

	=============================================
*/

--================= customers dimension =================
SELECT DISTINCT
ci.cst_gndr,
ca.gen
FROM Silver.crm_cust_info ci
LEFT JOIN Silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN Silver.erp_loc_a101 la
ON ci.cst_key = la.cid
ORDER BY 1, 2 DESC;

SELECT DISTINCT
ci.cst_gndr,
ca.gen,
CASE 
	WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr  --CRM is the master table for gender value
	ELSE COALESCE(ca.gen, 'n/a') 
END new_gen
FROM Silver.crm_cust_info ci
LEFT JOIN Silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN Silver.erp_loc_a101 la
ON ci.cst_key = la.cid
ORDER BY 1, 2 DESC;

SELECT TOP 30 * FROM Bronze.crm_cust_info;
SELECT TOP 30 * FROM Bronze.erp_cust_az12;
SELECT * FROM Silver.erp_loc_a101;

--================= products dimension =================
SELECT *
FROM Silver.crm_prd_info;

SELECT *
FROM Silver.erp_px_cat_g1v2;

SELECT q.prd_key,
COUNT(*)
FROM (
	SELECT 
	pn.prd_id,
	pn.cat_id,
	pn.prd_key,
	pn.prd_nm,
	pn.prd_cost,
	pn.prd_line,
	pn.prd_start_dt,
	pn.prd_end_dt,
	pc.id,
	pc.cat,
	pc.subcat,
	pc.maintenance
	FROM Silver.crm_prd_info pn
	LEFT JOIN Silver.erp_px_cat_g1v2 pc
	ON pn.cat_id = pc.id
	WHERE pn.prd_end_dt IS NULL
) q
GROUP BY q.prd_key
HAVING COUNT(*) > 1;

--================= fact sales (fact table) =================
--No further checks for fact table

--Gold layer data quality checks
SELECT * FROM Gold.fact_sales;
SELECT * FROM Gold.dim_products;
SELECT * FROM Gold.dim_customers;

--Gold layer fact table and dimensions integration check
SELECT *
FROM Gold.fact_sales fs
LEFT JOIN Gold.dim_customers dc
ON fs.customer_key = dc.customer_key
LEFT JOIN Gold.dim_products dp
ON fs.product_key = dp.product_key
WHERE dc.customer_key IS NULL
OR dp.product_key IS NULL;
