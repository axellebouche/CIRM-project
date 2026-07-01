dir = "D:\\Data\\Human\\IF\\MB_PregnancySerum\\stitched\\MF20\\MB_dif_P\\";

list = getFileList(dir);

for (i = 0; i < list.length; i++) {
    oldName = list[i];
    
    // Skip directories
    if (File.isDirectory(dir + oldName))
        continue;
    
    // Remove all "#" characters
//    newName = replace(oldName, "_P00001_CH1", "");
    newName = replace(oldName, "MF20MB_dif_P_", "");
    
    // Only rename if different
    if (oldName != newName) {
        File.rename(dir + oldName, dir + newName);
        print("Renamed: " + oldName + " -> " + newName);
    }
}
