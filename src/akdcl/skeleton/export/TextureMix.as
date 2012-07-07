package akdcl.skeleton.export{
	import flash.display.BitmapData;
	
	/**
	 * ...
	 * @author Akdcl
	 */
	final public class TextureMix{
		public var bitmapData:BitmapData;
		public var xml:XML;
		public var texture:Object;
		
		public function TextureMix(_bmd:BitmapData, _xml:XML = null, _texture:Object = null):void {
			bitmapData = _bmd;
			xml = _xml;
			texture = _texture;
		}
		
		public function dispose():void {
			bitmapData.dispose();
			xml = null;
			if (texture && ("dispose" in texture)) {
				texture.dispose();
			}
			texture = null;
		}
		
		public function getTexture(_id:String):XML {
			return xml.children().(@name.toString() == _id)[0];
		}
		
		public function getTextureList(_prefix:String):XMLList {
			return xml.children().(@name.toString().indexOf(_prefix + "_") == 0);
		}
		
		public function getTexturePreFix(_fullName:String):String {
			var _arr:Array = _fullName.split("_");
			return _arr.length > 1?_arr[0]:null;
		}
		
		public function getTextureSuffix(_fullName:String, _prefix:String):String{
			if(!_prefix){
				_prefix = getTexturePreFix(_fullName);
			}
			if(_prefix){
				_prefix += "_";
				var _index:int = _fullName.indexOf(_prefix);
				if(_index == 0){
					return _fullName.substr(_index + _prefix.length);
				}
			}
			return null;
		}
	}
}