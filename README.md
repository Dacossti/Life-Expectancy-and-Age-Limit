# Life Expectancy and Age Limit

![R](https://img.shields.io/badge/R-%3E%3D%204.1-blue)
![Shiny](https://img.shields.io/badge/Shiny-Interactive-orange)
![Plotly](https://img.shields.io/badge/Plotly-Interactive%20Graphics-3F4F75)
[![HLD](https://img.shields.io/badge/Data-HLD-blueviolet)](https://www.lifetable.de)
[![HMD](https://img.shields.io/badge/Data-HMD-5A9BD5)](https://www.mortality.org)
[![IDL](https://img.shields.io/badge/Data-IDL-8A2BE2)](https://www.supercentenarians.org)
![Life Expectancy](https://img.shields.io/badge/Topic-Life%20Expectancy-lightgreen)
![Reproducible](https://img.shields.io/badge/Reproducible-Yes-success)

## 🧭 Project Overview

This project investigates two complementary questions:

1. **Life Expectancy** — trends across genders, countries and years.
2. **Human Lifespan Limit** — estimation of a theoretical upper bound using Extreme Value Theory (EVT).

The workflow combines data processing, statistical modelling, geospatial visualisation, and advanced mathematical modelling, and is fully reproducible in R.

---

## 🥇 PART I — Life Expectancy Analysis

### 🎯 Objectives

- Compute and analyze **life expectancy at age x** for all available countries.
- Study **temporal trends** from the earliest to the latest year of data.
- Compare **male vs female** life expectancy gaps.
- Build **global and country-specific visualisations**, including time series, boxplots, choropleth world maps, and population pyramids.

---

### 📂 Data Used

- **Human Life-Table Database (HLD)** — primary source of life expectancy at birth data.
- **Human Mortality Database (HMD)** — complementary country-level mortality and demographic indicators.

All datasets were cleaned, harmonised, and matched using standardised country names and ISO3 codes. No raw data is redistributed in this repository.

---

### 🧹 Data Processing

- Removal of duplicates, missing values, and inconsistent entries.
- Selection of relevant variables: **Country**, **Year**, **Age**, **Sex**, **eₓ**.
- Standardisation of country names using **ISO3 codes**, with manual corrections for problematic territories (Kosovo, Indian Ocean Territories, Siachen Glacier, etc.).
- Merging all cleaned datasets into a unified analytical dataset.

---

### 📊 Analyses Performed

- Distribution of life expectancy by **age** and **sex** (boxplot, histogram).
- Time series analysis: sex gap (Female − Male), cross-country comparisons.
- Regional comparisons via choropleth maps.

---

## 🥈 PART II — Human Maximum Lifespan Estimation

### 🎯 Objectives

- Estimate the **theoretical maximum age** a human can reach.
- Apply **Extreme Value Theory (EVT)** to model exceptional lifespans.
- Assess the **impact of outliers** (e.g. Jeanne Calment) on the estimates.
- Compare results across **two independent EVT approaches**.

---

### 📂 Data Used

- **International Database on Longevity (IDL)** — validated ages at death for individuals aged 105 and over, covering years **1906 to 2024**. The study is restricted to **French supercentenarians** to satisfy the i.i.d. assumption required by EVT and to ensure sufficient sample size.

Two datasets are considered to isolate the effect of Jeanne Calment (122.45 years):

| Dataset | N | Age max (years) |
|---|---|---|
| France (105+) | 15 054 | 122.45 |
| France without Jeanne Calment | 15 053 | 118.93 |

---

### ⚙️ EVT Methodology

#### Approach 1 — Peaks Over Threshold (POT) + GPD

1. **Threshold selection** via Mean Residual Life plot and stability plots of ξ and σ*.
2. **GPD fitting** using L-moments estimation (more robust than MLE when ξ ≈ 0).
3. **Age bound estimation**: $\hat{x}^* = u - \hat{\sigma}/\hat{\xi}$ (valid when ξ < 0).

**Interpretation of ξ**: ξ < 0 → finite upper bound; ξ ≥ 0 → no detectable limit.

#### Approach 2 — Einmahl & Smeets (2009)

Based on the methodology of [Einmahl & Smeets (2009)](https://doi.org/10.1111/j.1467-9574.2008.00410.x), originally applied to 100m world records:

1. **Moment estimator** of the extreme-value index γ (Dekkers et al., 1989).
2. **Optimal k-region selection** via minimisation of the asymptotic mean squared error (AMSE).
3. **Endpoint estimation**: $\hat{x}^* = \hat{b}_text{n/k} - \hat{a}_text{n/k}/\hat{\gamma}$.
4. **95% upper confidence bound** via the asymptotic normality result of Dekkers et al. (1989).

---

### 📊 Main Results

Both approaches yield consistent estimates, confirming the existence of a plausible upper bound to human lifespan:

| Method | Dataset | $\hat{x}^*$ (years) | Upper 95% bound |
|---|---|---|---|
| GPD + L-moments | France | 129.37 | — |
| GPD + L-moments | France w/o J.C. | 125.19 | — |
| Einmahl & Smeets | France | 127.86 | 132.87 |
| Einmahl & Smeets | France w/o J.C. | 125.87 | 129.86 |

These results are consistent with the international literature, which places the human lifespan limit between **125 and 132 years** (Weon & Je, 2009; de Beer et al., 2017; Pearce & Raftery, 2021).

---

## 🧱 Project Structure

```bash
📁 data/
    HLD_database.csv          # Download from https://www.lifetable.de
    supercentenaires.xlsx     # Download from https://www.supercentenarians.org

📁 scripts/
    plot_functions.R          # Helper functions: boxplot, histogram, choropleth, timeseries
    map_utils.R               # Country name → ISO3 mapping
    GPD_Supercentenarians.Rmd # POT + GPD analysis (Quarto/RMarkdown)
    EVT_100M.Rmd              # Einmahl & Smeets analysis (Quarto/RMarkdown)

📄 README.md
```

---

## 📚 Key References

- Einmahl, J.H.J. & Smeets, S.G.W.R. (2009). Ultimate 100m World Records through Extreme-Value Theory. *Statistica Neerlandica*, 63(2), 154–186.
- Dekkers, A.L.M., Einmahl, J.H.J. & de Haan, L. (1989). A moment estimator for the index of an extreme-value distribution. *Annals of Statistics*, 17(4), 1833–1855.
- Weon, B.M. & Je, J.H. (2009). Theoretical estimation of maximum human lifespan. *Biogerontology*, 10, 65–71.
- de Beer, J., Bardoutsos, A. & Janssen, F. (2017). Maximum human lifespan may increase to 125 years. *Nature*, 546, E16–E17.
- Pearce, M. & Raftery, A.E. (2021). Probabilistic forecasting of maximum human lifespan by 2100. *Demographic Research*, 44(52), 1271–1294.

---

## 📊 Data Sources and Acknowledgements

| Source | URL |
|---|---|
| Human Life-Table Database (HLD) | https://www.lifetable.de |
| Human Mortality Database (HMD) | https://www.mortality.org |
| International Database on Longevity (IDL) | https://www.supercentenarians.org |

⚠️ Raw data are **not included** in this repository due to redistribution restrictions. Please download the data directly from the official sources and place them in the `data/` folder.

---

## 👥 Authors

- Stave Icnel Dany OSIAS
- Keevson Judlin VAL
- Jana AL JAMAL
- Khadim FALL

*Supervised by [Jonathan El Methni](https://sites.google.com/view/jonathanelmethni/accueil) — Université Grenoble Alpes, 2025–2026.*
