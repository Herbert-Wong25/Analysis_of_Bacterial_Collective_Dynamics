// Phase 2: Temporal Analysis — Nematic Order Over Full Stack
// Extends Phase 1 to time-lapse movies.
//
// BUGS FIXED:
//   1. sum_Sr explicitly reset to 0 each frame (was missing — caused
//      accumulation across frames giving wrong Sr from frame 2 onward)
//   2. phi_i_rad read from Results table per cell (same fix as Phase 1)
//   3. path variable now defined via dialog (was undefined in calc_nematic_final)

filepath = File.openDialog("Select your mask stack:");
open(filepath);
title = getTitle();
selectImage(title);

// Update this path before running:
path = "/path/to/output/Sr_output.csv";
file = File.open(path);
print(file, "Frame,Time(s),Nematic Order (Sr),N_cells");

frameInt  = 5;          // seconds — match your acquisition
numFrames = nSlices();

for (frame = 1; frame <= numFrames; frame++) {
    setSlice(frame);

    // 1.1 Triangle auto-threshold (replaces manual threshold from Phase 1)
    setOption("BlackBackground", false);
    run("Auto Threshold", "method=Triangle white setthreshold");

    // 1.2 Particle analysis — size and circularity filters exclude noise
    run("Set Measurements...", "area centroid fit redirect=None decimal=9");
    run("Analyze Particles...", "size=5-3000 circularity=0-0.7 display exclude clear add composite");

    n = nResults();
    t = (frame - 1) * frameInt;

    if (n == 0) {
        print("Frame " + frame + ": no cells detected.");
        print(file, frame + "," + t + ",NaN,0");
        continue;
    }

    // 1.3 Colony centroid
    sumX = 0; sumY = 0;
    for (i = 0; i < n; i++) {
        sumX += getResult("X", i);
        sumY += getResult("Y", i);
    }
    colonyX = sumX / n;
    colonyY = sumY / n;

    // 1.4 Angular position phi_i
    for (i = 0; i < n; i++) {
        deltaX = getResult("X", i) - colonyX;
        deltaY = getResult("Y", i) - colonyY;
        setResult("phi", i, atan2(deltaY, deltaX));
    }
    updateResults();

    // 1.5 Sr — reset sum_Sr each frame
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

File.close(file);
close("all");
print("Done. Saved to: " + path);