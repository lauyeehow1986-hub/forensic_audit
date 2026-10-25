# 4-Gate Forensic Research Audit Packet
**Target Study:** *Safety, Acceptability and Efficacy of Noninvasive Transcutaneous-Autonomic Neuromodulation in Uncontrolled Hypertension*  
**Journal:** *Hypertension* (American Heart Association / Wolters Kluwer)  
**DOI:** `10.1161/HYPERTENSIONAHA.126.27847`  
**PMID:** `42802996`  
**Trial Pre-Registration:** ClinicalTrials.gov `NCT05179343`  
**Audit Date:** 2026-10-25  
**Auditor Engine:** Google Antigravity (Gemini 3.8 Flash Swarm)  
**NotebookLM Destination:** [Forensic Research Auditor](https://gemini.google.com/notebook/6b8609aa-fa3d-4a82-a123-5ffe7b4518e1)

---

## 1. Provenance & Triage Summary (Gate 1 & Gate 2)

| Forensic Gate | Gate Status | Verdict & Notes |
| :--- | :--- | :--- |
| **Gate 1: Provenance Scout** | **PASS** | `is_retracted == FALSE`. Published ahead of print (Sep 28, 2026). No Expression of Concern. PubPeer API returned 404 (0 comments / 0 image duplications reported). Verified trial registry: `NCT05179343`. |
| **Gate 2: Paper-Mill & Reagent Screener** | **PASS** | 0 tortured phrases detected. Legitimate clinical RCT conducted across NHS trusts / academic institutions (Queen Mary University of London, Imperial College London). Human medical device trial (no cell lines, no PCR primers requiring RRID/BLAST verification). |

---

## 2. Gate 3: Forensic Statistical Audit (Verbatim R Stdout)

```text
=======================================================================
FORENSIC STATISTICAL AUDIT STDOUT (scripts/audit_paper.R)
=======================================================================

--- 1. STATCHECK AUDIT ---
Extracting statistics...
  |======================================================================| 100%
  source                        raw  computed_p error decision_error
1     01    t(61) = 0.694, p = 0.49 0.490316786 FALSE          FALSE
2     01   t(61) = -0.347, p = 0.73 0.729785618 FALSE          FALSE
3     01 F(1, 59) = 9.58, p = 0.003 0.003006731 FALSE          FALSE

--- 2. GRIM & DEBIT (SCRUTINY) AUDIT ---
GRIM all checks:
# A tibble: 3 × 5
  x         n consistency probability sd   
  <chr> <dbl> <lgl>             <dbl> <chr>
1 47.2     63 TRUE                  0 12.4 
2 150      63 TRUE                  0 14.2 
3 95       63 TRUE                  0 8.6  
GRIM impossible means:
# A tibble: 0 × 5
# ℹ 5 variables: x <chr>, n <dbl>, consistency <lgl>, probability <dbl>,
#   sd <chr>
Kill switch tripped:
[1] FALSE

--- 3. SPRITE BOUNDARY VARIANCE CHECK ---
SPRITE possible distributions found:
# A tibble: 2 × 6
     id outcome distribution  mean    sd iterations
  <int> <chr>   <list>       <dbl> <dbl>      <dbl>
1     1 success <dbl [63]>    11.4  4.25        747
2     2 success <dbl [63]>    11.4  4.23        750

--- 4. CARLISLE TABLE 1 BASELINE AUDIT ---
Carlisle combined p-value:
[1] 0.7070982
Carlisle kill switch tripped:
[1] FALSE

=======================================================================
END OF FORENSIC AUDIT STDOUT
=======================================================================
```

---

## 3. Gate 4: Methodological Appraisal & Outcome Alignment

### 3.1 Pre-Registration Alignment (NCT05179343 vs Published Report)
* **Registered Primary Outcome (`NCT05179343`):**
  > *"Change in average daytime ambulatory Systolic Blood Pressure (SBP) from baseline to the end of treatment. Daytime SBP values will be obtained with 24hr ABPM (Time Frame: from baseline to 3 months)"*
* **Published Primary Outcome (Verbatim from Paper):**
  > *"The primary efficacy end point was change in daytime ambulatory SBP from baseline to 3 months."*
* **Outcome Concordance Verdict:** **100% Exact Match.** No post-hoc primary endpoint switching occurred. The null result was faithfully declared and reported (*"between-group difference, 2.35 mm Hg [95% CI, -4.37 to 9.07]; P=0.49"*).

### 3.2 Cochrane Risk of Bias 2 (RoB 2) Assessment

| RoB 2 Domain | Rating | Supporting Verbatim Text / Evidence |
| :--- | :--- | :--- |
| **D1: Randomisation process** | **Low Risk** | *"SCRATCH-HTN... was a double-blind, sham-controlled, phase 2a trial... Sixty-three patients... were randomized 2:1 to tAN or sham."* Baseline balance supported by Carlisle check ($p = 0.707$). |
| **D2: Deviations from intended interventions** | **Low Risk** | *"Participants self-administered active tAN or sham treatment for 30 minutes daily for 14 days, then 10 weekly sessions."* Double-blind sham design with identical appearance and procedural administration. |
| **D3: Missing outcome data** | **Low Risk** | Intention-to-treat / complete 24-hour ambulatory blood pressure monitoring (ABPM) protocol with reported adherence. |
| **D4: Measurement of the outcome** | **Low Risk** | Automated, objective 24-hour ABPM monitors utilized; blinding preserved for both participants and outcome assessors. |
| **D5: Selection of the reported result** | **Low Risk** | Analyzed according to pre-registered protocol (`NCT05179343`). Primary null efficacy result fully presented without selective omission. Interaction analysis declared as pre-specified adjusted analysis. |
| **Overall RoB 2 Judgement** | **Low Risk of Bias** | Rigorous trial methodology with transparent negative trial reporting. |

---

## 4. Tier 2: Bayesian Credibility Calculation

### Inputs & Priors
* **Study Type:** Phase 2a Pilot / Exploratory RCT
  * Baseline Prior Probability ($P_{\text{prior}}$): $0.30$ (Exploratory biomedical trial) $\to$ **Prior Odds = 0.4286**
  * *(Reference Confirmatory RCT Prior ($P_{\text{prior}} = 0.50$): Prior Odds = 1.0000)*
* **Likelihood Ratios ($LR_i$):**
  * Pre-registered with exact primary endpoint match: **$\text{LR} = 2.50$**
  * Underpowered sample ($N = 63$, $< 50\%$ power for minor BP differences): **$\text{LR} = 0.35$**
  * Primary p-value ($p = 0.49$, null result honestly reported, not in p-hacking zone): **$\text{LR} = 1.00$**
  * Zero mathematical / rounding errors detected: **$\text{LR} = 1.00$**
  * Cochrane RoB 2 Low Risk across all domains: **$\text{LR} = 1.00$**
  * No outcome switching: **$\text{LR} = 1.00$**

$$\text{Product}(LR_i) = 2.50 \times 0.35 = 0.875$$

### Posterior Credibility Calculation (Deterministic R Engine)
```text
Product of Likelihood Ratios (Product LR_i): 0.875 

Case A: Exploratory Prior (P = 0.30, Odds = 0.4286)
  Posterior Odds: 0.375 
  Posterior Credibility Probability: 27.27%

Case B: RCT Baseline Prior (P = 0.50, Odds = 1.0000)
  Posterior Odds: 0.875 
  Posterior Credibility Probability: 46.67%
```

---

## 5. NotebookLM Ingestion Instructions
This verified audit packet (`42802996_gate1to3_verified.md`) is formatted for direct upload into the **Forensic Research Auditor** Gemini Notebook:
* URL: `https://gemini.google.com/notebook/6b8609aa-fa3d-4a82-a123-5ffe7b4518e1`
* Supported artifacts: Upload this markdown document alongside the trial protocol (`audit_reports/NCT05179343_protocol.json`) and pubmed XML (`audit_reports/42802996_pubmed.xml`).
