package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import akdcl.skeleton.Armature;
	import akdcl.skeleton.Contour;
	import akdcl.skeleton.ConnectionXMLMaker;
	import akdcl.skeleton.ConnectionData;
	
	//starling
	import akdcl.textures.TexturePacker;
	import starling.core.Starling;
	
	/**
	 * ...
	 * @author Akdcl
	 */
    [SWF(width="800", height="600", nodeRate="30", backgroundColor="#999999")]
	public class Example03 extends Sprite {
		private var armature:Armature;
		
		public function Example03() {
			init();
		}
		
		private function init():void {
			/*
			由于xml是在Contour的时间轴上赋值
			无法在实例化Contour对象的时候马上获得xml
			所以延时一定时间读取结构
			*/
			setTimeout(delayEncode, 200, new Knight());
		}
		
		private function delayEncode(_contour:Contour):void {
			
			var _xml:XML = ConnectionXMLMaker.encode(_contour);
			trace(_xml);
			/*
			把xml数据再转成内置数据
			xml生成后，也可以保存为xml文件，导入到swf中灵活的为其他骨骼使用
			*/
			ConnectionData.setData(_xml);
			
			//创建关节容器和骨架，容器里已经包含了我们需要的关节
			var _container:Sprite = new KnightJoints() as Sprite;
			_container.x = 300;
			_container.y = 300;
			addChild(_container);
			
			armature = new Armature(_container);
			armature.setup("knight");
			armature.animation.playTo("run", 20, 0.2, true, 2);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheelHandler);
			
			
			//starling
			//生成贴图
			TexturePacker.getInstance().addTexturesFromContainer(_contour, _contour.getName());
			StarlingGame.texture = TexturePacker.getInstance().packTextures(128, 2);
			TexturePacker.getInstance().clear();
			
			var _starling:Starling = new Starling(StarlingGame, stage);
			_starling.antiAliasing = 1;
			_starling.showStats = true;
			_starling.start();
		}
		
		private function onEnterFrameHandler(_e:Event):void {
			armature.update();
		}
		
		private function onMouseWheelHandler(_e:MouseEvent):void {
			if (_e.delta < 0) {
				if (armature.animation.scale > 0.2) {
					armature.animation.scale-= 0.1;
					armature.animation.setAnimationScale(armature.animation.scale);
				}
				
				//starling
				if (StarlingGame.instance.armature.animation.scale > 0.2) {
					StarlingGame.instance.armature.animation.scale-= 0.1;
					StarlingGame.instance.armature.animation.setAnimationScale(armature.animation.scale);
				}
			}else {
				if (armature.animation.scale < 4) {
					armature.animation.scale += 0.1;
					armature.animation.setAnimationScale(armature.animation.scale);
				}
				
				//starling
				if (StarlingGame.instance.armature.animation.scale < 4) {
					StarlingGame.instance.armature.animation.scale += 0.1;
					StarlingGame.instance.armature.animation.setAnimationScale(StarlingGame.instance.armature.animation.scale);
				}
			}
		}
	}
}

//starling
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.textures.Texture;

import akdcl.skeleton.ConnectionData;
import akdcl.skeleton.Armature;

import akdcl.textures.TextureMix;
import akdcl.textures.EasyForStarling;

class StarlingGame extends Sprite {
	public static var texture:TextureMix;
	public static var instance:StarlingGame;
	
	public var armature:Armature;
	public function StarlingGame() {
		instance = this;
		texture.texture = Texture.fromBitmapData(texture.bitmapData);
		
		var _id:String = "knight";
		var _sprite:Sprite;
		_sprite = new Sprite();
		_sprite.x = 500;
		_sprite.y = 300;
		addChild(_sprite);
		
		EasyForStarling.addJointsTo(_sprite, StarlingGame.texture, _id);
		
		armature = new Armature(_sprite, true);
		armature.setup(_id);
		armature.animation.playTo("run", 20, 0.2, true, 2);
		
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
	}
	
	private function onEnterFrameHandler(_e:EnterFrameEvent):void {
		armature.update();
	}
}