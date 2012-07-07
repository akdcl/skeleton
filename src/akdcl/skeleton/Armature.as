package akdcl.skeleton {
	
	/**
	 * 骨架
	 * @author Akdcl
	 */
	public class Armature {
		public var name:String;
		public var animation:Animation;
		
		protected var isRadian:Boolean;
		protected var display:Object;
		protected var boneDic:Object;
		protected var boneList:Vector.<Bone>;
		
		/**
		 * 构造函数
		 * @param _display 包含所有骨骼显示对象的显示容器
		 * @param _isRadian 骨骼旋转角度是否采用弧度制，比如starling使用的是弧度制
		 */
		public function Armature(_display:Object, _isRadian:Boolean = false) {
			boneDic = { };
			boneList = new Vector.<Bone>;
			animation = new Animation();
			display = _display;
			isRadian = _isRadian;
		}
		
		/**
		 * 更新步进
		 */
		public function update():void {
			var _len:uint = boneList.length;
			var _bone:Bone;
			for (var _i:uint = 0; _i < _len; _i++ ) {
				_bone = boneList[_i];
				animation.updateTween(_bone.name);
				_bone.update();
			}
			animation.update();
		}
		
		/**
		 * 删除
		 */
		public function remove():void {
			for each(var _bone:Bone in boneList) {
				_bone.remove();
			}
			
			animation.remove();
			animation = null;
			display = null;
			boneDic = null;
			boneList = null;
		}
		
		/**
		 * 绑定骨骼
		 * @param _name 骨骼名
		 * @param _parentName 绑定到父骨骼名
		 * @param _display 骨骼的显示对象
		 * @param _index 绑定到深度，如果是替换原有显示对象，则使用原显示对象的深度
		 */
		public function addBone(_name:String, _parentName:String = null, _display:Object=null, _index:int = -1):Bone {
			var _bone:Bone = boneDic[_name];
			if(!_bone){
				_bone = Bone.create();
				_bone.name = _name;
				_bone.isRadian = isRadian;
				boneList.push(_bone);
				boneDic[_name] = _bone;
				var _boneParent:Bone = boneDic[_parentName];
				if(_boneParent){
					_boneParent.addChild(_bone);
				}
				animation.addTween(_bone);
			}
			if(_display){
				if(_display.name != _name){
					_display.name = _name;
				}
				var _displayOld:Object = _bone.display;
				_bone.display = _display;
				if(_displayOld){
					display.addChildAt(_display, display.getChildIndex(_displayOld) - 1);
				}else if (_index == -1) {
					display.addChild(_display);
				}else if (_index >= 0) {
					display.addChildAt(_display, _index);
				}
			}
			return _bone;
		}
		
		public function removeBone(_name:String):void {
			var _bone = boneDic[_name];
			if(_bone){
				if(_bone.display && display.contains(_bone.display)){
					display.removeChild(_bone.display);
				}
				animation.removeTween(_bone);
				_bone.remove();
			}
		}
		
		public function getBone(_name:String):Bone {
			return boneDic[_name];
		}
		
		/**
		 * 获取骨架显示对象
		 */
		public function getDisplay():Object {
			return display;
		}
	}
}