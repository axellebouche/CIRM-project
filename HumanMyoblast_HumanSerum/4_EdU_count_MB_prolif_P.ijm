// --------------------
// DEFINE DIRECTORY
// --------------------

dir = "D:\\Data\\Human\\IF\\MB_PregnancySerum\\stitched\\EdU\\MB_prolif_P\\";
outputFile = dir + "EdU_results.csv";

// --------------------
// INIT CSV FILE
// --------------------
File.delete(outputFile);
File.append("SampleID,EdUcount\n", outputFile);

// --------------------
// GET FILE LIST
// --------------------
list = getFileList(dir);

// --------------------
// BUILD UNIQUE SAMPLE IDs
// --------------------
sampleIDs = newArray();


setBatchMode(true);

for (i = 0; i < list.length; i++) {
    name = list[i];

    if (endsWith(name, ".tif") || endsWith(name, ".tiff") || endsWith(name, ".jpg") || endsWith(name, ".png")) {
        
        id = substring(name, 0, 4);

        exists = false;
        for (j = 0; j < sampleIDs.length; j++) {
            if (sampleIDs[j] == id) {
                exists = true;
                break;
            }
        }

        if (!exists) {
            sampleIDs = Array.concat(sampleIDs, id);
        }
    }
}

// --------------------
// MAIN LOOP PER SAMPLE
// --------------------
for (s = 0; s < sampleIDs.length; s++) {

    currentID = sampleIDs[s];
    print("Processing: " + currentID);

    run("Close All");
    roiManager("Reset");

    // --------------------
    // OPEN + RENAME IMAGES
    // --------------------
    for (i = 0; i < list.length; i++) {

        name = list[i];

        if (startsWith(name, currentID)) {

            path = dir + name;
            open(path);

            title = getTitle();

            // Remove extension
            dotIndex = lastIndexOf(title, ".");
            baseName = substring(title, 0, dotIndex);

            // Rename logic
            if (lengthOf(baseName) == 4) {
            	rename("raw");
            }
            else if (endsWith(baseName, "_delete")) {
                rename("delete");
            }
            else if (endsWith(baseName, "_ROI")) {
                rename("ROI");
            }
        }
    }

    // --------------------
    // 👉 YOUR ANALYSIS STARTS HERE
    // --------------------


    // 1. Apply ROI to raw image
   	
   	// --- Clean artefacts ---
	roiManager("Reset");
	selectWindow("delete");
	overlayCount = Overlay.size;


	if (overlayCount == 1) {
		selectWindow("delete");
		run("To ROI Manager");
	  	selectImage("raw");
        roiManager("Select", 0);
        run("Enlarge...", "enlarge=5 pixel");
        run("Clear", "slice");
	}
	
	// --- Well detection ---
	roiManager("Reset");
	selectWindow("ROI");
	run("To ROI Manager");	
   	selectImage("raw");
	roiManager("Select", 0);
	run("Clear Outside");
	
	

     // 2. EdU segmentation and count
    selectImage("raw");
    run("8-bit");
	run("Subtract Background...", "rolling=75");
	run("Gaussian Blur...", "sigma=1");
	setThreshold(54, 255, "raw");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Watershed");
	run("Set Measurements...", "  redirect=None decimal=3");
	run("Analyze Particles...", "add");
		
    EdUcount = nResults;
    print("EdU count = " + EdUcount);
	
    // Clear results table for next sample
    run("Clear Results");

    // --------------------
    // SAVE RESULT TO CSV
    // --------------------
    line = currentID + "," + EdUcount + "\n";
    File.append(line, outputFile);

    // --------------------
    // CLEAN BEFORE NEXT SAMPLE
    // --------------------
    run("Close All");
    roiManager("Reset");
}

// --------------------
// DONE
// --------------------
print("Analysis complete. Results saved to:");
print(outputFile);

setBatchMode(false);
		