/*

Data Cleaning in SQL

*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------

-- Update SaleDate Format

SELECT SaleDate
FROM PortfolioProject.dbo.NashvilleHousing

SELECT SaleDate, CONVERT(Date, SaleDate)	
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD SaleDateConverted Date;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL

---- Make use of the ParcelID to find the missing PropertyAddress.
----
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
ORDER BY ParcelID

---- IF a.ParcelID = b.ParcelID
----    AND a.UniqudID <> b.UniqueID
---- THEN a.PropertyAddress = b.PropertyAddress
----
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

---- Update the missing PropertyAddress 
---- 
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

---- Check the results
----
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------

-- Split Address into separate columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT PropertyAddress, 
	   SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
	   SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NashvilleHousing

---- Add the split address to the table :
----
---- PropertyAddressSplit
---- PropertyCitySplit
----
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertyAddressSplit NVARCHAR(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertyCitySplit NVARCHAR(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertyCitySplit = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

---- Check the results
----
SELECT PropertyAddress, PropertyAddressSplit, PropertyCitySplit
FROM PortfolioProject.dbo.NashvilleHousing

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------

-- Split the OwnerAddress with Parsename()

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT OwnerAddress, 
	   PARSENAME( REPLACE(OwnerAddress, ',', '.'), 3),
	   PARSENAME( REPLACE(OwnerAddress, ',', '.'), 2),
	   PARSENAME( REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing

---- Add the split owner address to the table :
----
---- OwnerAddressSplit
---- OwnerCitySplit
---- OwnerStateSplitt
----
ALTER TABLE NashvilleHousing
ADD OwnerAddressSplit NVARCHAR(255)

ALTER TABLE NashvilleHousing
ADD OwnerCitySplit NVARCHAR(255)

ALTER TABLE NashvilleHousing
ADD OwnerStateSplitt NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerAddressSplit = PARSENAME( REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE NashvilleHousing
SET OwnerCitySplit = PARSENAME( REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE NashvilleHousing
SET OwnerStateSplitt = PARSENAME( REPLACE(OwnerAddress, ',', '.'), 1)


---- Check the results
----
SELECT OwnerAddress, OwnerAddressSplit, OwnerCitySplit, OwnerStateSplitt
FROM PortfolioProject.dbo.NashvilleHousing

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT distinct SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, 
       CASE 
	       WHEN SoldAsVacant = 'Y' THEN 'Yes'
		   WHEN SoldAsVacant = 'N' THEN 'No'
		   ELSE SoldAsVacant
	   END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =
    CASE 
	    WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END

---- Check the results
----
SELECT distinct SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

----------------------------------------------------------------------------------------------------

-- Remove Duplicates

SELECT [UniqueID ], ParcelID,
       ROW_NUMBER() OVER (
	       PARTITION BY ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
			ORDER BY UniqueID
	   ) AS row_num
FROM PortfolioProject.dbo.NashvilleHousing

WITH RowNumCTW 
AS ( 
SELECT *,
       ROW_NUMBER() OVER (
	       PARTITION BY ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
			ORDER BY UniqueID
	   ) AS row_num
FROM PortfolioProject.dbo.NashvilleHousing
)
SELECT *
--DELETE
FROM RowNumCTW
WHERE row_num > 1
ORDER BY PropertyAddress  -- If deleting the rows, cannot use ORDER BY

----------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate, TaxDistrict

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
