package akdcl.skeleton{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.FrameLabel;
	
	import flash.geom.Point;
	
	/**
	 * 把骨骼模板制作成XML数据，方便保存或修改
	 * @author Akdcl
	 */
	final public class ConnectionXMLMaker {
		private static const NAN_VALUE:uint = 99;
		private static const AT:String = "@";
		
		private static var pointTemp:Point = new Point();
		private static var frameNode:FrameNode = new FrameNode();
		
		/**
		 * 将Contour转换成XML数据
		 * @param _contour 需要转换的Contour
		 */
		public static function encode(_contour:Contour):XML {
			var _xml:XML = <skeleton/>;
			_xml[AT + ConnectionData.NAME] = _contour.getName();
			formatXML(_contour.xml, _xml);
			generateBone(_contour, _xml);
			generateAnimation(_contour, _xml);
			return _xml;
		}
		
		private static function formatXML(_xml:XML, _xmlCopy:XML = null, _level:uint = 0):void {
			var _boneCopy:XML;
			var _boneXMLList:XMLList = _xml.children();
			for each(var _boneXML:XML in _boneXMLList) {
				_boneCopy = _boneXML.copy();
				_boneCopy.setName(ConnectionData.BONE);
				_boneCopy[AT + ConnectionData.NAME] = _boneXML.name();
				if (_level > 0) {
					_boneCopy[AT + ConnectionData.PARENT] = _boneXML.parent().name();
				}
				delete _boneCopy.*;
				_xmlCopy.appendChild(_boneCopy);
				if (_boneXML.children().length() > 0) {
					formatXML(_boneXML, _xmlCopy, _level+1);
				}
			}
		}
		
		private static function generateBone(_contour:Contour, _xml:XML):void {
			var _parent:DisplayObject;
			var _joint:DisplayObject;
			var _x:Number;
			var _y:Number;
			var _boneXML:XML;
			
			//按照深度顺序检索
			var _boneXMLList:XMLList = _xml.elements(ConnectionData.BONE);
			var _length:uint = _contour.numChildren;
			for (var _i:uint = 0; _i < _length; _i++ ) {
				_joint = _contour.getChildAt(_i);
				_boneXML = _boneXMLList.(attribute(ConnectionData.NAME) == _joint.name)[0];
				if (_boneXML) {
					_parent = _contour.getChildByName(_boneXML.attribute(ConnectionData.PARENT));
					if (_parent) {
						transfromParentXY(pointTemp, _joint, _parent);
						_x = pointTemp.x;
						_y = pointTemp.y;
					}else {
						_x = _joint.x;
						_y = _joint.y;
					}
					_boneXML[AT + ConnectionData.X] = Math.round(_x * 100) / 100;
					_boneXML[AT + ConnectionData.Y] = Math.round(_y * 100) / 100;
					_boneXML[AT + ConnectionData.Z] = _contour.getChildIndex(_joint);
				}else {
					trace("contour:" + _contour.getName(), "bone:" + _joint.name, "未找到对应的配置XML节点");
				}
			}
		}
		
		private static function generateAnimation(_contour:Contour, _xml:XML):void {
			var _frameLabel:FrameLabel;
			
			var _labelFrameLength:uint;
			var _name:String;
			var _joint:DisplayObject;
			
			var _animationXML:XML;
			var _boneXML:XML;
			var _boneNodeXML:XML;
			var _frameXMLList:XMLList;
			var _boneXMLList:XMLList = _xml.elements(ConnectionData.BONE);
			
			var _currentLabels:Array = _contour.currentLabels;
			var _frameLabels:Array = formatFrameLabels(_currentLabels);
			var _length:uint = _frameLabels.length;
			for (var _i:uint = 0; _i < _length; _i++ ) {
				_frameLabel = _frameLabels[_i];
				//忽略第一帧的帧标签
				if (_frameLabel.frame == 1) {
					continue;
				}
				
				//获取带标签的帧的长度
				if (_i + 1 == _length) {
					_labelFrameLength = _contour.totalFrames - _frameLabel.frame + 1;
				}else {
					_labelFrameLength = _frameLabels[_i + 1].frame - _frameLabel.frame;
				}
				_animationXML =<{ConnectionData.ANIMATION}/>;
				_animationXML[AT + ConnectionData.NAME] = _frameLabel.name;
				_animationXML[AT + ConnectionData.FRAME] = _labelFrameLength;
				_xml.appendChild(_animationXML);
				
				_contour.gotoAndStop(_frameLabel.name);
				for (var _k:uint = 0; _k < _labelFrameLength; _k++ ) {
					if (_k == _labelFrameLength - 1) {
						//为最后一个子标签帧修正其长度
						setFrameLabels(_animationXML, null, _contour.currentFrame + 1);
					}else if (_contour.currentFrameLabel && _contour.currentFrameLabel != _frameLabel.name) {
						//如果这帧带有子标签（不能是最后一帧和第一帧）
						setFrameLabels(_animationXML, _contour.currentFrameLabel.split("_").pop(), _contour.currentFrame);
					}
					
					for (var _j:uint = 0; _j < _contour.numChildren; _j++ ) {
						_joint = _contour.getChildAt(_j);
						_name = _joint.name;
						_boneXML = _boneXMLList.(attribute(ConnectionData.NAME) == _name)[0];
						if (!_boneXML) {
							//没有配置xml的元件忽略
							continue;
						}
						
						setFrameNode(
							(_contour.getChildByName(_boneXML.attribute(ConnectionData.PARENT))) as DisplayObjectContainer,
							_joint,
							_boneXML,
							_contour.getValue(_name, ConnectionData.OFF_R)
						);
						
						_boneXML = null;
						//找到该关键的动画列表
						_frameXMLList = _animationXML.elements(_name);
						if (_frameXMLList.length() > 0) {
							//如果已经创建了该关键的动画列表则找到列表的最后一个
							_boneXML = _frameXMLList[_frameXMLList.length() - 1];
						}
						
						if (_boneXML && sameFrameNode(_boneXML)) {
							//忽略相同的节点
							if (_boneXML.attribute(ConnectionData.FRAME).length() > 0) {
								_boneXML[AT + ConnectionData.FRAME] = int(_boneXML.attribute(ConnectionData.FRAME)) + 1;
							}else {
								//1+1
								_boneXML[AT + ConnectionData.FRAME] = 2;
							}
						}else {
							addFrameNode(
								_name,
								_animationXML,
								_boneXML,
								_contour.getValue(_name, ConnectionData.SCALE),
								_contour.getValue(_name, ConnectionData.DELAY)
							);
						}
					}
					_contour.clearValues();
					_contour.nextFrame();
				}
			}
		}
		
		private static function setFrameLabels(_animationXML:XML, _labelName:String, _frame:int):void {
			if (_labelName) {
				var _node:XML =<{ConnectionData.FRAME}/>;
				_node[AT + ConnectionData.NAME] = _labelName;
				_node[AT + ConnectionData.FRAME] = _frame;
			}
			
			var _list:XMLList = _animationXML.elements(ConnectionData.FRAME);
			if (_list.length() > 0) {
				var _prevNode:XML = _list[_list.length() - 1];
				//为前一个子标签帧修正长度
				_prevNode[AT + ConnectionData.FRAME] = _frame-int(_prevNode.attribute(ConnectionData.FRAME));
				if (_node) {
					_animationXML.insertChildAfter(_prevNode, _node);
				}
			}else {
				if (_node) {
					_animationXML.prependChild(_node);
				}
			}
		}
		
		private static function formatFrameLabels(_frameLabels:Array):Array {
			var _labelsFormated:Array = [];
			var _length:uint = _frameLabels.length;
			var _frameLabel:FrameLabel;
			var _prevLabel:FrameLabel;
			for (var _i:uint = 0; _i < _length; _i++ ) {
				_frameLabel = _frameLabels[_i];
				//忽略第一帧的帧标签
				if (_frameLabel.frame == 1) {
					continue;
				}
				//如果标签是前一个标签的子节点，则忽略
				if (_prevLabel && _frameLabel.name.indexOf(_prevLabel.name + "_") == 0) {
					continue;
				}
				_labelsFormated[_labelsFormated.length] = _frameLabel;
				_prevLabel = _frameLabel;
			}
			return _labelsFormated;
		}
		
		private static function setFrameNode(_parent:DisplayObjectContainer, _joint:DisplayObject, _boneXML:XML, _offR:Number):void {
			if (_parent) {
				transfromParentXY(pointTemp, _joint, _parent, Number(_boneXML.attribute(ConnectionData.X)), Number(_boneXML.attribute(ConnectionData.Y)));
				frameNode.rotation = _joint.rotation - _parent.rotation;
				frameNode.x = pointTemp.x;
				frameNode.y = pointTemp.y;
			}else {
				frameNode.rotation = _joint.rotation;
				frameNode.x = _joint.x;
				frameNode.y = _joint.y;
			}
			
			frameNode.scaleX = _joint.scaleX;
			frameNode.scaleY = _joint.scaleY;
			frameNode.alpha = _joint.alpha;
			frameNode.offR = _offR;
			//
			formatFrameNode();
		}
		
		private static function addFrameNode(_name:String, _parentXML:XML, _prevNode:XML, _scale:Number, _delay:Number):void {
			var _frameNodeXML:XML =<{_name}/>;
			if (_prevNode) {
				_parentXML.insertChildAfter(_prevNode, _frameNodeXML);
			}else {
				_parentXML.appendChild(_frameNodeXML);
			}
			
			_frameNodeXML[AT + ConnectionData.X] = frameNode.x;
			_frameNodeXML[AT + ConnectionData.Y] = frameNode.y;
			_frameNodeXML[AT + ConnectionData.ROTATION] = frameNode.rotation;
			if (frameNode.scaleX != NAN_VALUE) {
				_frameNodeXML[AT + ConnectionData.SCALE_X] = frameNode.scaleX;
			}
			if (frameNode.scaleY != NAN_VALUE) {
				_frameNodeXML[AT + ConnectionData.SCALE_Y] = frameNode.scaleY;
			}
			if (frameNode.alpha != NAN_VALUE) {
				_frameNodeXML[AT + ConnectionData.ALPHA] = frameNode.alpha;
			}
			if (frameNode.offR) {
				_frameNodeXML[AT + ConnectionData.OFF_R] = frameNode.offR;
			}
			if (_scale) {
				_frameNodeXML[AT + ConnectionData.SCALE] = _scale;
			}
			if (_delay) {
				_delay %= 1;
				_frameNodeXML[AT + ConnectionData.DELAY] = _delay;
			}
		}
		
		private static function formatFrameNode():void {
			frameNode.rotation = Math.round(frameNode.rotation * 100) / 100;
			frameNode.x = Math.round(frameNode.x * 100) / 100;
			frameNode.y = Math.round(frameNode.y * 100) / 100;
			frameNode.scaleX = Math.round(frameNode.scaleX * 20) / 20;
			frameNode.scaleY = Math.round(frameNode.scaleY * 20) / 20;
			frameNode.alpha = Math.round(frameNode.alpha * 20) / 20;
					
			if (Math.abs(frameNode.rotation) < 1) {
				frameNode.rotation = 0;
			}
			if (Math.abs(frameNode.x) < 1) {
				frameNode.x = 0;
			}
			if (Math.abs(frameNode.y) < 1) {
				frameNode.y = 0;
			}
			//如果scaleXY和alpha为1则忽略
			//node中默认为1
			if (frameNode.scaleX == 1) {
				frameNode.scaleX = NAN_VALUE;
			}else if (frameNode.scaleX > 3)  {
				//避免使用matrix使用大于3以上的值充当负值
				frameNode.scaleX = 3 - frameNode.scaleX;
			}
			if (frameNode.scaleY == 1) {
				frameNode.scaleY = NAN_VALUE;
			}else if (frameNode.scaleY > 3)  {
				//避免使用matrix使用大于3以上的值充当负值
				frameNode.scaleY = 3 - frameNode.scaleY;
			}
			if (frameNode.alpha == 1) {
				frameNode.alpha = NAN_VALUE;
			}
		}
		
		private static function sameFrameNode(_frameNodeXML:XML):Boolean {
			var _isSame:Boolean = true;
			//忽略相差一像素以内的位移和旋转
			_isSame = _isSame && int(_frameNodeXML.attribute(ConnectionData.X)) == int(frameNode.x);
			_isSame = _isSame && int(_frameNodeXML.attribute(ConnectionData.Y)) == int(frameNode.y);
			_isSame = _isSame && int(_frameNodeXML.attribute(ConnectionData.ROTATION)) == int(frameNode.rotation);
			//scaleXY和alpha没有则默认为1
			_isSame = _isSame && (_frameNodeXML.attribute(ConnectionData.SCALE_X).length() == 0?(frameNode.scaleX == NAN_VALUE):(Number(_frameNodeXML.attribute(ConnectionData.SCALE_X)) == frameNode.scaleX));
			_isSame = _isSame && (_frameNodeXML.attribute(ConnectionData.SCALE_Y).length() == 0?(frameNode.scaleY == NAN_VALUE):(Number(_frameNodeXML.attribute(ConnectionData.SCALE_Y)) == frameNode.scaleY));
			_isSame = _isSame && (_frameNodeXML.attribute(ConnectionData.ALPHA).length() == 0?(frameNode.alpha == NAN_VALUE):(Number(_frameNodeXML.attribute(ConnectionData.ALPHA)) == frameNode.alpha));
			//offR没有则默认为0
			_isSame = _isSame && (_frameNodeXML.attribute(ConnectionData.OFF_R).length() == 0?(frameNode.offR == 0):(Number(_frameNodeXML.attribute(ConnectionData.OFF_R)) == frameNode.offR));
			return _isSame;
		}
		
		private static function transfromParentXY(_point:Point, _joint:DisplayObject, _parent:DisplayObject, _offX:Number = 0, _offY:Number = 0):void {
			var _dX:Number = _joint.x - _parent.x;
			var _dY:Number = _joint.y - _parent.y;
			var _r:Number = Math.atan2(_dY, _dX) - _parent.rotation * Math.PI / 180;
			var _len:Number = Math.sqrt(_dX * _dX + _dY * _dY);
			_point.x = _len * Math.cos(_r) - _offX;
			_point.y = _len * Math.sin(_r) - _offY;
		}
	}
}