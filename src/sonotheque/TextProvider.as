package sonotheque
{
	import org.casalib.util.StringUtil;
	
	/**
	 * @copyright www.pense-tete.com
	 * @author GUYF
	 * @version 1.0.0 [2 mars 2012][GUYF] creation
	 *
	 * sonotheque.TextProvider
	 */
	public class TextProvider
	{
		
		static private var _instance:TextProvider;
		static public function get instance():TextProvider
		{
			if (_instance == null) _instance = new TextProvider();
			return _instance;
		}
		
		private var textes:Object = {
			paris :"à Paris",
			caire : "au Caire",
			shanghai : "à Shanghai",
			sf : "à San Francisco",
			kyoto : "à Kyoto",
			
			gare: "une gare",
			jardin : "un jardin",
			carrefour:"un carrefour",
			marche:"un marché",
			rue:"une rue",
			imprevu:"un imprévu"
			
			
		}
			
		public function descriptionJeu(lieu:String,ville:String):String {
			return StringUtil._capitalizeFirstLetter("Bravo ! C'est bien "+textes[lieu]+" "+textes[ville]);
		}
		public function questionJeu() :String {
			return StringUtil._capitalizeFirstLetter("De quelle ville provient ce son ?");
		}
			
		public function questionJeulieu(ville:String) :String {
			return StringUtil._capitalizeFirstLetter("De quel lieu "+textes[ville]+" provient ce son ?");
		}
			
		public function questionVille(ville:String) :String {
			return "Quel lieu "+textes[ville]+" ?";
		}
		public function questionlieu(lieu:String) :String {
			return StringUtil._capitalizeFirstLetter(textes[lieu]+", mais où ?");
		}
		public function question():String {
			return "Choisir une ville et un lieu"
		}
		public function description(lieu:String,ville:String):String {
			return StringUtil._capitalizeFirstLetter(textes[lieu]+" "+textes[ville]);
		}
	}
}