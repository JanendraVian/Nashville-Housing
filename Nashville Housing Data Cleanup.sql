--DATA CLEANING

select*
from [Nashville Housing]..NashvilleHousing

--[Adding SaleDate with no time]
select SaleDateConverted,CONVERT(date, SaleDate) SaleDateConverted
from [Nashville Housing]..NashvilleHousing

Update NashvilleHousing set SaleDate=CONVERT(date, SaleDate)

Alter Table NashvilleHousing
add SaleDateConverted date;

Update NashvilleHousing set SaleDateConverted=CONVERT(date, SaleDate)

--[Populating Null PropertyAddress]
select *
from [Nashville Housing]..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.propertyaddress) 
from [Nashville Housing]..NashvilleHousing a
join [Nashville Housing]..NashvilleHousing b
	on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.propertyaddress, b.propertyaddress) 
from [Nashville Housing]..NashvilleHousing a
join [Nashville Housing]..NashvilleHousing b
	on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--[Breaking out PropertyAddress into individual columns (Address, City, State)]
select PropertyAddress
from [Nashville Housing]..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)) City
from [Nashville Housing]..NashvilleHousing

Alter Table NashvilleHousing
add Address nvarchar(225);

Update NashvilleHousing set Address=SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

EXEC sp_rename 'NashvilleHousing.Address', 'PropertyAddressOnly', 'COLUMN'

Alter Table NashvilleHousing
add City nvarchar(225);

Update NashvilleHousing set City=SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress))

EXEC sp_rename 'NashvilleHousing.City', 'PropertyCity', 'COLUMN'

--[Breaking out OwnerAddress into individual columns (Address, City, State)]
select
PARSENAME(replace(OwnerAddress,',','.'), 3),
PARSENAME(replace(OwnerAddress,',','.'), 2),
PARSENAME(replace(OwnerAddress,',','.'), 1)
from [Nashville Housing]..NashvilleHousing

Alter Table NashvilleHousing
add OwnerAddressOnly nvarchar(225),
add OwnerCity nvarchar(225),
add OwnerState nvarchar(225)

Update NashvilleHousing set OwnerAddressOnly=PARSENAME(replace(OwnerAddress,',','.'), 3)
Update NashvilleHousing set OwnerCity=PARSENAME(replace(OwnerAddress,',','.'), 2)
Update NashvilleHousing set OwnerState=PARSENAME(replace(OwnerAddress,',','.'), 1)

--[Changing 'Y' and 'N' to 'Yes' and 'No' in SoldAsVacant]
select distinct(SoldAsVacant), count(SoldAsVacant)
from [Nashville Housing]..NashvilleHousing
group by SoldAsVacant
order by 2 desc

select SoldAsVacant
,case	when SoldAsVacant='Y' then 'Yes'
		when SoldAsVacant='N' then 'No'
		else SoldAsVacant
		end
from [Nashville Housing]..NashvilleHousing

update NashvilleHousing
set SoldAsVacant=case	when SoldAsVacant='Y' then 'Yes'
		when SoldAsVacant='N' then 'No'
		else SoldAsVacant
		end

--[Removing duplicates]
with RowNumCTE as(
select*,
	ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY UniqueID
				 ) RowNum
from [Nashville Housing]..NashvilleHousing
)
Delete
from RowNumCTE
where RowNum > 1

--[Deleting redundant columns (PropertyAddress and OwnerAddress)]
alter table [Nashville Housing]..NashvilleHousing
drop column PropertyAddress, OwnerAddress

select*
from [Nashville Housing]..NashvilleHousing