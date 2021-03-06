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
package org.bigbluebutton.modules.present.business
{
	import com.asfusion.mate.events.Dispatcher;
	
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.utils.Timer;
	
	import mx.controls.Alert;
	
	import org.bigbluebutton.common.LogUtil;
	import org.bigbluebutton.core.managers.UserManager;
	import org.bigbluebutton.main.events.MadePresenterEvent;
	import org.bigbluebutton.main.model.users.BBBUser;
	import org.bigbluebutton.main.model.users.Conference;
	import org.bigbluebutton.main.model.users.events.RoleChangeEvent;
	import org.bigbluebutton.modules.present.events.PresentModuleEvent;
	import org.bigbluebutton.modules.present.events.PresenterCommands;
	import org.bigbluebutton.modules.present.events.RemovePresentationEvent;
	import org.bigbluebutton.modules.present.events.SlideEvent;
	import org.bigbluebutton.modules.present.events.UploadEvent;
	import org.bigbluebutton.modules.present.events.ConlibEvent;
	import org.bigbluebutton.modules.present.managers.PresentationSlides;
	import org.bigbluebutton.modules.present.events.NavigationEvent;
	import org.bigbluebutton.modules.present.business.PresentDelayManager;
	
	public class PresentProxy
	{
		private var url:String;
		private var host:String;
		private var conference:String;
		private var room:String;
		private var userid:Number;
		private var connection:NetConnection;
		private var soService:PresentSOService;
		private var uploadService:FileUploadService;
		private var slides:PresentationSlides;
		private var conlibService:ConlibService;
		
		private var pageNumMap:Object = new Object();
		
		public function PresentProxy(){
			slides = new PresentationSlides();
		}
		
		public function connect(e:PresentModuleEvent):void{
			extractAttributes(e.data);
			soService = new PresentSOService(connection, url, userid);
			soService.connect();
		}
		
		private function extractAttributes(a:Object):void{
			host = a.host as String;
			conference = a.conference as String;
			room = a.room as String;
			userid = a.userid as Number;
			connection = a.connection;
			url = connection.uri;
		}
				
		/**
		 * Start uploading the selected file 
		 * @param e
		 * 
		 */		
		public function startUpload(e:UploadEvent):void{
			if (uploadService == null) uploadService = new FileUploadService(host + "/bigbluebutton/presentation/upload", conference, room);
			uploadService.upload(e.presentationName, e.fileToUpload);
		}
		
		/**
		 * To to the specified slide 
		 * @param e - The event which holds the slide number
		 * 
		 */		
		public function gotoSlide(e:PresenterCommands):void{
			if (soService == null) return;
			soService.gotoSlide(e.slideNumber);
		}
		
		/**
		 * Gets the current slide number from the server, then loads the page on the local client 
		 * @param e
		 * 
		 */		
		public function loadCurrentSlideLocally(e:SlideEvent):void{
			soService.getCurrentSlideNumber();
		}
		
		/**
		 * Reset the zoom level of the current slide to the default value 
		 * @param e
		 * 
		 */		
		public function resetZoom(e:PresenterCommands):void{
			if (soService == null) return;
			soService.restore();
		}
		
		/**
		 * Loads a presentation from the server. creates a new PresentationService class 
		 * 
		 */		
		private var currPresName:String = null;
		public function loadPresentation(e:UploadEvent) : void
		{
			var presentationName:String = e.presentationName;
			currPresName = e.presentationName;
			PresentDelayManager.currPres = e.presentationName;
			
			LogUtil.debug("PresentProxy::loadPresentation: presentationName=" + presentationName);
			var fullUri : String = host + "/bigbluebutton/presentation/" + conference + "/" + room + "/" + presentationName+"/slides";	
			var slideUri:String = host + "/bigbluebutton/presentation/" + conference + "/" + room + "/" + presentationName;
			
			LogUtil.debug("PresentationApplication::loadPresentation()... " + fullUri);
			var service:PresentationService = new PresentationService();
			service.load(fullUri, slides, slideUri);
			LogUtil.debug('number of slides=' + slides.size());
		}
		
		/**
		 * It may take a few seconds for the process to complete on the server, so we allow for some time 
		 * before notifying viewers the presentation has been loaded 
		 * @param e
		 * 
		 */		
		private var testNum:Number = 1;
		public function sharePresentation(e:PresenterCommands):void{
			if (soService == null) return;
			soService.sharePresentation(e.share, e.presentationName);
			var timer:Timer = new Timer(PresentDelayManager.getDelayTime(e.presentationName), 1);
			timer.addEventListener(TimerEvent.TIMER, sendViewerNotify);
			timer.start();
			
			PresentDelayManager.delayMap.push(e.presentationName);
		}
		
		public function updatePresentationPageNums(e:NavigationEvent):void {
			if (soService == null || currPresName == null) return;
			pageNumMap[currPresName] = e.pageNumber;
		}
		
		public function removePresentation(e:RemovePresentationEvent):void {
			if (soService == null) return;
			soService.removePresentation(e.presentationName);
		}
		
		private function sendViewerNotify(e:TimerEvent):void{
			if (soService == null) return;
			if(currPresName == null) {
				soService.gotoSlide(0);
				LogUtil.debug("@@@ CHANGING SLIDE NUM TO: 0");
			} else {
				soService.gotoSlide(pageNumMap[currPresName]);
				LogUtil.debug("@@@ CHANGING SLIDE NUM TO: " + pageNumMap[currPresName]);
			}
		}
			
		/**
		 * Move the slide within the presentation window 
		 * @param e
		 * 
		 */		
		public function moveSlide(e:PresenterCommands):void{
			soService.move(e.xOffset, e.yOffset, e.slideToCanvasWidthRatio, e.slideToCanvasHeightRatio);
		}
		
		/**
		 * Zoom the slide within the presentation window
		 * @param e
		 * 
		 */		
		public function zoomSlide(e:PresenterCommands):void{
			soService.zoom(e.xOffset, e.yOffset, e.slideToCanvasWidthRatio, e.slideToCanvasHeightRatio);
		}
		
		/**
		 * Update the presenter cursor within the presentation window 
		 * @param e
		 * 
		 */		
		public function sendCursorUpdate(e:PresenterCommands):void{
			soService.sendCursorUpdate(e.xPercent, e.yPercent);
		}
		
		public function resizeSlide(e:PresenterCommands):void{
			soService.resizeSlide(e.newSizeInPercent);
		}
	
		public function requestContentLibraryData(e:ConlibEvent):void{
			LogUtil.debug("received contentlibrary request event");
			soService.requestContentLibraryData(e);
		}
		
		public function getConlibDocument(e:ConlibEvent):void {
			LogUtil.debug("PRESENT PROXY: starting conlib service... with host: " + host);
			if (conlibService == null) 
				conlibService = new ConlibService(host + "/bigbluebutton/presentation/process-conlib-file", conference, room);
			LogUtil.debug("PRESENT PROXY: getting conlib document... from url " + host + "/bigbluebutton/presentation/process-conlib-file");
			conlibService.getConlibDocument(e.conlibFilenameToGet, e.conlibPresnameToGet);
		}
	}
}