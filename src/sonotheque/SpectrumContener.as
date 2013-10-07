package sonotheque
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import hype.extended.behavior.FunctionTracker;
	import hype.extended.layout.GridLayout;
	import hype.framework.behavior.BehaviorStore;
	import hype.framework.core.ObjectPool;
	import hype.framework.display.BitmapCanvas;
	import hype.framework.sound.SoundAnalyzer;
	
	
	/**
	 * @copyright www.pense-tete.com
	 * @author GUYF
	 * @version 1.0.0 [12 mars 2012][GUYF] creation
	 *
	 * sonotheque.SpectrumContener
	 */
	public class SpectrumContener extends Sprite
	{
		
		public static var MAXWIDTH:Number=612;
		public static var MAXHEIGHT:Number=300;
		public var itemWitdh:Number=12;
		
		
		private var bmc:BitmapCanvas;
		private var clipContainer:Sprite;
		private var sa:SoundAnalyzer;
		private var pool:ObjectPool;
		private var layout:GridLayout;
		
		public function SpectrumContener()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE,evt_added,false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE,evt_removed,false,0,true);
			//bmc = new BitmapCanvas(MAXWIDTH, MAXHEIGHT);
			//addChild(bmc);
			clipContainer=new Sprite();
			sa=new SoundAnalyzer();
			pool = new ObjectPool(Mc_SpectrumLine, 64);
			pool.onRequestObject=poolOnRequest;
			pool.onReleaseObject=poolOnRelease;
			layout = new GridLayout(0, 0, 12, 0, 64);
			addChild(clipContainer);
			
		}
		
		
		
		protected function evt_removed(event:Event):void
		{
			// TODO Auto-generated method stub
			
		//	bmc.stopCapture();
			try {
			pool.destroy();
			} catch (e:Error) {
				
			}
			sa.stop();
		}
	
		protected function evt_added(event:Event):void
		{
			// TODO Auto-generated method stub
			pool.requestAll();
			sa.start();
	//		bmc.startCapture(clipContainer, true);
		}
		
	
		
		private function poolOnRequest(item:Object):void {
			var clip:Sprite=item as Sprite;
			layout.applyLayout(clip);
			var i:int = pool.activeSet.length-1;
			
			var heightTracker:FunctionTracker = new FunctionTracker(clip, "height", sa.getFrequencyRange, [i*4, i*4+4, 0, 300]);
			heightTracker.store("spectrum");
			heightTracker.start();
			
			clipContainer.addChild(clip);
		}
		
		private function poolOnRelease(item:Object):void {
		
				var clip:Sprite=item as Sprite;
				
				BehaviorStore.retrieve(item,"spectrum").destroy()
				BehaviorStore.remove(item,"spectrum");
		}
	}
}