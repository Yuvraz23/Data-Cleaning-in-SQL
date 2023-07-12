CREATE DATABASE house;

use house;

-- lets view our imported data
SELECT * FROM House.dbo.houses;

-- We can see that SaleDate is included with time (as 00:00:00:000) whic is not required so we are standardizing the SaleDate column

SELECT SaleDate,CONVERT(date,SaleDate) FROM House.dbo.houses;

UPDATE House.dbo.houses
SET SaleDate = CONVERT(date,SaleDate);

SELECT * FROM House.dbo.houses;

-- Since update method didnt work properly now we will alter the table.

ALTER TABLE Houses
ADD Std_SaleDate Date;

UPDATE houses
SET Std_SaleDate = CONVERT(date,SaleDate);



-- Now we will check if changes are made or not
SELECT * FROM houses;

-- Now we will drop SaleDate column as Standardization is done.

ALTER TABLE houses
DROP COLUMN SaleDate;


-- Now we will check for nulls in PropertyAdress column
SELECT PropertyAddress FROM houses WHERE PropertyAddress IS NULL;



-- WE will need to populate the null values
SELECT * FROM houses WHERE PropertyAddress	IS NULL;




SELECT * FROM houses ORDER BY ParcelID;
-- Now we can see that there are null PropertyAddress where ParcelID are same. So we will replace the null value with those where ParecelID matches

SELECT a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress 
FROM houses AS a JOIN houses AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;





-- Now we will populate the PropertyAddress Column
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM houses AS a JOIN houses AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;





-- Now we wil seprate Adress and city into two different columns
SELECT SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) - 1),
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
from houses;



-- Adding new to column to parse these information into it
ALTER TABLE Houses
ADD PropertySplitAddress VARCHAR(255);

UPDATE houses
SET PropertySplitAddress =  SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) - 1);

--

ALTER TABLE Houses
ADD PropertySplitCity VARCHAR(255);

UPDATE houses
SET PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));




-- We will drop PropertyAddress column as well
ALTER TABLE houses
DROP COLUMN PropertyAddress;



-- Simmilary we will split OwnerAddress column as well
SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM houses; 




-- Adding new to column to parse these information into it

ALTER TABLE Houses
ADD OwnerSplitAddress VARCHAR(255);

UPDATE houses
SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress,',','.'),3);

--
ALTER TABLE Houses
ADD OwnerSplitCity VARCHAR(255);

UPDATE houses
SET OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress,',','.'),2)

--
ALTER TABLE Houses
ADD OwnerSplitState VARCHAR(255);

UPDATE houses
SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress,',','.'),1);

-- Now we will drop OwnerAddress column

ALTER TABLE houses
DROP COLUMN OwnerAddress;



-- We will check SoldAsvacant column 

SELECT * FROM houses WHERE SoldAsVacant IS NULL; /* No Null Values */
-- checking the values of the column

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant) FROM houses
GROUP BY SoldAsVacant;




-- Now replacing N to No and Y to Yes 
SELECT SoldAsVacant, 
		CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END 
		FROM Houses;


-- Updating the column

UPDATE houses
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
;




-- Droping dupplicates from the dataset

WITH Dups_row AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY ParcelID,
								SalePrice,
								LegalReference,
								OwnerName,
								Std_SaleDate
					ORDER BY ParcelID) AS Row_num
FROM Houses
)
DELETE FROM Dups_row WHERE row_num > 1;



-- Checking SalePrice column
SELECT * FROM houses WHERE SalePrice IS NULL; /* No Null Values */

--Checking LegalReference Column
SELECT * FROM houses WHERE LegalReference IS NULL; /* No Null Values */



--Now we will drop unnecessary column 
SELECT * FROM Houses;

ALTER TABLE houses DROP COLUMN TaxDistrict;




--------------------------------------------------------------------------------------------------END--------------------------------------------------------------------------------------------------------------------------------
