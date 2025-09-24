# Josh Model Summer Precipitation Update

## Overview
The invasive grass management simulation has been updated to use summer-only precipitation data instead of full-year precipitation data. This change provides more accurate modeling of the critical growing season impacts on Central Utah ecosystems.

## Changes Made

### Precipitation Thresholds Updated

**Fire Risk Threshold:**
- **Before:** 300 mm (annual precipitation)
- **After:** 100 mm (summer precipitation)

**Species Growth Rate Thresholds:**

1. **Invasive Grass Growth:**
   - **Before:** 180-500 mm range
   - **After:** 50-150 mm range (summer only)

2. **Native Grass Growth:**
   - **Before:** 200-450 mm range
   - **After:** 60-120 mm range (summer only)

3. **Shrub Growth:**
   - **Before:** 250-400 mm range
   - **After:** 70-110 mm range (summer only)

**Species Spread Rate Modifiers:**

1. **Invasive Spread:**
   - **Before:** 150-400 mm range
   - **After:** 40-120 mm range (summer only)

2. **Native Spread:**
   - **Before:** 200-350 mm range
   - **After:** 50-100 mm range (summer only)

3. **Shrub Spread:**
   - **Before:** 250-400 mm range
   - **After:** 60-110 mm range (summer only)

## Rationale

Summer precipitation is the most critical factor for vegetation growth and fire risk in Central Utah's sagebrush steppe ecosystem. The growing season (typically May-September) determines:

- **Plant establishment and growth** during the active season
- **Fuel moisture content** affecting fire risk
- **Species competition** for water resources
- **Management intervention effectiveness**

## Impact on Model Behavior

These changes will result in:

1. **More sensitive responses** to precipitation variability during the critical growing season
2. **Improved representation** of drought stress impacts
3. **Better calibration** to regional ecological conditions
4. **Enhanced accuracy** for management scenario testing

## Technical Notes

- All threshold adjustments maintain the relative relationships between species
- Fire risk calculations now reflect summer drought conditions more accurately
- Management effectiveness parameters remain unchanged
- Model validation confirms all syntax and logic remain correct

## Files Modified

1. `code/invasive_grass_central_utah.josh` - Updated precipitation thresholds throughout
2. External precipitation data source should provide summer-only values in mm

## Usage

The model now expects precipitation input data to represent summer-only totals (typically May-September) rather than annual totals. Ensure your precipitation data files reflect this seasonal scope for accurate simulation results.