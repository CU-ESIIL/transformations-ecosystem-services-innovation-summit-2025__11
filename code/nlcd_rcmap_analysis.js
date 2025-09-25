/*
 * NLCD RCMAP Rangeland Analysis for Study Area
 * 
 * This Google Earth Engine script processes USGS/NLCD_RELEASES/2023_REL/RCMAP/V6/COVER
 * data to extract rangeland vegetation layers for a study area from 1985-2023.
 * 
 * Required layers:
 * - rangeland_annual_herbaceous
 * - rangeland_sagebrush  
 * - rangeland_perennial_herbaceous
 * 
 * Also includes surface management agency data extraction.
 * 
 * Instructions:
 * 1. Upload your studyArea.shp to Google Earth Engine Assets
 * 2. Update the AOI_ASSET_PATH variable below with your asset path
 * 3. Run the script in Google Earth Engine Code Editor
 */

// =============================================================================
// CONFIGURATION - UPDATE THESE PATHS
// =============================================================================

// Update this path to point to your uploaded study area shapefile in GEE Assets
var AOI_ASSET_PATH = 'users/YOUR_USERNAME/studyArea';

// Optionally update this if you have uploaded SMA data to GEE Assets
var SMA_ASSET_PATH = 'projects/johnsongrass-adaptation/assets/BLM_UT_SMA';

// =============================================================================
// DATASET IMPORTS AND PARAMETERS
// =============================================================================

// Import RCMAP dataset
var rcmap = ee.ImageCollection('USGS/NLCD_RELEASES/2023_REL/RCMAP/V6/COVER');

// Import AOI (replace with your asset path)
// For now, we'll create a demo geometry - replace this with your uploaded shapefile
var aoi;
try {
  aoi = ee.FeatureCollection(AOI_ASSET_PATH);
  print('Successfully loaded AOI from assets');
} catch (error) {
  print('Could not load AOI from assets. Using demo geometry.');
  print('Please upload your studyArea.shp to GEE Assets and update AOI_ASSET_PATH');
  // Demo geometry for testing (replace with your study area)
  aoi = ee.Geometry.Rectangle([-112.0, 39.0, -111.0, 40.0]);
  aoi = ee.FeatureCollection([ee.Feature(aoi)]);
}

// Define the years of interest (1985-2023)
var startYear = 1985;
var endYear = 2023;
var years = ee.List.sequence(startYear, endYear);

// Define the rangeland bands of interest
var rangelandBands = [
  'rangeland_annual_herbaceous',
  'rangeland_sagebrush', 
  'rangeland_perennial_herbaceous'
];

// =============================================================================
// VISUALIZATION PARAMETERS
// =============================================================================

var visParams = {
  annualHerb: {
    min: 0, max: 100,
    palette: [
      '000000', 'f9e8b7', 'f7e3ac', 'f0dfa3', 'eedf9c', 'eada91', 'e8d687',
      'e0d281', 'ddd077', 'd6cc6d', 'd3c667', 'd0c55e', 'cfc555', 'c6bd4f',
      'c4ba46', 'bdb83a', 'bbb534', 'b7b02c', 'b0ad1f', 'adac17', 'aaaa0a',
      'a3a700', '9fa700', '9aa700', '92a700', '8fa700', '87a700', '85a700',
      '82aa00', '7aaa00', '77aa00', '70aa00', '6caa00', '67aa00', '5fa700',
      '57a700', '52a700', '4fa700', '4aa700', '42a700', '3ca700', '37a700',
      '37a300', '36a000', '369f00', '349d00', '339900', '339900', '2f9200',
      '2d9100', '2d8f00', '2c8a00', '2c8800', '2c8500', '2c8400', '2b8200',
      '297d00', '297a00', '297900', '277700', '247400', '247000', '29700f',
      '2c6d1c', '2d6d24', '336d2d', '366c39', '376c44', '396a4a', '396a55',
      '3a6a5f', '3a696a', '396774', '3a6782', '39668a', '376292', '34629f',
      '2f62ac', '2c5fb7', '245ec4', '1e5ed0', '115cdd', '005ae0', '0057dd',
      '0152d6', '0151d0', '014fcc', '014ac4', '0147bd', '0144b8', '0142b0',
      '0141ac', '013da7', '013aa0', '01399d', '013693', '013491', '012f8a',
      '012d85', '012c82', '01297a'
    ]
  },
  sagebrush: {
    min: 0, max: 100,
    palette: [
      '000000', 'f9e8b7', 'f7e3ac', 'f0dfa3', 'eedf9c', 'eada91', 'e8d687',
      'e0d281', 'ddd077', 'd6cc6d', 'd3c667', 'd0c55e', 'cfc555', 'c6bd4f',
      'c4ba46', 'bdb83a', 'bbb534', 'b7b02c', 'b0ad1f', 'adac17', 'aaaa0a',
      'a3a700', '9fa700', '9aa700', '92a700', '8fa700', '87a700', '85a700',
      '82aa00', '7aaa00', '77aa00', '70aa00', '6caa00', '67aa00', '5fa700',
      '57a700', '52a700', '4fa700', '4aa700', '42a700', '3ca700', '37a700',
      '37a300', '36a000', '369f00', '349d00', '339900', '339900', '2f9200',
      '2d9100', '2d8f00', '2c8a00', '2c8800', '2c8500', '2c8400', '2b8200',
      '297d00', '297a00', '297900', '277700', '247400', '247000', '29700f',
      '2c6d1c', '2d6d24', '336d2d', '366c39', '376c44', '396a4a', '396a55',
      '3a6a5f', '3a696a', '396774', '3a6782', '39668a', '376292', '34629f',
      '2f62ac', '2c5fb7', '245ec4', '1e5ed0', '115cdd', '005ae0', '0057dd',
      '0152d6', '0151d0', '014fcc', '014ac4', '0147bd', '0144b8', '0142b0',
      '0141ac', '013da7', '013aa0', '01399d', '013693', '013491', '012f8a',
      '012d85', '012c82', '01297a'
    ]
  },
  perennialHerb: {
    min: 0, max: 100,
    palette: [
      '000000', 'f9e8b7', 'f7e3ac', 'f0dfa3', 'eedf9c', 'eada91', 'e8d687',
      'e0d281', 'ddd077', 'd6cc6d', 'd3c667', 'd0c55e', 'cfc555', 'c6bd4f',
      'c4ba46', 'bdb83a', 'bbb534', 'b7b02c', 'b0ad1f', 'adac17', 'aaaa0a',
      'a3a700', '9fa700', '9aa700', '92a700', '8fa700', '87a700', '85a700',
      '82aa00', '7aaa00', '77aa00', '70aa00', '6caa00', '67aa00', '5fa700',
      '57a700', '52a700', '4fa700', '4aa700', '42a700', '3ca700', '37a700',
      '37a300', '36a000', '369f00', '349d00', '339900', '339900', '2f9200',
      '2d9100', '2d8f00', '2c8a00', '2c8800', '2c8500', '2c8400', '2b8200',
      '297d00', '297a00', '297900', '277700', '247400', '247000', '29700f',
      '2c6d1c', '2d6d24', '336d2d', '366c39', '376c44', '396a4a', '396a55',
      '3a6a5f', '3a696a', '396774', '3a6782', '39668a', '376292', '34629f',
      '2f62ac', '2c5fb7', '245ec4', '1e5ed0', '115cdd', '005ae0', '0057dd',
      '0152d6', '0151d0', '014fcc', '014ac4', '0147bd', '0144b8', '0142b0',
      '0141ac', '013da7', '013aa0', '01399d', '013693', '013491', '012f8a',
      '012d85', '012c82', '01297a'
    ]
  }
};

// =============================================================================
// DATA PROCESSING FUNCTIONS
// =============================================================================

/**
 * Process RCMAP data for a specific year
 */
function processRCMAPYear(year) {
  year = ee.Number(year).int();
  
  // Filter collection to specific year - try multiple filter methods
  var yearlyImages = rcmap.filter(ee.Filter.calendarRange(year, year, 'year'));
  
  // Check if any images found for this year
  var imageCount = yearlyImages.size();
  
  // Get the first (and likely only) image for this year
  var yearlyImage = yearlyImages.first();
  
  // Return null if no image found
  return ee.Algorithms.If(
    imageCount.gt(0),
    ee.Algorithms.If(
      ee.Algorithms.IsEqual(yearlyImage, null),
      null,
      // Select only the rangeland bands we need and clip to AOI
      yearlyImage.select(rangelandBands)
                 .clip(aoi)
                 .set({
                   'year': year,
                   'system:time_start': ee.Date.fromYMD(year, 1, 1).millis()
                 })
    ),
    null
  );
}

/**
 * Calculate statistics for rangeland bands within AOI
 */
function calculateStats(image) {
  var year = image.get('year');
  
  // Clip image to AOI for statistics calculation only
  var clippedImage = image.clip(aoi);
  
  // Calculate mean values within AOI
  var stats = clippedImage.reduceRegion({
    reducer: ee.Reducer.mean().combine({
      reducer2: ee.Reducer.stdDev(),
      sharedInputs: true
    }).combine({
      reducer2: ee.Reducer.minMax(),
      sharedInputs: true
    }),
    geometry: aoi,
    scale: 30,
    maxPixels: 1e13,
    bestEffort: true
  });
  
  return ee.Feature(null, stats).set('year', year);
}

// =============================================================================
// MAIN PROCESSING
// =============================================================================

print('Processing RCMAP data for years', startYear, 'to', endYear);
print('Study area bounds:', aoi.geometry().bounds());

// First, let's check the RCMAP dataset availability and structure
print('');
print('=== RCMAP DATASET DEBUGGING ===');
print('Total RCMAP images available:', rcmap.size());
print('RCMAP date range:', rcmap.aggregate_min('system:time_start'), 'to', rcmap.aggregate_max('system:time_start'));

// Check what bands are available
var firstImage = rcmap.first();
print('Available bands in RCMAP:', firstImage.bandNames());
print('First image date:', firstImage.date());

// Check if our study area intersects with RCMAP coverage
var rcmapBounds = rcmap.geometry();
var aoiBounds = aoi.geometry().bounds();
print('AOI intersects RCMAP coverage:', rcmapBounds.intersects(aoiBounds, 1)); // 1m error margin

// Try a simpler approach - get all images and filter later (no spatial filtering)
var rcmapFiltered = rcmap.filterDate(startYear + '-01-01', (endYear + 1) + '-01-01');

print('RCMAP images within date range:', rcmapFiltered.size());

// Process years with better error handling
var processYearImproved = function(year) {
  var yearNum = ee.Number(year).int();
  var yearString = yearNum.format('%d');
  
  // Try multiple filtering approaches with proper date formatting
  var yearFilter1 = rcmapFiltered.filter(ee.Filter.calendarRange(yearNum, yearNum, 'year'));
  var yearFilter2 = rcmapFiltered.filterDate(
    ee.Date.fromYMD(yearNum, 1, 1), 
    ee.Date.fromYMD(yearNum.add(1), 1, 1)
  );
  
  // Use the filter that returns more results
  var yearlyImages = ee.ImageCollection(ee.Algorithms.If(
    yearFilter1.size().gt(0), yearFilter1, yearFilter2
  ));
  
  var imageCount = yearlyImages.size();
  
  return ee.Algorithms.If(
    imageCount.gt(0),
    yearlyImages.first()
               .select(rangelandBands)
               .set({
                 'year': yearNum,
                 'system:time_start': ee.Date.fromYMD(yearNum, 1, 1).millis(),
                 'image_count_for_year': imageCount
               }),
    null
  );
};

// Process all years
var rcmapTimeSeries = ee.ImageCollection(years.map(processYearImproved))
  .filter(ee.Filter.notNull(['system:time_start']));

print('');
print('=== PROCESSING RESULTS ===');
print('RCMAP Time Series Collection:', rcmapTimeSeries);
print('Number of successful years:', rcmapTimeSeries.size());

// List which years have data
var yearsWithData = rcmapTimeSeries.aggregate_array('year');
print('Years with available data:', yearsWithData);

// Calculate annual statistics only if we have data
var annualStats = ee.FeatureCollection(ee.Algorithms.If(
  rcmapTimeSeries.size().gt(0),
  rcmapTimeSeries.map(calculateStats),
  ee.FeatureCollection([])
));

print('Annual Statistics:', annualStats);

// Get the most recent year for visualization
var latestYear = ee.Image(ee.Algorithms.If(
  rcmapTimeSeries.size().gt(0),
  rcmapTimeSeries.sort('system:time_start', false).first(),
  null
));

print('Latest year data:', latestYear);

// =============================================================================
// SURFACE MANAGEMENT AGENCY DATA
// =============================================================================

// Surface Management Agency data with color coding by owner attribute
var smaData;
try {
  smaData = ee.FeatureCollection(SMA_ASSET_PATH);
  print('Successfully loaded SMA data');
  
  // Get unique owner values for color mapping
  var uniqueOwners = smaData.distinct('owner');
  print('Unique land owners in dataset:', uniqueOwners.aggregate_array('owner'));
  
  // Color scheme for Utah SMA owners based on 'owner' attribute
  var ownerColors = ee.Dictionary({
    'BLM': '#D2691E',                    // Orange-brown for Bureau of Land Management
    'USFS': '#228B22',                   // Forest green for US Forest Service
    'STATE': '#FFD700',                  // Gold for State land
    'PRIVATE': '#DCDCDC',                // Light gray for Private
    'NPS': '#8B4513',                    // Saddle brown for National Park Service
    'FWS': '#4169E1',                    // Royal blue for Fish & Wildlife Service
    'DOD': '#800080',                    // Purple for Department of Defense
    'TRIBAL': '#8A2BE2',                 // Blue violet for Tribal land
    'LOCAL': '#FF69B4',                  // Hot pink for Local government
    'OTHER': '#20B2AA'                   // Light sea green for Other
  });
  
  // Function to style features by owner
  var styleByOwner = function(feature) {
    var owner = ee.String(feature.get('owner')).toUpperCase();
    var color = ownerColors.get(owner, '#808080'); // Default gray for unknown
    return feature.visualize({color: color, fillColor: color});
  };
  
  // Apply styling and add to map
  var styledOwnership = smaData.map(styleByOwner);
  Map.addLayer(styledOwnership, {}, 'Land Ownership by Agency');
  
  // Intersect SMA with AOI to get management agencies within study area
  var aoiSMA = smaData.filterBounds(aoi);
  
  // Calculate area by management agency
  var ownershipStats = aoiSMA.map(function(feature) {
    var area = feature.geometry().area().divide(1000000); // Convert to km²
    return feature.set('area_km2', area);
  });
  
  print('Land Ownership Statistics for Study Area:', ownershipStats);
  
  // Create summary by owner
  var ownerSummary = ownershipStats.reduceColumns({
    reducer: ee.Reducer.sum().group({
      groupField: 0,
      groupName: 'owner'
    }),
    selectors: ['owner', 'area_km2']
  });
  
  print('Area by Land Owner (km²):', ownerSummary);
  
} catch (error) {
  print('Surface Management Agency data not available.');
  print('To add SMA data:');
  print('1. Download BLM Surface Management Agency data');
  print('2. Upload to GEE Assets');
  print('3. Update SMA_ASSET_PATH variable');
}

// =============================================================================
// MAP VISUALIZATION
// =============================================================================

// Center map on AOI but with broader view to show regional context
Map.centerObject(aoi, 8);

// Try to get at least one year of data if the time series failed
if (latestYear === null && rcmapTimeSeries.size().getInfo() === 0) {
  print('Trying simple approach to get RCMAP data...');
  
  // Try to get just the most recent year with a simple approach
  var simpleRCMAP = rcmap.sort('system:time_start', false)
                         .first();
  
  if (simpleRCMAP !== null) {
    latestYear = simpleRCMAP.select(rangelandBands);
    print('Successfully loaded RCMAP data with simple approach');
  }
}

// Add latest year rangeland layers only if data exists
if (latestYear !== null && (rcmapTimeSeries.size().getInfo() > 0 || latestYear !== null)) {
  Map.addLayer(
    latestYear.select('rangeland_annual_herbaceous'),
    visParams.annualHerb,
    'Annual Herbaceous (' + endYear + ')'
  );

  Map.addLayer(
    latestYear.select('rangeland_sagebrush'),
    visParams.sagebrush,
    'Sagebrush (' + endYear + ')'
  );

  Map.addLayer(
    latestYear.select('rangeland_perennial_herbaceous'),
    visParams.perennialHerb,
    'Perennial Herbaceous (' + endYear + ')'
  );
  
  // Add study area outline on top of the data layers
  Map.addLayer(aoi.style({
    color: 'red',
    fillColor: '00000000',
    width: 3
  }), {}, 'Study Area Boundary');
  
} else {
  print('');
  print('=== NO RCMAP DATA AVAILABLE ===');
  print('No RCMAP data found for your study area.');
  print('Possible reasons:');
  print('1. Study area is outside RCMAP coverage (western US rangelands only)');
  print('2. Study area geometry issues');
  print('3. Dataset access problems');
  print('');
  print('RCMAP covers: Western United States rangelands');
  print('Your study area center:', aoi.geometry().centroid().coordinates());
  
  // Still show the study area boundary even without RCMAP data
  Map.addLayer(aoi.style({
    color: 'red',
    fillColor: '00000000',
    width: 3
  }), {}, 'Study Area Boundary');
}

// =============================================================================
// TIME SERIES CHART
// =============================================================================

// Create time series chart only if data exists
if (annualStats.size().getInfo() > 0) {
  var chart = ui.Chart.feature.byFeature({
    features: annualStats,
    xProperty: 'year',
    yProperties: [
      'rangeland_annual_herbaceous_mean',
      'rangeland_sagebrush_mean',
      'rangeland_perennial_herbaceous_mean'
    ]
  }).setOptions({
    title: 'Rangeland Cover Time Series (1985-2023)',
    hAxis: {title: 'Year'},
    vAxis: {title: 'Percent Cover'},
    lineWidth: 2,
    pointSize: 3,
    series: {
      0: {color: '#2b8cbe', labelInLegend: 'Annual Herbaceous'},
      1: {color: '#d7301f', labelInLegend: 'Sagebrush'},
      2: {color: '#238b45', labelInLegend: 'Perennial Herbaceous'}
    }
  });

  print(chart);
} else {
  print('No data available for time series chart');
}

// =============================================================================
// DATA EXPORT FUNCTIONS
// =============================================================================

/**
 * Export time series data to Google Drive
 */
function exportTimeSeries() {
  Export.table.toDrive({
    collection: annualStats,
    description: 'RCMAP_TimeSeries_StudyArea',
    fileFormat: 'CSV',
    selectors: [
      'year',
      'rangeland_annual_herbaceous_mean',
      'rangeland_annual_herbaceous_stdDev',
      'rangeland_sagebrush_mean',
      'rangeland_sagebrush_stdDev',
      'rangeland_perennial_herbaceous_mean',
      'rangeland_perennial_herbaceous_stdDev'
    ]
  });
}

/**
 * Export latest year raster data
 */
function exportLatestRaster() {
  Export.image.toDrive({
    image: latestYear.select(rangelandBands),
    description: 'RCMAP_' + endYear + '_StudyArea',
    scale: 30,
    region: aoi,
    maxPixels: 1e13,
    crs: 'EPSG:4326'
  });
}

// Print export instructions
print('To export data:');
print('1. Time series CSV: run exportTimeSeries()');
print('2. Latest year raster: run exportLatestRaster()');
print('3. Check the Tasks tab to monitor exports');

// =============================================================================
// ADDITIONAL ANALYSIS FUNCTIONS
// =============================================================================

/**
 * Calculate trend analysis for each vegetation type
 */
function calculateTrends() {
  var trendAnalysis = rangelandBands.map(function(band) {
    // Create a collection with year and band values
    var bandCollection = rcmapTimeSeries.select([band]).map(function(img) {
      var year = img.get('year');
      var meanValue = img.reduceRegion({
        reducer: ee.Reducer.mean(),
        geometry: aoi,
        scale: 30,
        maxPixels: 1e13
      }).get(band);
      return ee.Feature(null, {
        'year': year,
        'value': meanValue
      });
    });
    
    // Calculate linear trend
    var trend = bandCollection.reduceColumns({
      reducer: ee.Reducer.linearFit(),
      selectors: ['year', 'value']
    });
    
    return ee.Feature(null, trend).set('band', band);
  });
  
  return ee.FeatureCollection(trendAnalysis);
}

var trends = calculateTrends();
print('Trend Analysis (slope per year):', trends);

// =============================================================================
// INSTRUCTIONS FOR USERS
// =============================================================================

print('');
print('=== INSTRUCTIONS ===');
print('1. Upload your studyArea.shp to Google Earth Engine Assets');
print('2. Update AOI_ASSET_PATH variable with your asset path');
print('3. For Surface Management Agency data:');
print('   - Download from BLM Geospatial Business Platform');
print('   - Upload to GEE Assets');
print('   - Update SMA_ASSET_PATH variable');
print('4. Run the script to visualize and analyze data');
print('5. Use export functions to download results');
print('');
print('=== OUTPUTS ===');
print('- Time series charts showing trends 1985-2023');
print('- Map layers for latest year data');
print('- Statistical summaries and trend analysis');
print('- Export functions for CSV and raster data');
