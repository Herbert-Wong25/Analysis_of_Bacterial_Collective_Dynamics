# Quantifying Bacterial Mechanotaxis & Group Dynamics

This repository contains a computational workflow designed to analyze the collective surface-specific "twitching" motility of *Pseudomonas aeruginosa*. Based on the research by **Kühn et al. (PNAS 2021)**, this project implements a pipeline to extract quantitative data from microscopy images to understand how the **Chp mechanosensory system** (specifically regulators **PilG** and **PilH**) influences group coordination.

## 🔬 Scientific Context

Mechanotaxis allows individual bacteria to direct their motility based on physical cues. While single-cell mechanosensing is known to regulate pili deployment, this project explores its role in collective behavior. By comparing Wild-Type (WT) strains with $\Delta pilG$ and $\Delta pilH$ mutants, we quantify how mechanosensing prevents "traffic jams" and promotes orientational order in dense colonies.

## 🛠 Tech Stack & Dependencies

* **Image Processing:** FIJI / ImageJ
* **Cell Tracking:** TrackMate (FIJI Plugin)
* **Computational Analysis:** Python 3.9+
* **Core Libraries:** `pandas`, `numpy`, `scipy`, `matplotlib`, `seaborn`
* **Advanced Bio-Imaging:** `omnipose` (CNN-based segmentation), `scikit-image`, `opencv-python-headless`
* **Segmentation:** Omnipose (CNN-based)

---

## 🚀 The Pipeline & Script Evolution

The workflow is divided into three parts, reflecting an iterative refinement of both image processing and statistical analysis.

### Part A & B: Image Processing (FIJI/ImageJ Macros)

These scripts handle the transition from raw microscopy frames to clean binary
masks ready for TrackMate tracking.

#### Quick Start — Run This

For end-to-end processing of a full movie, use the production pipeline:

**`Production_Pipeline.ijm`**

This single script performs segmentation (Part A) and Nematic Order Sr
quantification (Part B) for all frames and outputs a CSV file
`[filename]_Sr.csv`. Update the three parameters in **Section 0** before
running (frame interval, particle size limits, circularity threshold).

---

#### Pipeline Development History

The production script was developed iteratively through four stages, archived
in `/macros/evolution/` for transparency and reproducibility:

| Script | Stage | What it introduced |
|---|---|---|
| `01_calc_nematic_order_single.ijm` | Mathematical foundation | Sr formula validated on a single frame using manual threshold |
| `02_calc_nematic_order_stack.ijm` | Temporal analysis | Extended to full image stacks; switched to Triangle auto-threshold; added CSV export |
| `03_segmentation_auto_threshold.ijm` | Segmentation development | Rolling-ball background subtraction + Top-Hat + Watershed; 3-frame test loop |
| `04_segmentation_advanced_watershed.ijm` | Single-frame production | Validated final segmentation pipeline for individual QC inspection before batch runs |

The key methodological advance from Phase 3 onward was the **Watershed
Transformation** — critical for resolving overlapping cell boundaries in dense
twitching colonies where simple thresholding fails.

### Part C: Data Interpretation (Python Notebooks)

Once single-cell trajectories were extracted via TrackMate, I developed a Python pipeline to move from "global" averages to "local" spatial interactions.

* **Spatial Analysis:** Developed a distance-based filtering algorithm (`09_final_mechanotaxis_analysis.ipynb`) to calculate the **Nematic Order Parameter ($S_r$)** only for cells within a 30µm radius, providing a true measure of local coordination.

* **Phase 5: Exploratory Analysis (`05_exploratory_nematic_analysis.ipynb`)**
Baseline extraction of orientations and initial $S_r$ calculations across mutant conditions.
* **Phase 6: Spatial Coordination (`07_quadrant_spatial_analysis.ipynb`)**
Divided the Field of View (FOV) into quadrants to investigate if alignment was a local micro-domain phenomenon rather than a global colony trait.
* **Phase 7: Neighbor-Based Filtering (`09_final_mechanotaxis_analysis.ipynb`)**
The most refined analysis. Instead of arbitrary quadrants, I implemented a **radius-based filter (30µm)**. This calculates the alignment of each bacterium only with its immediate physical neighbors, providing a true biological measure of coordinated mechanotaxis.

---

## 📊 Results & Biological Interpretation

The computational analysis revealed that the Chp system is fundamental to collective phase transitions in *P. aeruginosa*.

### 1. Quantification of Nematic Order ($S_r$)

Using the polar coordinate alignment formula, we quantified the transition from random to aligned movement:

* **Wild-Type (WT):** Exhibited high local coordination with $S_r$ values peaking at **~0.45** in dense regions. This indicates a robust ability to align trajectories with neighbors.
* **Mutants ($\Delta pilG$ and $\Delta pilH$):** Showed a significant breakdown in coordination, with $S_r$ values dropping to **~0.1–0.2**. Without functional mechanosensing, cells remain in a poorly ordered, isotropic state.

### 2. Spatial Dynamics & "Crowding" Effects

* **Findings:** WT coordination is non-uniform; alignment is highest in the dense colony center and decreases toward the expanding edge.
* **Mutant Behavior:** Both $\Delta pilG$ and $\Delta pilH$ failed to increase their coordination even as local density increased. This suggests that the Chp system is the "feedback loop" required to translate physical crowding into coordinated movement.

### 3. Conclusion

Our results confirm that **mechanotaxis is a prerequisite for collective order.** By regulating reversal frequencies upon cell-cell collisions, the Chp system allows WT bacteria to avoid kinetic traps, whereas mutants lacking this system exhibit "traffic jams" that hinder efficient colony expansion.


---

## 📂 Project Structure

* **`/macros`**: FIJI/ImageJ scripts for automated segmentation and $S_r$ calculation.
* **`/notebooks`**: Jupyter notebooks for batch processing TrackMate data and spatial statistics.
* **`/demo`**: Comparison montages of auto-thresholding methods and video demos of the tracking pipeline.
* **`requirements.txt`**: List of Python dependencies for the analysis environment.

---

## ⚙️ Setup & Installation

### 1. ImageJ/FIJI

1. Download [FIJI](https://fiji.sc/).
2. Ensure the **TrackMate** plugin is updated via `Help > Update`.

### 2. Python Environment

I recommend using Anaconda to manage the environment:

```bash
# Create and activate a new environment
conda create -n mechanotaxis python=3.9
conda activate mechanotaxis

# Install dependencies
pip install -r requirements.txt

```

---

## 📝 Potential Extension

* **PIV Analysis:** Implementing Particle Image Velocimetry to characterize the "flow field" in regions of extreme density where individual cell tracking fails.
* **Deep Learning:** Further integration of `Omnipose` for more robust segmentation of non-standard bacterial morphologies.

---

