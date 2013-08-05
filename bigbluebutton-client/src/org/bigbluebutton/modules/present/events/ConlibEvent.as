package org.bigbluebutton.modules.present.events
{
	import flash.events.Event;
	import flash.net.FileReference;
	
	public class ConlibEvent extends Event {
		public static const OPEN_CONLIB_WINDOW:String = "OPEN_CONLIB_WINDOW";
    	public static const CLOSE_CONLIB_WINDOW:String = "CLOSE_CONLIB_WINDOW";
		public static const REQUEST_CONTENT_LIBRARY:String = "REQUEST_CONLIB";
		public static const GET_DOCUMENT_ON_SERVER:String = "GET_DOCUMENT_ON_SERVER";
		public static const CONVERT_START:String = "CONLIB_CONVERT_START";
		
		public var conLibData:Array;
		
		public var conlibFilenameToGet:String;
		public var conlibPresnameToGet:String;
		
		public function ConlibEvent(type:String) {
			super(type, true, false);
		}
	}
}