package akdcl.skeleton{
	
	/**
	 * 骨骼动画，处理关键帧数据并渲染到骨骼
	 * @author Akdcl
	 */
	final public class Tween extends ProcessBase {
		private static const HALF_PI:Number = Math.PI * 0.5;
		
		private static var prepared:Vector.<Tween> = new Vector.<Tween>;
		public static function create():Tween {
			if (prepared.length > 0) {
				return prepared.pop();
			}
			return new Tween();
		}
		
		private static function recycle(_tween:Tween):void {
			if (prepared.indexOf(_tween) < 0) {
				prepared[prepared.length] = _tween;
			}
		}
		
		private var from:TweenNode;
		private var to:TweenNode;
		private var node:TweenNode;
		private var tweenList:FrameNodeList;
		
		public function Tween() {
			super();
			from = new TweenNode();
			to = new TweenNode();
		}
		
		override public function remove():void {
			super.remove();
			node = null;
			tweenList = null;
			recycle(this);
		}
		
		internal function setNode(_node:TweenNode):void {
			node = _node;
		}
		
		override public function playTo(_to:Object, _toFrames:uint, _listFrames:uint=0, _loop:Boolean = false, _ease:int = 0):void {
			super.playTo(_to, _toFrames, _listFrames, _loop, _ease);
			node.rotation %= 360;
			from.copy(node);
			tweenList = _to as FrameNodeList;
			if (tweenList.length == 1) {
				//普通过渡
				loop = -4;
				to.copy(tweenList.getFrame(0));
			}else {
				if (_loop) {
					//循环过渡
					loop = -2;
					noScaleListFrames = tweenList.frame;
				}else {
					//列表过渡
					loop = -3;
					noScaleListFrames = tweenList.frame - 1;
				}
				listFrames = _listFrames * tweenList.scale;
				if (_loop && tweenList.delay != 0) {
					var _playedFrames:Number = noScaleListFrames * (1 - tweenList.delay);
					var _prevFrameID:int = 0;
					var _toFrameID:int = 0;
					var _listEndFrame:int = 0;
					var _betweenFrame:int = 0;
					do {
						_betweenFrame = tweenList.getFrame(_toFrameID).frame;
						_listEndFrame += _betweenFrame;
						_prevFrameID = _toFrameID;
						if (++_toFrameID >= tweenList.length) {
							_toFrameID = 0;
						}
					}while (_playedFrames >= _listEndFrame);
					
					to.betweenValue(tweenList.getFrame(_prevFrameID), tweenList.getFrame(_toFrameID));
			
					var _currentPrecent = 1 - (_listEndFrame - _playedFrames) / _betweenFrame;
					if (ease == 2) {
						_currentPrecent = 0.5 * (1 - Math.cos(_currentPrecent * Math.PI ));
					}else if (ease != 0) {
						_currentPrecent = ease > 0?Math.sin(_currentPrecent * HALF_PI):(1 - Math.cos(_currentPrecent * HALF_PI));
					}
					to.tweenTo(_currentPrecent);
				}else {
					to.copy(tweenList.getFrame(0));
				}
			}
			node.betweenValue(from, to);
		}
		
		override protected function updateHandler():void {
			if (currentPrecent >= 1) {
				switch(loop) {
					case -3:
						//列表过渡
						loop = -1;
						currentPrecent = (currentPrecent - 1) * totalFrames / listFrames;
						if (currentPrecent >= 1) {
							//
						}else {
							totalFrames = listFrames;
							currentPrecent %= 1;
							listEndFrame = 0;
							break;
						}
					case -1:
					case -4:
						currentPrecent = 1;
						isComplete = true;
						break;
					case -2:
						//循环开始
						loop = 0;
						totalFrames = listFrames;
						if (tweenList.delay != 0) {
							currentFrame = (1 - tweenList.delay) * totalFrames;
							currentPrecent += currentFrame / totalFrames;
						}
						currentPrecent %= 1;
						listEndFrame = 0;
						break;
					default:
						//继续循环
						loop += int(currentPrecent);
						currentPrecent %= 1;
						break;
				}
			}else if (loop < -1) {
				//
				currentPrecent = Math.sin(currentPrecent * HALF_PI);
			}
			
			if (loop >= -1) {
				//多关键帧动画过程
				updateCurrentPrecent();
			}
			node.tweenTo(currentPrecent);
		}
		
		private function updateCurrentPrecent():void {
			var _playedFrames:Number = noScaleListFrames * currentPrecent;
			
			if (_playedFrames <= listEndFrame-betweenFrame || _playedFrames > listEndFrame) {
				listEndFrame = 0;
				toFrameID = 0;
				var _prevFrameID:int;
				do {
					betweenFrame = tweenList.getFrame(toFrameID).frame;
					listEndFrame += betweenFrame;
					_prevFrameID = toFrameID;
					if (++toFrameID >= tweenList.length) {
						toFrameID = 0;
					}
				}while (_playedFrames >= listEndFrame);
				
				from.copy(tweenList.getFrame(_prevFrameID));
				to.copy(tweenList.getFrame(toFrameID));
				node.betweenValue(from, to);
			}
			
			currentPrecent = 1 - (listEndFrame - _playedFrames) / betweenFrame;
			if (ease == 2) {
				currentPrecent = 0.5 * (1 - Math.cos(currentPrecent * Math.PI ));
			}else if (ease != 0) {
				currentPrecent = ease > 0?Math.sin(currentPrecent * HALF_PI):(1 - Math.cos(currentPrecent * HALF_PI));
			}
		}
	}
}