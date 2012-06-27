package akdcl.textures
{
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	import starling.display.DisplayObjectContainer;
	import starling.textures.Texture;
	import starling.textures.SubTexture;
	
	/**
	 * ...
	 * @author Akdcl
	 */
	final public class EasyForStarling {
		public static function addJointsTo(_sprite:DisplayObjectContainer, _textureMix:TextureMix, _id:String):void {
			if (!_textureMix.texture) {
				_textureMix.texture = Texture.fromBitmapData(_textureMix.bitmapData);
			}
			
			var _xmlList:XMLList = _textureMix.getTextures(_id);
			var _img:Image;
			for each(var _textXML:XML in _xmlList) {
				_img = getJoint(_textXML, _textureMix.texture as Texture);
				_img.name = _textureMix.getNodeName(_textXML, _id);
				_sprite.addChild(_img);
			}
			
		}
		
		private static function getJoint(_textXML:XML, _texture:Texture):Image {
			var _rect:Rectangle = new Rectangle(int(_textXML.@x), int(_textXML.@y), int(_textXML.@width), int(_textXML.@height));
			var _subT:SubTexture = new SubTexture(_texture, _rect);
			var _img:Image = new Image(_subT);
			_img.pivotX = -int(_textXML.@frameX);
			_img.pivotY = -int(_textXML.@frameY);
			return _img;
		}
		
		public static function getTexture(_id:String, _textureMix:TextureMix):Image {
			var _textXML:XML = _textureMix.getTexture(_id);
			var _rect:Rectangle = new Rectangle(int(_textXML.@x), int(_textXML.@y), int(_textXML.@width), int(_textXML.@height));
			var _subT:SubTexture = new SubTexture(_textureMix.texture as Texture, _rect);
			var _img:Image = new Image(_subT);
			_img.pivotX = -int(_textXML.@frameX);
			_img.pivotY = -int(_textXML.@frameY);
			return _img;
		}
	}
	
}
			
			