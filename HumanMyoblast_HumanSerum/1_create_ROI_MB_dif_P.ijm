// --------------------
// CLEAN START
// --------------------

// Close all open images
run("Close All");

// Make sure ROI Manager exists, then reset it
if (roiManager("count") > 0) {
    roiManager("reset");
} else {
    run("ROI Manager...");
    roiManager("reset");
}

//Folder
// CHANGE dir name
dir = "D:\\Data\\Human\\IF\\MB_PregnancySerum\\stitched\\DAPI\\MB_dif_P\\";
list = getFileList(dir);

setBatchMode(true);

for (i = 0; i < list.length; i++) {

    if (endsWith(list[i], ".tif")) {

        // --------------------
        // OPTION A: FORCE CLEAN STATE BEFORE EACH IMAGE
        // --------------------
        run("Close All");

        if (roiManager("count") > 0) {
            roiManager("reset");
        } else {
            run("ROI Manager...");
            roiManager("reset");
        }

        // --------------------
        // OPEN ORIGINAL IMAGE
        // --------------------
        open(dir + list[i]);
        originalTitle = getTitle();

        // --------------------
        // DUPLICATE FOR PROCESSING
        // --------------------
        run("Duplicate...", "title=processing");

        // --------------------
        // RUN YOUR ROI DETECTION HERE
        // --------------------
        selectWindow("processing");

        run("Gaussian Blur...", "sigma=50");
        run("8-bit");

        setThreshold(0, 18, "raw");
        setOption("BlackBackground", true);
        run("Convert to Mask");

        run("Analyze Particles...", "exclude overlay add");

        // Keep only the largest ROI
        maxArea = -1;
        maxIndex = -1;

        for (j = 0; j < roiManager("count"); j++) {
            roiManager("Select", j);
            getStatistics(area);

            if (area > maxArea) {
                maxArea = area;
                maxIndex = j;
            }
        }

        // Delete all except the largest
        for (j = roiManager("count")-1; j >= 0; j--) {
            if (j != maxIndex) {
                roiManager("Select", j);
                roiManager("Delete");
            }
        }
		
		
		if (roiManager("count") == 0) {

    		// Create log file path
    		logFile = dir + "failed_images.txt";

    		// Append image name to log
   			File.append(originalTitle + "\n", logFile);

    		// Clean and skip this image
    		selectWindow("processing");
    		close();
   			selectWindow(originalTitle);
    		close();
    		roiManager("reset");

    		continue; // skip to next image
		}
		
		
		// Fit perfect circle
        roiManager("Select", 0);
        run("Fit Circle");
        roiManager("Add");

        // FORCE the ROI to be active on the image
        roiManager("Select", 1);

        // Now shrink
        run("Enlarge...", "enlarge=-15 pixel");
        roiManager("Update");

        // Keep only final ROI
        roiManager("Select", newArray(roiManager("count")-1));
        roiManager("Delete");

        // --------------------
        // APPLY ROI TO ORIGINAL IMAGE
        // --------------------
        selectWindow(originalTitle);
        roiManager("Show All without labels");

        // --------------------
        // SAVE IMAGE
        // --------------------
        baseName = replace(originalTitle, ".tif", "");

        // CHANGE NAME HERE
        saveAs("Tiff", dir + baseName + "_ROI.tif");

        // --------------------
        // CLEAN UP
        // --------------------
        close();
        selectWindow("processing");
        close();
        roiManager("Reset");
    }
}

setBatchMode(false);