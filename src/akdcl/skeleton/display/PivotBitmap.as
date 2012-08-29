package akdcl.skeleton.display{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import flash.geom.Matrix;
	
	public class PivotBitmap extends Bitmap{
		public var pivotX:Number;
		public var pivotY:Number;
		
		public var tran_scaleX:Number;
		public var tran_scaleY:Number;
		
		public var tran_skewX:Number;
		public var tran_skewY:Number;
		
		public var tran_x:Number;
		public var tran_y:Number;
		
		private var m:Matrix;
		private var skew_matrix:Matrix;
		
		public function PivotBitmap(bitmapData:BitmapData = null, pixelSnapping:String = "auto", smoothing:Boolean = false){
			super(bitmapData, pixelSnapping, smoothing);
			
			m=new Matrix();
			skew_matrix=new Matrix();
			
			pivotX=0;
			pivotY=0;
			
			tran_scaleX=1;
			tran_scaleY=1;
			
			tran_skewX=0;
			tran_skewY=0;
			
			tran_x=0;
			tran_y=0;
		}
		
		public function update():void{
			m.a=1;
			m.b=0;
			m.c=0;
			m.d=1;
			m.tx=-pivotX;
			m.ty=-pivotY;
			
			m.scale(tran_scaleX,tran_scaleY);
			
			var rad:Number = tran_skewX;
			skew_matrix.c=-Math.sin(rad);
			skew_matrix.d=Math.cos(rad);
			rad = tran_skewY;
			skew_matrix.a=Math.cos(rad);
			skew_matrix.b=Math.sin(rad);
			m.concat(skew_matrix);
			m.translate(tran_x,tran_y);
			
			this.transform.matrix=m;
		}
	}
}