package org.bigbluebutton.main.model
{
    import flash.display.Sprite;
    import flash.events.*;
    import flash.net.*;
    import flash.system.Security;

    import mx.controls.DateField;
    import org.bigbluebutton.common.LogUtil;
    import org.bigbluebutton.util.logging.Logger;
    import org.bigbluebutton.core.UsersUtil;

    public class CrashLogger {
        public static var logs:Logger;

        public static function sendLog():void {
	    LogUtil.debug("CRASH_LOG: Starting crash log....");
LogUtil.debug("CRASH_LOG: -1");
		 var loader:URLLoader = new URLLoader();
            configureListeners(loader);
	LogUtil.debug("CRASH_LOG: 0");
	    var crashLogUrl:String = "http://www.learntobe.org/bbb_crashes";
            var request:URLRequest = new URLRequest(crashLogUrl);
            request.method = URLRequestMethod.POST;
	    LogUtil.debug("CRASH_LOG: 1");
 	    var variables:URLVariables = new URLVariables();
		LogUtil.debug("CRASH_LOG: 2");
            variables.date = DateField.dateToString(new Date(), "MM/DD/YYYY");
	LogUtil.debug("CRASH_LOG: 3");
            variables.user_id = UsersUtil.getMyExternalUserID();
	LogUtil.debug("CRASH_LOG: 4");
	    variables.crash = logs.messages;
LogUtil.debug("CRASH_LOG: 5");
	    LogUtil.debug("CRASH_LOG: Sending with user id " + variables.user_id);
	    LogUtil.debug("CRASH_LOG: Sending with date " + variables.date);
	    LogUtil.debug("CRASH_LOG: Sending with crash data " + variables.crash.substring(0, 100));

            request.data = variables;
	    
            try {
   		Security.allowDomain("http://www.learntobe.org/");
	        Security.loadPolicyFile("http://www.learntobe.org/crossdomain.xml"); 
		loader.load(request);
 
            } catch (error:Error) {
                LogUtil.debug("CRASH_LOG: Unable to load requested document.");
            }
        }

        private static function configureListeners(dispatcher:IEventDispatcher):void {
            dispatcher.addEventListener(Event.COMPLETE, completeHandler);
            dispatcher.addEventListener(Event.OPEN, openHandler);
            dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        }

        private static function completeHandler(event:Event):void {
            var loader:URLLoader = URLLoader(event.target);
            LogUtil.debug("CRASH_LOG: completeHandler: completed successfully!");
        }

        private static function openHandler(event:Event):void {
            LogUtil.debug("CRASH_LOG: openHandler: " + event);
        }

        private static function progressHandler(event:ProgressEvent):void {
            LogUtil.debug("CRASH_LOG: progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
        }

        private static function securityErrorHandler(event:SecurityErrorEvent):void {
            LogUtil.debug("CRASH_LOG: securityErrorHandler: " + event);
        }

        private static function httpStatusHandler(event:HTTPStatusEvent):void {
            LogUtil.debug("CRASH_LOG: httpStatusHandler: " + event);
        }

        private static function ioErrorHandler(event:IOErrorEvent):void {
            LogUtil.debug("CRASH_LOG: ioErrorHandler: " + event);
        }
    }
}
