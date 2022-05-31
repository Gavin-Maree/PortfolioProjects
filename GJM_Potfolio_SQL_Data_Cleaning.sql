
Select *
From PortfolioProject..NashvilleHousing

-- Standardize date Format

Select SaleDate, SalesDateConverted
From PortfolioProject..NashvilleHousing

-- Add new column to table

Alter Table NashvilleHousing
Add SalesDateConverted Date;

-- Update new table column

Update PortfolioProject..NashvilleHousing
Set SalesDateConverted  = Convert(Date,SaleDate);

-- Populate property address data (self join)

Select *
From PortfolioProject..NashvilleHousing
where PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a. PropertyAddress,  b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = isnull(a. PropertyAddress,  b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Split property address field into new & separate address, city & state fields
-- With substring
Select
Substring(PropertyAddress, 1, CharIndex(',',PropertyAddress) - 1) as Address,
Substring(PropertyAddress, CharIndex(',',PropertyAddress) + 1, Len(PropertyAddress)) as City

From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

-- Update new table column

Update PortfolioProject..NashvilleHousing
Set PropertySplitAddress  = Substring(PropertyAddress, 1, CharIndex(',',PropertyAddress) - 1)

Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

-- Update new table column

Update PortfolioProject..NashvilleHousing
Set PropertySplitCity  = Substring(PropertyAddress, CharIndex(',',PropertyAddress) + 1, Len(PropertyAddress))

-- With parsename
Select 
PARSENAME(Replace(OwnerAddress, ',', '.') , 3),
PARSENAME(Replace(OwnerAddress, ',', '.') , 2),
PARSENAME(Replace(OwnerAddress, ',', '.') , 1)
From PortfolioProject..NashvilleHousing

-- Update new table column

Update PortfolioProject..NashvilleHousing
Set PropertySplitAddress  = Substring(PropertyAddress, 1, CharIndex(',',PropertyAddress) - 1)

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255),
	OwnerSplitCity Nvarchar(255),
	OwnerSplitState Nvarchar(255);

-- Update new table columns

Update PortfolioProject..NashvilleHousing
Set OwnerSplitAddress  = PARSENAME(Replace(OwnerAddress, ',', '.') , 3)

Update PortfolioProject..NashvilleHousing
Set OwnerSplitCity  = PARSENAME(Replace(OwnerAddress, ',', '.') , 2)

Update PortfolioProject..NashvilleHousing
Set OwnerSplitState  = PARSENAME(Replace(OwnerAddress, ',', '.') , 1)

-- Change Y & N to Yes & No for Sold as Vacant field

Select SoldAsVacant, Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2 desc

Select SoldAsVacant,
	Case 
		when SoldAsVacant = 'N' Then 'No'
		when SoldAsVacant = 'Y' Then 'Yes'
	Else SoldAsVacant 
	End
From PortfolioProject..NashvilleHousing

-- Update new table columns

Update PortfolioProject..NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'N' Then 'No'
	 when SoldAsVacant = 'Y' Then 'Yes'
	 Else SoldAsVacant 
	 End

-- Remove Duplicates

With RowNumCTE as(
Select *,
	ROW_NUMBER() over (
	Partition by ParcelID,
				 PropertySplitAddress,
				 SalePrice,
				 SalesDateConverted,
				 LegalReference
	Order by	 UniqueID	
	) row_num
From PortfolioProject..NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1

-- Remove unused columns

Select *
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop column SaleDate, PropertyAddress, TaxDistrict, OwnerAddress
