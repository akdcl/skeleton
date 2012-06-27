package akdcl.skeleton
{
	/**
	 * ...
	 * @author akdcl
	 */
	final public class FrameNodeList{
		public var delay:Number;
		public var scale:Number;
		public var totalFrames:uint;
		public var length:uint;
		private var list:Vector.<FrameNode>;
		
		public function FrameNodeList(_delay:Number = 0, _scale:Number = 1) {
			delay = _delay;
			scale = _scale;
			totalFrames = 0;
			length = 0;
			
			list = new Vector.<FrameNode>;
		}
		
		public function addValue(_value:FrameNode):void {
			list.push(_value);
			totalFrames += _value.totalFrames;
			length++;
		}
		
		public function getValue(_id:int):FrameNode {
			if (_id<0) {
				_id = length - 1;
			}
			return list[_id];
		}
	}
	
}