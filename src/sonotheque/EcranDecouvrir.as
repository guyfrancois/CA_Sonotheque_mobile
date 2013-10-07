package sonotheque
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import sonotheque.ecranDecouvrir.MenuSelection;
	
	
	/**
	 * @copyright www.pense-tete.com
	 * @author GUYF
	 * @version 1.0.0 [2 mars 2012][GUYF] creation
	 *
	 * sonotheque.EcranDecouvrir
	 */
	public class EcranDecouvrir extends Sprite implements I_Ecran
	{
		public var btn_autre:MovieClip;
		public var controle:MovieClip;
		public var choix_villes:MenuSelection;
		public var choix_lieux:MenuSelection;
		
		private var itemChoixVille:MovieClip;
		private var itemChoixlieu:MovieClip;
		
		private var bmp:Bitmap;
		
		public function EcranDecouvrir()
		{
			super();
			bmp=new Bitmap(null,PixelSnapping.AUTO,true);
			bmp.x=controle.x;
			bmp.y=controle.y;
			
			controle.texte.text="";
			btn_autre.mouseEnabled=false;
			controle.choix1.gotoAndStop("idle");
			controle.choix2.gotoAndStop("idle");
			choix_villes.addEventListener(MenuSelection.EVT_SELECTION,evt_selection_ville,false,0,true)
			choix_lieux.addEventListener(MenuSelection.EVT_SELECTION,evt_selection_lieu,false,0,true)
			controle.texte.text=TextProvider.instance.question();
			evt_added(null)
		}
		
		protected function evt_added(event:Event):void
		{
			// TODO Auto-generated method stub
			var myBitmapData:BitmapData = new BitmapData(controle.width+5, controle.height+5,true,0);
			myBitmapData.draw(controle,null,null,null,null,true);
			bmp.bitmapData=myBitmapData;
			addChild(bmp);
			controle.visible=false;;
		}
		
		public function  startContent(param:Object = null ):void {
			removeEventListener(Event.ADDED,evt_added,false)
			if (bmp.parent == this) {
				removeChild(bmp);
			}
			controle.visible=true;
			controle.casque.addEventListener(MouseEvent.CLICK,evt_repeatSon,false,0,true);

			SoundProvider.instance.dispatcher.addEventListener(SoundProvider.SOUND_COMPLET,evt_soundComplet,false,0,true);
			btn_autre.mouseEnabled=true;
			
			
		}
		public function  stopContent(param:Object = null ):void {
			
			
			SoundProvider.instance.stop();
			btn_autre.mouseEnabled=false;
			SoundProvider.instance.dispatcher.removeEventListener(SoundProvider.SOUND_COMPLET,evt_soundComplet,false);
			evt_soundComplet(null);
			
			var myBitmapData:BitmapData = new BitmapData(controle.width, controle.height,true,0);
			myBitmapData.draw(controle,null,null,null,null,true);
			bmp.bitmapData=myBitmapData;
			addChild(bmp);
			controle.visible=false;
		}
		
		protected function evt_soundComplet(event:Event):void
		{
			// TODO Auto-generated method stub
			if (choix_villes.currentSelection=="" || choix_lieux.currentSelection=="") {
				controle.casque.gotoAndStop(1);
			} else {
				controle.casque.gotoAndStop(3);
			}
			
		}
		
		protected function evt_repeatSon(event:MouseEvent):void
		{
			if (SoundProvider.instance.isPlaying) {
				SoundProvider.instance.stop();
				controle.casque.gotoAndStop(3);
			} else 	if (choix_villes.currentSelection && choix_lieux.currentSelection) {
				SoundProvider.instance.repeat();
				controle.casque.gotoAndStop(2);
			}
			
		}		
		
		protected function evt_selection_ville(event:Event):void
		{
			if (itemChoixVille==null) {
				itemChoixlieu=controle.choix2;
				itemChoixVille=controle.choix1;
			}
			itemChoixVille.gotoAndStop(choix_villes.currentSelection);
			choix_lieux.enableOnlyList(SoundProvider.instance.getLieux(choix_villes.currentSelection));
			updateSon();
		
		}
		private function helper_getLieux(item:*, index:int, array:Array):String {
			return item.lieu
		}
		protected function evt_selection_lieu(event:Event):void
		{
			if (itemChoixlieu==null) {
				itemChoixlieu=controle.choix1;
				itemChoixVille=controle.choix2;
			}
			itemChoixlieu.gotoAndStop(choix_lieux.currentSelection);
			choix_villes.enableOnlyList(SoundProvider.instance.getVilles(choix_lieux.currentSelection));
			updateSon();
		}
		
		
		protected function updateSon():void {
			SoundProvider.instance.play(choix_villes.currentSelection,choix_lieux.currentSelection);
			var tf:TextField=controle.texte;
			if (choix_villes.currentSelection && choix_lieux.currentSelection) {
				controle.casque.gotoAndStop(2);
				controle.texte.text=TextProvider.instance.description(choix_lieux.currentSelection,choix_villes.currentSelection);
				
			} else if (choix_villes.currentSelection=="" && choix_lieux.currentSelection=="") {
				controle.texte.text=TextProvider.instance.question()
				controle.casque.gotoAndStop(1);
			} else if (choix_villes.currentSelection=="") {
				controle.texte.text=TextProvider.instance.questionlieu(choix_lieux.currentSelection)
				controle.casque.gotoAndStop(1);
			} else if (choix_lieux.currentSelection=="") {
				controle.texte.text=TextProvider.instance.questionVille(choix_villes.currentSelection)
				controle.casque.gotoAndStop(1);
			} 
					
		}
		
	}
}