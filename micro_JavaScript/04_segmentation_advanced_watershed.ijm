//Open and select mask files at the specific file path
filepath = File.openDialog("Select your image or mask file");
open(filepath);

// Get the name of the opened image automatically
title = getTitle(); 
selectImage(title);

/*1.0. Obtain data for each frame in a movie mask 
 * 
 */

//Define the frame interval and number of frames

//Create arrays to store time and nematic order for each frame


//Loop through each frame, perform 1.1-1.3 to compute nematic order Sr_t, and store the result


	/*1.1. Convert Mask into a Binary Image,
 * where each bacterial cell is white and the background is back using auto-thresholding 
 * with the method: Yen/Triangle. As illustrated in the report, the method was determined by the Montage 
 * created by "Try All" from a training mask */ 
 	 //Convert image to 8-bit grayscale
	setOption("BlackBackground", false);
	//setThreshold(1, 65535);

	run("Subtract Background...", "rolling=50 sliding");
	run("Top Hat...", "radius=14");
	run("Auto Threshold", "method=Triangle white");
	run("8-bit");
	run("Distance Map");
	run("Make Binary");
	run("Invert");
	run("Watershed");

/* Define the parameters for measurements, including area, centroid, ... 
 * where the area can be used to filtered out segmented objects that are not cells 
 * but did not implement here due to limited time
 */
	run("Set Measurements...", "centroid fit redirect=None decimal=9");

/* For 1.2 and 1.3,  we perform analysis to extract the "Centroid" (i.e., geometric center) 
 * and "Orientation information" of each bacterium to use in polar coordinates
 * Fit Ellipse was used to fit an ellipse to each segmented cell, while the orientation
 * of the ellipse will be calculated and displayed as the "Angle"
 * It is noted that Exclude on Edges was selected to remove bacteria touching the edges of the image.
 * "Add to Manager" was also applied to visually track the particles in the region of interest (ROIs)
 */
 	//setSlice(frame); //This sets the current frame in the stack
	run("Analyze Particles...", "display exclude clear add composite");

/*
n = nResults(); // Get the number of segmented cells from the Results table
	sumX = 0;
	sumY = 0;

// Obtain the individual centroid
	for (i = 0; i < n; i++){ 
	sumX += getResult("X", i);; //Calculate the sum of all X & Y coordinates
	sumY += getResult("Y", i);; 
	}

// Compute the average X & Y (centroid of the colony)
	colonyX = sumX/n;
	colonyY = sumY/n; 
//Print each Sr to log from inspection
	print("Colony Centroid: ("+ colonyX +","+ colonyY + ")");
*/
