# Quantifying Bacterial Mechanotaxis & Collective Dynamics

Computational pipeline for quantifying collective surface-specific twitching motility in *Pseudomonas aeruginosa* — comparing Wild-Type (WT) with Chp mechanosensory mutants ($\Delta pilG$ and $\Delta pilH$) across dense, medium, and dilute colony densities.

Based on: **Kühn et al. (PNAS 2021)** — [DOI: 10.1073/pnas.2101759118](https://doi.org/10.1073/pnas.2101759118)

---

## 🔬 Scientific Context

Mechanotaxis allows individual *P. aeruginosa* cells to direct twitching motility in response to physical input from type IV pili (T4P). The chemotaxis-like **Chp system** — including regulators **PilG** and **PilH** — controls reversal frequency upon cell–cell collisions, enabling coordinated group movement.

This project builds on Kühn et al. by quantifying how loss of mechanosensing disrupts collective order at the population level. Three strains are compared:

| Strain | Genotype | Expected phenotype |
|---|---|---|
| **WT** | *ΔfliC* | Balanced reversals; intermediate collective order |
| **pilG** | *ΔfliC ΔpilG* | Frequent reversals; low net displacement; high local alignment at dense conditions |
| **pilH** | *ΔfliC ΔpilH* | Persistent directional movement; high displacement; variable alignment due to jamming |

---

## 🛠 Tech Stack & Dependencies

| Tool | Purpose |
|---|---|
| **FIJI / ImageJ** | Image visualisation, segmentation development, macro scripting |
| **Omnipose** | CNN-based segmentation optimised for rod-shaped bacteria |
| **TrackMate** (FIJI plugin) | Single-cell tracking via Label Image Detector |
| **Python 3.9+** | Batch analysis, nematic order quantification, visualisation |
| `pandas`, `numpy`, `scipy` | Data processing and spatial statistics |
| `matplotlib` | Figure generation |

---

## 🚀 Pipeline Overview

The workflow follows three sequential parts:

```
Raw microscopy TIFFs
        │
        ▼
  Part A: Segmentation (Omnipose → binary masks)
        │
        ▼
  Part B: Tracking (TrackMate → cell coordinates + orientations CSV)
        │
        ▼
  Part C: Analysis (Python → Nematic Order Sr, displacement, visualisation)
```

---

## Part A & B: Segmentation & Tracking (FIJI/ImageJ Macros)

### Segmentation approach

Segmentation was performed using **Omnipose** (not FIJI's built-in thresholding), as it operates on the full 16-bit pixel intensity spectrum and uniquely labels each cell (values 0–65,535). This preserves per-cell resolution that is critical for downstream orientation extraction.

> **Note on the FIJI macros:** An earlier segmentation pipeline was developed in FIJI using rolling-ball background subtraction + Top-Hat filtering + Triangle auto-threshold + Watershed (documented in `/macros/evolution/`). These macros were ultimately not used for final results because FIJI's thresholding step converts Omnipose's 16-bit labelled masks to binary images, discarding the per-cell label information that makes Omnipose superior. The macros are retained here as a documented development record.

### Tracking approach

TrackMate's **Label Image Detector** was used on Omnipose masks. This detector reads unique integer cell labels directly — outperforming LoG and Mask detectors on dense bacterial images (see `/demo/` for comparison). The **Advanced Kalman Tracker** was selected after systematic comparison of six tracking algorithms, with final parameters: Initial search radius = 2 µm, Search radius = 5 µm.

### FIJI Macro Scripts — Quick Start

For end-to-end segmentation and Sr calculation on a raw movie:

**`/macros/Bacterial_Mechanotaxis_Pipeline.ijm`**

Update the three parameters in **Section 0** before running (frame interval, particle size limits, circularity threshold). Outputs `[filename]_Sr.csv`.

### FIJI Macro Development History

Archived in `/macros/evolution/` for transparency:

| Script | Stage | What it introduced |
|---|---|---|
| `01_calc_nematic_order_single.ijm` | Mathematical foundation | Sr formula validated on a single frame; manual threshold [3–65535] from training data |
| `02_calc_nematic_order_stack.ijm` | Temporal analysis | Extended to full image stacks; Triangle auto-threshold; CSV export |
| `03_segmentation_auto_threshold.ijm` | Segmentation testing | Rolling-ball + Top-Hat + Watershed pipeline; 3-frame test loop for parameter optimisation |
| `04_segmentation_advanced_watershed.ijm` | Single-frame production | Validated segmentation for visual QC before TrackMate handoff |

The key methodological advance from Phase 3 onward was **Watershed Transformation** — essential for separating overlapping cell boundaries in dense twitching colonies where simple thresholding fails.

---

## Part C: Nematic Order Analysis (Python Notebooks)

### Quick Start

**`/notebooks/09_Mechanotaxis_Analysis_Pipeline.ipynb`**

Single end-to-end notebook. Update `DATA_DIR` and `OUTPUT_DIR` in **Section 0** before running. Outputs five CSVs and three figures to `data/results/`.

### Two Sr formulas implemented

| Label in notebook | Label in report | Formula | Outcome |
|---|---|---|---|
| **Sr₁ (Legendre)** | Equation 2 | $\langle(3\cos^2\theta - 1)/2\rangle$ | **Primary result** — differentiates mutants at dense conditions |
| Sr₂ (Basaran) | Equation 3 | $\langle\cos(2(\theta_i - \phi_i))\rangle$ | Retained for comparison; showed no significant differences across conditions |

### Analysis sections

| Section | Analysis | Output |
|---|---|---|
| **C.1** | Global Sr₁ & Sr₂ for all frames, all 9 conditions | `1_Sr_global.csv` |
| **C.2** | Quadrant-based Sr — FOV divided into 4 × 66.5 µm regions | `2_Sr_quadrant.csv` |
| **C.3** | Distance-based local Sr — 20 µm neighbourhood radius | `3_Sr_distance_20um.csv` |
| **C.4** | Per-cell Sr map from a representative random frame | `4_Sr_per_cell.csv` |
| **C.5** | Sr vs neighbourhood radius sweep (0–133 µm) | `5_Sr_vs_distance.csv` |

### Notebook Development History

Archived in `/notebooks/evolution/`:

| Notebook | Stage | What it introduced |
|---|---|---|
| `05_exploratory_nematic_analysis.ipynb` | Baseline | Sr₁ (Legendre) on global FOV; TrackMate CSV batch loading |
| `06_batch_nematic_calculation.ipynb` | Dual-formula | Added Sr₂ (Basaran) with φ calculation; switched to proper TrackMate column names |
| `07_quadrant_spatial_analysis.ipynb` | Spatial subdivision | FOV divided into quadrants to test micro-domain alignment hypothesis |
| `08_random_frame_validation.ipynb` | Local filtering | Distance-based neighbourhood filter; validated Sr is time-independent |
| `09_final_mechanotaxis_analysis.ipynb` | Distance sweep | Sr vs neighbourhood radius sweep (0–133 µm); per-cell spatial maps; visualisation |

---

## 📊 Key Results

### 1. Nematic Order — collective alignment

Sr₁ (Legendre) computed within a 20 µm neighbourhood radius revealed a clear density-dependent hierarchy:

**Dense conditions: pilG > pilH > WT**

- **pilG mutants** show the highest local nematic order at dense conditions. Without PilG to promote directional switching, cells align in parallel and maintain orientation, producing high Sr.
- **pilH mutants** show intermediate but highly variable Sr. PilH-driven reversals upon collisions occasionally produce forward collective movement (high Sr) but can also generate colony-wide jamming (low Sr), explaining the large spread.
- **WT** shows intermediate, stable Sr — the Chp system balances reversals with persistence, producing coordinated but not rigidly aligned motion.
- Under **dilute conditions**, all three strains show no significant Sr differences, consistent with minimal cell–cell collisions at low density.

The Sr value was found to be **time-independent** within each condition, justifying the use of a single representative frame for per-cell analysis (Section C.4).

### 2. Neighbourhood length scale

The Sr vs radius sweep (Section C.5) showed that **max_distance < 10 µm** gives the most reliable discrimination between conditions. Sr plateaus at larger radii as the neighbourhood grows beyond the scale of coherent collective motion. Each condition reaches its plateau at a different radius, reflecting differences in colony structure — a single global threshold is therefore insufficient for cross-condition comparison.

### 3. Displacement analysis

Three displacement metrics were extracted from TrackMate tracks (fluorescent cells only):

| Metric | pilG | pilH | WT |
|---|---|---|---|
| Displacement/frame (velocity) | Low–moderate | Highest | Intermediate |
| Total distance | Moderate | Highest | Intermediate |
| Net displacement | **Lowest** | Highest | Intermediate |

**pilG** reverses frequently → low net displacement despite similar velocity to WT ("jiggling" phenotype).
**pilH** moves persistently → highest net displacement; large error bars in dense conditions reflect jamming variability.
**WT** balances both behaviours.

---

## 🛠 Methodology: Nematic Order Parameter

Two formulations of the nematic order parameter were evaluated:

**Sr₁ — Legendre P₂ (absolute orientational order):**
$$S_{r1} = \left\langle \frac{3\cos^2\theta - 1}{2} \right\rangle$$

where $\theta$ is the orientation angle of each cell's fitted ellipse relative to the x-axis.

**Sr₂ — Basaran radial order (relative to colony expansion direction):**
$$S_{r2} = \left\langle \cos\left(2(\theta_i - \phi_i)\right) \right\rangle$$

where $\phi_i$ is the polar angle of cell $i$ relative to the colony centroid. Sr₂ = +1 indicates radial alignment; Sr₂ = −1 indicates tangential alignment.

Sr₁ was adopted as the primary metric as it differentiated strains and density conditions. Sr₂ did not yield significant differences and was retained for methodological completeness.

---

## 📂 Project Structure

```
/
├── macros/
│   ├── Bacterial_Mechanotaxis_Pipeline.ijm   # Production pipeline
│   └── evolution/                            # Development history (01–04)
├── notebooks/
│   ├── 09_Mechanotaxis_Analysis_Pipeline.ipynb  # Production notebook
│   └── evolution/                               # Development history (05–09)
├── data/
│   ├── trackmate/                            # TrackMate CSV exports (input)
│   └── results/                              # Analysis outputs (CSVs + figures)
├── demo/                                     # Detector comparison, tracking montages
└── requirements.txt
```

---

## ⚙️ Setup & Installation

### 1. FIJI / ImageJ

1. Download [FIJI](https://fiji.sc/).
2. Ensure **TrackMate** is updated via `Help > Update`.

### 2. Python Environment

```bash
conda create -n mechanotaxis python=3.9
conda activate mechanotaxis
pip install -r requirements.txt
```

---

## 📝 Potential Extensions

- **PIV / Optical Flow:** Characterise the bacterial "flow field" in extreme-density regions where individual cell tracking becomes unreliable — directly addressing Part B's requirement for an alternative motion analysis method.
- **Adaptive distance threshold:** The Sr vs radius sweep (Section C.5) showed each condition reaches its plateau at a different length scale. Automating per-condition threshold selection (e.g., via the inflection point of the Sr–radius curve) would improve cross-condition comparability.
- **Distribution uniformity analysis:** Dividing frames into grids to quantify spatial heterogeneity — predicted to show pilH clustering (jamming) vs. pilG uniform spread (frequent reversals).

---

## References

1. Kühn, M.J. et al. *Mechanotaxis directs Pseudomonas aeruginosa twitching motility.* PNAS **118**, e2101759118 (2021).
2. Basaran, M. et al. *Large-scale orientational order in bacterial colonies during inward growth.* eLife **11**, e72187 (2022).
