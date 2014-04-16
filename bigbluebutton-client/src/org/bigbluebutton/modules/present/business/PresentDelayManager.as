package org.bigbluebutton.modules.present.business
{
	import mx.utils.StringUtil;
	
	public class PresentDelayManager {
		public static var PRESENT_FIRST_DELAY:Number = 2000;
		public static var PRESENT_SHORT_DELAY:Number = 50;
		
		public static var delayMap:Array = [];
		
		public static function getDelayTime(presName:String):Number {
			return (delayMap.indexOf(presName) == -1) ? PresentDelayManager.PRESENT_FIRST_DELAY : PresentDelayManager.PRESENT_SHORT_DELAY;
		}
	}
}
