package utils
{
	import akdcl.skeleton.utils.ConstValues;
	
	import flash.geom.Rectangle;
	
	
	public final class TextureUtil{
		public static function packTextures(_widthMax:uint, _interval:uint, _verticalSide:Boolean, _textureAtlasXML:XML):void{
			var _textureXMLList:XMLList = _textureAtlasXML.elements(ConstValues.SUB_TEXTURE);
			
			if (_textureXMLList.length() == 0) {
				return;
			}
			var _textureList:Array = [];
			for each(var _textureXML:XML in _textureXMLList){
				_textureList.push(_textureXML);
			}
			//贴图按照大小排序
			_textureList.sort(sortTextureList);
			
			_widthMax = getNearest2N(Math.max(_textureList[0].width + _interval, _widthMax));
			
			//预置一个较高的高度
			var _heightMax:uint = 40960;
			var _remainRectList:Array = [new Rectangle(0, 0, _widthMax, _heightMax)];
			
			var _isFit:Boolean;
			var _width:uint;
			var _height:uint;
			var _pivotX:Number;
			var _pivotY:Number;
			
			var _rect:Rectangle;
			var _rectPrev:Rectangle;
			var _rectNext:Rectangle;
			var _rectID:int;
			
			do {
				//寻找最高的空白区域
				_rect = getHighestRect(_remainRectList);
				_rectID = _remainRectList.indexOf(_rect);
				_isFit = false;
				for(var _iT:String in _textureList) {
					//逐个比较贴图对象是否适合该区域
					_textureXML = _textureList[_iT];
					_width = int(_textureXML.attribute(ConstValues.A_WIDTH)) + _interval;
					_height = int(_textureXML.attribute(ConstValues.A_HEIGHT)) + _interval;
					if (_rect.width >= _width && _rect.height >= _height) {
						//考虑竖直贴图的合理摆放
						if (_verticalSide?(_height > _width * 4?(_rectID > 0?(_rect.height - _height >= _remainRectList[_rectID - 1].height):true):true):true){
							_isFit = true;
							break;
						}
					}
				}
				if(_isFit){
					//如果合适，放置贴图，并将矩形区域再次分区
					_textureXML[ConstValues.AT + ConstValues.A_X] = _rect.x;
					_textureXML[ConstValues.AT + ConstValues.A_Y] = _rect.y;
					_textureList.splice(int(_iT), 1);
					_remainRectList.splice(_rectID + 1, 0, new Rectangle(_rect.x + _width, _rect.y, _rect.width - _width, _rect.height));
					_rect.y += _height;
					_rect.width = _width;
					_rect.height -= _height;
				}else{
					//不合适，则放弃这个矩形区域，把这个区域将与他相邻的矩形区域合并（与较高的一边合并）
					if(_rectID == 0){
						_rectNext = _remainRectList[_rectID + 1];
					}else if(_rectID == _remainRectList.length - 1){
						_rectNext = _remainRectList[_rectID - 1];
					}else{
						_rectPrev = _remainRectList[_rectID - 1];
						_rectNext = _remainRectList[_rectID + 1];
						_rectNext = _rectPrev.height <= _rectNext.height?_rectNext:_rectPrev;
					}
					if(_rect.x < _rectNext.x){
						_rectNext.x = _rect.x;
					}
					_rectNext.width = _rect.width + _rectNext.width;
					_remainRectList.splice(_rectID, 1);
				}
			}while (_textureList.length > 0);
			_heightMax = getNearest2N(_heightMax - getLowestRect(_remainRectList).height);
			_textureAtlasXML[ConstValues.AT + ConstValues.A_WIDTH] = _widthMax;
			_textureAtlasXML[ConstValues.AT + ConstValues.A_HEIGHT] = _heightMax;
		}
		
		private static function sortTextureList(_textureXML1:XML, _textureXML2:XML):int{
			var _v1:uint = int(_textureXML1.attribute(ConstValues.A_WIDTH)) + int(_textureXML1.attribute(ConstValues.A_HEIGHT));
			var _v2:uint = int(_textureXML2.attribute(ConstValues.A_WIDTH)) + int(_textureXML2.attribute(ConstValues.A_HEIGHT));
			if (_v1 == _v2) {
				return int(_textureXML1.attribute(ConstValues.A_WIDTH)) > int(_textureXML2.attribute(ConstValues.A_WIDTH))?-1:1;
			}
			return _v1 > _v2?-1:1;
		}
		
		private static function getNearest2N(_n:uint):uint{
			return _n & _n - 1?1 << _n.toString(2).length:_n;
		}
		
		private static function getHighestRect(_rectList:Array):Rectangle{
			var _height:uint = 0;
			var _rectHighest:Rectangle;
			for each(var _rect:Rectangle in _rectList) {
				if (_rect.height > _height) {
					_height = _rect.height;
					_rectHighest = _rect;
				}
			}
			return _rectHighest;
		}
		
		private static function getLowestRect(_rectList:Array):Rectangle{
			var _height:uint = 40960;
			var _rectLowest:Rectangle;
			for each(var _rect:Rectangle in _rectList) {
				if (_rect.height < _height) {
					_height = _rect.height;
					_rectLowest = _rect;
				}
			}
			return _rectLowest;
		}
	}
}