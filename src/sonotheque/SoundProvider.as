package sonotheque
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.getDefinitionByName;
	
	import org.casalib.util.SingletonUtil;
	
	import pensetete.events.Dispatch;
	
	/**
	 * @copyright www.pense-tete.com
	 * @author GUYF
	 * @version 1.0.0 [1 mars 2012][GUYF] creation
	 *
	 * sonotheque.SoundProvider
	 */
	
	
	public class SoundProvider
	{
		
		private var _dispatcher:EventDispatcher;
		
		public static var lib:Class=Object;
		
		
		private static var _instance:SoundProvider;
		/**
		 * private constucteur
		 * utiliser en singleton
		 * 
		 */
		public function SoundProvider()
		{
			_dispatcher=new EventDispatcher();
			createSoundRef();
		}
		
		private var arrSound:Array;
		
		public function getSoundList():Array {
			return arrSound.concat();
		}
		
		public function get listVilles():Array
		{
			return _listVilles;
		}

		public function get listLieux():Array
		{
			return _listLieux;
		}

		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}

		public function get dispatcher():EventDispatcher
		{
			return _dispatcher;
		}

		private var _listLieux:Array;
		private var _listVilles:Array;
		private function createSoundRef():void{
			//Get an XML description of this class
			//and return the variable types as XMLList with e4x
			var varList:XMLList = flash.utils.describeType(lib)..variable;
			arrSound=new Array();
			_listLieux=new Array();
			_listVilles=new Array();
			for(var i:int; i < varList.length(); i++){
				//Show the name and the value
				trace("createSoundRef :",varList[i].@name+':'+ lib[varList[i].@name]);
				var arrName:Array=varList[i].@name.toString().split("_");
				var cl:Class = lib[varList[i].@name] as Class
				if (arrName.length>1) {
					arrSound.push({ville:arrName[0],lieu:arrName[1],son:(new cl()) as Sound})
						
					if (listVilles.indexOf(arrName[0]==-1)) {
						listVilles.push(arrName[0]);
					}
					
					if (listLieux.indexOf(arrName[1]==-1)) {
						listLieux.push(arrName[1]);
					}
				}
			}
			
		}
		
		private var _currentSound:Sound;
		private var _currentSoundChannel:SoundChannel;

		public function get currentSound():Sound
		{
			return _currentSound;
		}

		/**
		 * créer ou fournisseur de son 
		 * @return 
		 * 
		 */
		public static function get instance():SoundProvider {
			if (_instance)
				return _instance
			return _instance=new SoundProvider();
		}
		private var _isPlaying:Boolean=false;
		
		public function repeat():void {
			if (_currentSoundChannel) {
				_isPlaying=false;
				_currentSoundChannel.stop();
				
			}
			if (_currentSound) {
				_currentSoundChannel=_currentSound.play();
				_currentSoundChannel.addEventListener(Event.SOUND_COMPLETE,evt_complet,false,0,true);
				_isPlaying=true;
			}
		}
		
		public function stop():void {
			if (_currentSoundChannel) {
				_currentSoundChannel.stop();
				_isPlaying=false;
				evt_complet(null);
			}
		}

		public function erreur():void {
			var cl:Class = (lib["erreur"] as Class);
			((new cl()) as Sound).play();
		}
		
		public function success():void {
			var cl:Class = (lib["success"] as Class);
			((new cl()) as Sound).play();
		}
		
		public function play(ville:String,lieu:String):void {
			if (_currentSoundChannel) {
				_currentSoundChannel.stop();
				try {
				_currentSound.close()
				} catch (e:Error) {
					
				}
				_isPlaying=false;
			}
			var obj:Object=find(ville,lieu);
			if (obj) {
				_isPlaying=true;
				_currentSound = obj.son;
				_currentSoundChannel=_currentSound.play();
				_currentSoundChannel.addEventListener(Event.SOUND_COMPLETE,evt_complet,false,0,true);
			} else {
				trace("ERREUR SoundProvider.play("+ville+", "+lieu+")");
			}
			
		}
		public static const SOUND_COMPLET:String="SOUND_COMPLET";
		protected function evt_complet(event:Event):void
		{
			trace("SoundProvider.evt_complet(event)");
			
			_isPlaying=false;
			// TODO Auto-generated method stub
			_dispatcher.dispatchEvent(new Event(SOUND_COMPLET));
		}		
		
		
	
		
		
		/********************************************************************************************************/
		/**									INSPECTION DES SONS													*/
		/********************************************************************************************************/
		
		/**
		 * recherche des son lié à un lieu
		 * @return {lieu:String,ville::String,son:SoundAsset}
		 **/
		public function filter_villeByLieu(lieu:String):Array {
			function helper_filter_villeByLieu(item:*, index:int, array:Array):Boolean {
				return this['lieu']==item.lieu;
			}
			return arrSound.filter(helper_filter_villeByLieu,{lieu:lieu})
		}
		
		
		/**
		 * recherche des son lié à une ville
		 * @return {lieu:String,ville::String,son:SoundAsset}
		 **/
		public function filter_lieuByVille(ville:String):Array {
			function helper_filter_lieuByVille(item:*, index:int, array:Array):Boolean {
				return this['ville']==item.ville;
			}
			
			return arrSound.filter(helper_filter_lieuByVille,{ville:ville})
		}
		
		/**
		 * recherche des son lié à une ville && un lieu
		 * @return {lieu:String,ville::String,son:SoundAsset}
		 **/
		private function find(ville:String,lieu:String):Object {
			function helper_filter_villeByLieu(item:*, index:int, array:Array):Boolean {
				return this['lieu']==item.lieu;
			}
			var res:Array=filter_lieuByVille(ville).filter(helper_filter_villeByLieu,{lieu:lieu});
			if (res.length==0) {
				return null
			} else {
				return res[0];
			}
		}
		
		/**
		 * verifie l'existence d'un son
		 * @return Boolean
		 **/
		public function exist(ville:String,lieu:String) :Boolean {
			return find(ville,lieu) != null;
		}
		
		public function getLieux(ville:String):Array {
			
			var arr:Array=SoundProvider.instance.filter_lieuByVille(ville);
			return  arr.map(helper_getLieux);
		}
		private function helper_getLieux(item:*, index:int, array:Array):String {
			return item.lieu
		}
		public function getVilles(lieu:String):Array {
			var arr:Array=SoundProvider.instance.filter_villeByLieu(lieu);
			return  arr.map(helper_getVilles);
		}
		
		private function helper_getVilles(item:*, index:int, array:Array):String {
			return item.ville
		}
		
		
	}
}