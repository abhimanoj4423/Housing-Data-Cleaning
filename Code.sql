SELECT * 
FROM cleaning.book1;

#Standardize the date format
-- SalesDate is Given in different columns as Month,Day and Year

SELECT *,CAST(CONCAT(Year,"-",Month,"-",Day) AS Date) AS SalesDate 
FROM cleaning.book1;

-- Adding and updating a new column in the existing table

ALTER TABLE cleaning.book1 
  ADD COLUMN Sale_Date DATE AFTER PropertyAddress;               

UPDATE cleaning.book1
SET Sale_Date= CAST(CONCAT(Year,"-",Month,"-",Day) AS Date) 

#Populate the property address data

SELECT Count(*)
FROM cleaning.book1 
WHERE PropertyAddress is null;                -- 29 NULL values are present in PropertyAddress Column

-- Finding reference points using similar ParcelID for same PropertyAddres

SELECT A.ParcelID,A.PropertyAddress,B.ParcelID,B.PropertyAddress,IFNULL(A.PropertyAddress,B.PropertyAddress)
FROM cleaning.book1 AS A
INNER JOIN cleaning.book1 AS B                 -- Self Joining the table
ON A.ParcelID = B.ParcelID                     -- Finding common parcelID for same Address 
AND A.UniqueID != B.UniqueID                   -- To eliminate Duplicates as UniqueID is UNIQUE for each sale
Where A.PropertyAddress is null;

-- Updating the Table       

UPDATE cleaning.book1 AS A
INNER JOIN cleaning.book1 AS B  
ON A.ParcelID = B.ParcelID                     
AND A.UniqueID != B.UniqueID
SET A.PropertyAddress = IFNULL(A.PropertyAddress,B.PropertyAddress)
Where A.PropertyAddress is null;


#Breaking out PropertyAddress into Different columns (Address and City)

SELECT SUBSTRING(PropertyAddress, 1 ,LOCATE(",",PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,LOCATE(",",PropertyAddress)+1,LENGTH(PropertyAddress)) AS City
FROM cleaning.book1 ;

ALTER TABLE cleaning.book1 
  ADD COLUMN Address VARCHAR(255) AFTER LandUse;               

UPDATE cleaning.book1
SET Address=SUBSTRING(PropertyAddress, 1 ,LOCATE(",",PropertyAddress)-1);

ALTER TABLE cleaning.book1 
  ADD COLUMN City VARCHAR(255) AFTER Address;               

UPDATE cleaning.book1 
SET City= SUBSTRING(PropertyAddress,LOCATE(",",PropertyAddress)+1,LENGTH(PropertyAddress));

#Breaking out Owneraddress into Different columns (Address,City and State)

SELECT OwnerAddress, SUBSTRING(OwnerAddress, 1 ,LOCATE(",",OwnerAddress)-1) AS Owner_Address,
SUBSTRING(OwnerAddress, LOCATE(",",OwnerAddress)+1,LENGTH(OwnerAddress)-(LOCATE(",",OwnerAddress)+4)) AS City,
SUBSTRING(OwnerAddress,LENGTH(OwnerAddress)-2,3) AS State
FROM cleaning.book1; 

ALTER TABLE cleaning.book1
ADD COLUMN Owner_Address VARCHAR(255) AFTER OwnerName;               

UPDATE cleaning.book1
SET Owner_Address= SUBSTRING(OwnerAddress, 1 ,LOCATE(",",OwnerAddress)-1);

ALTER TABLE cleaning.book1
ADD COLUMN OwnerCity VARCHAR(255) AFTER Owner_Address;           

UPDATE cleaning.book1
SET OwnerCity = SUBSTRING(OwnerAddress, LOCATE(",",OwnerAddress)+1,LENGTH(OwnerAddress)-(LOCATE(",",OwnerAddress)+4))

ALTER TABLE cleaning.book1
ADD COLUMN State VARCHAR(255) AFTER OwnerCity;              

UPDATE cleaning.book1
SET State = SUBSTRING(OwnerAddress,LENGTH(OwnerAddress)-2,3)

# Deleting Editted and Unwanted columns

ALTER TABLE cleaning.book1
DROP COLUMN PropertyAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN OwnerAddress,
DROP COLUMN Year,
DROP COLUMN Month,
DROP COLUMN Day;


# Removing duplicates using the UniqueId column

Select DISTINCT UniqueID
FROM cleaning.book1;

WITH BOOK3
AS (
SELECT *,ROW_NUMBER() OVER( 
PARTITION BY UniqueID,LegalReference
ORDER BY UniqueID) AS ROW_NUM
   FROM cleaning.book1  )
   SELECT *
   FROM BOOK3
   WHERE ROW_NUM > 1;
   