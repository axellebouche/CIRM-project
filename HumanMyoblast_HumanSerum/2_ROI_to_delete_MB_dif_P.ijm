// --------------------
// CLEAN START
// --------------------

// Close all open images
run("Close All");

// Make sure ROI Manager exists, then reset it
if (roiManager("count") > 0) {
    roiManager("reset");
} else {
    // This ensures ROI Manager is initialized even if empty
    run("ROI Manager...");
    roiManager("reset");
}

//Folder
	//CHANGE dir name
dir = "D:\\Data\\Human\\IF\\MB_PregnancySerum\\stitched\\DAPI\\MB_dif_P\\";
list = getFileList(dir);


setBatchMode(true);


for (i = 0; i < list.length; i++) {
    
    name = list[i];
    
    // Only process files containing "_ROI"
    if (indexOf(name, "_ROI") != -1) {
        
        baseName = replace(name, "_ROI.tif", "");
        
        open(dir + name);

		name = getTitle();

        // --------------------
        // DUPLICATE FOR PROCESSING
        // --------------------
        rename("rgb");
        run("To ROI Manager");
        run("Duplicate...", "title=processing");
		roiManager("Select", 0);
		run("Clear Outside");
		run("8-bit");
		
		roiManager("Reset");
		run("Subtract Background...", "rolling=75");
		run("Gaussian Blur...", "sigma=1");
		setThreshold(22, 255, "raw");
		setOption("BlackBackground", true);
		run("Convert to Mask");

		// --------------------
		// REMOVE LARGE OBJECTS (> 0.08)
		// --------------------

		// Make sure measurements include area
		
		run("Set Measurements...", "area shape redirect=None decimal=3");
		
		run("Analyze Particles...", "size=0.08-Infinity circularity=0.01-1.00 display clear add");
		
		roiManager("Select All");
		roiManager("Combine");
		roiManager("reset");
		roiManager("Add");
		
		selectImage("rgb");
		roiManager("Show All without labels");
		
		saveAs("Tiff", dir + baseName + "_delete.tif");
		
		run("Close All");
		roiManager("Reset");
		    }
}
		
		