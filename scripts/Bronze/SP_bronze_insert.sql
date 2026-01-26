
/*
	=============================================
	Stored Procedure Script: Insert data from source system into Bronze Layer tables
	*********************************************

	Description:
		The following script truncates any existing data in Bronze Layer tables
		in order to proceed with a BULK INSERT of data from source system (CSV files)
		without performing any data transformation.
		
		It shows user if load was successful, error message and also measures load performance.
		
		This stored procedure does not need any input parameter and it does not return any value.
		
		To call this procedure:
		
		EXEC Bronze.load_bronze;

	=============================================
*/

CREATE OR ALTER PROCEDURE Bronze.load_bronze AS
BEGIN
	DECLARE 
	@start_time DATETIME,
	@end_time DATETIME,
	@start_tot_time DATETIME,
	@end_tot_time DATETIME;
	BEGIN TRY
		SET @start_tot_time = GETDATE();
		SET @start_time = GETDATE();
		PRINT'======================================';
		PRINT'LOADING CRM TABLES';
		PRINT'======================================';
		PRINT'';
		PRINT'';
		PRINT'======================================';
		PRINT'>> TRUNCATING crm_cust_info';
		PRINT'======================================';
		TRUNCATE TABLE Bronze.crm_cust_info;
		PRINT'======================================';
		PRINT'>> INSERTING ROWS INTO crm_cust_info';
		PRINT'======================================';
		BULK INSERT Bronze.crm_cust_info
		FROM 'Z:\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ERRORFILE = 'Z:\sql-data-warehouse-project-main\datasets\source_crm\cust_info_error.txt',
			TABLOCK
		);
		PRINT'';
		PRINT'';
		SET @end_time = GETDATE();
		PRINT'======================================';
		PRINT 'Successful data load into crm_cust_info. Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR);
		PRINT'======================================';
		PRINT'';
		PRINT'';

		SET @start_time = GETDATE();
		PRINT'======================================';
		PRINT'>> TRUNCATING crm_prd_info';
		PRINT'======================================';
		TRUNCATE TABLE Bronze.crm_prd_info;
		PRINT'======================================';
		PRINT'>> INSERTING ROWS INTO crm_prd_info';
		PRINT'======================================';
		BULK INSERT Bronze.crm_prd_info
		FROM 'Z:\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ERRORFILE = 'Z:\sql-data-warehouse-project-main\datasets\source_crm\crm_prd_info_error.txt',
			TABLOCK
		);
		PRINT'';
		PRINT'';
		SET @end_time = GETDATE();
		PRINT'======================================';
		PRINT 'Successful data load into crm_prd_info. Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR);
		PRINT'======================================';
		PRINT'';
		PRINT'';

		SET @start_time = GETDATE();
		PRINT'======================================';
		PRINT'>> TRUNCATING crm_sales_details';
		PRINT'======================================';
		TRUNCATE TABLE Bronze.crm_sales_details;
		PRINT'======================================';
		PRINT'>> INSERTING ROWS INTO crm_sales_details';
		PRINT'======================================';
		BULK INSERT Bronze.crm_sales_details
		FROM 'Z:\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ERRORFILE = 'Z:\sql-data-warehouse-project-main\datasets\source_crm\crm_sales_details_error.txt',
			TABLOCK
		);
		PRINT'';
		PRINT'';
		SET @end_time = GETDATE();
		PRINT'======================================';
		PRINT 'Successful data load into crm_sales_details. Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR);
		PRINT'======================================';
		PRINT'';
		PRINT'';
		PRINT'======================================';
		PRINT'LOADING ERP TABLES';
		PRINT'======================================';
		PRINT'';
		PRINT'';

		SET @start_time = GETDATE();
		PRINT'======================================';
		PRINT'>> TRUNCATING crm_sales_details';
		PRINT'======================================';
		TRUNCATE TABLE Bronze.erp_cust_az12;
		PRINT'======================================';
		PRINT'>> INSERTING ROWS INTO erp_cust_az12';
		PRINT'======================================';
		TRUNCATE TABLE Bronze.erp_cust_az12;
		BULK INSERT Bronze.erp_cust_az12
		FROM 'Z:\sql-data-warehouse-project-main\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ERRORFILE = 'Z:\sql-data-warehouse-project-main\datasets\source_erp\cust_az12_error.txt',
			TABLOCK
		);
		PRINT'';
		PRINT'';
		SET @end_time = GETDATE();
		PRINT'======================================';
		PRINT 'Successful data load into erp_cust_az12. Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR);
		PRINT'======================================';
		PRINT'';
		PRINT'';

		SET @start_time = GETDATE();
		PRINT'======================================';
		PRINT'>> TRUNCATING erp_loc_a101';
		PRINT'======================================';
		TRUNCATE TABLE Bronze.erp_loc_a101;
		PRINT'======================================';
		PRINT'>> INSERTING ROWS INTO erp_loc_a101';
		PRINT'======================================';
		BULK INSERT Bronze.erp_loc_a101
		FROM 'Z:\sql-data-warehouse-project-main\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ERRORFILE = 'Z:\sql-data-warehouse-project-main\datasets\source_erp\loc_a101_error.txt',
			TABLOCK
		);
		PRINT'';
		PRINT'';
		SET @end_time = GETDATE();
		PRINT'======================================';
		PRINT 'Successful data load into erp_loc_a101. Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR);
		PRINT'======================================';
		PRINT'';
		PRINT'';

		SET @start_time = GETDATE();
		PRINT'======================================';
		PRINT'>> TRUNCATING erp_px_cat_g1v2';
		PRINT'======================================';
		TRUNCATE TABLE Bronze.erp_px_cat_g1v2;
		PRINT'======================================';
		PRINT'>> INSERTING ROWS INTO erp_px_cat_g1v2';
		PRINT'======================================';
		BULK INSERT Bronze.erp_px_cat_g1v2
		FROM 'Z:\sql-data-warehouse-project-main\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ERRORFILE = 'Z:\sql-data-warehouse-project-main\datasets\source_erp\px_cat_g1v2_error.txt',
			TABLOCK
		);
		PRINT'';
		PRINT'';
		SET @end_time = GETDATE();
		PRINT'======================================';
		PRINT 'Successful data load into erp_px_cat_g1v2. Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR);
		PRINT'======================================';

		PRINT'**************************************';
		PRINT'>> Loading data action successfully.';
		PRINT'>> Total time: ' + CAST(DATEDIFF(second, @start_tot_time, @end_tot_time) AS NVARCHAR);
		PRINT'**************************************';

	END TRY
	BEGIN CATCH
		PRINT'======================================';
		PRINT'ERROR WHILE LOADING DATA INTO BRONZE LAYER';
		PRINT'======================================';
		PRINT'>> ERROR MESSAGE: ' + ERROR_MESSAGE();
		PRINT'>> ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT'>> ERROR STATE: ' + CAST(ERROR_STATE() AS NVARCHAR);
	END CATCH
END
