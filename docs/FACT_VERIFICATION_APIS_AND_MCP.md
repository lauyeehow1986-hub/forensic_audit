# Ground-Truth Fact Verification: MCP Servers & APIs Architecture

The **Forensic Research Auditor** pipeline enforces absolute zero-hallucination verification. Every finding, claim, retraction check, table audit, and protocol discrepancy is substantiated by direct programmatic queries to authoritative metadata providers, registries, and computation engines.

This document provides a comprehensive reference of all **Model Context Protocol (MCP) servers** and **REST APIs** utilized across the forensic audit lifecycle.

---

## 1. Audit Gate to Provider Mapping Matrix

| Forensic Audit Gate | Primary MCP Server(s) | Direct REST / Programmatic APIs | Facts & Evidence Verified |
| :--- | :--- | :--- | :--- |
| **Gate 1: Retraction & EoC Status** | `papers-openalex`, `pubmed`, `zotero` | OpenAlex API, CrossRef API, Europe PMC REST API, NCBI E-utilities | Real-time `is_retracted` status, CrossMark update notices, Expressions of Concern (EoC), PubPeer alerts, errata/corrigenda deposits. |
| **Gate 2: Paper-Mill & Reagent Forensics** | `pubmed`, `arxiv` | Problematic Paper Screener API / Lexicon, ICLAC Database, NCBI Nucleotide | Flagged paper-mill "tortured phrases", cell line misidentification (ICLAC register), nucleotide primer sequence validation against target organisms. |
| **Gate 3: Universal Statistical Audit** | `rstudio-mcp` | R 4.x runtime (`statcheck`, `scrutiny`, `rsprite2`, `benford.analysis`) | Degrees of freedom, test statistics ($t, F, z, r, \chi^2$), recalculation of reported vs. computed $p$-values, GRIM test for mathematically impossible integer means across ALL tables, Benford first-digit distribution. |
| **Gate 3.5: Chart & Density Audit** | `rstudio-mcp` | R runtime (`run_chart_density_audit`) | Individual participant data points on scatterplots, clinical severity threshold support ($<5\%$ tail density threshold), sample size ($N$) cross-table reconciliation. |
| **Gate 4: Protocol Pre-Registration Audit** | `pubmed` | ClinicalTrials.gov REST API v2, WHO ICTRP, OSF API, PROSPERO | Inception-date timestamped primary vs. secondary outcomes, protocol amendments, silent outcome switching, demotion of failed endpoints, post-hoc subgroup spin. |
| **Gate 4: Cochrane RoB 2 Grading** | `pubmed`, `zotero` | PubMed Central (PMC) OA API, Europe PMC FullText | Verbatim manuscript quotes for random sequence generation, allocation concealment, blinding/masking, differential co-intervention rates, and attrition. |
| **Ingestion to Knowledge Base** | Gemini Notebook Integration | Google Gemini Notebook API (`notebookLM`) | Multimodal evidence synthesis, cross-trial meta-analytic chronicling, and grounded conversational deep dives. |

---

## 2. Model Context Protocol (MCP) Servers

The repository defines its MCP connections in [`.agents/mcp_config.json`](../.agents/mcp_config.json). Each server exposes native tools directly to the auditing swarm:

```json
{
  "mcpServers": {
    "papers-openalex": {
      "command": "papers",
      "args": ["mcp", "start", "--stdio"],
      "env": { "OPENALEX_MAILTO": "your-email@institution.edu" }
    },
    "pubmed": {
      "command": "uvx",
      "args": ["pubmed-search-mcp"],
      "env": { "NCBI_API_KEY": "YOUR_OPTIONAL_NCBI_API_KEY", "NCBI_EMAIL": "your-email@institution.edu" }
    },
    "arxiv": {
      "command": "uvx",
      "args": ["arxiv-mcp-server", "--storage-path", "./arxiv_pdfs"]
    },
    "zotero": {
      "command": "zotero-mcp",
      "args": [],
      "env": { "ZOTERO_LOCAL": "true" }
    },
    "rstudio": {
      "command": "rstudio-mcp",
      "args": ["--config", "~/.rstudio-mcp/config.yaml"],
      "env": { "RSTUDIO_MCP_DEBUG": "false" }
    }
  }
}
```

### Detailed Server Specifications

### 1. `papers-openalex` (`papers`)
- **Transport:** `stdio` (CLI binary via `papers.exe` / Python)
- **Data Source:** [OpenAlex Global Scholarly Index](https://openalex.org/) (250M+ scientific publications)
- **Core Capabilities:**
  - Fast DOI-to-metadata resolution.
  - Verification of global retraction status (`is_retracted: boolean`).
  - Institutional and funding provenance extraction.
  - Citation trajectory analysis to evaluate whether citations spiked post-retraction or post-concern.

### 2. `pubmed` (`pubmed-search-mcp`)
- **Transport:** `stdio` (managed via `uvx pubmed-search-mcp`)
- **Data Source:** [National Library of Medicine (NLM)](https://pubmed.ncbi.nlm.nih.gov/) / NCBI
- **Core Capabilities:**
  - 41 discovery and verification tools including `fetch_article_details`, `get_fulltext`, `verify_reference_list`, and `build_citation_tree`.
  - Resolution of official MeSH terms, databank accessions (e.g. ClinicalTrials.gov identifiers), and author conflict-of-interest declarations.
  - Retrieval of indexed publication types (e.g., Clinical Trial Phase II, Randomized Controlled Trial, Retraction of Publication).

### 3. `arxiv` (`arxiv-mcp-server`)
- **Transport:** `stdio` (managed via `uvx arxiv-mcp-server`)
- **Data Source:** [arXiv.org](https://arxiv.org/) (Cornell University)
- **Core Capabilities:**
  - Automated retrieval and local caching of preprints.
  - Extraction of LaTeX equations and source sections before peer-review editing.
  - History diffing between initial preprint submissions and finalized journal versions to catch retroactive changes to hypotheses or baseline data.

### 4. `zotero` (`zotero-mcp`)
- **Transport:** `stdio` (managed via `zotero-mcp`)
- **Data Source:** Local Zotero SQLite database / Cloud Sync
- **Core Capabilities:**
  - Cross-references locally curated full-text PDF files and author notes.
  - Access to citation attachments, supplemental appendices, and verified BibTeX records.

### 5. `rstudio` (`rstudio-mcp`)
- **Transport:** `stdio` / loopback HTTP bridge to R
- **Data Source:** Native R 4.x environment (`httpuv` R daemon)
- **Core Capabilities:**
  - Exposes live R state to the agent for deterministic statistical execution.
  - Enforces **zero mental math**: executes `scripts/audit_paper.R` directly and returns unaltered `stdout` streams containing `statcheck` data frames and `scrutiny::grim_map` consistency flags.

---

## 3. Direct Programmatic REST APIs

In addition to MCP servers, the pipeline interacts directly with authoritative REST endpoints to extract unedited machine-readable records:

### 1. ClinicalTrials.gov REST API v2
- **Base Endpoint:** `https://clinicaltrials.gov/api/v2/studies/{NCT_ID}`
- **Authentication:** Public / No API key required
- **Data Format:** JSON
- **Facts Referenced:**
  - `protocolSection.statusModule`: Study first posted date, completion date, and last update posted date.
  - `protocolSection.outcomesModule.primaryOutcomes`: Verbatim primary outcome measures, time frames, and descriptions registered *prior* to study launch.
  - `protocolSection.outcomesModule.secondaryOutcomes`: Secondary endpoints to detect if a failed primary outcome was swapped with an incidental secondary endpoint.
  - `protocolSection.designModule.maskingInfo`: Verbatim allocation and blinding structure (e.g., Open-Label vs. Double-Blind).
  - Search verification: Full-text scan for pre-specified subgroup hypotheses (e.g., checking if cut-offs like "baseline SBP > 160 mm Hg" existed in the registered protocol).

### 2. CrossRef Works API
- **Base Endpoint:** `https://api.crossref.org/works/{DOI}`
- **Authentication:** Polite Pool (`mailto` header)
- **Data Format:** JSON
- **Facts Referenced:**
  - CrossMark update metadata: Explicit `updated-by` and `update-policy` records indicating formal errata, corrigenda, or retractions.
  - Timestamped publisher deposit dates: Online-first vs. print publication chronology.
  - Registered clinical trial numbers linked by the publisher.

### 3. Europe PMC REST API
- **Base Endpoint:** `https://www.ebi.ac.uk/europepmc/webservices/rest/search`
- **Authentication:** Public / No API key required
- **Data Format:** JSON / XML
- **Facts Referenced:**
  - European PubMed Central open-access full-text indexing.
  - Automated bio-entity text mining (linking gene names, organisms, and clinical diseases).
  - Grant agreements and public funding disclosures from Wellcome Trust, UKRI, ERC, and NIH.

### 4. NCBI Entrez E-utilities API
- **Base Endpoints:**
  - `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi`
  - `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi`
- **Authentication:** Optional `api_key` parameter (increases rate limit from 3 to 10 req/sec)
- **Data Format:** XML
- **Facts Referenced:**
  - Structured XML abstracts divided into official `BACKGROUND`, `METHODS`, `RESULTS`, and `CONCLUSIONS` segments.
  - Explicit `DataBankList` tags containing accession numbers across international trial registries (`ClinicalTrials.gov`, `ISRCTN`, `ANZCTR`, `EudraCT`).

### 5. OpenAlex REST API
- **Base Endpoint:** `https://api.openalex.org/works/https://doi.org/{DOI}`
- **Authentication:** Polite Pool (`mailto` header)
- **Data Format:** JSON
- **Facts Referenced:**
  - Immediate `is_retracted` Boolean verification.
  - Direct open-access PDF URL resolution via Unpaywall integration.
  - Global institutional author affiliation IDs (ROR IDs).

---

## 4. Verification Workflow: How Hallucination is Prevented

```
┌────────────────────────────────────────────────────────────────────────┐
│                   PIPELINE FACT VERIFICATION FLOW                      │
└────────────────────────────────────────────────────────────────────────┘
                               │
               [ Target DOI / PMID / Trial ID ]
                               │
        ┌──────────────────────┴──────────────────────┐
        ▼                                             ▼
  [ MCP Servers ]                             [ REST Endpoints ]
  - papers-openalex                           - ClinicalTrials.gov API v2
  - pubmed-search-mcp                         - CrossRef / Europe PMC
  - rstudio-mcp (R execution)                 - NCBI E-utilities XML
        │                                             │
        └──────────────────────┬──────────────────────┘
                               ▼
            [ Raw Structured Payloads (JSON / XML) ]
                               │
            ┌──────────────────┴──────────────────┐
            ▼                                     ▼
   [ Text & Protocol Forensic ]       [ R Statistical Suite ]
   - ClinicalTrials.gov vs NEJM/AHA    - statcheck(manuscript_text)
   - Discrepancy JSON Search           - scrutiny::grim_map(tables)
   - Zero-occurrence checks            - run_chart_density_audit()
            │                                     │
            └──────────────────┬──────────────────┘
                               ▼
        [ Adversarial Verification Packet (Markdown) ]
        - Verbatim R stdout embedded
        - Verbatim registry quotes embedded
        - Zero mental math computed
                               │
                               ▼
    [ Ingestion to Forensic Research Auditor Gemini Notebook ]
    (https://gemini.google.com/notebook/6b8609aa-fa3d-4a82-a123-5ffe7b4518e1)
```

1. **Direct API Fetch:** The pipeline retrieves raw XML and JSON payloads directly from NCBI, CrossRef, and ClinicalTrials.gov rather than relying on LLM internal memory.
2. **Deterministic Script Execution:** Summary tables are parsed into exact numerical matrices and processed by R functions (`grim_map()`, `benford()`). The model is strictly prohibited from doing mental arithmetic.
3. **Verbatim Audit Trail:** The final markdown report embeds verbatim excerpts from both the trial registry JSON and the R terminal output. Any assertion made in Gate 4 or Tier 2 must link to a specific line in the official record.
