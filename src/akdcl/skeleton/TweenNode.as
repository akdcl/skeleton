package akdcl.skeleton
{
	/**
	 * ...
	 * @author Akdcl
	 */
	final public class TweenNode extends FrameNode {
		private var sR:Number;
		private var sX:Number;
		private var sY:Number;
		private var sSX:Number;
		private var sSY:Number;
		private var sA:Number;
		
		private var dR:Number;
		private var dX:Number;
		private var dY:Number;
		private var dSX:Number;
		private var dSY:Number;
		private var dA:Number;
		
		public function TweenNode(_x:Number = 0, _y:Number = 0, _rotation:Number = 0) {
			super(_x, _y, _rotation);
		}
		
		public function betweenValue(_from:FrameNode, _to:FrameNode):void {
			sR = _from.rotation;
			sX = _from.x;
			sY = _from.y;
			sSX = _from.scaleX;
			sSY = _from.scaleY;
			sA = _from.alpha;
			
			if (_to.offR) {
				dR = _to.rotation + _to.offR * 360 - sR;
			}else {
				dR = _to.rotation - sR;
			}
			
			dX = _to.x - sX;
			dY = _to.y - sY;
			dSX = _to.scaleX - sSX;
			dSY = _to.scaleY - sSY;
			dA = _to.alpha - sA;
		}
		
		public function tweenTo(_k:Number):void {
			rotation = sR + dR * _k;
			x = sX + dX * _k;
			y = sY + dY * _k;
			
			if (dSX) {
				scaleX = sSX + dSX * _k;
			}else {
				scaleX = NaN;
			}
			
			if (dSY) {
				scaleY = sSY + dSY * _k;
			}else {
				scaleY = NaN;
			}
			
			if (dA) {
				alpha = sA + dA * _k;
			}else {
				alpha = NaN;
			}
		}
	}
	
}