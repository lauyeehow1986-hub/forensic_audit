# R Forensic Statistical & Chart Auditing Script (`audit_paper.R`)

Save the R code below as `./scripts/audit_paper.R` in your Google Antigravity workspace for execution via `rstudio-mcp`:

```r
# Autonomous Forensic Research Auditing Suite (scripts/audit_paper.R)
# Universal Table & Chart Auditing Engine (statcheck, GRIM/DEBIT, SPRITE, Carlisle, Benford, Chart Density)
# Supports both pure base R runtime (zero external dependencies) and enhanced mode via CRAN packages.

suppressPackageStartupMessages({
  has_statcheck <- requireNamespace("statcheck", quietly = TRUE)
  has_scrutiny  <- requireNamespace("scrutiny", quietly = TRUE)
  has_rsprite2  <- requireNamespace("rsprite2", quietly = TRUE)
  has_benford   <- requireNamespace("benford.analysis", quietly = TRUE)
  has_tibble    <- requireNamespace("tibble", quietly = TRUE)
})

# 1. STATCHECK: Recalculate inline APA NHST p-values across all text sections
run_statcheck_audit <- function(paper_text_or_pdf_path, is_pdf = FALSE) {
  if (has_statcheck) {
    res <- if (is_pdf) {
      statcheck::checkPDF(paper_text_or_pdf_path)
    } else {
      statcheck::statcheck(paper_text_or_pdf_path)
    }
    if (is.null(res) || nrow(res) == 0) {
      return(data.frame(Status = "No APA NHST strings detected", stringsAsFactors = FALSE))
    }
    names(res) <- tolower(names(res))
    cols_to_keep <- intersect(c("source", "raw", "computed_p", "error", "decision_error"), names(res))
    return(res[, cols_to_keep])
  } else {
    # Robust Base R APA NHST regex parser and statistical recalculation
    txt <- if (is_pdf) {
      if (file.exists(paper_text_or_pdf_path)) {
        tryCatch(paste(readLines(paper_text_or_pdf_path, warn = FALSE), collapse = "\n"), error = function(e) "")
      } else ""
    } else {
      paper_text_or_pdf_path
    }
    
    # Patterns for t, F, z, r
    patterns <- list(
      t = "t\\s*\\(\\s*([0-9.]+)\\s*\\)\\s*=\\s*(-?[0-9.]+)\\s*,\\s*p\\s*([<>=])\\s*([0-9]*\\.?[0-9]+)",
      F = "F\\s*\\(\\s*([0-9.]+)\\s*,\\s*([0-9.]+)\\s*\\)\\s*=\\s*(-?[0-9.]+)\\s*,\\s*p\\s*([<>=])\\s*([0-9]*\\.?[0-9]+)",
      z = "z\\s*=\\s*(-?[0-9.]+)\\s*,\\s*p\\s*([<>=])\\s*([0-9]*\\.?[0-9]+)",
      r = "r\\s*\\(\\s*([0-9.]+)\\s*\\)\\s*=\\s*(-?[0-9.]+)\\s*,\\s*p\\s*([<>=])\\s*([0-9]*\\.?[0-9]+)"
    )
    
    extracted <- list()
    idx <- 1
    
    # Check t tests
    t_matches <- gregexpr(patterns$t, txt, perl = TRUE)[[1]]
    if (t_matches[1] != -1) {
      match_lens <- attr(t_matches, "match.length")
      for (m in seq_along(t_matches)) {
        sub_str <- substr(txt, t_matches[m], t_matches[m] + match_lens[m] - 1)
        caps <- regmatches(sub_str, regexec(patterns$t, sub_str, perl = TRUE))[[1]]
        if (length(caps) >= 5) {
          df <- as.numeric(caps[2])
          stat <- as.numeric(caps[3])
          op <- caps[4]
          p_rep <- as.numeric(caps[5])
          p_comp <- 2 * (1 - pt(abs(stat), df = df))
          err <- abs(p_comp - p_rep) > 0.01 && !(op == "<" && p_comp < p_rep)
          dec_err <- (p_rep <= 0.05 && p_comp > 0.05) || (p_rep > 0.05 && p_comp <= 0.05)
          extracted[[idx]] <- data.frame(source = sprintf("%02d", idx), raw = sub_str, computed_p = p_comp, error = err, decision_error = dec_err, stringsAsFactors = FALSE)
          idx <- idx + 1
        }
      }
    }
    
    # Check F tests
    F_matches <- gregexpr(patterns$F, txt, perl = TRUE)[[1]]
    if (F_matches[1] != -1) {
      match_lens <- attr(F_matches, "match.length")
      for (m in seq_along(F_matches)) {
        sub_str <- substr(txt, F_matches[m], F_matches[m] + match_lens[m] - 1)
        caps <- regmatches(sub_str, regexec(patterns$F, sub_str, perl = TRUE))[[1]]
        if (length(caps) >= 6) {
          df1 <- as.numeric(caps[2])
          df2 <- as.numeric(caps[3])
          stat <- as.numeric(caps[4])
          op <- caps[5]
          p_rep <- as.numeric(caps[6])
          p_comp <- 1 - pf(stat, df1 = df1, df2 = df2)
          err <- abs(p_comp - p_rep) > 0.01 && !(op == "<" && p_comp < p_rep)
          dec_err <- (p_rep <= 0.05 && p_comp > 0.05) || (p_rep > 0.05 && p_comp <= 0.05)
          extracted[[idx]] <- data.frame(source = sprintf("%02d", idx), raw = sub_str, computed_p = p_comp, error = err, decision_error = dec_err, stringsAsFactors = FALSE)
          idx <- idx + 1
        }
      }
    }
    
    # Check z tests
    z_matches <- gregexpr(patterns$z, txt, perl = TRUE)[[1]]
    if (z_matches[1] != -1) {
      match_lens <- attr(z_matches, "match.length")
      for (m in seq_along(z_matches)) {
        sub_str <- substr(txt, z_matches[m], z_matches[m] + match_lens[m] - 1)
        caps <- regmatches(sub_str, regexec(patterns$z, sub_str, perl = TRUE))[[1]]
        if (length(caps) >= 4) {
          stat <- as.numeric(caps[2])
          op <- caps[3]
          p_rep <- as.numeric(caps[4])
          p_comp <- 2 * (1 - pnorm(abs(stat)))
          err <- abs(p_comp - p_rep) > 0.01 && !(op == "<" && p_comp < p_rep)
          dec_err <- (p_rep <= 0.05 && p_comp > 0.05) || (p_rep > 0.05 && p_comp <= 0.05)
          extracted[[idx]] <- data.frame(source = sprintf("%02d", idx), raw = sub_str, computed_p = p_comp, error = err, decision_error = dec_err, stringsAsFactors = FALSE)
          idx <- idx + 1
        }
      }
    }

    # Check r tests
    r_matches <- gregexpr(patterns$r, txt, perl = TRUE)[[1]]
    if (r_matches[1] != -1) {
      match_lens <- attr(r_matches, "match.length")
      for (m in seq_along(r_matches)) {
        sub_str <- substr(txt, r_matches[m], r_matches[m] + match_lens[m] - 1)
        caps <- regmatches(sub_str, regexec(patterns$r, sub_str, perl = TRUE))[[1]]
        if (length(caps) >= 5) {
          df <- as.numeric(caps[2])
          stat <- as.numeric(caps[3])
          op <- caps[4]
          p_rep <- as.numeric(caps[5])
          t_stat <- stat * sqrt(df / (1 - stat^2))
          p_comp <- 2 * (1 - pt(abs(t_stat), df = df))
          err <- abs(p_comp - p_rep) > 0.01 && !(op == "<" && p_comp < p_rep)
          dec_err <- (p_rep <= 0.05 && p_comp > 0.05) || (p_rep > 0.05 && p_comp <= 0.05)
          extracted[[idx]] <- data.frame(source = sprintf("%02d", idx), raw = sub_str, computed_p = p_comp, error = err, decision_error = dec_err, stringsAsFactors = FALSE)
          idx <- idx + 1
        }
      }
    }
    
    if (length(extracted) == 0) {
      return(data.frame(Status = "No APA NHST strings detected", stringsAsFactors = FALSE))
    }
    return(do.call(rbind, extracted))
  }
}

# 2. GRIM & DEBIT (scrutiny): Audit ALL summary tables (Table 1, Table 2, Subgroups)
run_all_tables_audit <- function(named_tables_list) {
  results <- lapply(names(named_tables_list), function(tbl_name) {
    df <- named_tables_list[[tbl_name]]
    if (has_scrutiny) {
      df_tbl <- if (has_tibble) tibble::as_tibble(df) else as.data.frame(df, stringsAsFactors = FALSE)
      grim_res <- scrutiny::grim_map(df_tbl)
      flagged <- subset(grim_res, consistency == FALSE)
      list(table_name = tbl_name, all_checks = grim_res, impossible_means = flagged)
    } else {
      # Pure Base R GRIM & proportion granularity audit
      x_vals <- as.character(df$x)
      n_vals <- as.numeric(df$n)
      
      checks <- lapply(seq_along(x_vals), function(i) {
        x_str <- x_vals[i]
        n_val <- n_vals[i]
        x_num <- as.numeric(x_str)
        dec_places <- if (grepl("\\.", x_str)) nchar(strsplit(x_str, "\\.")[[1]][2]) else 0
        
        # Percentage check: k / n * 100 rounded
        possible_k <- 0:n_val
        pcts <- round(possible_k / n_val * 100, dec_places)
        match_pct <- any(sprintf(paste0("%.", dec_places, "f"), pcts) == x_str)
        
        # Continuous mean check: sum / n rounded
        possible_sums <- round(x_num * n_val) + (-2:2)
        means <- round(possible_sums / n_val, dec_places)
        match_mean <- any(sprintf(paste0("%.", dec_places, "f"), means) == x_str)
        
        is_consistent <- match_pct || match_mean
        data.frame(x = x_str, n = n_val, consistency = is_consistent, stringsAsFactors = FALSE)
      })
      all_df <- do.call(rbind, checks)
      flagged <- subset(all_df, consistency == FALSE)
      list(table_name = tbl_name, all_checks = all_df, impossible_means = flagged)
    }
  })
  names(results) <- names(named_tables_list)
  return(results)
}

# 3. SPRITE (rsprite2): Reconstruct distributions to check scale boundary variance
run_sprite_check <- function(mean_val, sd_val, n_obs, min_scale = 1, max_scale = 7) {
  if (has_rsprite2) {
    params <- rsprite2::set_parameters(
      mean = mean_val, sd = sd_val, n_obs = n_obs,
      min_val = min_scale, max_val = max_scale
    )
    possibilities <- rsprite2::find_possible_distributions(params, seed = 42, n_distributions = 5)
    return(possibilities)
  } else {
    # Analytical scale variance bounds check
    max_var <- (mean_val - min_scale) * (max_scale - mean_val)
    observed_var <- sd_val^2
    is_possible <- (mean_val >= min_scale) && (mean_val <= max_scale) && (observed_var <= max_var)
    
    return(list(
      mean = mean_val,
      sd = sd_val,
      n_obs = n_obs,
      min_scale = min_scale,
      max_scale = max_scale,
      max_theoretical_variance = max_var,
      observed_variance = observed_var,
      variance_bounded = (observed_var <= max_var),
      status = if (is_possible) "Valid scale parameters (rsprite2 optional for sample generation)" else "Mathematically impossible scale variance"
    ))
  }
}

# 4. CARLISLE TABLE 1 BASELINE UNIFORMITY & IMBALANCE AUDIT
run_carlisle_baseline_audit <- function(baseline_p_values) {
  valid_p <- baseline_p_values[!is.na(baseline_p_values)]
  if (length(valid_p) == 0) {
    return(list(
      combined_p_value = NA_real_,
      severe_imbalance_risk = FALSE,
      kill_switch_tripped = FALSE,
      error = "No valid p-values provided"
    ))
  }
  # Clamp extreme values to protect against log(0)
  clamped_p <- pmin(pmax(valid_p, 1e-15), 1.0 - 1e-15)
  chisq_stat <- -2 * sum(log(clamped_p))
  df <- 2 * length(clamped_p)
  combined_p <- pchisq(chisq_stat, df = df, lower.tail = FALSE)
  return(list(
    combined_p_value = combined_p,
    severe_imbalance_risk = (combined_p < 0.05),
    kill_switch_tripped = (combined_p < 0.0001 || combined_p > 0.9999)
  ))
}

# 5. BENFORD'S LAW: Audit ALL multi-magnitude numerical tables
run_comprehensive_benford_audit <- function(numeric_vector, table_label = "Dataset") {
  valid_vec <- numeric_vector[!is.na(numeric_vector) & is.finite(numeric_vector) & numeric_vector != 0]
  if (has_benford) {
    df <- data.frame(val = valid_vec)
    bfd <- benford.analysis::benford(df$val, number.of.digits = 1, discrete = TRUE)
    return(list(
      label = table_label,
      mad_conformity = bfd$MAD.conformity,
      chisq_p_value  = bfd$stats$chisq$p.value,
      suspects       = benford.analysis::getSuspects(bfd, df)
    ))
  } else {
    # Base R First-Digit Benford analysis
    first_digits <- as.numeric(substr(gsub("[^1-9]", "", sprintf("%.10f", abs(valid_vec))), 1, 1))
    first_digits <- first_digits[!is.na(first_digits) & first_digits >= 1 & first_digits <= 9]
    n_digits <- length(first_digits)
    
    if (n_digits == 0) {
      return(list(label = table_label, mad_conformity = NA_character_, chisq_p_value = NA_real_, suspects = NULL))
    }
    
    observed_counts <- table(factor(first_digits, levels = 1:9))
    observed_props <- observed_counts / n_digits
    expected_props <- log10(1 + 1 / (1:9))
    expected_counts <- n_digits * expected_props
    
    mad <- mean(abs(observed_props - expected_props))
    mad_conf <- if (mad <= 0.006) "Close conformity" else if (mad <= 0.012) "Acceptable conformity" else if (mad <= 0.015) "Marginally acceptable conformity" else "Nonconformity"
    
    chisq_stat <- sum((observed_counts - expected_counts)^2 / expected_counts)
    chisq_p <- pchisq(chisq_stat, df = 8, lower.tail = FALSE)
    
    discrepancies <- abs(observed_props - expected_props) / sqrt(expected_props * (1 - expected_props) / n_digits)
    suspect_digits <- which(discrepancies > 1.96)
    
    return(list(
      label = table_label,
      mad_conformity = mad_conf,
      chisq_p_value  = chisq_p,
      suspects       = if (length(suspect_digits) > 0) paste("Excess in digit(s):", paste(suspect_digits, collapse = ", ")) else "None"
    ))
  }
}

# 6. SCATTERPLOT & SUBGROUP DENSITY AUDIT (Universal Chart Scrutiny)
run_chart_density_audit <- function(x_values, y_values, claimed_threshold_x) {
  if (missing(x_values) || length(x_values) == 0) {
    return(list(
      total_observations = 0,
      points_in_claimed_extreme_zone = 0,
      percentage_in_extreme_zone = 0,
      unsupported_extrapolation_risk = TRUE,
      error = "Empty or missing x_values"
    ))
  }
  valid_mask <- !is.na(x_values) & is.finite(x_values)
  valid_x <- x_values[valid_mask]
  total_points <- length(valid_x)
  
  if (total_points == 0) {
    return(list(
      total_observations = 0,
      points_in_claimed_extreme_zone = 0,
      percentage_in_extreme_zone = 0,
      unsupported_extrapolation_risk = TRUE,
      error = "No non-missing finite values"
    ))
  }
  
  high_severity_mask <- valid_x >= claimed_threshold_x
  count_high_sev <- sum(high_severity_mask)
  pct_high_sev <- (count_high_sev / total_points) * 100
  marginal_support <- pct_high_sev < 5.0
  
  return(list(
    total_observations = total_points,
    points_in_claimed_extreme_zone = count_high_sev,
    percentage_in_extreme_zone = pct_high_sev,
    unsupported_extrapolation_risk = marginal_support
  ))
}
```
