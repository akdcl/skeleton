package akdcl.skeleton
{
	/**
	 * ...
	 * @author akdcl
	 */
	final public class FrameNodeList{
		public var delay:Number;
		public var scale:Number;
		public var frame:uint;
		public var length:uint;
		private var list:Vector.<FrameNode>;
		
		public function FrameNodeList(_delay:Number = 0, _scale:Number = 1) {
			delay = _delay;
			scale = _scale;
			frame = 0;
			length = 0;
			
			list = new Vector.<FrameNode>;
		}
		
		public function addFrame(_value:FrameNode):void {
			list.push(_value);
			frame += _value.frame;
			length++;
		}
		
		public function getFrame(_id:int):FrameNode {
			if (_id<0) {
				_id = length + _id;
			}
			return list[_id];
		}
	}
	
}