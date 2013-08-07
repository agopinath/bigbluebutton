package org.bigbluebutton.modules.present.business
{
	import com.asfusion.mate.events.Dispatcher;

	import flash.events.*;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import mx.events.CloseEvent;
	import mx.controls.Alert;
	
	import org.bigbluebutton.common.LogUtil;
	import org.bigbluebutton.modules.present.events.ConlibEvent;
	import org.bigbluebutton.modules.present.events.UploadEvent;

	public class ConlibService {
		public static const ID:String = "ConlibService";

		private var request:URLRequest = new URLRequest();
		private var sendVars:URLVariables = new URLVariables();

		private var dispatcher:Dispatcher;

		/**
		 * The default constructor 
		 * @param url - the address of the server
		 * @param room - a room in the server we're connecting to
		 * 
		 */		
		public function ConlibService(url:String, conference:String, room:String):void {
			sendVars.conference = conference;
			sendVars.room = room;
			request.url = url;
			request.data = sendVars;
			dispatcher = new Dispatcher();
		}

		/**
		 * Gets the conlib document from the server
		 * @param conlibFilename - The name of the file we want to get from the server's content library
		 * 
		 */		
		public function getConlibDocument(conlibFilename:String, conlibPresName:String):void {
			LogUtil.debug("get conlib document step 1");
			sendVars.conlib_filename = conlibFilename;
			sendVars.conlib_presname = conlibPresName;
			LogUtil.debug("get conlib document step 2");
			var loader:URLLoader = new URLLoader();
			LogUtil.debug("get conlib document step 3");
			loader.addEventListener(Event.COMPLETE, onGetConlibComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onGetConlibIoError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onGetConlibSecurityError);
			LogUtil.debug("get conlib document step 4");
			request.method = URLRequestMethod.POST;
			LogUtil.debug("get conlib document step 5");
			loader.load(request);
			LogUtil.debug("get conlib document SENT REQUEST SUCCESSFULLY");
			
			dispatcher.dispatchEvent(new ConlibEvent(ConlibEvent.CONVERT_START));
		}
		
		private function onGetConlibComplete(event:Event):void {
			LogUtil.debug("SUCCESSFULLY DID POST ON GET CONLIB DOCUMENT: " + event.toString());
		}
		
		private function onGetConlibIoError(event:IOErrorEvent):void {
			LogUtil.debug("An error occured while trying to get the conlib document. " + event.toString()); 
			LogUtil.debug("NOTE: If the above error occurs even if the the command reports having succeded " + 
						  "on the server, then it most probably did, and this error is expected.");
			dispatcher.dispatchEvent(new ConlibEvent(ConlibEvent.CLOSE_CONLIB_WINDOW));		  
			Alert.show("An error occured while retrieving the content library document. " +
					   "Please try again.", "Error");

		}

		private function onGetConlibSecurityError(event:SecurityErrorEvent) : void {
			LogUtil.debug("A security error occured while trying to get the conlib document. " + event.toString());
		}		
	}
}