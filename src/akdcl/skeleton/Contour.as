package akdcl.skeleton
{
	import flash.display.MovieClip;
	
	/**
	 * 用于在FlashCS创建骨骼数据的模板，实例使用后无用处
	 * @author Akdcl
	 */
	public class Contour extends MovieClip {
		/**
		 * 配置骨骼从属关系的xml。xml节点名name()当作ConnectionData的索引ID，故不同的模板name不能重复
		 */
		public var xml:XML;
		private var values:Object;
		
		/**
		 * 构造函数
		 */
		public function Contour() {
			reset();
		}
		
		/**
		 * @private
		 */
		public function getName():String {
			return xml.name();
		}
		
		/**
		 * 为关节设置特殊变量
		 * @param _id 显示关节ID
		 * @param _key 值名，scale、delay，scale用来缩放骨骼动画的周期T，delay用来延缓骨骼动画
		 * @example 例如使手臂动画相对于其他身体部分动画，周期缩短为0.5，并滞后0.1（相对于整个动画周期）
		 * <listing version="3.0">setValue("arm", "scale", 0.5);setValue("arm", "delay", 0.1);</listing >
		 */
		public function setValue(_id:String, _key:String, _v:*):void {
			var _value:Object = values[_id];
			if (!_value) {
				_value = values[_id] = { };
			}
			_value[_key] = _v;
		}
		
		/**
		 * @private
		 */
		internal function getValue(_id:String, _key:String):* {
			var _value:Object = values[_id];
			if (_value) {
				return _value[_key];
			}
			return false;
		}
		
		public function reset():void {
			clearValues();
			gotoAndStop(1);
		}
		
		/**
		 * 删除这个模板，当通过ConnectionDataMaker转化数据后，可删除回收此实例
		 */
		public function remove():void {
			values = null;
			stop();
			xml = null;
			if (parent) {
				parent.removeChild(this);
			}
		}
		
		/**
		 * @private
		 */
		internal function clearValues():void {
			values = { };
		}
	}
	
}