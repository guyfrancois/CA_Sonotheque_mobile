package sonotheque.ecranDecouvrir
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import navigation.BtnOverDisableSelect;
	
	/**
	 * @copyright www.pense-tete.com
	 * @author GUYF
	 * @version 1.0.0 [2 mars 2012][GUYF] creation
	 *
	 * sonotheque.ecranDecouvrir.MenuSelection
	 */
	public class MenuSelection extends Sprite
	{
		public static const EVT_SELECTION:String="EVT_SELECTION";
		public function MenuSelection()
		{
			trace("MenuSelection)");
			addEventListener(Event.ADDED_TO_STAGE,evt_added,false,0,false);
		}
		
		protected function evt_added(event:Event):void
		{
			trace("MenuSelection evt_added");
			arrBtn=new Array();
			for (var s:String in this) 
			{
				if (this[s] is BtnOverDisableSelect) {
					trace("MenuSelection BtnOverDisableSelect");
					initBtn(this[s] as BtnOverDisableSelect);
				} else {
					trace("MenuSelection ! BtnOverDisableSelect",s,this[s]);
				}
			}
		}
		
		private var arrBtn:Array;
		
		private function initBtn(btn:BtnOverDisableSelect):void
		{
			trace("MenuSelection.initBtn("+btn.name+")");
			
			arrBtn.push(btn);
			btn.btnEnable=true;
			btn.addEventListener(MouseEvent.CLICK,evt_click_btn,false,0,true);
		}
		
		
		private var _currentSelect:String="";
		public function get currentSelection():String {
			return _currentSelect;
		}
		protected function evt_click_btn(event:MouseEvent):void
		{
			_currentSelect=   event.currentTarget.name.substr(String("btn_").length);
			var selected:BtnOverDisableSelect=(event.currentTarget as BtnOverDisableSelect);
			for (var i:int = 0; i < arrBtn.length; i++) 
			{
				arrBtn[i].select=(arrBtn[i]==selected)
			}
			dispatchEvent(new Event("EVT_SELECTION"));
		}

		public function enableOnlyList(arrNames:Array):void {
			for (var i:int = 0; i < arrBtn.length; i++) 
			{
				
				name.substr(String("btn_").length)
				var id:Number=arrNames.indexOf(arrBtn[i].name.substr(String("btn_").length));
				arrBtn[i].btnEnable=(id!=-1);
			}
		}
	}
}