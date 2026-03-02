// ==========================================================================
// PRODUCTION PIPELINE: Bacterial Mechanotaxis Analysis
// ==========================================================================
// End-to-end macro: segmentation + Nematic Order Sr per frame.
//
// PART A - Segmentation: Background subtraction > Top-Hat > Triangle
//          threshold > Watershed
// PART B - Sr analysis:  Centroids > Colony centroid > phi > Sr > CSV
//
// USER SETTINGS: Edit Section 0 before running.
// Input : Raw phase contrast TIFF stack
// Output: CSV [Frame, Time(s), Sr, N_cells]
//
// Reference: Basaran et al. (2022) eLife 72187
//            Kuhn et al. (2021) PNAS 2101759118
// ==========================================================================

// SECTION 0 - USER SETTINGS
frameInt        = 5;     // Frame interval in seconds
minParticleSize = 5;     // Min particle area px (removes noise)
maxParticleSize = 3000;  // Max particle area px (removes clusters)
maxCircularity  = 0.8;   // Rod-shaped bacteria: 0-0.8

// SECTION 1 - FILE I/O
filepath = File.openDialog("Select raw phase contrast TIFF stack:");
open(filepath);
title = getTitle();
selectImage(title);

outputDir = getDirectory("Choose output folder:");
stem      = replace(title, ".tif", "");
outputCSV = outputDir + stem + "_Sr.csv";

file = File.open(outputCSV);
print(file, "Frame,Time(s),Nematic Order (Sr),N_cells");

numFrames = nSlices();
print("Processing: " + title + " | " + numFrames + " frames");

// SECTION 2 - MAIN LOOP
for (frame = 1; frame <= numFrames; frame++) {
    setSlice(frame);

    // --- PART A: Segmentation ---
    run("Subtract Background...", "rolling=50 sliding");
    run("Top Hat...", "radius=14");
    setOption("BlackBackground", false);
    run("Auto Threshold", "method=Triangle white setthreshold");
    run("8-bit");
    run("Distance Map");
    run("Make Binary");
    run("Invert");
    run("Watershed");

    // --- PART B: Nematic Order ---
    run("Set Measurements...", "area centroid fit redirect=None decimal=9");
    run("Analyze Particles...", "size=" + minParticleSize + "-" + maxParticleSize
        + " circularity=0-" + maxCircularity
        + " display exclude clear add composite");

    n = nResults();
    t = (frame - 1) * frameInt;

    if (n == 0) {
        print("Frame " + frame + ": no cells detected.");
        print(file, frame + "," + t + ",NaN,0");
        continue;
    }

    // Colony centroid
    sumX = 0; sumY = 0;
    for (i = 0; i < n; i++) {
        sumX += getResult("X", i);
        sumY += getResult("Y", i);
    }
    colonyX = sumX / n;
    colonyY = sumY / n;

    // Angular position phi_i
    for (i = 0; i < n; i++) {
        deltaX = getResult("X", i) - colonyX;
        deltaY = getResult("Y", i) - colonyY;
        setResult("phi", i, atan2(deltaY, deltaX));
    }
    updateResults();

    // Sr calculation
    // FIX 1: sum_Sr reset each frame (prevents cross-frame accumulation)
    // FIX 2: phi_i_rad from Results table, not loop variable
    sum_Sr = 0;
    for (i = 0; i < n; i++) {
        theta_i_rad = getResult("Angle", i) * PI / 180;
        phi_i_rad   = getResult("phi",   i);
        sum_Sr += cos(2 * (theta_i_rad - phi_i_rad));
    }
    Sr = sum_Sr / n;

    print("Frame " + frame + " | t=" + t + "s | Sr=" + Sr + " | n=" + n);
    print(file, frame + "," + t + "," + Sr + "," + n);
}

// SECTION 3 - FINALISE
File.close(file);
print("Analysis complete. CSV saved to: " + outputCSV);
