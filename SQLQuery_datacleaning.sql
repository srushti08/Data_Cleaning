use PortfolioProject

Select *
From PortfolioProject.dbo.NashvilleHousing

--standardize Date Format
select SaleDateConverted ,convert(date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted date;

update PortfolioProject.dbo.NashvilleHousing

set SaleDateConverted = convert (date,SaleDate)
 

 --populate property address data
 Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking out Address into individual Columns (address,city,State)
Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--to separate the address
select 
substring(PropertyAddress,1,charindex(',',PropertyAddress)-1) as address,
substring(PropertyAddress,charindex(',',PropertyAddress)+1 ,len(PropertyAddress))as address
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitAddress nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress,1,charindex(',',PropertyAddress)-1) 

alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitCity nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitCity = substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress))



--now separate owner address(parse name)
select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

select 
Parsename(replace (OwnerAddress,',','.'),3) 
,Parsename(replace (OwnerAddress,',','.'),2) 
,Parsename(replace (OwnerAddress,',','.'),1) 
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
add ownerSplitAddress nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set ownerSplitAddress = Parsename(replace (OwnerAddress,',','.'),3)

alter table PortfolioProject.dbo.NashvilleHousing
add ownerSplitCity nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set ownerSplitCity = Parsename(replace (OwnerAddress,',','.'),2)

alter table PortfolioProject.dbo.NashvilleHousing
add ownerSplitstate nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set ownerSplitstate = Parsename(replace (OwnerAddress,',','.'),1) 

--change Y and N to Yes and NO in "SoldAsVacant" filed

select Distinct(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing

select Distinct(SoldAsVacant),count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant

select SoldAsVacant,
CASE when SoldAsVacant='Y'then 'Yes'
	 when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = CASE when SoldAsVacant='Y'then 'Yes'
	 when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end


-- Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
select*
From RowNumCTE
where Row_num>1
--order by PropertyAddress


--Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
