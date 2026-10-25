library(statcheck)
library(scrutiny)
library(rsprite2)
library(benford.analysis)
library(tibble)

# 1. STATCHECK: Recalculate inline APA NHST p-values across all text sections
run_statcheck_audit <- function(paper_text_or_pdf_path, is_pdf = FALSE) {
  res <- if (is_pdf) {
    statcheck::checkPDF(paper_text_or_pdf_path)
  } else {
    statcheck::statcheck(paper_text_or_pdf_path)
  }
  if (is.null(res) || nrow(res) == 0) {
    return(tibble::tibble(Status = "No APA NHST strings detected"))
  }
  names(res) <- tolower(names(res))
  cols_to_keep <- intersect(c("source", "raw", "computed_p", "error", "decision_error"), names(res))
  return(res[, cols_to_keep])
}

# 2. GRIM & DEBIT (scrutiny): Audit ALL summary tables (Table 1, Table 2, Subgroups)
run_all_tables_audit <- function(named_tables_list) {
  results <- lapply(names(named_tables_list), function(tbl_name) {
    df <- tibble::as_tibble(named_tables_list[[tbl_name]])
    grim_res <- scrutiny::grim_map(df)
    flagged <- subset(grim_res, consistency == FALSE)
    list(table_name = tbl_name, all_checks = grim_res, impossible_means = flagged)
  })
  names(results) <- names(named_tables_list)
  return(results)
}

# 3. SPRITE (rsprite2): Reconstruct distributions to check scale boundary variance
run_sprite_check <- function(mean_val, sd_val, n_obs, min_scale = 1, max_scale = 7) {
  params <- rsprite2::set_parameters(
    mean = mean_val, sd = sd_val, n_obs = n_obs,
    min_val = min_scale, max_val = max_scale
  )
  possibilities <- rsprite2::find_possible_distributions(params, seed = 42, n_distributions = 5)
  return(possibilities)
}

# 4. CARLISLE TABLE 1 BASELINE UNIFORMITY & IMBALANCE AUDIT
run_carlisle_baseline_audit <- function(baseline_p_values) {
  chisq_stat <- -2 * sum(log(baseline_p_values))
  df <- 2 * length(baseline_p_values)
  combined_p <- pchisq(chisq_stat, df = df, lower.tail = FALSE)
  return(list(
    combined_p_value = combined_p,
    severe_imbalance_risk = (combined_p < 0.05),
    kill_switch_tripped = (combined_p < 0.0001 || combined_p > 0.9999)
  ))
}

# 5. BENFORD'S LAW: Audit ALL multi-magnitude numerical tables
run_comprehensive_benford_audit <- function(numeric_vector, table_label = "Dataset") {
  df <- data.frame(val = numeric_vector)
  bfd <- benford.analysis::benford(df$val, number.of.digits = 1, discrete = TRUE)
  return(list(
    label = table_label,
    mad_conformity = bfd$MAD.conformity,
    chisq_p_value  = bfd$stats$chisq$p.value,
    suspects       = benford.analysis::getSuspects(bfd, df)
  ))
}

# 6. SCATTERPLOT & SUBGROUP DENSITY AUDIT (Universal Chart Scrutiny)
run_chart_density_audit <- function(x_values, y_values, claimed_threshold_x) {
  total_points <- length(x_values)
  high_severity_mask <- x_values >= claimed_threshold_x
  count_high_sev <- sum(high_severity_mask, na.rm = TRUE)
  pct_high_sev <- (count_high_sev / total_points) * 100
  marginal_support <- pct_high_sev < 5.0
  
  return(list(
    total_observations = total_points,
    points_in_claimed_extreme_zone = count_high_sev,
    percentage_in_extreme_zone = pct_high_sev,
    unsupported_extrapolation_risk = marginal_support
  ))
}
