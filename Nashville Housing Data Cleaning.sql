
/*Cleaning Data in SQL queries  for Nashville Housing*/

Select *
From [Portfolio Project].[dbo].[Nashvillehousing]




------------------------------------
--Standardize Date Format

Select SaleDateConverted, CONVERT(date, [SaleDate])
From [Portfolio Project].[dbo].[Nashvillehousing]


Update [dbo].[Nashvillehousing]
SET [SaleDate] = CONVERT(date,[SaleDate])


--OR

Alter table [dbo].[Nashvillehousing]
Add SaleDateConverted Date;

Update [dbo].[Nashvillehousing]
SET SaleDateConverted = CONVERT(Date,[SaleDate])




-------------------------------
--Populate Property Address Data

Select *
From [Portfolio Project]..Nashvillehousing
--Where PropertyAddress is null
order by ParcelID

--Match same address to same ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project]..Nashvillehousing a
Join [Portfolio Project]..Nashvillehousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project]..Nashvillehousing a
Join [Portfolio Project]..Nashvillehousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null





-----------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From [Portfolio Project]..Nashvillehousing
--Where PropertyAddress is null
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From [Portfolio Project]..Nashvillehousing



Alter table [dbo].[Nashvillehousing]
Add PropertySplitAddress Nvarchar(255);

Update [dbo].[Nashvillehousing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )



Alter table [dbo].[Nashvillehousing]
Add PropertySplitCity Nvarchar(255);

Update [dbo].[Nashvillehousing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
From [Portfolio Project]..Nashvillehousing


Select Owneraddress
From [Portfolio Project]..Nashvillehousing


Select
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
From [Portfolio Project]..Nashvillehousing


Alter table [dbo].[Nashvillehousing]
Add OwnerSplitAddress Nvarchar(255);

Update [dbo].[Nashvillehousing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)



Alter table [dbo].[Nashvillehousing]
Add OwnerSplitCity Nvarchar(255);

Update [dbo].[Nashvillehousing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)



Alter table [dbo].[Nashvillehousing]
Add OwnerSplitState Nvarchar(255);

Update [dbo].[Nashvillehousing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)


Select *
From [Portfolio Project]..Nashvillehousing


----------------------------------------------------------

--Change Y and N in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Portfolio Project]..Nashvillehousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' Then 'No'
	   else SoldAsVacant
	   End
From [Portfolio Project]..Nashvillehousing

Update Nashvillehousing
SET SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' Then 'No'
	   else SoldAsVacant
	   End

-----------------------------------------------------------------------
--Remove Duplicates



With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	Partition by ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by
					UniqueID
					) row_num

From [Portfolio Project]..Nashvillehousing
--Order by ParcelID
)
Select *
From RowNumCTE
where row_num > 1
Order by PropertyAddress


Select *
From [Portfolio Project]..Nashvillehousing



------------------------------------------------------------------------------
--DELETE unused columns



Select *
From [Portfolio Project]..Nashvillehousing

ALTER TABLE [Portfolio Project]..Nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE [Portfolio Project]..Nashvillehousing
DROP COLUMN SaleDate