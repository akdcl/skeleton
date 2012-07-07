package akdcl.textures{
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
		
		public function getTextures(_prefix:String):XMLList {
			return xml.children().(@name.toString().indexOf(_prefix + "_") == 0);
		}
		
		public function getTexture(_id:String):XML {
			return xml.children().(@name.toString() == _id)[0];
		}
		
		public function getNodeName(_xml:XML, _id:String = null):String {
			var _string:String = _xml.@name;
			if (_id) {
				var _start:int = _string.indexOf(_id);
				if (_start == 0) {
					return _string.substr(_start + _id.length + 1);
				}
			}
			return _string;
		}
	}
}