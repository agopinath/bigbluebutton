package org.bigbluebutton.conference.service.presentation;

import java.io.File;
import java.io.FileFilter;
import java.io.FileNotFoundException;
import java.io.FilenameFilter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Scanner;

import org.red5.logging.Red5LoggerFactory;
import org.slf4j.Logger;

public final class LTBContentLibraryManager {
	private static Logger log = Red5LoggerFactory.getLogger( PresentationRoom.class, "bigbluebutton" );
	private static final String CONFIG_DELIMITER = ":";
	private static final String CONFIG_FILENAME_DELIMITER = ",";
	private static final String CONFIG_ALL_CATEGORY = "all";
	private static final File CONLIB_ROOT = new File("/var/www/bigbluebutton-default/Dropbox/content-library");
	private static final File CONLIB_CONFIG = new File("/var/www/bigbluebutton-default/Dropbox/content-library-conf/conf.txt");
	
	// prevent instantiation
	private LTBContentLibraryManager() {}

	public static List doLookup(final String learnToBeUserID) {
		Map<String, String> env = System.getenv();
		for(String s: env.keySet()) {
			log.debug("C@key: " + s + " value: " + env.get(s));
		}
		
		if(!checkPermissions(CONLIB_ROOT, CONLIB_CONFIG)) {
			log.debug("C@!!PERMISSIONS INVALID");
			return null;
		}
		
		log.debug("doing conlib lookup with root: " + CONLIB_ROOT.getAbsolutePath() + " and config file " + CONLIB_CONFIG.getAbsolutePath());
		log.debug("C@doing conlib lookup with root: " + CONLIB_ROOT.getAbsolutePath() + " and config file " + CONLIB_CONFIG.getAbsolutePath());

		File[] canAccess = getAccessibleFiles(learnToBeUserID, CONLIB_CONFIG, CONLIB_ROOT);

		List conlibFiles = new ArrayList();
		crawlAndPopulate(canAccess, conlibFiles);

		for(Object fileName: conlibFiles) {
			log.debug("FILE IN CONTENT LIB FOR USER " + learnToBeUserID + ": " + fileName.toString());
		}
		
		return conlibFiles;
	}	
	
	public static void crawlAndPopulate(File[] toCheck, final List toPopulate) {
        if (toCheck == null || toPopulate == null) return;
		
        for(File f : toCheck) {
            if (f.isDirectory()) {
                crawlAndPopulate(f.listFiles(), toPopulate);
                log.debug("Dir: " + f.getAbsoluteFile());
            } else {
				String filenamePath = f.getAbsoluteFile().toString();
				if(filenamePath.substring(filenamePath.lastIndexOf("/")+1).trim().startsWith("."))
					continue;
				String relativeName = filenamePath.substring(CONLIB_ROOT.toString().length()+1);
				toPopulate.add(relativeName);
                log.debug("File: " + f.getAbsoluteFile());
            }
        }
    }
	
	private static File[] getAccessibleFiles(String learnToBeUserID, File config, File conlibRoot) {
		Scanner configScanner = null;
		List<String> allAccessibleFiles = new ArrayList();

		try {
			configScanner = new Scanner(config, "UTF-8");
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}

		while(configScanner.hasNextLine()) {
			String userIDEntries = configScanner.nextLine();
			log.debug("C@Scanning line: " + userIDEntries);
			String[] parsedData = userIDEntries.trim().split(CONFIG_DELIMITER);

			if(parsedData[0].equalsIgnoreCase(CONFIG_ALL_CATEGORY)) {
				String[] userFiles = parsedData[1].split(CONFIG_FILENAME_DELIMITER);
				allAccessibleFiles.addAll(Arrays.asList(userFiles));
				log.debug("C@Got all category with data: " + parsedData[1]);
			} else if(parsedData[0].equals(learnToBeUserID)) {
				String[] userFiles = parsedData[1].split(CONFIG_FILENAME_DELIMITER);
				allAccessibleFiles.addAll(Arrays.asList(userFiles));
				break;
			}
		}

		if(allAccessibleFiles.isEmpty()) {
			log.debug("C@warning: no content library files found in any category");
		}

		final File[] accessibleFiles = new File[allAccessibleFiles.size()];

		for(int i = 0; i < allAccessibleFiles.size(); i++) {
			accessibleFiles[i] = new File(conlibRoot.getAbsolutePath() + "/" + allAccessibleFiles.get(i));
			log.debug("C@accessibleFiles for user: " + conlibRoot.getAbsolutePath() + "/" + allAccessibleFiles.get(i));
		}

		try {
			configScanner.close();
		} catch(Exception e) {
			e.printStackTrace();
		}
		
		return accessibleFiles;
	}

	private static boolean checkPermissions(File conlibRoot, File conLibConfig) {
		if(!conlibRoot.exists())
			log.debug("C@conlib root does not exist");
		else if(!conlibRoot.isDirectory())
			log.debug("C@conlib root is not a directory");
		else if(!conlibRoot.canRead())
			log.debug("C@conlib root can't be read");
		else if(!conLibConfig.exists())
			log.debug("C@conlib root config does not exist");
		else if(!conLibConfig.isFile())
			log.debug("C@conlib root config is not a file");
		else if(!conLibConfig.canRead())
			log.debug("C@conlib root config cannot be read");
			
		if((conlibRoot.exists() && conlibRoot.isDirectory() && conlibRoot.canRead()) &&
			(conLibConfig.exists() && conLibConfig.isFile() && conLibConfig.canRead())) {
			return true;
		} else {
			return false;
		}
	}
}