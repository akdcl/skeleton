package akdcl.skeleton {
	
	/**
	 * ...
	 * @author Akdcl
	 */
	public class ProcessBase {
		public var scale:Number;
		
		protected var isPause:Boolean;
		protected var isComplete:Boolean;
		
		protected var currentFrame:Number;
		protected var totalFrames:uint;
		protected var listFrames:uint;
		protected var noScaleListFrames:uint;
		protected var currentPrecent:Number;
		
		protected var loop:int;
		protected var ease:int;
		
		protected var toFrameID:int;
		protected var betweenFrame:uint;
		protected var listEndFrame:uint;
		
		public function ProcessBase() {
			scale = 1;
			isComplete = true;
			isPause = false;
			currentFrame = 0;
		}
		
		public function remove():void {
			scale = 1;
			isComplete = true;
			isPause = false;
			currentFrame = 0;
		}
		
		public function pause():void {
			isPause = true;
		}
		
		public function resume():void {
			isPause = false;
		}
		
		public function stop():void {
			isComplete = true;
			currentFrame = 0;
		}
		
		public function playTo(_to:Object, _toFrames:uint, _listFrames:uint = 0, _loop:Boolean = false, _ease:int = 0):void {
			isComplete = false;
			isPause = false;
			currentFrame = 0;
			totalFrames = _toFrames;
			ease = _ease;
		}
		
		final public function update():void {
			if (isComplete || isPause) {
				return;
			}
			currentFrame += scale;
			currentPrecent = currentFrame / totalFrames;
			currentFrame %= totalFrames;
			updateHandler();
		}
		
		protected function updateHandler():void {
			
		}
	}
	
}