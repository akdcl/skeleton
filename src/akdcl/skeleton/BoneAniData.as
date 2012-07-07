package akdcl.skeleton{
	
	/**
	 * ...
	 * @author Akdcl
	 */
	final public class BoneAniData {
		public var frame:uint;
		public var eventList:Vector.<EventFrame>;
		
		private var frameNodeListDic:Object;
		public function BoneAniData() {
			frameNodeListDic = { };
		}
		
		public function addAnimation(_frameNodeList:FrameNodeList, _boneName:String):void {
			frameNodeListDic[_boneName] = _frameNodeList;
		}
		
		public function getAnimation(_boneName:String):FrameNodeList {
			return frameNodeListDic[_boneName];
		}
	}
}