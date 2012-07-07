package akdcl.skeleton
{
	import flash.geom.Point;
	
	/**
	 * 格式化、管理骨骼配置与骨骼动画
	 * @author Akdcl
	 */
	final public class ConnectionData {
		internal static const BONE:String = "bone";
		internal static const ANIMATION:String = "animation";
		
		internal static const NAME:String = "name";
		internal static const PARENT:String = "parent";
		internal static const ROTATION:String = "rotation";
		internal static const OFF_R:String = "offR";
		internal static const X:String = "x";
		internal static const Y:String = "y";
		internal static const Z:String = "z";
		internal static const SCALE_X:String = "scaleX";
		internal static const SCALE_Y:String = "scaleY";
		internal static const ALPHA:String = "alpha";
		internal static const DELAY:String = "delay";
		internal static const SCALE:String = "scale";
		internal static const FRAME:String = "frame";
		internal static const EVENT_FRAME:String = "eventFrame";
		
		private static var armarureDatas:Object = { };
		private static var animationDatas:Object = { };
		
		public static function getAnimationData(_id:String):ArmatureAniData {
			return animationDatas[_id];
		}
		
		public static function getArmatureData(_id:String):XMLList {
			return armarureDatas[_id];
		}
		
		/**
		 * 将XML数据转换成内置数据
		 * @param _xml XML数据
		 */
		public static function addData(_xml:XML):void {
			var _name:String = _xml.attribute(NAME);
			var _aniData:ArmatureAniData = armarureDatas[_name];
			if (_aniData) {
				return;
			}
			
			armarureDatas[_name] = _xml.elements(BONE);
			animationDatas[_name] = _aniData = new ArmatureAniData();
			
			var _aniName:String;
			var _boneName:String;
			var _boneAniData:BoneAniData;
			var _frameXMLList:XMLList;
			var _animationList:XMLList = _xml.elements(ANIMATION);
			for each(var _eachAni:XML in _animationList) {
				_aniName = String(_eachAni.attribute(NAME));
				_boneAniData = new BoneAniData();
				_aniData.addAnimation(_boneAniData, _aniName);
				_boneAniData.frame = int(_eachAni.attribute(FRAME));
				_frameXMLList = _eachAni.elements(EVENT_FRAME);
				if (_frameXMLList.length() > 0) {
					_boneAniData.eventList = new Vector.<EventFrame>;
					var _eventFrame:EventFrame;
					var _frame:uint = 0;
					for each(_eachBoneAni in _frameXMLList){
						_eventFrame = new EventFrame(String(_eachBoneAni.attribute(NAME)), int(_eachBoneAni.attribute(FRAME)));
						_boneAniData.eventList.push(_eventFrame);
						_frame += _eventFrame.frame;
					}
					_boneAniData.eventList.unshift(new EventFrame("init", _boneAniData.frame - _frame));
				}
				
				for each(var _eachBoneAni:XML in _eachAni.children()) {
					_boneName = String(_eachBoneAni.name());
					if (_boneName != EVENT_FRAME) {
						if (_boneAniData.getAnimation(_boneName)) {
							continue;
						}
						_boneAniData.addAnimation(getFrameNodeList(_eachAni.elements(_boneName)), _boneName);
					}
				}
			}
			delete _xml[ANIMATION];
			delete _xml[BONE];
		}
		
		private static function getFrameNodeList(_frameXMLList:XMLList):FrameNodeList {
			var _nodeList:FrameNodeList = new FrameNodeList();
			_nodeList.scale = Number(_frameXMLList[0].attribute(SCALE)) || _nodeList.scale;
			_nodeList.delay = Number(_frameXMLList[0].attribute(DELAY)) || _nodeList.delay;
			
			for each(var _nodeXML:XML in _frameXMLList) {
				_nodeList.addFrame(getFrameNode(_nodeXML));
			}
			return _nodeList;
		}
		
		private static function getFrameNode(_nodeXML:XML):FrameNode {
			var _rotation:Number = Number(_nodeXML.attribute(ROTATION));
			//_rotation = _rotation * Math.PI / 180;
			var _node:FrameNode = new FrameNode(Number(_nodeXML.attribute(X)), Number(_nodeXML.attribute(Y)), _rotation);
			_node.scaleX = Number(_nodeXML.attribute(SCALE_X)) || _node.scaleX;
			_node.scaleY = Number(_nodeXML.attribute(SCALE_Y)) || _node.scaleY;
			_node.alpha = Number(_nodeXML.attribute(ALPHA)) || _node.alpha;
			_node.offR = Number(_nodeXML.attribute(OFF_R)) || _node.offR;
			//_node.offR = _node.offR * Math.PI / 180;
			_node.frame = int(_nodeXML.attribute(FRAME)) || _node.frame;
			return _node;
		}
	}
}