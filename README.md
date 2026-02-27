# Quantifying Bacterial Mechanotaxis & Group Dynamics

This repository contains a computational workflow designed to analyze the collective surface-specific "twitching" motility of *Pseudomonas aeruginosa*. Based on the research by **Kühn et al. (PNAS 2021)**, this project implements a pipeline to extract quantitative data from microscopy images to understand how mechanosensing influences group behavior through single-cell and collective parameters.

## 🔬 Scientific Context

Mechanotaxis allows individual bacteria to direct their motility based on physical cues from their environment. While single-cell mechanosensing is well-documented, the transition to collective movement in dense colonies requires robust image segmentation and tracking. This project replicates and extends analytical techniques to quantify how mechanosensing prevents "traffic jams" and coordinates group alignment.

## 🛠 Tech Stack & Dependencies

* **Image Processing:** FIJI / ImageJ
* **Cell Tracking:** TrackMate (FIJI Plugin)

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
The final production script. It utilizes **Top-Hat Filtering** for contrast enhancement and **Watershed Transformation** to resolve overlapping cell boundaries in high-density regions, ensuring data integrity for dense collective groups.

### Part C: Data Interpretation (Python Notebooks)

Once single-cell trajectories were extracted via TrackMate, I developed a Python pipeline to move from "global" averages to "local" spatial interactions.

* **Phase 5: Exploratory Analysis (`05_exploratory_nematic_analysis.ipynb`)**
Baseline extraction of orientations and initial $S_r$ calculations across mutant conditions.
* **Phase 6: Spatial Coordination (`07_quadrant_spatial_analysis.ipynb`)**
Divided the Field of View (FOV) into quadrants to investigate if alignment was a local micro-domain phenomenon rather than a global colony trait.
* **Phase 7: Neighbor-Based Filtering (`09_final_mechanotaxis_analysis.ipynb`)**
The most refined analysis. Instead of arbitrary quadrants, I implemented a **radius-based filter (30µm)**. This calculates the alignment of each bacterium only with its immediate physical neighbors, providing a true biological measure of coordinated mechanotaxis.
