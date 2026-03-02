/* This part of the Marco code (Javascript) aims to compute the Nematic order from the 
 * segmentation masks using FIJI built-in tools and plugins. The segmentation
 * Masks were generated from the code () on Python.
 * 
 */

//Open and select mask files at the specific file path
filepath = File.openDialog("Select your image or mask file");
open(filepath);

// Get the name of the opened image automatically
title = getTitle(); 
selectImage(title);

/*1.1 Convert Mask into a Binary Image,
 * where each bacterial cell is white and the background is back using thresholding
 * from [3,65535], which was determined by the training data set (5 images)*/ 
run("Threshold...");
setThreshold(3, 65535, "raw");
setOption("BlackBackground", false);
run("Convert to Mask");

/* Define the parameters for measurements, including area, centroid, ... 
 * where the area can be used to filtered out segmented objects that are not cells 
 * but did not implement here due to limited time
 */
run("Set Measurements...", "area centroid fit redirect=None decimal=9");

/* For 1.2 and 1.3, here we perform analysis to extract the "Centroid" (i.e., geometric center) 
 * and "Orientation information" of each bacterium to use in polar coordinates
 * Fit Ellipse was used to fit an ellipse to each segmented cell, while the orientation
 * of the ellipse will be calculated and displayed as the "Angle." It is noted 
 * that the Exclude on Edges was selected to remove bacteria touching the edges of the image;
 * "Add to Manager" was also applied to visually track the particles in the region of interest (ROIs)
 */
run("Analyze Particles...", "display exclude clear add composite");

/*1.2. Compute Angular Position ϕ, 
 * where each bacterium in polar coordinates with respect to the colony center
 * (i.e., the angle between the bacterium and the colony center)
 */
 
// First, we define the Colony Center by averaging the centroid of individual cells
// Assuming the "X" "Y" column in the Results table are the centroid coordinates of cells
n = nResults(); // Get the number of segmented cells from the Results table
sumX = 0;
sumY = 0;

// Obtain the individual centroid
for (i = 0; i < n; i++){ 
	sumX += getResult("X", i);; //Calculate the sum of all X & Y coordinates
	sumY += getResult("Y", i);; 
}

// Compute the average X & Y (centroid of the colony)
ColonyX = sumX/n;
ColonyY = sumY/n; 
print("Colony Centroid: ("+ ColonyX +","+ ColonyY + ")");

// Compute angular position ϕ of each of the bacterium in polar coordinates about the colony center
for (i = 0; i < n; i++){
	X_i = getResult("X", i); //Get the results of individual X & Y coordinates
	Y_i = getResult("Y", i);
	deltaX = X_i - ColonyX;
	deltaY = Y_i - ColonyY;
	
	// calculate the angular position ϕ in radians
    phi_i_rad = atan2(deltaY, deltaX);
    
    //Optionally calculate the angular position ϕ in degrees; note that 
    //phi_i_deg = ((atan2 (deltaY, deltaX))*(180/PI) + 360) % 360;
    
    setResult("phi", i, phi_i_rad); //Add the computed angle to Results table
}
updateResults();

/*1.3.  Obtain the orientation angles θ and calculate the Nematic order, 
 * which is the angular orientation with respect to x-axis in radian
 */
 
// Assuming the "Angle" column in ROI manager contains orientation angles in degree
for (i = 0; i < n; i++){
	theta = getResult("Angle", i);
	theta_i_rad = theta*PI/180; // Convert to radians
	// Calculate the sum of the radial order parameter (Sr) refer to the paper:
	// Large-scale orientational order in bacterial colonies during inward growth (Basaran, 2022)
	Sr_i = cos (2 * (theta_i_rad - phi_i_rad));
	sum_Sr += Sr_i;
}
Sr = sum_Sr / n; // The Average of cos(2*theta-


print("Nematic/Radial Order (Sr)): " + Sr);

 
 
