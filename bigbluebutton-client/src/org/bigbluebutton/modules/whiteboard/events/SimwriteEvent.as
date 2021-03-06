/**
* BigBlueButton open source conferencing system - http://www.bigbluebutton.org/
* 
* Copyright (c) 2012 BigBlueButton Inc. and by respective authors (see below).
*
* This program is free software; you can redistribute it and/or modify it under the
* terms of the GNU Lesser General Public License as published by the Free Software
* Foundation; either version 3.0 of the License, or (at your option) any later
* version.
* 
* BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
* WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
* PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License along
* with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.
*
*/
package org.bigbluebutton.modules.whiteboard.events
{
	import flash.events.Event;
	
	import org.bigbluebutton.modules.present.ui.views.PresentationWindow;
	
	public class SimwriteEvent extends Event
	{
		public static const SIMWRITE_BUTTON_CLICKED:String = "SIMWRITE_BUTTON_CLICKED";
		public static const SIMWRITE_CHANGED_CALLBACK:String = "SIMWRITE_CHANGED_CALLBACK";
		public static const GET_SIMWRITE_STATE:String = "GET_SIMWRITE_STATE";
		public static const TOGGLE_BUTTON_STATE:String = "TOGGLE_BUTTON_STATE";
		
		public var simwriteEnabled:Boolean;
		
		public function SimwriteEvent(type:String)
		{
			super(type, true, false);
		}

	}
}