package 
{
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
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
	public class Example08 extends Sprite {
		public function Example08() {
			init();
		}
		
		private function init():void {
			
			setTimeout(delayEncode, 200, new Zombie());
		}
		
		private function delayEncode(_contour:Contour):void {
			TexturePacker.getInstance().addTexturesFromContainer(_contour, _contour.getName());
			StarlingGame.texture = TexturePacker.getInstance().packTextures(512, 2);
			TexturePacker.getInstance().clear();
			//看看贴图的样子
			addChild(new Bitmap(StarlingGame.texture.bitmapData)).y = 40;
			
			ConnectionData.setData(ConnectionXMLMaker.encode(_contour));
			_contour.remove();
			
			//starling
			var _starling:Starling = new Starling(StarlingGame, stage);
			_starling.antiAliasing = 1;
			_starling.showStats = true;
			_starling.start();
			
			
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyEventHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyEventHandler);
		}

		private var left:Boolean;
		private var right:Boolean;
		
		private function onKeyEventHandler(e:KeyboardEvent):void {
			switch (e.keyCode) {
				case 37 :
				case 65 :
					left = e.type == KeyboardEvent.KEY_DOWN;
					updateMove(-1);
					break;
				case 39 :
				case 68 :
					right = e.type == KeyboardEvent.KEY_DOWN;
					updateMove(1);
					break;
				case 38 :
				case 87 :
					break;
				case 83 :
				case 40 :
					break;
			}
		}
		
		private function updateMove(_dir:int):void {
			if (left && right) {
				StarlingGame.instance.move(_dir);
			}else if (left){
				StarlingGame.instance.move(-1);
			}else if (right){
				StarlingGame.instance.move(1);
			}else {
				StarlingGame.instance.move(0);
			}
		}
	}
}

import flash.geom.Point;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.textures.Texture;

import akdcl.skeleton.ConnectionData;
import akdcl.skeleton.Armature;
import akdcl.skeleton.Bone;
import akdcl.skeleton.Animation;

import akdcl.textures.TextureMix;
import akdcl.textures.EasyForStarling;

class StarlingGame extends Sprite {
	public static var texture:TextureMix;
	public static var instance:StarlingGame;
	
	public function StarlingGame() {
		instance = this;
		texture.texture = Texture.fromBitmapData(texture.bitmapData);
		
		
		
		var _id:String = "zombie";
		
		armatureClip = new Sprite();
		armatureClip.x = 400;
		armatureClip.y = 400;
		addChild(armatureClip);
		
		EasyForStarling.addJointsTo(armatureClip, StarlingGame.texture, _id);
		armature = new Armature(armatureClip, true);
		armature.setup(_id);
		move(0);
		
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
	}
	
	private var armature:Armature;
	private var armatureClip:Sprite;
	private var mouseX:Number = 0;
	private var mouseY:Number = 0;
	private var moveDir:int=-1;
	private var face:int;
	
	private var speedX:Number = 0;
	
	public function move(_dir:int):void {
		if (moveDir == _dir) {
			return;
		}
		
		if (_dir == 0) {
			speedX = 0;
			armature.animation.playTo("stand", 80, 0.1, true);
		}else if (moveDir == 0) {
			face = _dir;
			armatureClip.scaleX = -face;
			speedX = 0.8 * face;
			armature.animation.playTo("run", 120, 0.1, true);
		}
		moveDir = _dir;
		
	}
	
	private function updateSpeed():void {
		if (speedX != 0) {
			armatureClip.x += speedX;
			if (armatureClip.x < 0) {
				armatureClip.x = 0;
			}else if (armatureClip.x > 800) {
				armatureClip.x = 800;
			}
		}
	}
	
	private function onEnterFrameHandler(_e:EnterFrameEvent):void {
		updateSpeed();
		armature.update();
	}
}