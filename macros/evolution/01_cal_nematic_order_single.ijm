// Phase 1: Mathematical Foundation — Single Frame Nematic Order
// Proof-of-concept: validates the Sr formula on one segmentation mask.
//
// Original used the loop variable from step 1.4, which carried only the
// last computed phi for ALL cells — giving incorrect Sr values.
//
// Formula: Sr = mean(cos(2*(theta_i - phi_i)))
// Reference: Basaran et al. (2022) eLife 72187

filepath = File.openDialog("Select your segmentation mask:");
open(filepath);
title = getTitle();
selectImage(title);

// 1.1 Convert to binary — threshold [3,65535] from 5 training images
run("Threshold...");
setThreshold(3, 65535, "raw");
setOption("BlackBackground", false);
run("Convert to Mask");

// 1.2 Extract centroids and ellipse orientations
run("Set Measurements...", "area centroid fit redirect=None decimal=9");
run("Analyze Particles...", "display exclude clear add composite");

n = nResults();
if (n == 0) { print("WARNING: No cells detected."); exit(); }

// 1.3 Colony centroid
sumX = 0; sumY = 0;
for (i = 0; i < n; i++) {
    sumX += getResult("X", i);
    sumY += getResult("Y", i);
}
colonyX = sumX / n;
colonyY = sumY / n;
print("Colony centroid: (" + colonyX + ", " + colonyY + ") | n=" + n);

// 1.4 Angular position phi_i per cell
for (i = 0; i < n; i++) {
    deltaX = getResult("X", i) - colonyX;
    deltaY = getResult("Y", i) - colonyY;
    setResult("phi", i, atan2(deltaY, deltaX));
}
updateResults();

// 1.5 Nematic Order Sr — phi_i_rad read from table, not loop variable
sum_Sr = 0;
for (i = 0; i < n; i++) {
    theta_i_rad = getResult("Angle", i) * PI / 180;
    phi_i_rad   = getResult("phi",   i);
    sum_Sr += cos(2 * (theta_i_rad - phi_i_rad));
}
Sr = sum_Sr / n;
print("Nematic Order Sr = " + Sr);
