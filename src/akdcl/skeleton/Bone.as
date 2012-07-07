package akdcl.skeleton{
	import flash.geom.Point;
	
	/**
	 * 骨骼，用来控制显示关节的移动
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
		
		public static function recycle(_bone:Bone):void {
			_bone.reset();
			prepared[prepared.length] = _bone;
		}
		
		public var isRadian:Boolean;
		/**
		 * 用于Armature索引
		 */
		public var name:String;
		
		/**
		 * 受骨骼控制的显示关节
		 */
		public var joint:Object;
		
		/**
		 * 骨骼关键点信息
		 */
		public var node:Node;
		
		/**
		 * @private
		 */
		internal var tweenNode:TweenNode;
		
		//private var children:Vector.<Bone>;
		private var parent:Bone;
		private var parentX:Number;
		private var parentY:Number;
		private var parentR:Number;
		private var parentLocalX:Number;
		private var parentLocalY:Number;
		
		private var lockX:Number;
		private var lockY:Number;
		private var lockR:Number;
		
		/**
		 * 构造函数
		 * @param _joint 受骨骼控制的显示关节
		 * @param _name 用于Armature索引
		 */
		public function Bone() {
			parentX = 0;
			parentY = 0;
			parentR = 0;
			parentLocalX = 0;
			parentLocalY = 0;
			lockX = 0;
			lockY = 0;
			lockR = 0;
			
			node = new Node();
			tweenNode = new TweenNode();
			//children = new Vector.<Bone>();
		}
		
		public function reset():void {
			joint = null;
			name = null;
			parentX = 0;
			parentY = 0;
			parentR = 0;
			parentLocalX = 0;
			parentLocalY = 0;
			lockX = 0;
			lockY = 0;
			lockR = 0;
			//从parent中删除
			parent = null;
		}
		
		public function remove():void {
			joint = null;
			name = null;
			//从parent中删除
			parent = null;
		}
		
		internal function getGlobalX():Number {
			return parentLocalX + parentX;
		}
		
		internal function getGlobalY():Number {
			return parentLocalY + parentY;
		}
		
		internal function getGlobalR():Number {
			return node.rotation + tweenNode.rotation + parentR + lockR;
		}
		
		/**
		 * 加入字骨骼
		 * @param _child 要绑定的子骨骼
		 */
		public function addChild(_child:Bone):Bone {
			//children.push(_child);
			_child.parent = this;
			return _child;
		}
		
		/**
		 * 在parent中的偏移坐标
		 * @param _x x偏移
		 * @param _y y偏移
		 * @param _r rotation偏移
		 */
		public function setLockPosition(_x:Number, _y:Number, _r:Number = 0):void {
			lockX = _x;
			lockY = _y;
			lockR = _r;
		}
		
		/**
		 * 更新
		 */
		public function update():void {
			if (parent) {
				//把node和animationNode坐标和映射到parent的坐标系
				parentX = parent.getGlobalX();
				parentY = parent.getGlobalY();
				parentR = parent.getGlobalR();
				
				var _dX:Number = lockX + node.x + tweenNode.x;
				var _dY:Number = lockY + node.y + tweenNode.y;
				var _r:Number = Math.atan2(_dY, _dX) + parentR * ANGLE_TO_RADIAN;
				
				var _len:Number = Math.sqrt(_dX * _dX + _dY * _dY);
				parentLocalX = _len * Math.cos(_r);
				parentLocalY = _len * Math.sin(_r);
			}else {
				parentLocalX = node.x + tweenNode.x;
				parentLocalY = node.y + tweenNode.y;
			}
			
			if (joint) {
				joint.x = parentLocalX + parentX;
				joint.y = parentLocalY + parentY;
				if (isRadian) {
					joint.rotation = (node.rotation + tweenNode.rotation + parentR + lockR) * ANGLE_TO_RADIAN;
				}else {
					joint.rotation = node.rotation + tweenNode.rotation + parentR + lockR;
				}
				
				//scale和alpha只由tweenNode控制
				if (isNaN(tweenNode.scaleX)) {
				}else {
					joint.scaleX = tweenNode.scaleX;
				}
				if (isNaN(tweenNode.scaleY)) {
				}else {
					joint.scaleY = tweenNode.scaleY;
				}
				if (isNaN(tweenNode.alpha)) {
				}else {
					if (tweenNode.alpha) {
						joint.visible = true;
						joint.alpha = tweenNode.alpha;
					}else {
						joint.visible = false;
					}
				}
			}
		}
	}
	
}