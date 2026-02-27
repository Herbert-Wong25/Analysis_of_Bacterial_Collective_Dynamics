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

These scripts handle the transition from raw microscopy frames to clean, binary masks ready for tracking.

* **Phase 1: Mathematical Foundation (`01_calc_nematic_order_single.ijm`)**
Implemented the Nematic Order Parameter ($S_r$) formula derived from Basaran (2022). It calculates the alignment of bacteria relative to the colony center using polar coordinates.
* **Phase 2: Temporal Analysis (`02_calc_nematic_order_stack.ijm`)**
Expanded logic to handle image stacks (time-lapse movies), allowing for the observation of alignment dynamics over time.
* **Phase 3: Automated Segmentation (`03_segmentation_auto_threshold.ijm`)**
Introduced automated background subtraction and evaluated multiple thresholding algorithms (Yen, Triangle) to remove observer bias.
* **Phase 4: Advanced Watershed Pipeline (`04_segmentation_advanced_watershed.ijm`)**
The final production script. It utilizes **Top-Hat Filtering** for contrast enhancement and **Watershed Transformation** to resolve overlapping cell boundaries in high-density regions. This was critical for maintaining data integrity in dense "twitching" groups where simple thresholding fails.

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

Using the polar coordinate alignment formula $S_r = \langle \cos(2(\theta_i - \phi_i)) \rangle$, we quantified the transition from random to aligned movement:

* **Wild-Type (WT):** Exhibited high local coordination with $S_r$ values peaking at **~0.45** in dense regions. This indicates a robust ability to align trajectories with neighbors.
* **Mutants ($\Delta pilG$ and $\Delta pilH$):** Showed a significant breakdown in coordination, with $S_r$ values dropping to **~0.1–0.2**. Without functional mechanosensing, cells remain in a poorly ordered, isotropic state.

### 2. Spatial Dynamics & "Crowding" Effects

* **Findings:** WT coordination is non-uniform; alignment is highest in the dense colony center and decreases toward the expanding edge.
* **Mutant Behavior:** Both $\Delta pilG$ and $\Delta pilH$ failed to increase their coordination even as local density increased. This suggests that the Chp system is the "feedback loop" required to translate physical crowding into coordinated movement.

### 3. Conclusion

Our results confirm that **mechanotaxis is a prerequisite for collective order.** By regulating reversal frequencies upon cell-cell collisions, the Chp system allows WT bacteria to avoid kinetic traps, whereas mutants lacking this system exhibit "traffic jams" that hinder efficient colony expansion.


---

## 🛠 Methodology: Calculating Nematic Order ($S_r$)

To quantify the alignment of bacteria relative to the expansion of the colony, the following parameter was implemented:

$$S_r = \langle \cos(2(\theta_i - \phi_i)) \rangle$$

Where:

* $\theta_i$ is the orientation of the $i$-th bacterium relative to the x-axis.
* $\phi_i$ is the angular position of the bacterium relative to the centroid of the colony.
* $S_r = 1$: Perfect radial/nematic alignment.
* $S_r = 0$: Random, isotropic orientation.

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

## 📝 Future Work & Potential Enhancements

* **PIV Analysis:** Implementing Particle Image Velocimetry to characterize the "flow field" in regions of extreme density where individual cell tracking fails.
* **Deep Learning:** Further integration of `Omnipose` for more robust segmentation of non-standard bacterial morphologies.

---

