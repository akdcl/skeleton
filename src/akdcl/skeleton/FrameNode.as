package akdcl.skeleton
{
	
	/**
	 * ...
	 * @author Akdcl
	 */
	public class FrameNode extends Node{
		internal var scaleX:Number;
		internal var scaleY:Number;
		internal var alpha:Number;
		internal var offR:Number;
		internal var totalFrames:uint;
		public function FrameNode(_x:Number = 0, _y:Number = 0, _rotation:Number = 0) {
			super(_x, _y, _rotation);
			
			scaleX = 1;
			scaleY = 1;
			alpha = 1;
			totalFrames = 1;
			
			offR = 0;
		}
		
		override public function copy(_fV:Node):void {
			super.copy(_fV);
			var _nV:FrameNode = _fV as FrameNode;
			if (_nV) {
				scaleX = _nV.scaleX;
				scaleY = _nV.scaleY;
				alpha = _nV.alpha;
				//
				totalFrames = _nV.totalFrames;
				
				offR = _nV.offR;
			}
		}
	}
	
}