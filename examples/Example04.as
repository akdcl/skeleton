package 
{
	import effects.Shadow;
	import effects.ShadowContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import akdcl.skeleton.Armature;
	import akdcl.skeleton.Contour;
	import akdcl.skeleton.ConnectionXMLMaker;
	import akdcl.skeleton.ConnectionData;
	
	/**
	 * ...
	 * @author Akdcl
	 */
    [SWF(width="800", height="600", nodeRate="30", backgroundColor="#999999")]
	public class Example04 extends Sprite {
		private var armatures:Vector.<Armature>;
		
		public function Example04() {
			init();
		}
		
		private function init():void {
			setTimeout(delayEncode, 200, new Knight());
		}
		
		private function delayEncode(_contour:Contour):void {
			ConnectionData.setData(ConnectionXMLMaker.encode(_contour));
			
			armatures = new Vector.<Armature>;
			armatures.push(addKinght("stand1", 100, 100));
			armatures.push(addKinght("stand2", 100, 300));
			armatures.push(addKinght("run1", 300, 100));
			armatures.push(addKinght("run2", 300, 300));
			armatures.push(addKinght("attack1", 500, 100));
			armatures.push(addKinght("attack2", 500, 300));
			
			addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
		}
		
		private function addKinght(_action:String, _x:Number, _y:Number):Armature {
			var _container:Sprite = new KnightJoints() as Sprite;
			_container.x = _x;
			_container.y = _y;
			addChild(_container);
			
			var _armature:Armature = new Armature(_container);
			_armature.setup("knight");
			
			switch(_action) {
				case "stand1":
				case "stand2":
				case "run1":
				case "run2":
					_armature.animation.playTo(_action, 20, 0.3, true, 2);
					break;
				case "attack1":
					_armature.animation.playTo("attack", 55, 0.2, true, 1);
					//动画回调
					_armature.animation.onAnimation = animationHandler;
					break;
				case "attack2":
					_armature.animation.playTo("attack", 55, 0.2, true, 1);
					Shadow.drawContainer = this;
					//为weapon添加例子
					_armature.addJoint(new ShadowContainer(), "particle", 0, "weapon", 80, 0);
					break;
			}
			return _armature
		}
		
		private function animationHandler(_aniType:String, _aniID:String, _frameID:String = null):void {
			trace(_aniType, _aniID, _frameID);
		}
		
		private function onEnterFrameHandler(e:Event):void {
			for each(var _armature:Armature in armatures) {
				_armature.update();
			}
		}
	}
}