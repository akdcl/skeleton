package akdcl.skeleton{
	
	/**
	 * ...
	 * @author Akdcl
	 */
	final public class ArmatureAniData {
		private var animations:Object;
		public function ArmatureAniData() {
			animations = { };
		}
		public function addAnimation(_boneAniData:Object, _animationName:String, _boneName:String):void {
			var _boneAniDatas:Object = animations[_animationName];
			if (!_boneAniDatas) {
				animations[_animationName] = _boneAniDatas = { };
			}
			_boneAniDatas[_boneName] = _boneAniData;
		}
		
		public function getAnimation(_animationName:String, _boneName:String = null):Object {
			var _boneAniDatas:Object = animations[_animationName];
			if (_boneName) {
				return _boneAniDatas?_boneAniDatas[_boneName]:null;
			}else {
				return _boneAniDatas;
			}
		}
	}
}