# Life Expectancy and Age Limit

![R](https://img.shields.io/badge/R-%3E%3D%204.1-blue)
![Shiny](https://img.shields.io/badge/Shiny-Interactive-orange)
![Plotly](https://img.shields.io/badge/Plotly-Interactive%20Graphics-3F4F75)
![Data Source](https://img.shields.io/badge/Data-Human%20Life--table%20Database-blueviolet)
[![HLD](https://img.shields.io/badge/Data-HLD-blueviolet)](https://www.lifetable.de)
[![HMD](https://img.shields.io/badge/Data-HMD-5A9BD5)](https://www.mortality.org)
[![IDL](https://img.shields.io/badge/Data-IDL-8A2BE2)](https://www.supercentenarians.org)


## 🧭 Project Overview

This project investigates:
1. **Life Expectancy** (LE) across countries, years, age groups, and sexes.
2. **Human Maximum Lifespan (Age Limit)** estimation using Extreme Value Theory (EVT).

The workflow combines data processing, statistical analysis, geospatial visualization, and advanced mathematical modeling.

---

## 🥇 PART I — Life Expectancy Analysis

### 🎯 Objectives

- Compute and analyze **life expectancy at age x** for all available countries.  
- Study **temporal trends** from the earliest to the latest year of data.  
- Compare **male vs female** life expectancy gaps.  
- Build **global and country-specific visualizations**, including:
  - Time series
  - Boxplots and distributions
  - Choropleth world maps
  - Population pyramids  

---

### 📂 Data Used

- **Human Life-Table Database (HLD)** — primary source of life expectancy at birth data.
- **Human Mortality Database (HMD)** — complementary country-level mortality and demographic indicators.
- **International Database on Longevity (IDL)** — detailed longevity and extreme-age demographic data (used for validation and contextual analysis).

All datasets were cleaned, harmonized, and matched using standardized country names and ISO3 codes prior to analysis.  
No raw data from these sources is redistributed in this repository.


---

### 🧹 Data Processing

- Removal of duplicates, missing values, and inconsistent entries  
- Selection of relevant variables:  
  **Country**, **Year**, **Age**, **Sex**, **eₓ**  
- Normalization of variable names and formats  
- Standardization of country names using **ISO3 codes**, including:
  - Automatic detection via pattern matching  
  - Conversion using the `countrycode` package  
  - Manual corrections for problematic territories such as:  
    **Kosovo**, **Indian Ocean Territories**,  
    **Ashmore and Cartier Islands**,  
    **Siachen Glacier**  
- Merging all cleaned datasets into a unified analytical dataset  

---

### 📊 Analyses Performed

- Distribution of life expectancy by **age** and **sex**  
- Time series analysis of life expectancy trends  
- **Sex gap analysis** (Female − Male)  
- Cross-country comparisons  
- Regional or continent-level comparisons  
- Ranking tables (Top 10 / Bottom 10 life expectancy values)


### 🌍 Choropleth Maps

Choropleth maps are generated automatically using:

```r
choropleth_by_year(year, age)
```

Maps are produced considering any chosen age (e.g., e(0), e(65), etc.) for:

- Male
- Female
- Male + Female

All outputs images are saved in *outputs/*

---

## 🥈 PART II — Human Maximum Lifespan (Age Bound)

### 🎯 Objectives

- Estimate the **theoretical maximum age** a human can reach.  
- Analyze **deaths at extreme ages**.  
- Apply **Extreme Value Theory (EVT)** to model exceptional lifespans.  
- Compare results **across countries** and **between sexes** (male vs female).  

---

### 📂 Data Used

- **Maximum observed age** by country and year (`x_max`).  
- Selection of extreme values using the **POT (Peak Over Threshold)** method.  
- Cleaned mortality data extracted from demographic life tables.  

---

### ⚙️ EVT Methodology

#### 1. Threshold Selection  
Select an optimal threshold **u** to retain only the most extreme age-at-death values.  
Multiple diagnostic tools (mean excess plots, stability plots) are used to choose a robust threshold.

#### 2. Modeling with the Generalized Pareto Distribution (GPD)  
The exceedances over the threshold are modeled using the **Generalized Pareto Distribution (GPD)**.  

We estimate the following parameters:

- **ξ (xi)** — shape parameter  
- **σ (sigma)** — scale parameter  

**Interpretation of ξ**:  
- **ξ < 0** → finite upper bound (suggests a maximum human lifespan)  
- **ξ ≥ 0** → no detectable upper limit to lifespan  

#### 3. Age Bound Estimation  
Using the fitted GPD model, we compute the **theoretical maximal age** (upper endpoint) implied by the data.

#### 4. Diagnostic Tools  
To validate the GPD fit and the threshold choice, we rely on:

- **Q-Q plots**  
- **Stability plots** for ξ  
- **Threshold sensitivity analysis**

---

```mermaid
mindmap
  root)Projet Tutoré — Espérance de Vie & Âge Limite(
    
    Espérance de Vie
        📊 Collecte des Données
            HLD (Human Life-Table Database)
            Gapminder
            INSEE
        🧹 Préparation & Nettoyage
            Harmonisation des colonnes
            Gestion des doublons et valeurs manquantes
            Conversion pays → ISO3
        🔎 Analyses
            Espérance de vie par sexe
            Espérance de vie à différents âges e(x)
            Tendances temporelles (time series)
        🌍 Visualisations
            Cartes choroplèthes (hommes / femmes / total)
            Pyramides des âges
            Boxplots et distributions
            Évolution annuelle
    
    Limite d'Âge (Age Bound)
        📐 Modélisation de la longévité extrême
            Théorie des Valeurs Extrêmes (EVT)
            Loi de Pareto Généralisée (GPD)
            Maximum annuel / Peak Over Threshold
        ⚙️ Estimation de l'Âge Limite
            Choix du seuil
            Estimation des paramètres (ξ, σ)
            Projection de l’âge maximal possible
        🧪 Validation & Interprétation
            Diagnostics EVT
            Comparaison entre pays
            Différences hommes / femmes
    
    Rendu Final
        📁 Automatisation (R)
            Scripts reproductibles
            Fonctions de génération de choroplèthes
            Graphiques exportés automatiquement
        📝 Rapport & Présentation
            Méthodologie
            Résultats principaux
            Limites & perspectives
```


## 🧱 Project Structure

```
life
📁 data/
    HLD_database.csv
    HLD_database.csv
    

📁 scripts/
    LifeExpectancyHLD.R          # Ongoing
    LifeExpectancyHMD.R          # Ongoing
    evt_age_bound.R              # Future

📁 outputs/
    hld_outputs/                
    hMd_outputs/
    evt_results/                  

📄 README.md

```
