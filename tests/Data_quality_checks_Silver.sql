
/*
	===================================================
	Data Quality Script: Validates quality of data to be inserted into Silver Schema tables
	***************************************************

	Description:
		This script performs checks on data loaded into Silver Layer tables.
		Changes will be performed to fullfill the ETL requirements.
		
		It standarizes data for relations between tables,
		employs data type that best fits with the expected 
		data on each column and performs expressions to 
		avoid unwanted spaces or inconsitent data.
		
		It runs several queries for the following scenarios:
			-Null or duplicate Primary Key values 
			-Unwanted spaces in columns with strings
			-Standarize data and consistency
			-Invalid dates and orders
			-Consistency of data among tables and common columns
			
		Run this script to confirm data quality in Silver layer tables

	=============================================
*/

--================= crm_prd_info =================

--To find the latest date of those duplicated prd__id values
-- making sure the latest date regarding prd_id column is present in Silver layer
SELECT prd_id,
COUNT(*)
FROM Silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

--Same check for prd_key
SELECT prd_key,
COUNT(*)
FROM Silver.crm_prd_info
GROUP BY prd_key
HAVING COUNT(*) > 1 OR prd_key IS NULL;

--Query to check for undesired spaces on production line and  columns on Silver Layer.
--After INSERT, expectation is 0 rows found

SELECT *
FROM Silver.crm_prd_info
WHERE cat_id != TRIM(cat_id);

SELECT *
FROM Silver.crm_prd_info
WHERE prd_key != TRIM(prd_key);

SELECT *
FROM Silver.crm_prd_info
WHERE prd_line != TRIM(prd_line);

--Per Data Integration Diagram, crm_prd_info (prd_key) needs to comply
--with the format inherited from erp_px_cat_g1v2 (id) table
--which uses an underscore (_) as separator.
--prd_key column in crm_prd_info will be splitted into two columns,
--cat_id (first 5 characters) and prd_key (rest of characters)
--Additionally, checks for existing cat_id in crm_prd_info but not present
--in erp_px_cat_g1v2
SELECT REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') cat_id
FROM Bronze.crm_prd_info
WHERE REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') NOT IN(
SELECT DISTINCT id 
FROM Bronze.erp_px_cat_g1v2);

--Since prd_end_dt is less than prd_start_dt
--the following query fix the logic discrepancy.
--A small data set was selected to test the fix
--Note: prd_end_dt could be null if the product is still active

SELECT 
prd_id,
prd_key,
prd_nm,
prd_start_dt,
prd_end_dt,
LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_id,prd_key,prd_start_dt) - 1 AS end_date_test
FROM Bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509');

--================= crm_sales_info =================

--Check data in crm tables and common tables ammong them

select TOP 5 * from Bronze.crm_sales_details;

select TOP 5 * from Bronze.crm_cust_info;

select TOP 5 * from Bronze.crm_prd_info;

--Check for existing sls_prd_key and sls_cust_id in crm_sales_details
--but absent in crm_prd_info (prd_key) and crm_cust_info (cst_id)

SELECT sls_prd_key
FROM Silver.crm_sales_details
WHERE sls_prd_key NOT IN (
	SELECT prd_key
	FROM Silver.crm_prd_info
);

SELECT sls_cust_id
FROM Silver.crm_sales_details
WHERE sls_cust_id NOT IN (
	SELECT cst_id
	FROM Silver.crm_cust_info
);

--Check if sls_ship_dt and sls_due_dt is greater than sls_order_dt
-- and sls_due_dt is greater than sls_ship_dt

SELECT 
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt
FROM Silver.crm_sales_details
WHERE sls_ship_dt < sls_order_dt;

SELECT 
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt
FROM Silver.crm_sales_details
WHERE sls_due_dt < sls_order_dt;

SELECT 
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt
FROM Silver.crm_sales_details
WHERE sls_due_dt < sls_ship_dt;

--Check for null values

SELECT sls_price,
COUNT(*)
FROM Silver.crm_sales_details
GROUP BY sls_price
HAVING sls_price IS NULL;

SELECT * FROM Silver.crm_sales_details
WHERE sls_price IS NULL;

SELECT sls_sales,
COUNT(*)
FROM Silver.crm_sales_details
GROUP BY sls_sales
HAVING sls_sales IS NULL
OR sls_sales < 0;

SELECT * FROM Silver.crm_sales_details
WHERE sls_sales IS NULL;

SELECT 
sls_sales as sls_sales_inc,
sls_price as sls_price_inc,
CASE 
	WHEN (sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != ABS(sls_quantity) * ABS(sls_price)) 
	THEN ABS(sls_quantity) * ABS(sls_price)
	ELSE sls_sales
END sls_sales,
sls_quantity,
CASE 
	WHEN (sls_price <= 0 OR sls_price IS NULL)
	THEN ABS(sls_sales) / (NULLIF(sls_quantity, 0))
	ELSE sls_price
END sls_price
FROM Silver.crm_sales_details
WHERE sls_sales != (sls_quantity * sls_price)
OR sls_sales <= 0 OR sls_sales IS NULL
OR sls_quantity <= 0 OR sls_quantity IS NULL
OR sls_price <= 0 OR sls_price IS NULL
ORDER BY sls_sales, sls_quantity, sls_price;

--Check for undesired values in dates which have INT data format
--Column data type will be changed to DATE since dates are stored in sls_order_dt column
SELECT
CASE 
	WHEN sls_order_dt = 0 THEN NULL
	ELSE sls_order_dt
END sls_order_dt
FROM Bronze.crm_sales_details
WHERE sls_order_dt > 20500000
OR sls_order_dt < 0
OR LEN(sls_order_dt) != 8;

SELECT
CASE 
	WHEN sls_due_dt = 0 THEN NULL
	ELSE CAST(CAST(sls_due_dt AS NVARCHAR) AS DATE)
END sls_due_dt
FROM Bronze.crm_sales_details
WHERE sls_due_dt > 20500000
OR sls_due_dt < 19000000
OR LEN(sls_due_dt) != 8;

SELECT sls_quantity,
COUNT(*)
FROM Bronze.crm_sales_details
GROUP BY sls_quantity
HAVING sls_quantity IS NULL;

--================= erp_cust_az12 =================

--Check for incositencies in cid
--Found diferent prefix compared to crm_cust_info (cst_key) on Bronze layer
--Estandarized Silver.erp_cust_az12 (cid) and Silver.crm_cust_info(cst_key)
SELECT 
cid old_cid,
CASE 
	WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	ELSE cid
END AS cid, 
bdate, 
gen 
FROM Silver.erp_cust_az12
WHERE CASE 
	WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	ELSE cid
END NOT IN (
SELECT DISTINCT cst_key FROM Silver.crm_cust_info);

--Check for inconsistencies in birth dates, too old dates or in the future
SELECT bdate
FROM Silver.erp_cust_az12
WHERE bdate < CAST('1930-01-01' AS DATE) 
OR bdate > GETDATE() ;

SELECT bdate old_bdate,
CASE WHEN bdate > GETDATE() THEN NULL
	ELSE bdate
END bdate
FROM Silver.erp_cust_az12
WHERE bdate < CAST('1930-01-01' AS DATE) 
OR bdate > GETDATE() ORDER BY bdate;

--Check for inconsistencies in gender
SELECT DISTINCT gen
FROM Silver.erp_cust_az12;

SELECT gen
FROM Bronze.erp_cust_az12
WHERE gen != TRIM(gen);

SELECT TRIM(gen)
FROM Bronze.erp_cust_az12
WHERE gen LIKE ' ';

select * from Bronze.erp_cust_az12 where gen is null;

SELECT DISTINCT q.gen
FROM (
SELECT 
gen old_gen,
CASE 
	WHEN gen = 'F' THEN 'Female'
	WHEN gen = 'M' THEN 'Male'
	WHEN gen IS NULL OR TRIM(gen) = '' THEN 'n/a'
	ELSE gen
END gen
FROM Bronze.erp_cust_az12) q;

--================= erp_loc_a101 =================

--Check for discrepancy in erp_loc_a101(cid) and crm_cust_info(cst_key)
SELECT DISTINCT SUBSTRING(cid,1,4) 
FROM Bronze.erp_loc_a101;

SELECT REPLACE(cid,'-','') cid
FROM Bronze.erp_loc_a101
WHERE REPLACE(cid,'-','') NOT IN (
SELECT DISTINCT cst_key FROM Bronze.crm_cust_info);

--Check for inconsistencies in cntry
SELECT DISTINCT cntry
FROM Silver.erp_loc_a101;

SELECT cntry
FROM Bronze.erp_loc_a101
WHERE cntry != TRIM(cntry);

SELECT DISTINCT
CASE WHEN TRIM(cntry) IN ('USA', 'United States', 'US') THEN 'United States'
	WHEN TRIM(cntry) IN ('DE', 'Germany') THEN 'Germany'
	WHEN TRIM(cntry) = '' OR UPPER(TRIM(cntry)) IS NULL THEN 'n/a'
	ELSE TRIM(cntry)
END cntry
FROM Bronze.erp_loc_a101;

--================= erp_px_cat_g1v2 =================

--Check consistency in id
SELECT id
FROM Bronze.erp_px_cat_g1v2
WHERE id NOT IN (
SELECT DISTINCT prd_key FROM Silver.crm_prd_info);

--Check for undesired spaces
SELECT *
FROM Bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);

--Load into erp_px_cat_g1v2
INSERT INTO Silver.erp_px_cat_g1v2(
	id,
	cat,
	subcat,
	maintenance
)
SELECT
	id,
	cat,
	subcat,
	maintenance
FROM Bronze.erp_px_cat_g1v2;
