// Phase 3: Automated Segmentation — Background Subtraction + Auto Threshold
// Tests the watershed segmentation pipeline on the first 3 frames as a QC
// step before committing to full-movie processing.
//
// Changes from Phase 1/2:
//   - Adds rolling-ball background subtraction (rolling=50)
//   - Adds Top-Hat filter (r=14) for contrast enhancement
//   - Switches from manual threshold to Triangle auto-threshold
//   - Introduces Watershed to separate touching cells
//
// NOTE: Loop is intentionally limited to 3 frames for parameter optimisation.
// Once segmentation quality is confirmed, change <= 3 to <= numFrames
// and use 04_segmentation_advanced_watershed.ijm for single-frame production.

filepath = File.openDialog("Select your raw image stack:");
open(filepath);
title = getTitle();
selectImage(title);

numFrames = nSlices();

// --- TEST LOOP: 3 frames only (intentional) ---
for (frame = 1; frame <= 3; frame++) {
    setSlice(frame);

    // Step 1: Background subtraction — rolling ball r=50 corrects
    // uneven illumination across the field of view
    setOption("BlackBackground", false);
    run("Subtract Background...", "rolling=50 sliding");

    // Step 2: Top-Hat filter — enhances small bright objects (bacteria)
    // by subtracting local background. r=14 tuned to ~1 bacterial cell width.
    run("Top Hat...", "radius=14");

    // Step 3: Triangle auto-threshold + convert to binary mask
    run("Auto Threshold", "method=Triangle white setthreshold");
    run("Convert to Mask", "method=Triangle background=Dark only");

    // Step 4: Watershed separation of touching/overlapping cells.
    // Distance Map creates a grey-level image with maxima at cell centres;
    // Watershed then cuts along ridges between adjacent cell bodies.
    run("Distance Map");
    run("Make Binary");
    run("Invert");
    run("Watershed");

    // Step 5: Measure centroids (QC check only — no Sr computed here)
    run("Set Measurements...", "centroid fit redirect=None decimal=9");
    run("Analyze Particles...", "display exclude clear add composite");

    n = nResults();

    // BUG FIX: guard against n=0 before division — would cause divide-by-zero
    // crash in original if no cells detected in a test frame
    if (n == 0) {
        print("Frame " + frame + ": WARNING - no cells detected. Check parameters.");
        continue;
    }

    sumX = 0; sumY = 0;
    for (i = 0; i < n; i++) {
        sumX += getResult("X", i);
        sumY += getResult("Y", i);
    }
    print("Frame " + frame + " - Colony centroid: ("
        + sumX/n + ", " + sumY/n + ") | n=" + n);
}

print("Test complete (3 frames). Inspect masks in FIJI before full-movie processing.");