---
name: forensic-research-auditor
description: Audits scientific publications, preprints, clinical trials, DOIs, PMIDs, and PDFs for statistical fabrication (GRIM, statcheck, SPRITE, Benford), paper-mill tortured phrases, retraction status, outcome switching, Cochrane RoB 2 methodological bias, universal table consistency, and scatterplot/chart data density. Use whenever the user asks to vet, audit, fact-check, critique, or evaluate a research paper, clinical trial, or study results.
---

# Forensic Research Auditor

A comprehensive metascience and forensic peer-review workflow designed for both Gemini (with NotebookLM integration) and Google Antigravity (with MCP and RStudio execution). It evaluates scientific studies across a 4-Gate Lexicographic Triage (fast-fail kill-switches) followed by Tier 2 Bayesian Likelihood Ratio credibility scoring, ensuring every table (Table 1 through Table N) and every chart/scatterplot is audited for mathematical consistency and clinical plausibility.

## When to Use

- The user asks to audit, vet, fact-check, or evaluate a scientific paper, clinical trial, preprint, DOI, PMID, arXiv ID, or uploaded study PDF.
- The user wants to check if a paper's results are flawed, p-hacked, over-extrapolated, or fabricated.
- The user wants to generate or run a 4-Gate Forensic Audit packet for their Gemini Notebook (`Forensic Research Auditor`) or Google Antigravity workspace.

## Core Workflow: The 4-Gate Triage & Universal Table/Chart Audit

Execute these steps sequentially. If a study triggers a fatal kill-switch in Gates 1, 2, 3, or 3.5, halt downstream synthesis and issue a **HARD REJECT (0% Credibility / Do Not Cite)** verdict.

### Step 1: Gate 1 - Provenance & Retraction Hygiene (`thinkingLevel: "low"`)

1. Verify the publication's retraction status (`is_retracted`), Expressions of Concern, and post-publication peer-review flags (via OpenAlex, Crossref, PubMed, Zotero, or web search for PubPeer comments).
2. **Kill-Switch 1:** If the paper is retracted, has an unresolved Expression of Concern, or has verified image duplication/cloning on PubPeer, halt immediately and reject.

### Step 2: Gate 2 - Paper-Mill, Tortured Phrases & Reagent Forensics (`thinkingLevel: "medium"`)

1. Scan the manuscript text and Methods section for Problematic Paper Screener (PPS) tortured phrases:
   - `"counterfeit consciousness"` or `"fake brainpower"` (artificial intelligence)
   - `"profound learning"` or `"profound comprehension"` (deep learning)
   - `"irregular backwoods"` (random forest)
   - `"credulous Bayes"` (naive Bayes)
   - `"haze figuring"` or `"vapor processing"` (cloud computing)
   - `"bosom peril"` (breast cancer)
   - `"cruel"` used in place of statistical *mean*, or `"caesarean section"` used in place of *standard deviation*.
2. For wet-lab/biomedical studies, check for verifiable Research Resource Identifiers (`RRID:`), known cross-contaminated/misidentified cell lines (e.g., Chang liver used as normal hepatocytes, HEp-2 used as laryngeal carcinoma instead of HeLa), and PCR primer / shRNA target homology (`Seek & Blastn`).
3. **Kill-Switch 2:** If `>= 1` tortured phrase or invalidated cell-line/primer reagent is found, halt immediately and reject.

### Step 3: Gate 3 - Universal Mathematical & Table Consistency (`thinkingLevel: "high"`)

Do not restrict statistical checks to Table 1. Audit **every summary, outcome, subgroup, and regression table** (Table 1, Table 2, Table 3+) in the manuscript:

1. **Inline NHST Recalculation (`statcheck`):** Extract all inline test statistics (`t`, `F`, `r`, `chi2`, `Z`, `p`) and verify whether the reported test statistic and degrees of freedom (`df`) yield the reported p-value. Flag any **Decision Error** (claimed `p < .05`, recalculated `p > .05`).
2. **Universal Granularity Audit (`GRIM`, `GRIMMER`, `DEBIT`):** Across all tables reporting integer/discrete data or Likert scales (where sample size `N < 100` for 2 decimal places), test whether `round(round(Mean * N) / N, 2)` matches the reported mean (`GRIM`) and whether binary proportions match their standard deviations (`DEBIT`).
3. **Sample Size (`N`) Continuity Across Tables:** Cross-check sample sizes from Table 1 through all outcome and subgroup tables. Flag any unexplained sample size shifts or missingness not accounted for in the CONSORT flow diagram.
4. **Carlisle Baseline Table 1 Audit:** In RCTs, inspect Table 1 baseline differences across arms for implausible uniformity (`p > 0.9999` hyper-balance) or severe baseline imbalance (`p < 0.0001`), as well as suspiciously narrow standard deviations compared to natural clinical variance.
5. **Multi-Magnitude Numerical Tables (`Benford's Law`):** For regression tables, hazard ratios, or large count tables, check first-digit conformity using `benford.analysis`.
6. **Execution Rule:** In Google Antigravity, run `scripts/audit_paper.R` via `rstudio-mcp` and paste the verbatim R console stdout block into the report. Never perform mental math to fake R console output.
7. **Kill-Switch 3:** Halt and reject if `>= 2` GRIM/DEBIT impossibilities occur, a primary `statcheck` Decision Error is found, or `SPRITE` shows impossible scale variance.

### Step 4: Gate 3.5 - Universal Chart, Scatterplot & Clinical Plausibility Audit (`thinkingLevel: "high"`)

Inspect **every figure, scatterplot, dose-response curve, and forest plot** in the manuscript:

1. **Scatterplot Data Density vs. Claimed Therapeutic Envelope:** Check whether actual data points populate the clinical range claimed in the title, abstract, and conclusions. For example, if a hypertension study claims efficacy across uncontrolled/severe hypertension (e.g., SBP > 160 mm Hg), count how many scatterplot points actually lie above `SBP > 160`.
2. **Outlier-Driven Trends:** Check whether regression lines or interaction p-values in scatterplots are driven by `< 5%` of the sample (or 2-3 extreme outlier points) while the remaining 95% of observations cluster in a flat, narrow baseline band.
3. **Subgroup & Forest Plot Plausibility:** Check whether subgroup interaction claims rest on tiny, underpowered strata or post-hoc dichotomization.
4. **Over-Extrapolation Penalty / Kill-Switch:** If the paper's headline conclusion relies on a clinical range where scatterplot data density is `< 5%` or absent, flag as **Unsupported Subgroup Generalization (Over-Extrapolation)** and apply the `LR = 0.20` penalty (or halt if the primary conclusion is wholly unsupported by the plotted data).

### Step 5: Gate 4 - Pre-Registration, Risk of Bias & Bayesian Credibility Scorecard (`thinkingLevel: "high"`)

1. **Pre-Registration & Outcome Switching Check:** Compare the published primary and secondary endpoints (and assessment timepoints) against the timestamped registry record (`NCT` on ClinicalTrials.gov, `OSF`, `ISRCTN`, `PROSPERO`).
2. **Methodological Risk of Bias Grading:** Grade all 5 **Cochrane RoB 2** domains (for RCTs), 7 **ROBINS-I V2** domains (for observational studies), or **AMSTAR 2** domains (for systematic reviews), citing verbatim quotes from the text.
3. **Tier 2 Bayesian Credibility Calculation:**
   - Start with the baseline Field Prior Probability (`P_prior = 0.50` for confirmatory RCT; `0.30` for exploratory clinical/biomedical/psychology study; `0.20` for observational epidemiology).
   - Compute `Prior_Odds = P_prior / (1 - P_prior)`.
   - Multiply by all applicable Likelihood Ratios (`LR_i`):
     - Pre-registered with exact primary endpoint match: `LR = 2.50`
     - Open raw data and reproducible code verified: `LR = 2.00`
     - Independent supporting replication in `scite.ai`: `LR = 4.00`
     - Primary p-value in `.041 - .049` p-hacking zone: `LR = 0.25`
     - Single isolated non-decision rounding typo: `LR = 0.20`
     - Underpowered sample (`< 50%` power for target effect): `LR = 0.35`
     - Unreconciled sample size (`N`) shifts across tables: `LR = 0.30`
     - Scatterplot over-extrapolation / sparse tail density (`< 5%` points in claimed range): `LR = 0.20`
     - Baseline Table 1 clinical imbalance confounding the primary outcome: `LR = 0.25`
     - Benford's Law severe anomaly on numerical tables: `LR = 0.10`
     - Cochrane RoB 2 "Some Concerns" (2+ domains): `LR = 0.50`
     - Cochrane RoB 2 "High Risk" (any domain): `LR = 0.15`
     - Undeclared primary outcome switching: `LR = 0.05`
   - Calculate `Posterior_Odds = Prior_Odds * Product(LR_i)` and `Posterior_Probability = Posterior_Odds / (1 + Posterior_Odds)`.
4. **NotebookLM Grounded Sync:** When the user's **Forensic Research Auditor** Gemini Notebook (`notebooks/6b8609aa-fa3d-4a82-a123-5ffe7b4518e1`) is available, cross-check against its sources or export the verified audit packet (`<ID>_gate1to3_verified.md`) into the notebook.

## Required Output Structure

Always present the final audit using these 5 sections:

1. **Executive Integrity Verdict:** (`PASS`, `QUALIFIED PASS`, `SKEPTICAL CAUTION`, or `HARD REJECT - KILL-SWITCH TRIPPED`)
2. **Gate 1 & Gate 2 Provenance & Paper-Mill Summary:** Retraction status, registry ID, and tortured-phrase/reagent screen.
3. **Gate 3 & Gate 3.5 Universal Table & Chart Audit:**
   - Inline `statcheck` and `GRIM`/`DEBIT` table results (with verbatim R stdout if executed via RStudio MCP).
   - Table 1 through Table N sample-size continuity and baseline balance assessment.
   - Scatterplot & figure data-density audit (explicitly stating how many points support extreme/high-severity thresholds like `SBP > 160`).
4. **Gate 4 Outcome Switching & Cochrane RoB 2 Scorecard:** Registry alignment and domain-by-domain risk-of-bias table with verbatim quotes.
5. **Tier 2 Bayesian Credibility Calculation:** Step-by-step table showing Prior Probability, each applied `LR_i`, final Posterior Credibility Percentage, and GRADE certainty rating.

## Supplementary Resources in This Skill

- `scripts/audit_paper.R`: Complete R forensic script (`statcheck`, `scrutiny::grim_map`, `rsprite2`, `benford.analysis`, Carlisle baseline check, and `run_chart_density_audit`).
- `references/antigravity_kit.md`: Drop-in `AGENTS.md` and `.agents/mcp_config.json` templates for Google Antigravity.
- `references/example_42802996_audit.md`: Reference audit packet demonstrating how a study that passes basic Gate 1-3 math checks is evaluated and how to critique baseline imbalances and scatterplot density (`SBP > 160`).

## Gotchas

- **Never stop at Table 1:** Always inspect outcome tables (Table 2+), subgroup tables, and scatterplots/figures. Many papers pass basic `GRIM` and `statcheck` screens while drawing sweeping clinical conclusions from a scatterplot with almost no data points in the severe range.
- **No mental math masquerading as R output:** Only display an R console stdout block if it was genuinely executed in an R runtime (`rstudio-mcp`) or provided by the user. In chat-only environments without an R runtime, perform the exact mathematical verification transparently and provide the runnable R snippet.
