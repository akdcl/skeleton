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
		
		public static function recycle(_tween:Tween):void {
			_tween.reset();
			prepared.push(_tween);
		}
		
		/**
		 * Bone.TweenNode的引用
		 * @private
		 */
		private var from:TweenNode;
		private var to:TweenNode;
		private var node:TweenNode;
		private var list:FrameNodeList;
		
		/**
		 * 构造函数
		 */
		public function Tween() {
			super();
			from = new TweenNode();
			to = new TweenNode();
		}
		
		override public function reset():void {
			super.reset();
			node = null;
			list = null;
		}
		
		override public function remove():void {
			super.remove();
			node = null;
			list = null;
			from = null;
			to = null;
		}
		
		internal function setNode(_node:TweenNode):void {
			node = _node;
		}
		
		/**
		 * 控制动画播放
		 * @param _to 关键点Frame或FrameList
		 * @param _listFrame FrameList列表动画所用的帧数
		 * @param _toScale 过渡到该动画使用的帧数，当要播放的动画是列表动画时，此值表示当前动作过渡到列表动画花费的帧数的百分比(_listFrame*_toScale)
		 * @param _loop 是否循环播放动画
		 * @param _ease 缓动方式，0：线性，1：淡出，-1：淡入，2：淡入淡出
		 */
		override public function playTo(_to:Object, _listFrame:uint, _toScale:Number = 1, _loop:Boolean = false, _ease:int = 0):void {
			super.playTo(_to, _listFrame, _toScale, _loop, _ease);
			node.rotation %= 360;
			from.copy(node);
			if (_to is FrameNode) {
				//普通过渡
				loop = -4;
				list = null;
				to.copy(_to as FrameNode);
			}else {
				list = _to as FrameNodeList;
				
				if (_loop) {
					//循环过渡
					loop = -2;
					noScaleListFrames = list.totalFrames;
				}else {
					//列表过渡
					loop = -3;
					noScaleListFrames = list.totalFrames - 1;
				}
				listFrames = _listFrame * list.scale;
				if (_loop && list.delay != 0) {
					var _playedFrames:Number = noScaleListFrames * (1 - list.delay);
					var _prevFrameID:int = 0;
					var _toFrameID:int = 0;
					var _listEndFrame:int = 0;
					var _betweenFrame:int = 0;
					do {
						_betweenFrame = list.getValue(_toFrameID).totalFrames;
						_listEndFrame += _betweenFrame;
						_prevFrameID = _toFrameID;
						if (++_toFrameID >= list.length) {
							_toFrameID = 0;
						}
					}while (_playedFrames >= _listEndFrame);
					
					to.betweenValue(list.getValue(_prevFrameID), list.getValue(_toFrameID));
			
					var _currentPrecent = 1 - (_listEndFrame - _playedFrames) / _betweenFrame;
					if (ease == 2) {
						_currentPrecent = 0.5 * (1 - Math.cos(_currentPrecent * Math.PI ));
					}else if (ease != 0) {
						_currentPrecent = ease > 0?Math.sin(_currentPrecent * HALF_PI):(1 - Math.cos(_currentPrecent * HALF_PI));
					}
					to.tweenTo(_currentPrecent);
				}else {
					to.copy(list.getValue(0));
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
						if (list.delay != 0) {
							currentFrame = (1 - list.delay) * totalFrames;
							currentPrecent += currentFrame / totalFrames;
							currentPrecent %= 1;
						}
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
					betweenFrame = list.getValue(toFrameID).totalFrames;
					listEndFrame += betweenFrame;
					_prevFrameID = toFrameID;
					if (++toFrameID >= list.length) {
						toFrameID = 0;
					}
				}while (_playedFrames >= listEndFrame);
				
				from.copy(list.getValue(_prevFrameID));
				to.copy(list.getValue(toFrameID));
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