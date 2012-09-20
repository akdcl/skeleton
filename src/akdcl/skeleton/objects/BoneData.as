package akdcl.skeleton.objects{
	
	/**
	 * ...
	 * @author Akdcl
	 */
	final public class BoneData extends Node {
		public var name:String;
		public var parent:String;
		
		public function get displayLength():uint{
			return displayList.length;
		}
		
		private var displayList:Array;
		
		public function BoneData(_x:Number = 0, _y:Number = 0, _skewX:Number = 0, _skewY:Number = 0) {
			super(_x, _y, _skewX, _skewY);
			displayList = [];
		}
		
		override public function dispose():void{
			super.dispose();
			name = null;
			parent = null;
			displayList = null;
		}
		
		override public function copy(_node:Node):void{
			var _boneData:BoneData = _node as BoneData;
			if(_boneData){
				super.copy(_node);
				name = _boneData.name;
				parent = _boneData.parent;
				var _length:uint = _boneData.displayLength;
				var _displayData:DisplayData;
				for(var _i:uint = 0;_i < _length;_i ++){
					_displayData = _boneData.getDisplayData(_i);
					if(_displayData){
						setDisplayAt(_displayData.name, _displayData.isArmature, _i);
					}
				}
			}
		}
		
		public function getDisplayData(_index:int):DisplayData{
			return displayList[_index];
		}
		
		public function setDisplayAt(_name:String, _isArmature:Boolean = false, _index:int = 0):void{
			var _displayData:DisplayData = displayList[_index];
			if(_displayData){
				_displayData.name = _name;
				_displayData.isArmature = _isArmature;
			}else{
				_displayData = new DisplayData(_name, _isArmature);
				displayList[_index] = _displayData;
			}
		}
	}
}