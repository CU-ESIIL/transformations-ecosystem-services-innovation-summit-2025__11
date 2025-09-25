# Google Earth Engine NLCD RCMAP Analysis

This directory contains Google Earth Engine JavaScript code for processing USGS NLCD RCMAP (Rangeland Condition Monitoring Assessment and Projection) data to extract rangeland vegetation layers for your study area from 1985-2023.

## Files

- `nlcd_rcmap_analysis.js` - Main Google Earth Engine JavaScript code
- `README_GEE_NLCD_RCMAP.md` - This documentation file

## Overview

The script processes the `USGS/NLCD_RELEASES/2023_REL/RCMAP/V6/COVER` dataset to extract:

### Target Rangeland Layers
- **rangeland_annual_herbaceous** - Annual herbaceous vegetation cover (%)
- **rangeland_sagebrush** - Sagebrush cover (%)  
- **rangeland_perennial_herbaceous** - Perennial herbaceous vegetation cover (%)

### Time Period
- **1985-2023** - Complete time series (39 years)

### Additional Features
- Study area boundary visualization
- Surface management agency data integration
- Time series analysis and trend detection
- Statistical summaries
- Data export capabilities

## Setup Instructions

### 1. Upload Study Area Shapefile to Google Earth Engine

1. **Prepare your shapefile**:
   - Ensure you have all shapefile components: `.shp`, `.shx`, `.dbf`, `.prj`
   - Zip all components into a single `.zip` file

2. **Upload to GEE Assets**:
   - Open [Google Earth Engine Code Editor](https://code.earthengine.google.com/)
   - Go to the **Assets** tab (left panel)
   - Click **NEW** → **Shape files**
   - Upload your `.zip` file containing the shapefile
   - Name the asset (e.g., `studyArea`)
   - Wait for processing to complete

3. **Get the asset path**:
   - Once uploaded, the path will be: `users/YOUR_USERNAME/studyArea`
   - Copy this path for use in the script

### 2. Configure the Script

1. **Open the script**:
   - Copy the contents of `nlcd_rcmap_analysis.js`
   - Paste into Google Earth Engine Code Editor

2. **Update configuration**:
   ```javascript
   // Update this line with your actual asset path
   var AOI_ASSET_PATH = 'users/YOUR_USERNAME/studyArea';
   ```

3. **Run the script**:
   - Click **Run** in the Code Editor
   - The script will process data and display results

## Script Features

### Data Processing
- **Automatic year filtering**: Processes all available years (1985-2023)
- **AOI clipping**: Clips all data to your study area boundary
- **Statistical analysis**: Calculates mean, standard deviation, min/max for each year
- **Trend analysis**: Computes linear trends over the time period

### Visualizations
- **Study area outline**: Red boundary showing your AOI
- **Latest year layers**: Three rangeland layers with custom color palettes
- **Time series chart**: Interactive chart showing trends over time
- **Management boundaries**: Surface management agency polygons (if available)

### Export Options
- **Time series CSV**: Annual statistics for all vegetation types
- **Raster data**: Latest year rangeland layers as GeoTIFF
- **Export to Google Drive**: Automatic export to your Drive

## Surface Management Agency Data

The script includes functionality for surface management agency (SMA) data, which shows land ownership/management (BLM, USFS, etc.).

### Option 1: Use Existing GEE Dataset (if available)
Some surface management datasets may be available in GEE's public catalog. Check for:
- `BLM/SMA` (if available)
- `USGS/GAP/PAD-US` (Protected Areas Database)

### Option 2: Upload Your Own SMA Data
1. **Download SMA data**:
   - Visit [BLM Geospatial Business Platform](https://gbp-blm-egis.hub.arcgis.com/)
   - Download Surface Management Agency polygons
   - Or use other land ownership datasets

2. **Upload to GEE Assets**:
   - Follow same process as study area shapefile
   - Update `SMA_ASSET_PATH` in the script

## Script Output

### Console Output
- Processing status and data summaries
- Annual statistics table
- Trend analysis results
- Export instructions

### Map Layers
- **Study Area Boundary** (red outline)
- **Annual Herbaceous Cover** (blue palette)
- **Sagebrush Cover** (red-orange palette)
- **Perennial Herbaceous Cover** (green palette)
- **Surface Management Agencies** (purple, if available)

### Charts
- **Time Series Chart**: Interactive plot showing 39-year trends
- **Trend Analysis**: Linear regression results for each vegetation type

### Exports
Run these functions in the console to export data:
```javascript
// Export time series data as CSV
exportTimeSeries();

// Export latest year raster data
exportLatestRaster();
```

## Interpretation Guide

### Vegetation Cover Values
- **0-100%**: Fractional cover values
- **Higher values**: More vegetation cover
- **Trends**: 
  - Positive slope = increasing cover over time
  - Negative slope = decreasing cover over time

### Typical Rangeland Patterns
- **Annual herbaceous**: Often varies with precipitation
- **Sagebrush**: More stable, responds to disturbance and climate
- **Perennial herbaceous**: Important for ecosystem stability

## Troubleshooting

### Common Issues

1. **"AOI not found" error**:
   - Check that shapefile uploaded correctly
   - Verify asset path in script matches uploaded asset
   - Ensure asset sharing permissions are correct

2. **"No data available" warning**:
   - Study area may be outside RCMAP coverage area
   - Check that AOI geometry is valid
   - RCMAP covers western US rangeland areas

3. **Memory errors**:
   - Reduce study area size if very large
   - Increase scale parameter if needed
   - Use `bestEffort: true` in reduce operations

4. **Export failures**:
   - Check Google Drive storage space
   - Reduce maxPixels for large areas
   - Export smaller time ranges if needed

### Getting Help
- [Google Earth Engine Documentation](https://developers.google.com/earth-engine/)
- [GEE Community Forum](https://groups.google.com/g/google-earth-engine-developers)
- [RCMAP Dataset Documentation](https://developers.google.com/earth-engine/datasets/catalog/USGS_NLCD_RELEASES_2023_REL_RCMAP_V6_COVER)

## Data Sources

- **RCMAP Data**: USGS/NLCD_RELEASES/2023_REL/RCMAP/V6/COVER
- **Surface Management**: BLM Surface Management Agency polygons
- **Spatial Resolution**: 30 meters
- **Temporal Resolution**: Annual (1985-2023)
- **Geographic Coverage**: Western United States rangelands

## Citation

When using this analysis, please cite:
- USGS NLCD RCMAP data
- Google Earth Engine platform
- This analysis code (if publishing results)

```
Rigge, M., Shi, H., Homer, C., Danielson, P., Granneman, B., Postma, K., 
Ujenesa, M., Xian, G., and Bobo, M., 2023, Rangeland Condition Monitoring 
Assessment and Projection (RCMAP) Fractional Component Time-Series Across 
the Western U.S. 1985-2023: U.S. Geological Survey data release, 
https://doi.org/10.5066/P9ODAZHC.
```
