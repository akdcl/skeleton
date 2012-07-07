package akdcl.skeleton{
	import flash.geom.Point;
	
	/**
	 * 骨骼
	 * @author akdcl
	 */
	final public class Bone {
		private static const ANGLE_TO_RADIAN:Number = Math.PI / 180;
		
		private static var prepared:Vector.<Bone> = new Vector.<Bone>;
		public static function create():Bone {
			if (prepared.length > 0) {
				return prepared.pop();
			}
			return new Bone();
		}
		
		private static function recycle(_bone:Bone):void {
			if (Bone.prepared.indexOf(_bone) < 0) {
				return;
			}
			Bone.prepared.push(_bone);
		}
		
		public var isRadian:Boolean;
		public var name:String;
		public var display:Object;
		
		
		public var node:Node;
		
		internal var tweenNode:TweenNode;
		
		private var parent:Bone;
		
		private var transformX:Number;
		private var transformY:Number;
		
		private var lockX:Number;
		private var lockY:Number;
		private var lockR:Number;
		
		private var parentX:Number;
		private var parentY:Number;
		private var parentR:Number;
		
		public function Bone() {
			transformX = 0;
			transformY = 0;
			parentX = 0;
			parentY = 0;
			parentR = 0;
			lockX = 0;
			lockY = 0;
			lockR = 0;
			
			node = new Node();
			tweenNode = new TweenNode();
		}
		
		public function remove():void {
			display = null;
			name = null;
			parent = null;
			transformX = 0;
			transformY = 0;
			parentX = 0;
			parentY = 0;
			parentR = 0;
			lockX = 0;
			lockY = 0;
			lockR = 0;
			Bone.recycle(this);
		}
		
		public function addChild(_child:Bone):void{
			_child.parent = this;
		}
		
		public function setLockPosition(_x:Number, _y:Number, _r:Number = 0):void {
			lockX = _x;
			lockY = _y;
			lockR = _r;
		}
		
		public function update():void {
			if (parent) {
				parentX = parent.getGlobalX();
				parentY = parent.getGlobalY();
				parentR = parent.getGlobalR();
				
				var _dX:Number = lockX + node.x + tweenNode.x;
				var _dY:Number = lockY + node.y + tweenNode.y;
				var _r:Number = Math.atan2(_dY, _dX) + parentR * ANGLE_TO_RADIAN;
				
				var _len:Number = Math.sqrt(_dX * _dX + _dY * _dY);
				transformX = _len * Math.cos(_r);
				transformY = _len * Math.sin(_r);
			}else {
				transformX = node.x + tweenNode.x;
				transformY = node.y + tweenNode.y;
			}
			
			updateDisplay();
		}
		
		private function updateDisplay():void {
			if (display) {
				display.x = transformX + parentX;
				display.y = transformY + parentY;
				if (isRadian) {
					display.rotation = (node.rotation + tweenNode.rotation + parentR + lockR) * ANGLE_TO_RADIAN;
				}else {
					display.rotation = node.rotation + tweenNode.rotation + parentR + lockR;
				}
				
				if (isNaN(tweenNode.scaleX)) {
				}else {
					display.scaleX = tweenNode.scaleX;
				}
				if (isNaN(tweenNode.scaleY)) {
				}else {
					display.scaleY = tweenNode.scaleY;
				}
				if (isNaN(tweenNode.alpha)) {
				}else {
					if (tweenNode.alpha) {
						display.visible = true;
						display.alpha = tweenNode.alpha;
					}else {
						display.visible = false;
					}
				}
			}
		}
		
		internal function getGlobalX():Number {
			return transformX + parentX;
		}
		
		internal function getGlobalY():Number {
			return transformY + parentY;
		}
		
		internal function getGlobalR():Number {
			return node.rotation + tweenNode.rotation + parentR + lockR;
		}
	}
	
}