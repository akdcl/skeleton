package akdcl.skeleton{
	
	/**
	 * ...
	 * @author Akdcl
	 */
	final public class ArmatureAniData {
		private var boneAniDataDic:Object;
		private var animationNames:Array;
		
		public function ArmatureAniData() {
			boneAniDataDic = { };
			animationNames = [];
		}
		public function addAnimation(_boneAniData:BoneAniData, _animationName:String):void {
			boneAniDataDic[_animationName] = _boneAniData;
			animationNames.push(_animationName);
		}
		
		public function getAnimation(_animationName:String):BoneAniData {
			return boneAniDataDic[_animationName];
		}
		
		public function getAnimationNames():Array {
			return animationNames;
		}
	}
}