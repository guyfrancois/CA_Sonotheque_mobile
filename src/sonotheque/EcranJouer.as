package sonotheque
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	
	import navigation.BtnOverDisableSelect;
	
	import pt.utils.Permute;
	
	
	/**
	 * @copyright www.pense-tete.com
	 * @author GUYF
	 * @version 1.0.0 [12 mars 2012][GUYF] creation
	 *
	 * sonotheque.EcranJouer
	 */
	public class EcranJouer extends Sprite implements I_Ecran
	{
		public var btn_autre:MovieClip;
		public var controle:MovieClip;
		private var bmp:Bitmap;
		
		
		private var arrTirage:Array;
		
		
		private var objTirage:Object;
		public function EcranJouer()
		{
			
			super();
			bmp=new Bitmap(null,PixelSnapping.AUTO,true);
			bmp.x=controle.x;
			bmp.y=controle.y;
			controle.texte.text=""
			btn_autre.mouseEnabled=false;
			
			controle.choix1.gotoAndStop("idle");
			controle.choix2.gotoAndStop("idle");
			controle.btn_rejouer.visible=false;
			lieuxvisible(false);
			villevisible(true);
			evt_added(null)
			
			//addEventListener(Event.ADDED,evt_added,false,0,true)
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
			
			SoundProvider.instance.dispatcher.addEventListener(SoundProvider.SOUND_COMPLET,evt_soundComplet,false,0,true);
			//TODO : tirage aléatoire du son
			if (param) {
				controle.casque.addEventListener(MouseEvent.CLICK,evt_repeatSon,false,0,true);
				controle.btn_rejouer.addEventListener(MouseEvent.CLICK,evt_click_relay,false,0,true);
				initBtns();
				arrTirage=Permute.shuffle_out(SoundProvider.instance.getSoundList())
				
				re_initPlay();
				
			} else {
				SoundProvider.instance.play(objTirage.ville,objTirage.lieu);
				controle.casque.gotoAndStop(2);
			}
			
			btn_autre.mouseEnabled=true;
			
		}
		public function  stopContent(param:Object = null ):void {
			
			//controle.texte.text="";
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
		
		private var ville:String="";
		private var lieu:String="";
		
		
		private function re_initPlay():void {
			controle.texte.text=TextProvider.instance.questionJeu();
			ville="";
			lieu="";
			controle.choix1.gotoAndStop("idle");
			controle.choix2.gotoAndStop("idle");
			controle.btn_rejouer.visible=false;
			lieuxvisible(false);
			villevisible(true);
			objTirage=tirage()
			SoundProvider.instance.play(objTirage.ville,objTirage.lieu);
			controle.casque.gotoAndStop(2);
		}
		
		protected function evt_click_relay(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			re_initPlay();
		}
		
		private function tirage():Object {
			if (arrTirage && arrTirage.length>0) {
				return arrTirage.pop();
			} else {
				arrTirage=Permute.shuffle_out(SoundProvider.instance.getSoundList());
				return arrTirage.pop();
			}
			
		}
		
		private function initBtns():void
		{
			for (var i:int = 0; i < SoundProvider.instance.listLieux.length; i++) 
			{
			//	trace(i,SoundProvider.instance.listLieux[i]);
				initBtn(controle[SoundProvider.instance.listLieux[i]]);
				
			}
			for (var i:int = 0; i < SoundProvider.instance.listVilles.length; i++) 
			{
			//	trace(SoundProvider.instance.listVilles[i]);
				initBtn(controle[SoundProvider.instance.listVilles[i]]);
				
			}
		}
		
		private function initBtn(btn:BtnOverDisableSelect):void
		{
			// TODO Auto Generated method stub
			btn.addEventListener(MouseEvent.CLICK,evt_selectItem,false,0,true);
		}
		
	
		protected function evt_selectItem(event:MouseEvent):void
		{
			var btn:BtnOverDisableSelect=(event.currentTarget as BtnOverDisableSelect);
			
			if (ville=="") {
				if (btn.name == objTirage.ville) {
					ville=btn.name;
					villevisible(false)
					lieuxvisible(true);
					controle.choix1.gotoAndStop(ville);
					controle.texte.text=TextProvider.instance.questionJeulieu(ville);
					SoundProvider.instance.success()
					
				} else {
					SoundProvider.instance.erreur();
					btn.btnEnable=false;
				}
			} else if (lieu=="") {
				if (btn.name == objTirage.lieu) {
					lieu=btn.name;
					villevisible(false)
					lieuxvisible(false);
					controle.choix2.gotoAndStop(lieu);
					controle.btn_rejouer.visible=true;
					controle.texte.text=TextProvider.instance.descriptionJeu(lieu,ville);
					SoundProvider.instance.success()
				} else {
					SoundProvider.instance.erreur();
					btn.btnEnable=false;
				}
			}
		}
		
		private function lieuxvisible(visible:Boolean):void {
			for (var i:int = 0; i < SoundProvider.instance.listLieux.length; i++) 
			{
		//		trace(i,SoundProvider.instance.listLieux[i]);
				var btn:BtnOverDisableSelect=controle[SoundProvider.instance.listLieux[i]];
				btn.visible=visible;
				btn.btnEnable=true;
			}
			
		}
		private function villevisible(visible:Boolean):void {
			for (var i:int = 0; i < SoundProvider.instance.listVilles.length; i++) 
			{
		//		trace(SoundProvider.instance.listVilles[i]);
				var btn:BtnOverDisableSelect=controle[SoundProvider.instance.listVilles[i]];
				btn.visible=visible;
				btn.btnEnable=true;
				
			}
			
		}
		
		protected function evt_soundComplet(event:Event):void
		{
			trace("EcranJouer.evt_soundComplet(event)");
			
			controle.casque.gotoAndStop(3);
		}
		
		protected function evt_repeatSon(event:MouseEvent):void
		{
			if (SoundProvider.instance.isPlaying) {
				SoundProvider.instance.stop();
				controle.casque.gotoAndStop(3);
			} else 	{
				SoundProvider.instance.repeat();
				controle.casque.gotoAndStop(2);
			}
			
		}		
	}
}