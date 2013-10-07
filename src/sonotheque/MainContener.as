package sonotheque
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Quad;
	import com.greensock.easing.Sine;
	import com.greensock.easing.Strong;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.TouchEvent;
	import flash.system.System;
	import flash.ui.Mouse;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import mx.managers.SystemManager;
	
	import navigation.BtnOverDisableSelect;
	
	import net.hires.debug.Stats;
	
	import org.casalib.transitions.Tween;
	
	import pt.graphics.I_Bouton;
	
	import sonotheque.ecranDecouvrir.MenuSelection;
	
	import spark.core.SpriteVisualElement;
	
	import utils.DelayedCall;
	
	
	/**
	 * @copyright www.pense-tete.com
	 * @author GUYF
	 * @version 1.0.0 [1 mars 2012][GUYF] creation
	 *
	 * sonotheque.MainContener
	 */
	public class MainContener extends SpriteVisualElement
	{
		/*
		private var f_ecran_accueil:Mc_ecran_accueil;
		private var f_ecran_explorer:Mc_ecran_explorer;
		private var f_ecran_jouer:Mc_ecran_jouer;
		*/
		
		private var current_ecran:I_Ecran;
		private var titre:DisplayObject;
		
		private var timerAccueil:Timer;

		
		public static var DELAY:Number=1000*60*2;
		
		public static var ECRAN_WIDTH:Number=1280;
		
		private var stats:Stats;
		
		public function MainContener()
		{
			super();
			
			trace("MainContener.MainContener()");
			trace("Multitouch.supportsTouchEvents",Multitouch.supportsTouchEvents);
			trace("Multitouch.maxTouchPoints",Multitouch.maxTouchPoints);
			
			trace("Multitouch.mapTouchToMouse",Multitouch.mapTouchToMouse);
			trace("Multitouch.supportsGestureEvents",Multitouch.supportsGestureEvents);
			
			
			Multitouch.supportsTouchEvents
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			timerAccueil=new Timer(DELAY,1);
			timerAccueil.addEventListener(TimerEvent.TIMER_COMPLETE,evt_timerComplet,false,0,true);
		
			SoundProvider.lib=SoundLibrary;
			SoundProvider.instance;
			
			
			current_ecran=accueil()//veille()
			new DelayedCall(evt_timerAddDelay,100)
			//addChild(current_ecran as DisplayObject);
			/*
			stats = new Stats();
			stats.visible = true; 
			addChild(stats);
			*/
			if (stage) evt_added(null)
				else addEventListener(Event.ADDED_TO_STAGE,evt_added,false,0,true);
		}
		
		protected function evt_timerAddDelay(event:TimerEvent=null):void
		{
		
			addChild(current_ecran as DisplayObject);
		}
		
		protected function evt_added(event:Event):void
		{
			stage.displayState=StageDisplayState.FULL_SCREEN;
			stage.addEventListener(MouseEvent.MOUSE_MOVE,evt_updateTimer,false,0,true);
			stage.addEventListener(MouseEvent.MOUSE_DOWN,evt_updateTimer,false,0,true);
			trace("stage.stageWidth",stage.stageWidth,"stage.stageHeight",stage.stageHeight);
		}
		
		protected function evt_updateTimer(event:MouseEvent):void
		{
		//	trace("MainContener.evt_updateTimer(event)");
			
			if (timerAccueil.running) {
				timerAccueil.reset();
				timerAccueil.start();
			} 
			
			if (current_ecran is SimpleStageVideo) {
				event.stopImmediatePropagation();
				removeChild(current_ecran as DisplayObject)
				current_ecran=accueil()
		
				new DelayedCall(evt_timerAddDelay,100)
				//addChild(current_ecran as DisplayObject);
			}
			
		}
		
		protected function evt_timerComplet(event:TimerEvent):void
		{
			// TODO Auto-generated method stub
			SoundProvider.instance.stop();
			current_ecran.stopContent();
			removeChild(current_ecran as DisplayObject)
			current_ecran=veille()
			
			addChild(current_ecran as DisplayObject);
		}
		private function veille():I_Ecran {
			timerAccueil.stop();
			if (titre) {
				removeChild(titre);
				titre=null;
			}
				
			
			var f_ecran_veille:SimpleStageVideo=new SimpleStageVideo();
			return f_ecran_veille as I_Ecran
		}
		
		private function accueil():I_Ecran {
			timerAccueil.start();
	//		if (f_ecran_accueil==null) {
			titre=addChild(new lib_titre());
				var f_ecran_accueil:EcranAccueil=new Mc_ecran_accueil();
	//		}
			f_ecran_accueil.btn_decouvrir.addEventListener(MouseEvent.CLICK,evt_decouvrir,false,0,true);
			f_ecran_accueil.btn_jouer.addEventListener(MouseEvent.CLICK,evt_jouer,false,0,true);
			
			return f_ecran_accueil as I_Ecran
		}
		
		private function jouer():I_Ecran {
			timerAccueil.start();
		//	if (f_ecran_jouer==null) {
				var f_ecran_jouer:EcranJouer=new Mc_ecran_jouer();
		//	}
			
			
			if (Multitouch.supportsTouchEvents) {
				f_ecran_jouer.btn_autre.addEventListener(TouchEvent.TOUCH_BEGIN,evt_beginTouch_jouerToDec,false,0,true);
				
			} else {
				f_ecran_jouer.btn_autre.addEventListener(MouseEvent.MOUSE_DOWN,evt_click_jouerToDec,false,0,true);
			}
			return f_ecran_jouer as I_Ecran;
		}
		
		
		
		private function decouvrir():I_Ecran {
			timerAccueil.start();
		//	if (f_ecran_explorer==null) {
				var f_ecran_explorer:EcranDecouvrir=new Mc_ecran_explorer();
		//	}
			
			if (Multitouch.supportsTouchEvents) {
				f_ecran_explorer.btn_autre.addEventListener(TouchEvent.TOUCH_BEGIN,evt_beginTouch_decToJouer,false,0,true);
			
			} else {
				f_ecran_explorer.btn_autre.addEventListener(MouseEvent.MOUSE_DOWN,evt_click_decToJouer,false,0,true);
			}
			return f_ecran_explorer as I_Ecran;
		}
		
		/******************************************************************************/
		/**						Lancement des activitées							 **/
		/******************************************************************************/
		protected function evt_jouer(event:MouseEvent):void
		{
			timerAccueil.start()
			removeChild(current_ecran as DisplayObject);
			
			current_ecran=jouer()
			addChild(current_ecran as DisplayObject)
			current_ecran.startContent(true);
			
		}
		
		protected function evt_decouvrir(event:MouseEvent):void
		{
			timerAccueil.start()
			removeChild(current_ecran as DisplayObject);

			current_ecran=decouvrir();
			addChild(current_ecran as DisplayObject)
			current_ecran.startContent(true);
		}	
		
				
		/******************************************************************************/
		/**						changement d'activité multitouch					 **/
		/******************************************************************************/
		private var nextEcran:I_Ecran;
		private var xRef:Number;
		private var _lastTouch_timestamp:int
		protected function evt_beginTouch_jouerToDec(event:TouchEvent):void
		{
			_lastTouch_timestamp= getTimer();
			trace("MainContener.evt_beginTouch_jouerToDec(event)");
			
			current_ecran.stopContent();
			nextEcran=decouvrir();
			var dp:DisplayObject=addChild(nextEcran as DisplayObject)
			
			dp.x=-ECRAN_WIDTH-10
				xRef=stage.mouseX;
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE,evt_MouseMove,false,0,true);
			stage.addEventListener(MouseEvent.MOUSE_UP,evt_MouseEnd,false,0,true);
		}
		
		protected function evt_beginTouch_decToJouer(event:TouchEvent):void
		{
			_lastTouch_timestamp= getTimer();
			trace("MainContener.evt_beginTouch_decToJouer(event)");
			current_ecran.stopContent();
			
			nextEcran=jouer();
			var dp:DisplayObject=addChild(nextEcran as DisplayObject)
			
			dp.x=+ECRAN_WIDTH+10
				xRef=stage.mouseX;
			
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE,evt_MouseMove,false,0,true);
			stage.addEventListener(MouseEvent.MOUSE_UP,evt_MouseEnd,false,0,true);
		}	
		
		static public var param_touch_double_tap_timeout:uint = 400;
	
	
		
				
		/******************************************************************************/
		/**						changement d'activité	alternatif					 **/
		/******************************************************************************/
		

		
		protected function evt_click_jouerToDec(event:MouseEvent):void
		{
			
			_lastTouch_timestamp= getTimer();
			trace("MainContener.evt_beginTouch_jouerToDec(event)");
			current_ecran.stopContent();
			nextEcran=decouvrir();
			var dp:DisplayObject=addChild(nextEcran as DisplayObject)
			
			dp.x=-ECRAN_WIDTH-10
				xRef=stage.mouseX;
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE,evt_MouseMove,false,0,true);
			stage.addEventListener(MouseEvent.MOUSE_UP,evt_MouseEnd,false,0,true);
		}
		
		protected function evt_click_decToJouer(event:MouseEvent):void
		{
			
			_lastTouch_timestamp= getTimer();
			trace("MainContener.evt_beginTouch_decToJouer(event)");
			current_ecran.stopContent();
			
			nextEcran=jouer();
			var dp:DisplayObject=addChild(nextEcran as DisplayObject)
			
			dp.x=+ECRAN_WIDTH+10
				xRef=stage.mouseX;
			
			
				stage.addEventListener(MouseEvent.MOUSE_MOVE,evt_MouseMove,false,0,true);
				stage.addEventListener(MouseEvent.MOUSE_UP,evt_MouseEnd,false,0,true);
		}	
		
		protected function evt_MouseEnd(event:MouseEvent):void
		{
			var now:int = getTimer();
			var delay:int = Math.abs(now - _lastTouch_timestamp);
			trace("DELAY ",delay);
			if (delay < 4) {
				event.preventDefault();
				return; // écho d'un double event, on ignore
			} else if (delay < param_touch_double_tap_timeout) {
				TweenMax.allTo([current_ecran,nextEcran],1,{x:String(-(nextEcran as DisplayObject).x),ease : Strong.easeOut  },0,onCompleteAllTweenTransOk);
			} else {
				_endTransition()
			}
			
		
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,evt_MouseMove,false);
			stage.removeEventListener(MouseEvent.MOUSE_UP,evt_MouseEnd,false);
			
		}
		
	
		
		protected function evt_MouseMove(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
		//	trace("MainContener.evt_touchMove(event)",stage.mouseX,xRef,stage.mouseX-xRef);
			
			(current_ecran  as DisplayObject).x += stage.mouseX - xRef;
			(nextEcran  as DisplayObject).x += stage.mouseX - xRef;
			xRef=stage.mouseX
		}		
		
		
	
		protected function _endTransition():void {
			if (Math.abs((nextEcran as DisplayObject).x)<ECRAN_WIDTH*2/3) {
				
				TweenMax.allTo([current_ecran,nextEcran],1,{x:String(-(nextEcran as DisplayObject).x),ease : Strong.easeOut  },0,onCompleteAllTweenTransOk);
				
			} else {
				
				TweenMax.allTo([current_ecran,nextEcran],1,{x:String(-(current_ecran as DisplayObject).x),ease : Strong.easeOut },0,onCompleteAllTweenTransCancel);
			}
		}
		
		private function onCompleteAllTweenTransOk():void
		{
			removeChild(current_ecran as DisplayObject)
			current_ecran=nextEcran;
			
			var dp:DisplayObject=(current_ecran  as DisplayObject);
			dp.x=0
			current_ecran.startContent(true);
			nextEcran=null;
			System.gc();
		}
		private function onCompleteAllTweenTransCancel():void
		{
			removeChild(nextEcran as DisplayObject)
			var dp:DisplayObject=(current_ecran  as DisplayObject);
			dp.x=0
			current_ecran.startContent(false);
			nextEcran=null
			System.gc();
		}
		
				
		/******************************************************************************/
		/**						Force la compilation des classes à ce niveau		 **/
		/******************************************************************************/
		

		private function keep():void {
			SpectrumContener;
			EcranDecouvrir;
			EcranJouer;
			BtnOverDisableSelect
			
		}
	}
}