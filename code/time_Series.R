

###### This r code help plotting time series for a raster stack
### terra


# ---- terra version (recommended) ----


library(terra)
library(sf)
library(dplyr)
library(tidyr)
library(lubridate)
library(ggplot2)
library(rlang)

# list the files want to use for this project
file_list = dir("C:/Users/nayani/mydata/RAD-US/sage_core_2/", pattern = ".tif", full.names = FALSE, ignore.case = TRUE) 

# create a stack of rasters
stack_sagebrush <- rast(paste0("C:/Users/nayani/mydata/RAD-US/sage_core_2/", file_list))


# read the polygon layer if need to calculate means based on defined polygons
sage_poly <- st_read("C:/Users/nayani/mydata/RAD-US/treatment_poly.shp")
id_field <- "TRTMNT_NM"           # a column inside the polygons to label lines


polygon_mean_ts <- function(x, poly, id_field, dates = NULL,
                            exact = TRUE, ribbon = c("sd","ci","none")) {
  ribbon <- match.arg(ribbon)
  stopifnot(inherits(x, "SpatRaster"))
  if (missing(id_field) || !nzchar(id_field))
    stop("Please provide `id_field` (the polygon category column).")
  
  # 1) Read polygons
  p <- if (inherits(poly, "character")) sf::st_read(poly, quiet = TRUE)
  else if (inherits(poly, "sf")) poly
  else if (inherits(poly, "SpatVector")) sf::st_as_sf(poly)
  else stop("poly must be a file path, sf, or SpatVector")
  
  # 2) Confirm the category column exists (exact match)
  if (!id_field %in% names(p)) {
    stop(sprintf("Column '%s' not found in polygon data. Available: %s",
                 id_field, paste(names(p), collapse = ", ")))
  }
  
  # 3) Reproject polygons to raster CRS
  if (!is.na(sf::st_crs(p))) p <- sf::st_transform(p, terra::crs(x)) else sf::st_crs(p) <- terra::crs(x)
  
  # 4) Dates for bands
  if (is.null(dates)) {
    nm <- names(x)
    guess <- lubridate::parse_date_time(nm, orders = c("Y","Ymd","Y-m-d","Y_m_d","YmdHMS","Y-m-d H:M:S"), quiet = TRUE)
    dates <- if (all(is.na(guess))) seq_len(terra::nlyr(x)) else as_date(guess)
  }
  if (length(dates) != terra::nlyr(x)) stop("`dates` length must equal number of layers in `x`.")
  
  # 5) Extract per-cell values with weights
  ext <- terra::extract(x, terra::vect(p), exact = exact, weights = TRUE, cells = TRUE, na.rm = TRUE)
  idcol <- names(ext)[1]                # typically "ID"
  value_cols <- names(x)
  
  # 6) Long format and attach category; normalize the category name
  long <- ext |>
    dplyr::rename(.id = !!idcol) |>
    tidyr::pivot_longer(dplyr::all_of(value_cols), names_to = "layer", values_to = "value") |>
    dplyr::filter(!is.na(value), !is.na(weight), weight > 0)
  
  poly_lab <- p |>
    sf::st_drop_geometry() |>
    dplyr::mutate(.id = dplyr::row_number()) |>
    dplyr::select(.id, category = dplyr::all_of(id_field))   # <- normalize here
  
  df <- long |>
    dplyr::left_join(poly_lab, by = ".id") |>
    dplyr::filter(!is.na(category)) |>
    dplyr::group_by(category, layer) |>
    dplyr::summarize(
      w_sum  = sum(weight),
      w2_sum = sum(weight^2),
      mean_w = sum(weight * value) / w_sum,
      var_w_num = sum(weight * (value - (sum(weight * value) / w_sum))^2),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      N_eff = (w_sum^2) / pmax(w2_sum, .Machine$double.eps),
      sd_w  = sqrt(var_w_num / pmax(w_sum, .Machine$double.eps)),
      se_w  = sd_w / sqrt(pmax(N_eff, 1)),
      ci95  = 1.96 * se_w,
      time  = dates[match(layer, value_cols)]
    ) |>
    dplyr::arrange(category, time)
  
  # 7) Plot: one legend for line+fill
  p_plot <- ggplot(df, aes(time, mean_w, color = category, fill = category, group = category)) +
    geom_line() +
    geom_point() +
    labs(x = "Year", y = "Percent Sagebrush Cover", color = "Treatment", fill = "Treatment") +
    theme_minimal()
  
  if (ribbon == "sd") {
    p_plot <- p_plot + geom_ribbon(aes(ymin = mean_w - sd_w, ymax = mean_w + sd_w),
                                   alpha = 0.18, linewidth = 0, color = NA)
  } else if (ribbon == "ci") {
    p_plot <- p_plot + geom_ribbon(aes(ymin = mean_w - ci95, ymax = mean_w + ci95),
                                   alpha = 0.18, linewidth = 0, color = NA)
  }
  
  # make the single merged legend look nice
  p_plot <- p_plot +
    guides(color = guide_legend(override.aes = list(fill = NA, alpha = 1, linewidth = 1.2)),
           fill  = guide_legend(override.aes = list(linetype = 0, alpha = 0.3)))
  
  print(p_plot)
  
  invisible(list(
    data = dplyr::select(df, category, time, layer, mean = mean_w, sd = sd_w, se = se_w, ci95, N_eff),
    plot = p_plot
  ))
}





# quick sanity check:
names(sage_poly2)        # confirm it really contains "NFPORS_TRT" exactly

names(stack_sagebrush) <- sub(".*_(\\d{4})_.*", "\\1", names(stack_sagebrush))
dates <- as.Date(paste0(names(stack_sagebrush), "-07-01"))

res <- polygon_mean_ts(
  x = stack_sagebrush,
  poly = sage_poly2,
  id_field = "NFPORS_TRT",
  dates = dates,
  exact = TRUE,
  ribbon = "sd"
)



ggsave("C:/Users/nayani/mydata/RAD-US/figures/seeding_mastication.png", res$plot, width = 8, height = 5, dpi = 300)
readr::write_csv(res$data, "C:/Users/nayani/mydata/RAD-US/figures/seeding_mastication_means_ts.csv")






################################
##################################
#####################################


library(terra); library(dplyr); library(tidyr); library(lubridate); library(ggplot2)

polygon_mean_ts <- function(x, poly = NULL, id_field = NULL, dates = NULL,
                            exact = TRUE, ribbon = c("sd","ci","none")) {
  ribbon <- match.arg(ribbon)
  stopifnot(inherits(x, "SpatRaster"))
  
  # ----- Dates -----
  if (is.null(dates)) {
    nm <- names(x)
    guess <- lubridate::parse_date_time(
      nm, orders = c("Y","Ymd","Y-m-d","Y_m_d","YmdHMS","Y-m-d H:M:S"), quiet = TRUE
    )
    dates <- if (all(is.na(guess))) seq_len(terra::nlyr(x)) else as_date(guess)
  }
  if (length(dates) != terra::nlyr(x))
    stop("`dates` length must equal number of layers in `x`.")
  
  # ============= CASE A: NO POLYGONS -> AOI-wide 'core' only =============
  if (is.null(poly)) {
    # area weights if lon/lat; otherwise each cell has same area so unweighted is fine
    if (terra::is.lonlat(x)) {
      w <- terra::cellSize(x, unit = "m")          # 1 layer, m^2
      # weight mask per layer (0/1 where layer is not NA)
      # weighted mean: sum(w*v)/sum(w)
      sum_w   <- terra::global(w, "sum", na.rm = TRUE)[,1]          # scalar (same across layers)
      # compute sum(w) per-layer over non-NA cells:
      sum_w_i <- sapply(1:terra::nlyr(x), function(i) {
        terra::global(w * !is.na(x[[i]]), "sum", na.rm = TRUE)[1,1]
      })
      
      # sum(w*v) and sum(w*v^2)
      Swx  <- sapply(1:terra::nlyr(x), function(i) terra::global(w * x[[i]], "sum", na.rm = TRUE)[1,1])
      Swx2 <- sapply(1:terra::nlyr(x), function(i) terra::global(w * (x[[i]]^2), "sum", na.rm = TRUE)[1,1])
      
      mean_w <- Swx / pmax(sum_w_i, .Machine$double.eps)
      var_w  <- pmax(Swx2 / pmax(sum_w_i, .Machine$double.eps) - mean_w^2, 0)
      sd_w   <- sqrt(var_w)
      
      # effective N: (Σw)^2 / Σ(w^2), but restrict to cells used in each layer
      Sw2_i <- sapply(1:terra::nlyr(x), function(i) terra::global((w^2) * !is.na(x[[i]]), "sum", na.rm = TRUE)[1,1])
      N_eff <- (sum_w_i^2) / pmax(Sw2_i, .Machine$double.eps)
    } else {
      # projected: equal-area cells → standard mean/sd over non-NA cells
      m <- terra::global(x, "mean", na.rm = TRUE)[,1]
      # terra::global sd returns NA if only one non-NA; handle safely
      s <- terra::global(x, "sd",   na.rm = TRUE)[,1]
      mean_w <- as.numeric(m)
      sd_w   <- as.numeric(replace(s, is.na(s), 0))
      # approximate N_eff = number of non-NA cells per layer
      N_eff  <- sapply(1:terra::nlyr(x), function(i) terra::global(!is.na(x[[i]]), "sum", na.rm = TRUE)[1,1])
    }
    
    se_w  <- sd_w / sqrt(pmax(N_eff, 1))
    ci95  <- 1.96 * se_w
    layer <- names(x)
    
    df <- tibble::tibble(
      category = "Core",
      time     = dates,
      layer    = layer,
      mean     = mean_w,
      sd       = sd_w,
      se       = se_w,
      ci95     = ci95,
      N_eff    = N_eff
    )
    
    p_plot <- ggplot(df, aes(time, mean, color = category, fill = category, group = category)) +
      geom_line() + geom_point() +
      labs(x = "Year", y = "Percent Sagebrush cover", color = "Category", fill = "Category") +
      theme_minimal()
    
    if (ribbon == "sd") {
      p_plot <- p_plot + geom_ribbon(aes(ymin = mean - sd, ymax = mean + sd),
                                     alpha = 0.18, linewidth = 0, color = NA)
    } else if (ribbon == "ci") {
      p_plot <- p_plot + geom_ribbon(aes(ymin = mean - ci95, ymax = mean + ci95),
                                     alpha = 0.18, linewidth = 0, color = NA)
    }
    
    p_plot <- p_plot +
      guides(color = guide_legend(override.aes = list(fill = NA, alpha = 1, linewidth = 1.2)),
             fill  = guide_legend(override.aes = list(linetype = 0, alpha = 0.3)))
    
    print(p_plot)
    return(invisible(list(data = df, plot = p_plot)))
  }
  
  # ============= CASE B: WITH POLYGONS (unchanged from earlier) =============
  # 1) Read/reproject polygons, check id_field etc. (same as your previous version) …
  # (If you still need polygon mode, keep your previous block here.)
}


# Name layers with years and build dates
names(stack_sagebrush) <- sub(".*_(\\d{4})_.*", "\\1", names(stack_sagebrush))
dates <- as.Date(paste0(names(stack_sagebrush), "-07-01"))

# Just pass the raster stack; no poly/id_field needed
res_core <- polygon_mean_ts(
  x      = stack_sagebrush,
  poly   = NULL,      # ← no polygons
  dates  = dates,
  ribbon = "sd"       # shaded ±SD; use "ci" for 95% CI
)

res_core$plot
# Optional: ggsave("sagebrush_core_ts.png", res_core$plot, width=8, height=5, dpi=300)
# res_core$data has: category ("core"), time, layer, mean, sd, se, ci95, N_eff


ggsave("C:/Users/nayani/mydata/RAD-US/figures/core.png", res_core$plot, width = 8, height = 5, dpi = 300)
readr::write_csv(res_core$data, "C:/Users/nayani/mydata/RAD-US/figures/core.csv")


xx2 <- res_core$data


data <- rbind(xx, xx2)


# assume your data frame is `df` with columns:
#   year (or date), category, mean, sd
# if it's called something else, rename accordingly.
# if year is numeric, convert to Date for nicer axis (optional):
# df <- df %>% mutate(time = as.Date(paste0(year, "-07-01")))

df <- data %>%
  arrange(category, layer) %>%        # or `time` if you have dates
  mutate(
    ymin = mean - sd,
    ymax = mean + sd
  )

ggplot(df, aes(x = layer, y = mean, color = category, fill = category, group = category)) +
  geom_ribbon(aes(ymin = ymin, ymax = ymax), alpha = 0.18, linewidth = 0, color = NA) +
  geom_line() +
  geom_point(size = 2) +
  labs(x = "Year", y = "Percent Sagebrush Cover", color = "category", fill = "category") +
  guides(
    color = guide_legend(override.aes = list(fill = NA, alpha = 1, linewidth = 1.2)),
    fill  = guide_legend(override.aes = list(linetype = 0, alpha = 0.3))
  ) +
  theme(axis.text.x = element_text(angle = 60, hjust = 1, vjust = 1))
  


ggsave("C:/Users/nayani/mydata/RAD-US/figures/core.png", res_core$plot, width = 8, height = 5, dpi = 300)
readr::write_csv(data, "C:/Users/nayani/mydata/RAD-US/figures/all_samples.csv")










polygon_mean_ts <- function(x, poly, id_field = NULL, dates = NULL, exact = TRUE) {
  stopifnot(inherits(x, "SpatRaster"))
  
  # 1) Read/standardize polygons
  p <- if (inherits(poly, "character")) {
    # read from disk
    sf::st_read(poly, quiet = TRUE)
  } else if (inherits(poly, "sf")) {
    poly
  } else if (inherits(poly, "SpatVector")) {
    sf::st_as_sf(poly)
  } else {
    stop("poly must be a file path, sf, or SpatVector")
  }
  
  # 2) Reproject polygons to raster CRS (if needed)
  if (!is.na(st_crs(p))) {
    p <- st_transform(p, crs(x))
  } else {
    # if polygons lack a CRS, assume raster CRS
    st_crs(p) <- crs(x)
  }
  
  # 3) Ensure an ID column
  if (is.null(id_field) || !(id_field %in% names(p))) {
    p$id <- seq_len(nrow(p))
    id_field <- "id"
  }
  
  # 4) Dates for bands
  if (is.null(dates)) {
    nm <- names(x)
    guess <- parse_date_time(
      nm,
      orders = c("Ymd", "Y-m-d", "Y_m_d", "YmdHMS", "Y-m-d H:M:S"),
      quiet = TRUE
    )
    dates <- if (all(is.na(guess))) seq_len(nlyr(x)) else as_date(guess)
  }
  if (length(dates) != nlyr(x)) stop("`dates` length must equal number of layers in `x`.")
  
  # 5) Extract area-weighted means per polygon per band
  pv <- terra::vect(p)  # SpatVector
  means_df <- terra::extract(
    x, pv,
    fun = mean, na.rm = TRUE,
    exact = exact   # area-weighted when TRUE
  )
  # means_df: first col is ID, then one column per band
  idcol <- names(means_df)[1]
  
  # 6) Long format + attach dates and polygon labels
  out_long <- means_df |>
    rename(.id = all_of(idcol)) |>
    left_join( p |>
                 st_drop_geometry() |>
                 mutate(.id = row_number()) |>
                 select(.id, !!id_field),
               by = ".id") |>
    pivot_longer(
      cols = starts_with(names(x)[1]) | cols = names(x),
      names_to = "layer", values_to = "value"
    )
  
  # the previous pivot_longer line needs robustness: rebuild it safely
  value_cols <- names(x)
  out_long <- means_df |>
    rename(.id = all_of(idcol)) |>
    left_join( p |>
                 st_drop_geometry() |>
                 mutate(.id = row_number()) |>
                 select(.id, !!id_field),
               by = ".id") |>
    pivot_longer(all_of(value_cols), names_to = "layer", values_to = "value") |>
    group_by(.id) |>
    mutate(time = dates) |>
    ungroup() |>
    rename(poly = !!id_field)
  
  # 7) Plot (one line per polygon)
  p_plot <- ggplot(out_long, aes(time, value, color = poly, group = poly)) +
    geom_line() + geom_point() +
    labs(x = "Time", y = "Mean value", color = "Polygon") +
    theme_minimal()
  
  print(p_plot)
  invisible(list(data = out_long, plot = p_plot))
}


res <- polygon_mean_ts(
  x = x,
  poly = poly,
  id_field = id_field,  # if missing in file, it will create an integer id
  dates = NULL,         # or use the `dates` vector from step 3
  exact = TRUE          # area-weighted means
)


ggsave("poly_means_timeseries.png", res$plot, width = 8, height = 5, dpi = 300)
readr::write_csv(res$data, "poly_means_timeseries.csv")



# x can be a SpatRaster with time in layer names (e.g., "2020-06-01", "Band_20200601")
# Optional: provide a 'dates' vector aligned to layers if names don't contain dates.
plot_pixel_ts <- function(x, coords = NULL, n_random = 1, dates = NULL, crs_of_coords = NULL) {
  stopifnot(inherits(x, "SpatRaster"))
  if (is.null(dates)) {
    # Try to parse dates from layer names
    nm <- names(x)
    # Flexible parse: look for YYYY-MM-DD or YYYYMMDD anywhere
    dates_guess <- parse_date_time(nm, orders = c("Ymd", "Y-m-d", "Y_m_d", "YmdHMS", "Y-m-d H:M:S"), quiet = TRUE)
    if (all(is.na(dates_guess))) {
      warning("Could not parse dates from layer names; using layer index as time.")
      dates <- seq_len(nlyr(x))
    } else {
      dates <- as_date(dates_guess)
    }
  }
  
  # Pick cells
  if (!is.null(coords)) {
    # coords can be c(x, y) or a data.frame with columns x,y
    if (is.vector(coords) && length(coords) == 2) {
      pts <- data.frame(x = coords[1], y = coords[2])
    } else if (is.data.frame(coords) && all(c("x","y") %in% names(coords))) {
      pts <- coords
    } else {
      stop("coords must be c(x,y) or a data.frame with columns x,y")
    }
    
    # Reproject if needed
    if (!is.null(crs_of_coords)) {
      pts_vect <- vect(pts, geom = c("x","y"), crs = crs_of_coords)
      pts_vect <- project(pts_vect, crs(x))
    } else {
      pts_vect <- vect(pts, geom = c("x","y"), crs = crs(x))
    }
  } else {
    # Random cells from valid (non-NA) area
    valid <- !is.na(global(x[[1]], fun = "sum", na.rm = TRUE)) # quick check
    # Build a mask of non-NA in first layer:
    mask1 <- !is.na(x[[1]])
    # Sample n_random cell centers:
    set.seed(42)
    cells <- sample(which(values(mask1[]) == 1), size = n_random)
    xy <- xyFromCell(rast(x[[1]]), cells)
    pts_vect <- vect(as.data.frame(xy), geom = c("x","y"), crs = crs(x))
  }
  
  # Extract values across all layers for each point
  vals <- terra::extract(x, pts_vect)  # returns data.frame: ID + one col per layer
  idcol <- names(vals)[1]
  vals_long <- vals |>
    tidyr::pivot_longer(-all_of(idcol), names_to = "layer", values_to = "value") |>
    group_by(.data[[idcol]]) |>
    mutate(time = dates) |>
    ungroup()
  
  # Plot
  p <- ggplot(vals_long, aes(x = time, y = value, group = .data[[idcol]], color = as.factor(.data[[idcol]]))) +
    geom_line() +
    geom_point() +
    labs(x = "Time", y = "Value", color = "Point ID") +
    theme_minimal()
  
  print(p)
  
  # Return a list with data and plot for further use
  invisible(list(data = vals_long, plot = p, points = pts_vect))
}

# ------------------
# EXAMPLES
# ------------------

# 1) Load a stack
# x <- rast("path/to/your_stack.tif")   # multi-band raster (time in bands)

# 2) Given coordinates (in same CRS as x); if not, pass crs_of_coords
# plot_pixel_ts(x, coords = c(477050, 4331820))

# 3) Random pixel from valid area
# plot_pixel_ts(x, n_random = 3)

# 4) If your layer names don’t have dates, supply them:
# dt <- seq(as.Date("2019-01-01"), by = "month", length.out = nlyr(x))
# plot_pixel_ts(x, coords = c(477050, 4331820), dates = dt)

# 5) Coordinates in WGS84 while raster is projected:
# plot_pixel_ts(x, coords = data.frame(x = -105.27, y = 40.02), crs_of_coords = "EPSG:4326")



## Raster

library(raster)
library(dplyr)
library(ggplot2)
library(lubridate)
library(tidyr)

plot_pixel_ts_raster <- function(s, coords = NULL, n_random = 1, dates = NULL, crs_of_coords = NULL) {
  stopifnot(inherits(s, "RasterStack") || inherits(s, "RasterBrick"))
  
  if (is.null(dates)) {
    nm <- names(s)
    dates_guess <- parse_date_time(nm, orders = c("Ymd", "Y-m-d", "Y_m_d", "YmdHMS", "Y-m-d H:M:S"), quiet = TRUE)
    dates <- if (all(is.na(dates_guess))) seq_len(nlayers(s)) else as_date(dates_guess)
  }
  
  if (!is.null(coords)) {
    pts <- if (is.vector(coords) && length(coords) == 2) data.frame(x = coords[1], y = coords[2]) else coords
    sp <- SpatialPoints(pts, proj4string = CRS(projection(s)))
    if (!is.null(crs_of_coords) && crs_of_coords != projection(s)) {
      sp <- spTransform(SpatialPoints(pts, CRS(crs_of_coords)), CRS(projection(s)))
    }
  } else {
    set.seed(42)
    # sample from non-NA in first layer
    first <- raster::subset(s, 1)
    cells <- sample(Which(!is.na(first), cells = TRUE), n_random)
    xy <- xyFromCell(first, cells)
    sp <- SpatialPoints(xy, proj4string = CRS(projection(s)))
  }
  
  v <- raster::extract(s, sp)  # matrix: rows=points, cols=layers
  out <- as.data.frame(v)
  out$id <- seq_len(nrow(out))
  out_long <- out |>
    tidyr::pivot_longer(-id, names_to = "layer", values_to = "value") |>
    group_by(id) |>
    mutate(time = dates) |>
    ungroup()
  
  p <- ggplot(out_long, aes(time, value, color = as.factor(id))) +
    geom_line() + geom_point() +
    labs(x = "Time", y = "Value", color = "Point ID") +
    theme_minimal()
  print(p)
  
  invisible(list(data = out_long, plot = p, points = sp))
}




###over polygons

  library(terra)
  library(sf)
  library(dplyr)
  library(tidyr)
  library(lubridate)
  library(ggplot2)

sage_poly <- st_read("C:/Users/nayani/mydata/RAD-US/sample_sage_intact.shp")
  
  # x: SpatRaster (multi-band time stack)
  # poly: sf, SpatVector, or a path to a vector file (gpkg/shp/etc.)
  # id_field: name of a polygon attribute to label series (if NULL, uses row index)
  # dates: optional Date vector aligned to bands; if NULL tries to parse from layer names
  # exact: if TRUE, use area-weighted means for partial pixel overlap (recommended)
  
  
