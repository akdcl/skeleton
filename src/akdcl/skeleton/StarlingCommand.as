package akdcl.skeleton {
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.SubTexture;
	import starling.textures.Texture;
	
	import akdcl.skeleton.export.TextureMix;
	
	/**
	 * 骨架
	 * @author Akdcl
	 */
	final public class StarlingCommand {
		private static var textureMix:TextureMix;
		public static function createArmature(_name:String, _animationName:String, _textureMix:TextureMix):Armature {
			textureMix = _textureMix;
			if (!textureMix.texture) {
				textureMix.texture = Texture.fromBitmapData(textureMix.bitmapData);
			}
			var _armature:Armature = BaseCommand.createArmature(_name, _animationName, new Sprite(), boneFactory, true);
			textureMix = null;
			return _armature;
		}
		
		static private function boneFactory(_armarureName:String, _boneName:String):Object {
			if (textureMix) {
				return getTextureDisplay(textureMix, _armarureName + "_" + _boneName);
			}
			return null;
		}
		
		public static function getTextureDisplay(_textureMix:TextureMix, _fullName:String):Image {
			var _texture:XML = _textureMix.getTexture(_fullName);
			if (_texture) {
				var _rect:Rectangle = new Rectangle(int(_texture.@x), int(_texture.@y), int(_texture.@width), int(_texture.@height));
				var _img:Image = new Image(new SubTexture(_textureMix.texture as Texture, _rect));
				_img.pivotX = -int(_texture.@frameX);
				_img.pivotY = -int(_texture.@frameY);
				return _img;
			}
			return null;
		}
	}
}