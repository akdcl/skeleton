package 
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import akdcl.skeleton.Armature;
	import akdcl.skeleton.Bone;
	
	/**
	 * ...
	 * @author Akdcl
	 */
    [SWF(width="800", height="600", nodeRate="30", backgroundColor="#999999")]
	public class Example01 extends Sprite {
		protected var armature:Armature;
		protected var dragJoint:Sprite;
		protected var recordRotation:Number;
		
		private var clickPoint:Point = new Point();
		
		public function Example01() {
			init();
		}
		
		private function init():void {
			addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseHandler);
			
			//显示对象，用来做骨架所有显示关节的容器
			var _sprite:Sprite = new Sprite();
			_sprite.x = 400;
			_sprite.y = 300;
			_sprite.buttonMode = true;
			addChild(_sprite);
			
			//骨架
			armature = new Armature(_sprite);
			
			//添加显示关节
			armature.addJoint(createJoint(150, -75), "body");
			
			armature.addJoint(createJoint(50), "tail", "body", 0);
			armature.getBone("tail").setLockPosition( -75, 0, -90);
			armature.addJoint(createJoint(), "legL1", "body", 1);
			armature.getBone("legL1").setLockPosition( -75, 0, 60);
			armature.addJoint(createJoint(), "legL2", "body", 2);
			armature.getBone("legL2").setLockPosition( -75, 0, 120);
			armature.addJoint(createJoint(), "legR1", "body", 3);
			armature.getBone("legR1").setLockPosition(75, 0, 60);
			armature.addJoint(createJoint(), "legR2", "body", 4);
			armature.getBone("legR2").setLockPosition(75, 0, 120);
			
			armature.addJoint(createJoint(80), "neck", "body", 5);
			armature.getBone("neck").setLockPosition(75, 0, -60);
			armature.addJoint(createJoint(50), "head", "neck", 6);
			armature.getBone("head").setLockPosition(80, 0, 60);
		}
		
		//建立一个关节
		private function createJoint(_length:uint = 100, _offX:int=0, _color:uint=0x0000ff):Sprite {
			var _sprite:Sprite = new Sprite();
			var _graphics:Graphics = _sprite.graphics;
			_graphics.beginFill(_color, 0.3);
			_graphics.drawCircle(_length + _offX, 0, 16);
			_graphics.lineStyle(20, _color, 0.5);
			_graphics.moveTo(_offX, 0);
			_graphics.lineTo(_length + _offX, 0);
			return _sprite;
		}
		
		//驱动
		private function onEnterFrameHandler(e:Event):void {
			if (dragJoint) {
				//控制选中关节的rotation到一个合理的值
				var _dragBone:Bone = armature.getBone(dragJoint.name);
				_dragBone.node.rotation = 
					recordRotation +
					(
						Math.atan2(armature.getContainer().mouseY - dragJoint.y, armature.getContainer().mouseX - dragJoint.x) - 
						Math.atan2(clickPoint.y - dragJoint.y, clickPoint.x - dragJoint.x)
					) * 180 / Math.PI;
			}
			
			//驱动骨架
			armature.update();
		}
		
		//鼠标事件
		private function onMouseHandler(e:MouseEvent):void {
			if (e.type == MouseEvent.MOUSE_DOWN) {
				pressJoint(e.target as Sprite);
			}else if (dragJoint) {
				releaseJoint();
			}else {
				releaseOutSide();
			}
		}
		
		protected function pressJoint(_joint:Sprite):void {
			dragJoint = _joint;
			clickPoint.x = armature.getContainer().mouseX;
			clickPoint.y = armature.getContainer().mouseY;
			var _bone:Bone;
			//通过显示关节索引到对应骨骼bone，因显示关节的name与骨骼关系一致
			_bone = armature.getBone(dragJoint.name);
			recordRotation = _bone.node.rotation;
		}
		
		protected function releaseJoint():void {
			dragJoint = null;
		}
		
		protected function releaseOutSide():void {
			
		}
	}
}