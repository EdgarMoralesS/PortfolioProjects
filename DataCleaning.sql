Select *
From PortfolioProject1..NashvilleHousing

/*

Limpiemos informacion con SQL

*/

-------------

-- Hagamos un cambio en el formato de fechas.

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject1..NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)
-- No se porque esta no me funciono jeje


-- Agreguemos una columna
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

-- Ahora hagamos:
Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


--------------------------------------------- Populate Property Address Data


Select *
From PortfolioProject1..NashvilleHousing
order by ParcelID

-- Queremos saber cuales PropertyAdress tiene Nulls y vamos a llenarlos con aquellas que tengan el mismo ParcelId si es que hay una no null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject1..NashvilleHousing a 
JOIN PortfolioProject1..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null 

-- Esto de arriba esta tomando una columna que es nula y la llena con informacion de la otra columna.

Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject1..NashvilleHousing a 
JOIN PortfolioProject1..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null 

-- Ahora vemos que no hay nulls en la tabla que nos daba aquellos ParceID con Nulls





-----------------------------------------------------------------------------------------------

--Ahora rompamos la Address en columnas individuales. (Address, City, State)

Select PropertyAddress
From PortfolioProject1..NashvilleHousing

-- Vemos que hay comas como separadores. Por lo que veamos 

Select 
Substring( PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
From PortfolioProject1..NashvilleHousing

-- Este esta buscando la coma pero sin el -1 nos dara la coma, tons -1 para que no este la coma.

Select 
Substring( PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
Substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress)) as City
From PortfolioProject1..NashvilleHousing


---------------------------------
-- Agreguemos una columna
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

-- Ahora hagamos:
Update NashvilleHousing
SET PropertySplitAddress = Substring( PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


-- Agreguemos una columna
ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

-- Ahora hagamos:
Update NashvilleHousing
SET PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress))



Select *
From PortfolioProject1..NashvilleHousing

-- Ahora hagamos otra forma de separar datos

Select 
Parsename(OwnerAddress, 1)
From PortfolioProject1..NashvilleHousing

-- No hace nada jsj pero, porque esta buscando puntos, no comas, por lo que hagamos un pequeno cambio y separemos los datos.

Select 
Parsename(Replace(OwnerAddress, ',', '.'), 3)
, Parsename(Replace(OwnerAddress, ',', '.'), 2)
,Parsename(Replace(OwnerAddress, ',', '.'), 1)

From PortfolioProject1..NashvilleHousing

-- Lo hace al reves no se porque pero bueno, y ahora tendremos separado las columnas.


-- Agreguemos las columnas  OwnerAddress, OwnerCity, OwnerState
ALTER TABLE NashvilleHousing
Add OwnerSplitAdress Nvarchar(255),
 OwnerSplitCity   Nvarchar(255),
 OwnerSplitState Nvarchar(255) ;



-- Ahora hagamos:
Update NashvilleHousing
SET OwnerSplitAdress = Parsename(Replace(OwnerAddress, ',', '.'), 3) ,
OwnerSplitCity = Parsename(Replace(OwnerAddress, ',', '.'), 2), 
OwnerSplitState = Parsename(Replace(OwnerAddress, ',', '.'), 1)


Select *
From PortfolioProject1..NashvilleHousing


----------------------------- Ahora vamos a cambair Y and N en el Sold as Vacant 

Select Distinct(SoldAsVacant)
From PortfolioProject1..NashvilleHousing

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject1..NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant , 
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From PortfolioProject1..NashvilleHousing


-- Ahora hagamos un Update 
Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
	

	--------------------------- Ahora borremos cosas, no es una practica tan buena pero se debe conocer. -------------------------------------

	-- Borrar Duplicados.
-- Hagamos una columna donde haya un conteo de filas repetidas, datos que estan igualitos en varias columnas y podemos reunirlos...

-- Esta nos dira si 1 es unica o 2 si se repite (o mas)
	Select *,
	 ROW_NUMBER() OVER (
	 PARTITION BY ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  Order BY 
				  UniqueID
				  ) row_num
From PortfolioProject1..NashvilleHousing
order by ParcelID

Select *
From PortfolioProject1..NashvilleHousing


-- Esto nos da una temp table, donde podemos ahora usar la columna que acababamos de crear para poder hacer una operacion con ella, en este caso un when.

WITH RowNumCTE AS (
Select *,
	 ROW_NUMBER() OVER (
	 PARTITION BY ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  Order BY 
				  UniqueID
				  ) row_num
From PortfolioProject1..NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress 

-- Ahora borremos esos casos

WITH RowNumCTE AS (
Select *,
	 ROW_NUMBER() OVER (
	 PARTITION BY ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  Order BY 
				  UniqueID
				  ) row_num
From PortfolioProject1..NashvilleHousing
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1



-- Ahora borremos Columnas que no se usan

Select *
From PortfolioProject1..NashvilleHousing

ALTER TABLE PortfolioProject1..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


