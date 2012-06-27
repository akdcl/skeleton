package 
{
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import akdcl.skeleton.Contour;
	import akdcl.skeleton.ConnectionXMLMaker;
	import akdcl.skeleton.ConnectionData;
	
	import akdcl.textures.TexturePacker;
	
	import starling.core.Starling;
	
	/**
	 * ...
	 * @author Akdcl
	 */
    [SWF(width="800", height="600", nodeRate="30", backgroundColor="#999999")]
	public class Example05 extends Sprite {
		public function Example05() {
			init();
		}
		
		private function init():void {
			setTimeout(delayEncode, 200, new Knight());
		}
		
		private function delayEncode(_contour:Contour):void {
			ConnectionData.setData(ConnectionXMLMaker.encode(_contour));
			
			//生成贴图数据
			TexturePacker.getInstance().addTexturesFromContainer(_contour, _contour.getName());
			StarlingGame.texture = TexturePacker.getInstance().packTextures(128, 2);
			TexturePacker.getInstance().clear();
			//看看贴图的样子
			addChild(new Bitmap(StarlingGame.texture.bitmapData)).y = 20;
			
			//starling
			var _starling:Starling = new Starling(StarlingGame, stage);
			_starling.antiAliasing = 1;
			_starling.showStats = true;
			_starling.start();
		}
	}
}


import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.textures.Texture;

import akdcl.skeleton.ConnectionData;
import akdcl.skeleton.Armature;
import akdcl.skeleton.Animation;

import akdcl.textures.TextureMix;
import akdcl.textures.EasyForStarling;

class StarlingGame extends Sprite {
	public static var texture:TextureMix;
	public static var instance:StarlingGame;
	
	private var armatures:Vector.<KnightArmature>;
	public function StarlingGame() {
		instance = this;
		texture.texture = Texture.fromBitmapData(texture.bitmapData);
		
		armatures = new Vector.<KnightArmature>;
		var _knightArmature:KnightArmature;
		for (var _i:uint = 0; _i < 20; _i++ ) {
			_knightArmature = new KnightArmature();
			addChild(_knightArmature.getContainer() as Sprite);
			armatures.push(_knightArmature);
		}
		
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
	}
	
	private function onEnterFrameHandler(_e:EnterFrameEvent):void {
		for each(var _armature:KnightArmature in armatures) {
			_armature.update();
		}
		armatures.sort(sortDepth);
		
		for each(var _armature:KnightArmature in armatures) {
			addChild(_armature.getContainer() as Sprite);
		}
	}
	
	private function sortDepth(_a1:KnightArmature, _a2:KnightArmature):int {
		return _a1.depth > _a2.depth?1: -1;
	}
	
	
}

class KnightArmature extends Armature {
	private var speedX:Number;
	private var speedY:Number;
	private var face:int;
	
	public function get depth():Number {
		return container.y;
	}
	
	public function KnightArmature() {
		super(null,true);
		face = Math.random() > 0.5?1: -1;
		
		var _id:String = "knight";
		var _sprite:Sprite;
		_sprite = new Sprite();
		_sprite.x = -100 * Math.random() - 100;
		_sprite.y = 200 + Math.random() * 300;
		container = _sprite;
		container.scaleX = face;
		
		EasyForStarling.addJointsTo(_sprite, StarlingGame.texture, _id);
			
		setup(_id);
		animation.onAnimation = animationHandler;
		randomRun()
	}
	
	private function randomRun():void {
		var _scale:Number = Math.random() * 0.3 + 0.7;
		speedX = _scale * 5;
		speedY = Math.random() * 2;
		animation.setAnimationScale(_scale);
		animation.playTo("run", 20, 0.2, true, 2);
	}
	
	override public function update():void {
		super.update();
		
		container.x += speedX * face;
		container.y += speedY;
		if (face > 0) {
			if (container.x > StarlingGame.instance.stage.stageWidth + 100) {
				container.x = -100;
			}
		}else {
			if (container.x < 0 - 100) {
				container.x = StarlingGame.instance.stage.stageWidth + 100;
			}
		}
		
		if (container.y < 200) {
			container.y = 200;
			speedY = Math.random() * 2;
		}else if (container.y > StarlingGame.instance.stage.stageHeight) {
			speedY = -Math.random() * 2;
		}
	}
	
	private function animationHandler(_aniType:String, _aniID:String, _frameID:String = null):void {
		switch(_aniType) {
			case Animation.LOOP_COMPLETE:
				switch(_aniID) {
					case "run":
						if (Math.random() > 0.90) {
							speedX = 0;
							speedY = 0;
							if (Math.random()>0.5) {
								animation.playTo("stand", 20, 0.2, true, 2);
							}else {
								animation.playTo("attack", 55, 0.2, false, 1);
							}
						}
						break;
					case "stand":
						if (Math.random() > 0.60) {
							randomRun();
						}
						break;
				}
				break;
			case Animation.COMPLETE:
				randomRun();
				break;
		}
	}
}