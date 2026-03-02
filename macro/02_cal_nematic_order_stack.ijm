/* This part of the Marco code aims to compute the Nematic order from the 
 * segmentation masks using FIJI built-in tools and plugins. The segmentation
 * Masks were generated from the code () on Python. This macro only show 
 * an example to calculate the nematic order for one video. The user is 
 * required to select different mask files and define path for which 
 * corresponding data to be stored. Changes should be made for the first 3 lines. 
 */

//Open and select mask files at the specific file path
filepath = File.openDialog("Select your image or mask file");
open(filepath);

// Get the name of the opened image automatically
title = getTitle(); 
selectImage(title);

//define a path where the data want to be stored 
// Prompt user to choose where to save the results
path = File.saveDialog("Save Results As...", "results.csv");
	
file = File.open(path); //open the file for output writing
print(file, "Frame, Time, Nematic Order (Sr)"); //Writing headers

/*1.0. Obtain data for each frame in a movie mask 
 * 
 */

//Define the frame interval and number of frames
frameInt = 5; //in seconds
numFrames = nSlices(); //total number of frames in the movie

//Create arrays to store time and nematic order for each frame
times = newArray(numFrames);
Sr_t = newArray(numFrames);

//Loop through each frame, perform 1.1-1.3. to compute nematic order Sr_t, and store the result

for (frame = 1; frame <= numFrames; frame++){
	
	//Set the current frame
	setSlice(frame); //This sets the current frame in the stack
	
	/*1.1. Convert Mask into a Binary Image,
 * where each bacterial cell is white and the background is back using auto-thresholding 
 * with the method: Yen/Triangle. As illustrated in the report, the method was determined by the Montage 
 * created by "Try All" from a training mask */ 
// 	run("8-bit"); //Convert image to 8-bit grayscale
	setOption("BlackBackground", false);
	run("Auto Threshold", "method=Triangle white setthreshold");
//	run("Convert to Mask", "method=Triangle background=Dark only");

/* Define the parameters for measurements, including area, centroid, ... 
 * where the area can be used to filtered out segmented objects that are not cells 
 * but did not implement here due to limited time
 */
	run("Set Measurements...", "area centroid fit redirect=None decimal=9");

/* For 1.2 and 1.3,  we perform analysis to extract the "Centroid" (i.e., geometric center).  
 * and "Orientation information" of each bacterium to use in polar coordinates
 * Fit Ellipse was used to fit an ellipse to each segmented cell, while the orientation
 * of the ellipse will be calculated and displayed as the "Angle"
 * It is noted that Exclude on Edges was selected to remove bacteria touching the edges of the image.
 * "Add to Manager" was also applied to visually track the particles in the region of interest (ROIs)
 */
 	//setSlice(frame); //This sets the current frame in the stack
	run("Analyze Particles...", "size=5-3000 circularity=0-0.7 display exclude clear add composite");

/*1.2. Compute Angular Position ϕ, 
 * where each bacterium in polar coordinates with respect to the colony center
 * (i.e., the angle between the bacterium and the colony center)
 */
 
// First, we define the Colony Center by averaging the centroid of individual cells (i)
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
	colonyX = sumX/n;
	colonyY = sumY/n; 
//Print each Sr to log from inspection
	print("Colony Centroid: ("+ colonyX +","+ colonyY + ")");

// Compute angular position ϕ of each of the bacterium (i) in polar coordinates to the colony center
// which indicates the patterns in bacterial arrangement, such as whether they are radially aligned or if there
// is any specific angular order in the colony. 
	for (i = 0; i < n; i++){
		X_i = getResult("X", i); //Get the results of individual X & Y coordinates
		Y_i = getResult("Y", i);
		deltaX = X_i - colonyX;
		deltaY = Y_i - colonyY;
	
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
 
// Assuming the "Angle" column in ROI manager contains orientation angles in degree, for cell (i)
	Sr = 0; //Reset the Sr and sum_Sr to 0 from previous frames
	sum_Sr = 0;
	
	for (i = 0; i < n; i++){
		theta = getResult("Angle", i);
		phi_i_rad = getResult("phi", i);
	
		theta_i_rad = theta*PI/180; // Convert to radians
		// Calculate the sum of the Nematic order parameter (Sr) refer to the paper: 
		// Large-scale orientational order in bacterial colonies during inward growth (Basaran, 2022)
		Sr_i = cos (2 * (theta_i_rad - phi_i_rad));
		sum_Sr += Sr_i;
	}

	Sr = sum_Sr / n; // The Average of the sum of cos²(theta-pi) within [-1,1], where
	// Sr = 1: All bacterial cells are perfectly aligned
	// Sr = 0: Random orientation or no preferred alignment
	// Sr = -1: Cells are aligned perpendicular to each other
	
//Store the nematic order and corresponding time for time (t)
	times [frame - 1] = (frame - 1) * frameInt; // Time in seconds
	t = times [frame -1 ]; 
	Sr_t [frame - 1] = Sr; //The nematic order for each frame
	

//Print each Sr to log for inspection
	print("Frame " + frame + ": Time = " + times[frame - 1] + "s, Nematic Order (S) = " + Sr);
	
/*1.4. Extract and save the data into a CSV file for further data analysis	
 * 
 */
	
	print(file, frame + "," + t + "," + Sr); 

}

File.close(file);
close("all");
	
print("Nematic order data has been saved to CSV.");


 
