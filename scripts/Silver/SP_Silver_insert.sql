
/*
	===================================================
	DML Script: Loads Data Into Silver Schema tables
	***************************************************

	Description:
		The following script has DML statements in order to 
		load data with the required data transformations
		for Silver Layer.
		
		It standarizes data for relations between tables,
		employs data type that best fits with the expected 
		data on each column and performs expressions to 
		avoid unwanted spaces or inconsitent data.

	=============================================
*/

CREATE OR ALTER PROCEDURE Silver.load_silver AS
BEGIN
	DECLARE 
	@start_time DATETIME,
	@end_time DATETIME,
	@start_tot_time DATETIME,
	@end_tot_time DATETIME;
	BEGIN TRY
		SET @start_tot_time = GETDATE();
		SET @start_time = GETDATE();
		PRINT '=================================================='
		PRINT 'Loading Data Into Silver Schema Tables'
		PRINT '=================================================='
		PRINT'';
		PRINT'';
		PRINT'======================================'
		PRINT'LOADING CRM TABLES';
		PRINT'======================================'
		PRINT''
		PRINT''		
		PRINT '**************************************************'
		PRINT' >> TRUNCATING crm_cust_info'
		PRINT '**************************************************'
		TRUNCATE TABLE Silver.crm_cust_info;

		PRINT '**************************************************'
		PRINT' >> INSERTING ROWS INTO crm_cust_info'
		PRINT '**************************************************'

		INSERT INTO Silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)
		SELECT 
			cst_id,
			cst_key,
			TRIM(cst_firstname) cst_firstname,
			TRIM(cst_lastname) cst_lastname,
			CASE
				WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				ELSE 'n/a'
			END cst_marital_status,
			CASE
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				ELSE 'n/a'
			END cst_gndr,
			cst_create_date
		FROM (
			SELECT *,
			ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) latest_date
			FROM Bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
		) q
		WHERE latest_date = 1;
		PRINT'';
		PRINT'';
		SET @end_time = GETDATE();
		PRINT'======================================'
		PRINT 'Successful data load into crm_cust_info. Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR);
		PRINT'======================================'
		PRINT''
		PRINT''
		
		SET @start_time = GETDATE();
		PRINT '**************************************************'
		PRINT' >> TRUNCATING crm_prd_info'
		PRINT '**************************************************'
		TRUNCATE TABLE Silver.crm_prd_info;
		PRINT '**************************************************'
		PRINT' >> INSERTING ROWS INTO crm_prd_info'
		PRINT '**************************************************'
		INSERT INTO Silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT
		prd_id,
		REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') cat_id,
		SUBSTRING(prd_key, 7, LEN(prd_key)) prd_key,
		prd_nm,
		COALESCE(prd_cost, 0) prd_cost,
		CASE UPPER(TRIM(prd_line))
			WHEN 'M' THEN 'Mountain'
			WHEN 'R' THEN 'Road'
			WHEN 'S' THEN 'Other Sales'
			WHEN 'T' THEN 'Touring'
			ELSE 'n/a'
		END prd_line,
		prd_start_dt,
		LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_id,prd_key,prd_start_dt) - 1 AS end_date_test
		FROM Bronze.crm_prd_info;
		PRINT'';
		PRINT'';
		SET @end_time = GETDATE();
		PRINT'======================================'
		PRINT 'Successful data load into crm_prd_info. Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR);
		PRINT'======================================'
		PRINT''
		PRINT''

		SET @start_time = GETDATE();
		PRINT '**************************************************'
		PRINT' >> TRUNCATING crm_sales_details'
		PRINT '**************************************************'
		TRUNCATE TABLE Silver.crm_sales_details;
		PRINT '**************************************************'
		PRINT' >> INSERTING ROWS INTO crm_sales_details'
		PRINT '**************************************************'
		INSERT INTO Silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT 
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		CASE 
			WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_order_dt AS NVARCHAR) AS DATE)
		END sls_order_dt,
		CASE 
			WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_ship_dt AS NVARCHAR) AS DATE)
		END sls_ship_dt,
		CASE 
			WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_due_dt AS NVARCHAR) AS DATE)
		END sls_due_dt,
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
		FROM Bronze.crm_sales_details;
		PRINT'';
		PRINT'';
		SET @end_time = GETDATE();
		PRINT'======================================'
		PRINT 'Successful data load into crm_sales_details. Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR);
		PRINT'======================================'
		PRINT''
		PRINT''


		PRINT '**************************************************'
		PRINT'LOADING ERP TABLES';
		PRINT '**************************************************'
		PRINT'';
		PRINT'';
		
		SET @start_time = GETDATE();
		PRINT '**************************************************'
		PRINT' >> TRUNCATING erp_cust_az12'
		PRINT '**************************************************'
		TRUNCATE TABLE Silver.erp_cust_az12;
		PRINT '**************************************************'
		PRINT' >> INSERTING ROWS INTO erp_cust_az12'
		PRINT '**************************************************'
		INSERT INTO Silver.erp_cust_az12 (
			cid,
			bdate,
			gen
		)
		SELECT 
		CASE 
			WHEN cid LIKE 'NAS%'
			THEN SUBSTRING(cid, 4, LEN(cid))
			ELSE cid
		END cid,
		CASE WHEN bdate > GETDATE() THEN NULL
			ELSE bdate
		END bdate,
		CASE 
			WHEN UPPER(TRIM(gen)) = 'F' THEN 'Female'
			WHEN UPPER(TRIM(gen)) = 'M' THEN 'Male'
			WHEN UPPER(TRIM(gen)) IS NULL OR UPPER(TRIM(gen)) = '' THEN 'n/a'
			ELSE UPPER(TRIM(gen))
		END gen
		FROM Bronze.erp_cust_az12;
		PRINT'';
		PRINT'';
		SET @end_time = GETDATE();
		PRINT'======================================'
		PRINT 'Successful data load into erp_cust_az12. Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR);
		PRINT'======================================'
		PRINT''
		PRINT''

		SET @start_time = GETDATE();
		PRINT '**************************************************'
		PRINT' >> TRUNCATING erp_loc_a101'
		PRINT '**************************************************'
		TRUNCATE TABLE Silver.erp_loc_a101;
		PRINT '**************************************************'
		PRINT' >> INSERTING ROWS INTO erp_loc_a101'
		PRINT '**************************************************'
		INSERT INTO Silver.erp_loc_a101(
			cid,
			cntry
		)
		SELECT 
		REPLACE(cid,'-','') cid,
		CASE WHEN TRIM(cntry) IN ('USA', 'United States', 'US') THEN 'United States'
			WHEN TRIM(cntry) IN ('DE', 'Germany') THEN 'Germany'
			WHEN TRIM(cntry) = '' OR UPPER(TRIM(cntry)) IS NULL THEN 'n/a'
			ELSE TRIM(cntry)
		END cntry
		FROM Bronze.erp_loc_a101;
		PRINT'';
		PRINT'';
		SET @end_time = GETDATE();
		PRINT'======================================'
		PRINT 'Successful data load into erp_loc_a101. Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR);
		PRINT'======================================'
		PRINT''
		PRINT''

		SET @start_time = GETDATE();
		PRINT '**************************************************'
		PRINT' >> TRUNCATING erp_px_cat_g1v2'
		PRINT '**************************************************'
		TRUNCATE TABLE Silver.erp_px_cat_g1v2;
		PRINT '**************************************************'
		PRINT' >> INSERTING ROWS INTO erp_px_cat_g1v2'
		PRINT '**************************************************'
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
		PRINT'';
		PRINT'';
		SET @end_time = GETDATE();
		SET @end_tot_time = GETDATE();		
		PRINT'======================================'
		PRINT 'Successful data load into erp_px_cat_g1v2. Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR);
		PRINT'======================================'
		PRINT''
		PRINT''
		PRINT'**************************************'
		PRINT' >> Loading data action successfully.'
		PRINT' >> Total time: ' + CAST(DATEDIFF(second, @start_tot_time, @end_tot_time) AS NVARCHAR);
		PRINT'**************************************'

	END TRY
	BEGIN CATCH
		PRINT'======================================'
		PRINT'ERROR WHILE LOADING DATA INTO SILVER LAYER'
		PRINT'======================================'
		PRINT' >> ERROR MESSAGE: ' + ERROR_MESSAGE();
		PRINT' >> ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT' >> ERROR STATE: ' + CAST(ERROR_STATE() AS NVARCHAR);
	END CATCH
END
