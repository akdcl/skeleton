package akdcl.skeleton.display{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	
	public class PivotBitmap extends Bitmap{
		public var pivotX:Number;
		public var pivotY:Number;
		
		public function PivotBitmap(bitmapData:BitmapData = null, pixelSnapping:String = "auto", smoothing:Boolean = false){
			super(bitmapData, pixelSnapping, smoothing);
			
			pivotX=0;
			pivotY=0;
		}
		
		public function update(_matrix:Matrix):void{
			_matrix.tx -= pivotX;
			_matrix.ty -= pivotY;
			this.transform.matrix = _matrix;
		}
	}
}