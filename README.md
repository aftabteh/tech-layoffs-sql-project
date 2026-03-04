Tech Layoffs Data Cleaning Project 

Project Overview 
Cleaned and prepared a raw layoffs dataset using MySQL to make it analysis-ready. The dataset contained duplicates, inconsistent text formatting, incorrect date formats, and missing values. 

Tools Used 
  MySQL
  Window Functions (ROW_NUMBER)
  CTEs
  Data Type Conversion 
  Joins 

Data Cleaning Process
  1. Created a staging table to preserve raw data
     - Preserved raw dataset integrity
     - Performed all transformations in a copied table
  2. Removed duplicate records using ROW_NUMBER()
     - Used ROW_NUMBER() with PARITION BY
     - Deleted rows where row_num > 1 
  3. Standardized text fields (company, industry, country)
     - Trimmed whitespace from company names
     - Standardized industry labels (Crypto variation -> "Crypto")
     - Fixed inconsistent country names
     - Converted date column from TEXT -> DATE
  4. Handled missing values
     - Replaced blank values with NULL
     - Used self-join to populate missing industry values
     - Removed rows with insufficient layoff data
  9. Finalized Clean Dataset
     - Removed helper columns
     - Delivered analysis-ready dataset

Outcome 
Delivered a clean dataset ready for exploratory data analysis. 
