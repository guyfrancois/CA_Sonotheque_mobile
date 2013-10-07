package sonotheque
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.StageVideoAvailabilityEvent;
	import flash.events.StageVideoEvent;
	import flash.events.VideoEvent;
	import flash.geom.Rectangle;
	import flash.media.StageVideo;
	import flash.media.StageVideoAvailability;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	
	public class SimpleStageVideo extends Sprite implements I_Ecran
	{
		
		private static const FILE_NAME:String = "ACCROCHE_SONOTHEQUE_BD_2Tiers.mp4";
		//private static const FILE_NAME:String = "test.mp4";
		
		
		private var sv:StageVideo;
		private var nc:NetConnection;
		private var ns:NetStream;
		private var rc:Rectangle;
		private var video:Video;
		private var totalTime:Number;
		
		private var videoWidth:int;
		private var videoHeight:int;
		
		private var videoRect:Rectangle = new Rectangle(0, 0, 0, 0);
		private var gotStage:Boolean;
		private var stageVideoInUse:Boolean;
		private var classicVideoInUse:Boolean;
		private var accelerationType:String;
		
		private var available:Boolean;
		private var inited:Boolean;
		private var played:Boolean;
		
		
		/**
		 * 
		 * 
		 */		
		public function SimpleStageVideo()
		{
			// Make sure the app is visible and stage available
			visible=false;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE,evt_removed);
		}
		
		protected function evt_removed(event:Event):void
		{
			stage.removeEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onStageVideoState);
			stage.removeEventListener(Event.ENTER_FRAME, onFrame);
			ns.close();
			nc.close();
			
			
			if ( stageVideoInUse )
			{
				sv.attachNetStream(null)	
			} else 
			{
				stage.removeChild(video);
			}
		}
		
		public function startContent(param:Object=null):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function stopContent(param:Object=null):void
		{
			// TODO Auto Generated method stub
			
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */		
		private function onAddedToStage(event:Event):void
		{
			
			// Connections
			nc = new NetConnection();
			nc.connect(null);
			ns = new NetStream(nc);
			ns.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			ns.client = this;
			
			
			
			// Screen
			video = new Video();
			video.smoothing = true;
			
			
			// Video Events
			// the StageVideoEvent.STAGE_VIDEO_STATE informs you if StageVideo is available or not
			stage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onStageVideoState);
			// in case of fallback to Video, we listen to the VideoEvent.RENDER_STATE event to handle resize properly and know about the acceleration mode running
			video.addEventListener(VideoEvent.RENDER_STATE, videoStateChange);
			
		}

		/**
		 * 
		 * @param event
		 * 
		 */		
		private function onNetStatus(event:NetStatusEvent):void
		{
			if ( event.info == "NetStream.Play.StreamNotFound" )
				trace("SimpleStageVideo.onNetStatus(event)","Video file passed, not available!");
			
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */		
		private function onFrame(event:Event):void 
		{
			/*
			var ratio:Number = (ns.time / totalTime) * (stage.stageWidth - (BORDER << 1));
			rect.width = ratio;
			*/
			if (ns.time>=Math.floor(totalTime)) {
				ns.seek(0);
				ns.resume()
			}
		}
		
		
		
		/**
		 * 
		 * @param width
		 * @param height
		 * @return 
		 * 
		 */		
		private function getVideoRect(width:uint, height:uint):Rectangle
		{	
			var stageWidth:Number=1280;
			var stageHeight:Number=800
			var videoWidth:uint = width;
			var videoHeight:uint = height;
			var scaling:Number = Math.min ( stageWidth / videoWidth,stageHeight / videoHeight );
			
			videoWidth *= scaling, videoHeight *= scaling;
			
			var posX:uint = stageWidth - videoWidth >> 1;
			var posY:uint = stageHeight - videoHeight >> 1;
			
			videoRect.x = posX;
			videoRect.y = posY;
			videoRect.width = videoWidth;
			videoRect.height = videoHeight;
			
			return videoRect;
		}
		
		/**
		 * 
		 * 
		 */		
		private function resize ():void
		{	
			if ( stageVideoInUse )
			{
				// Get the Viewport viewable rectangle
				rc = getVideoRect(sv.videoWidth, sv.videoHeight);
				// set the StageVideo size using the viewPort property
				sv.viewPort = rc;
			} else 
			{
				// Get the Viewport viewable rectangle
				rc = getVideoRect(video.videoWidth, video.videoHeight);
				// Set the Video object size
				video.width = rc.width;
				video.height = rc.height;
				video.x = rc.x, video.y = rc.y;
			}
		}
		
		/**
		 * 
		 * @param evt
		 * 
		 */		
		public function onMetaData ( evt:Object ):void
		{
			totalTime = evt.duration;
			stage.addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		public function onXMPData(evt:Object):void {
			
		}
		public function onPlayStatus(evt:Object):void {
			
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */		
		private function onStageVideoState(event:StageVideoAvailabilityEvent):void
		{	
			// Detect if StageVideo is available and decide what to do in toggleStageVideo
			toggleStageVideo(available = inited = (event.availability == StageVideoAvailability.AVAILABLE));
		}
		
		/**
		 * 
		 * @param on
		 * 
		 */		
		private function toggleStageVideo(on:Boolean):void
		{	
			trace( "StageVideo Running (Direct path) : " + on );
			
			
			// If we choose StageVideo we attach the NetStream to StageVideo
			
			if (on) 
			{
				stageVideoInUse = true;
				if ( sv == null )
				{
					sv = stage.stageVideos[0];
					sv.addEventListener(StageVideoEvent.RENDER_STATE, stageVideoStateChange);
				}
				sv.attachNetStream(ns);
				if (classicVideoInUse)
				{
					// If we use StageVideo, we just remove from the display list the Video object to avoid covering the StageVideo object (always in the background)
					stage.removeChild ( video );
					classicVideoInUse = false;
				}
			} else 
		
			{
				// Otherwise we attach it to a Video object
				if (stageVideoInUse)
					stageVideoInUse = false;
				classicVideoInUse = true;
				video.attachNetStream(ns);
				stage.addChildAt(video,0);
			}
			
			if ( !played ) 
			{
				played = true;
				
				ns.play(FILE_NAME);
				
			}
		} 
		
		/**
		 * 
		 * @param event
		 * 
		 */		
		private function onResize(event:Event):void
		{
			resize();		
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */		
		private function stageVideoStateChange(event:StageVideoEvent):void
		{	
			trace("StageVideoEvent received\n");
			trace("Render State : " + event.status);
			resize();
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */		
		private function videoStateChange(event:VideoEvent):void
		{	
			trace( "VideoEvent received\n");
			trace( "Render State : " + event.status);
			resize();
		}
	}
}