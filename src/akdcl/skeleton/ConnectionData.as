package akdcl.skeleton
{
	import flash.geom.Point;
	
	/**
	 * 格式化、管理骨骼配置与骨骼动画
	 * @author Akdcl
	 */
	final public class ConnectionData {
		/**
		 * @private
		 */
		internal static const BONE:String = "bone";
		
		/**
		 * @private
		 */
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
		
		/**
		 * @private
		 */
		private static var armatureXML:XML =<root/>;
		
		/**
		 * @private
		 */
		private static var animationDatas:Object = { };
		
		/**
		 * 将ConnectionDataMaker生成的XML数据转换成内置数据
		 * @param _xml XML数据
		 */
		public static function setData(_xml:XML):void {
			var _name:String = _xml.attribute(NAME);
			var _aniData:ArmatureAniData = getArmatureAniData(_name);
			if (_aniData) {
				return;
			}
			
			armatureXML.appendChild(_xml);
			animationDatas[_name] = _aniData = new ArmatureAniData();
			var _aniName:String;
			var _boneName:String;
			var _frameXMLList:XMLList;
			var _animationXMLList:XMLList = _xml.elements(ANIMATION);
			for each(var _frameXML:XML in _animationXMLList) {
				_aniName = _frameXML.attribute(NAME);
				for each(var _nodeXML:XML in _frameXML.children()) {
					_boneName = _nodeXML.name();
					if (_aniData.getAnimation(_aniName, _boneName)) {
						continue;
					}
					_frameXMLList = _frameXML.elements(_boneName);
					if (_frameXMLList.length() > 1) {
						_aniData.addAnimation(getFrameNodeList(_frameXMLList), _aniName, _boneName);
					}else {
						_aniData.addAnimation(getFrameNode(_nodeXML), _aniName, _boneName);
					}
				}
				
				//需要分离
				var _boneAniData:Object = _aniData.getAnimation(_aniName);
				
				_boneAniData.totalFrames = int(_frameXML.attribute(FRAME));
				_frameXMLList = _frameXML.elements(FRAME);
				if (_frameXMLList.length() > 0) {
					
					var _arr:Array = [];
					var _obj:Object;
					var _frame:uint = 0;
					for each(_nodeXML in _frameXMLList) {
						_obj = { };
						_obj.name = String(_nodeXML.attribute(NAME));
						_obj.totalFrames = int(_nodeXML.attribute(FRAME));
						_arr.push(_obj);
						_frame += _obj.totalFrames;
					}
					
					_obj = { };
					//补第一帧信息
					_obj.name = "init";
					_obj.totalFrames = _boneAniData.totalFrames - _frame;
					_arr.unshift(_obj);
					_boneAniData.list = _arr;
				}
			}
		}
		
		private static function getFrameNodeList(_frameXMLList:XMLList):FrameNodeList {
			var _nodeList:FrameNodeList = new FrameNodeList();
			_nodeList.scale = Number(_frameXMLList[0].attribute(SCALE)) || _nodeList.scale;
			_nodeList.delay = Number(_frameXMLList[0].attribute(DELAY)) || _nodeList.delay;
			for each(var _nodeXML:XML in _frameXMLList) {
				_nodeList.addValue(getFrameNode(_nodeXML));
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
			
			_node.totalFrames = int(_nodeXML.attribute(FRAME)) || _node.totalFrames;
			return _node;
		}
		
		public static function getArmatureAniData(_id:String):ArmatureAniData {
			return animationDatas[_id];
		}
		
		public static function getBones(_id:String):XMLList {
			var _xmlList:XMLList = armatureXML.children().(attribute(NAME) == _id).elements(BONE);
			if (_xmlList.length() == 0) {
				return null;
			}
			return _xmlList;
		}
	}
}