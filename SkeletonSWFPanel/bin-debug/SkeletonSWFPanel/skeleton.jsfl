var dom = fl.getDocumentDOM();
var library = dom?dom.library:null;
var time = getTimer();

function trace(){
	var _str = "";
	for(var _i = 0;_i < arguments.length;_i ++){
		if(_i!=0){
			_str += ", ";
		}
		_str += arguments[_i];
	}
	fl.trace(_str);
}

function getTimer(){
	return new Date().getTime();
}

function checkTime(_id){
	if(_id){
		trace(_id+"，耗时："+(getTimer()-time)+" 毫秒。");
	}
	time = getTimer();
	return time;
}


function errorDOM(){
	if(!dom){
		alert("没有打开的 FLA 档案！");
		return true;
	}
	return false;
}

var SKELETON = "skeleton";

var ARMATURES = "armatures";
var ARMATURE = "armature";
var BONE = "b";
var DISPLAY = "d";

var ANIMATIONS = "animations";
var ANIMATION = "animation";
var MOVEMENT = "mov";
var EVENT = "event";
var FRAME = "f";

var TEXTURE_ATLAS = "TextureAtlas";
var SUB_TEXTURE = "SubTexture";

var AT = "@";
var A_BONE_TYPE = "bT";
var A_NAME = "name";
var A_START = "st";
var A_DURATION = "dr";
var A_DURATION_TO = "to";
var A_DURATION_TWEEN = "drTW";
var A_LOOP = "lp";
var A_MOVEMENT_SCALE = "sc";
var A_MOVEMENT_DELAY = "dl";

var A_PARENT = "parent";
var A_X = "x";
var A_Y = "y";
var A_SCALE_X = "cX";
var A_SCALE_Y = "cY";
var A_SKEW_X = "kX";
var A_SKEW_Y = "kY";
var A_Z = "z";
var A_DISPLAY_INDEX = "dI";
var A_EVENT = "evt";
var A_SOUND = "sd";
var A_SOUND_EFFECT = "sdE";
var A_TWEEN_EASING ="twE";
var A_TWEEN_ROTATE ="twR";
var A_IS_ARMATURE = "isArmature";
var A_MOVEMENT = "mov";

var A_WIDTH = "width";
var A_HEIGHT = "height";
var A_PIVOT_X = "pX";
var A_PIVOT_Y = "pY";

var V_SOUND_LEFT = "l";
var V_SOUND_RIGHT = "r";
var V_SOUND_LEFT_TO_RIGHT = "lr";
var V_SOUND_RIGHT_TO_LEFT = "rl";
var V_SOUND_FADE_IN = "in";
var V_SOUND_FADE_OUT = "out";

var MOVIE_CLIP = "movie clip";
var GRAPHIC = "graphic";
var STRING = "string";
var LABEL_TYPE_NAME = "name";
var EVENT_PREFIX = "@";
var MOVEMENT_PREFIX = "#";
var NO_EASING = "^";
var DELIM_CHAR = "|";
var UNDERLINE_CHAR = "_";

var SKELETON_PANEL = "SkeletonSWFPanel";
var ARMATURE_DATA = "armatureData";
var ANIMATION_DATA = "animationData";

var TEXTURE_SWF_ITEM = "textureSWFItem";
var TEXTURE_SWF = "armatureTextureSWF.swf";

var ALERT = "[ALERT]";
var INFO = "[INFO]";

var pointTemp = {x:0, y:0, skewX:0, skewY:0};

var xml = null;
var armaturesXML = null;
var animationsXML = null;
var textureAtlasXML = null;

function getArmatureList(_items){
	fl.outputPanel.clear();
	dom.exitEditMode();
	var _arr = [];
	for each(var _item in _items){
		if((_item.symbolType == MOVIE_CLIP || _item.symbolType == GRAPHIC) && _item.name != TEXTURE_SWF_ITEM && isArmatureItem(_item)){
			_arr.push(_item.name);
		}
	}
	return _arr;
}

function generateArmature(_armatureName){
	if(!xml){
		var _domName = dom.name.split(".")[0];
		xml = <{SKELETON} {A_NAME} = {_domName}/>;
		armaturesXML = <{ARMATURES}/>;
		animationsXML = <{ANIMATIONS}/>;
		textureAtlasXML = <{TEXTURE_ATLAS} {A_NAME} = {_domName}/>;
		xml.appendChild(armaturesXML);
		xml.appendChild(animationsXML);
		xml.appendChild(textureAtlasXML);
	}
	
	var _item = library.items[library.findItemIndex(_armatureName)];
	_armatureName = formatName(_item);
	if(armaturesXML[ARMATURE].(@name == _armatureName)[0]){
		return;
	}
	var _layersFiltered = isArmatureItem(_item);
	if(!_layersFiltered){
		return;
	}
	
	var _armatureXML = <{ARMATURE} {A_NAME} = {_armatureName}/>;
	var _animationXML = <{ANIMATION} {A_NAME} = {_armatureName}/>;
	var _connection = getArmatureConnection(_item);
	var _armatureConnectionXML = _connection?XML(_connection):_armatureXML.copy();
	
	armaturesXML.appendChild(_armatureXML);
	var _mainLayer = _layersFiltered.shift();
	//只有1个 movement 且movement.duration只有1，则定义没有动画的骨骼
	if(_mainLayer.frameCount > 1){
		animationsXML.appendChild(_animationXML);
	}
	
	var _keyFrames = filterKeyFrames(_mainLayer.frames);
	var _length = _keyFrames.length;
	var _nameDic = {};
	var _frame;
	var _mainFrame;
	var _isEndFrame;
	
	for(var _iF = 0;_iF < _length;_iF ++){
		_frame = _keyFrames[_iF];
		if(isMainFrame(_frame)){
			//新帧
			_mainFrame = {};
			_mainFrame.frame = _frame;
			_mainFrame.duration = _frame.duration;
			formatSameName(_frame, _nameDic);
		}else if(_mainFrame){
			//继续
			_mainFrame.duration += _frame.duration;
			if(_iF + 1 != _length){
				_mainFrame[_frame.startFrame] = _frame;
			}
		}else{
			//忽略
			continue;
		}
		_isEndFrame = _iF + 1 == _length || isMainFrame(_keyFrames[_iF + 1]);
		if(_mainFrame && _isEndFrame){
			//结束前帧
			//checkTime(_armatureName);
			generateMovement(_item, _mainFrame, _layersFiltered, _armatureXML, _animationXML, _armatureConnectionXML);
		}
	}
	
	setArmatureConnection(_item, _armatureXML.toXMLString());
	return xml;
}

function generateMovement(_item, _mainFrame, _layers, _armatureXML, _animationXML, _armatureConnectionXML){
	var _start = _mainFrame.frame.startFrame;
	var _duration = _mainFrame.duration;
	var _movementXML = createMovementXML(_item, _mainFrame.frame.name, _duration);
			
	var _symbol;
	var _boneName;
	var _boneType;
	var _movementBoneXML;
	var _frameXML;
	var _str;
	
	var _frameStart;
	var _frameDuration;
	
	var _boneNameDic = {};
	var _boneZDic = {};
	var _zList = [];
	var _boneList;
	var _z;
	var _i;
	
	for each(var _layer in _layers){
		for each(var _frame in filterKeyFrames(_layer.frames.slice(_start, _start + _duration))){
			_symbol = getBoneSymbol(_frame.elements);
			if(!_symbol){
				continue;
			}
			
			if(_frame.startFrame < _start){
				_frameStart = 0;
				_frameDuration = _frame.duration - _start + _frame.startFrame;
			}else if(_frame.startFrame + _frame.duration > _start + _duration){
				_frameStart = _frame.startFrame - _start;
				_frameDuration = _duration - _frame.startFrame + _start;
			}else{
				_frameStart = _frame.startFrame - _start;
				_frameDuration= _frame.duration;
			}
			
			/*switch(_frame.tweenType){
				case "motion":
					break;
				case "motion object":
					break;
			}*/
			
			if(_symbol.name){
				//按照实例名索引的骨骼
				_boneType = 1;
				_boneName = formatName(_symbol);
			}else{
				//按照图层名索引的骨骼
				_boneType = 0;
				_boneName = formatName(_layer);
			}
			
			for(_i = _frameStart ;_i < _frameStart + _frameDuration;_i ++){
				_z = _zList[_i];
				if(isNaN(_z)){
					_zList[_i] = _z = 0;
				}else{
					_zList[_i] = ++_z;
				}
			}
			if(!_boneZDic[_boneName]){
				_boneZDic[_boneName] = [];
			}
			_boneList = _boneZDic[_boneName];
			for(_i = _frameStart;_i < _frameStart + _frameDuration;_i ++){
				if(isNaN(_boneList[_i])){
				}else if(_boneType == 1){
					_boneName = formatSameName(_symbol, _boneNameDic);
					if(!_boneZDic[_boneName]){
						_boneList = _boneZDic[_boneName] = [];
					}
				}else if(_boneType == 0){
					_boneName = formatSameName(_layer, _boneNameDic);
					if(!_boneZDic[_boneName]){
						_boneList = _boneZDic[_boneName] = [];
					}
				}
				_boneList[_i] = _z;
			}
			
			_movementBoneXML = createMovementBone(_movementXML, _boneName);
			_frameXML = generateFrame(_layers, Math.max(_frame.startFrame, _start), _z, _symbol, _boneName, _boneType, _armatureXML, _armatureConnectionXML);
			
			//补间
			if(isNoEasingFrame(_frame)){
				//带有"^"标签的关键帧，将不会被补间
				_frameXML[AT + A_TWEEN_EASING] = NaN;
			}else if(_frame.tweenType == "motion"){
				_frameXML[AT + A_TWEEN_EASING] = formatNumber(_frame.tweenEasing * 0.01);
				var _tweenRotate = NaN;
				switch(_frame.motionTweenRotate){
					case "clockwise":
						_tweenRotate = _frame.motionTweenRotateTimes;
						break;
					case "counter-clockwise":
						_tweenRotate = - _frame.motionTweenRotateTimes;
						break;
				}
				if(!isNaN(_tweenRotate)){
					_frameXML[AT + A_TWEEN_ROTATE] = _tweenRotate;
				}
			}
			
			_str = isSpecialFrame(_frame, MOVEMENT_PREFIX, true);
			if(_str){
				_frameXML[AT + A_MOVEMENT] = _str;
			}
			_frameXML[AT + A_START] = _frameStart;
			_frameXML[AT + A_DURATION] = _frameDuration;
			_movementBoneXML.appendChild(_frameXML);
			
			//event
			_str = isSpecialFrame(_frame, EVENT_PREFIX, true);
			if(_str){
				_frameXML[AT + A_EVENT] = _str;
			}

			//sound
			if(_frame.soundName){
				_frameXML[AT + A_SOUND] = _frame.soundLibraryItem.linkageClassName || _frame.soundName;
				var _soundEffect;
				switch(_frame.soundEffect){
					case "left channel":
						_soundEffect = V_SOUND_LEFT;
						break;
					case "right channel":
						_soundEffect = V_SOUND_RIGHT;
						break;
					case "fade left to right":
						_soundEffect = V_SOUND_LEFT_TO_RIGHT;
						break;
					case "fade right to left":
						_soundEffect = V_SOUND_RIGHT_TO_LEFT;
						break;
					case "fade in":
						_soundEffect = V_SOUND_FADE_IN;
						break;
					case "fade out":
						_soundEffect = V_SOUND_FADE_OUT;
						break;
				}
				if(_soundEffect){
					_frameXML[AT + A_SOUND_EFFECT] = _soundEffect;
				}
			}
		}
	}
	
	var _prevFrameXML;
	var _prevStart;
	var _prevDuration;
	var _frameIndex;
	
	for each(var _movementBoneXML in _movementXML[BONE]){
		_boneName = _movementBoneXML[AT + A_NAME];
		for each(_frameXML in _movementBoneXML[FRAME]){
			_frameStart = Number(_frameXML[AT + A_START]);
			_frameIndex = _frameXML.childIndex();
			if(_frameIndex == 0){
				if(_frameStart > 0){
					_movementBoneXML.prependChild(<{FRAME} {A_DURATION} = {_frameStart} {A_DISPLAY_INDEX} = "-1"/>);
				}
			}else {
				_prevStart = Number(_prevFrameXML[AT + A_START]);
				_prevDuration = Number(_prevFrameXML[AT + A_DURATION]);
				if(_frameStart > _prevStart + _prevDuration){
					_movementBoneXML.insertChildBefore(_frameXML, <{FRAME} {A_DURATION} = {_frameStart - _prevStart - _prevDuration} {A_DISPLAY_INDEX} = "-1"/>);
				}
			}
			if(_frameIndex == _movementBoneXML[FRAME].length() - 1){
				_frameStart = Number(_frameXML[AT + A_START]);
				_prevDuration = Number(_frameXML[AT + A_DURATION]);
				if(_frameStart + _prevDuration < _duration){
					_movementBoneXML.appendChild(<{FRAME} {A_DURATION} = {_duration - _frameStart - _prevDuration} {A_DISPLAY_INDEX} = "-1"/>);
				}
			}else{
				//tweenRotate属性应留给补间的到点而不是起点
				if(_frameXML[AT + A_TWEEN_ROTATE][0]){
					var _nextFrameXML = _movementBoneXML[FRAME][_frameIndex + 1];
					/*var _boneXML = _armatureXML[BONE].(@name == _boneName)[0];
					if(_boneXML[AT + A_PARENT][0]){
						
					}
					var _skYP = Number(_frameXML[AT + A_SKEW_Y]);
					var _skYN = Number(_nextFrameXML[AT + A_SKEW_Y]);*/
					_tweenRotate = Number(_frameXML[AT + A_TWEEN_ROTATE]);
					/*if(){
						
					}*/
					_nextFrameXML[AT + A_TWEEN_ROTATE] = _tweenRotate;
					delete _frameXML[AT + A_TWEEN_ROTATE];
				}
			}
			_prevFrameXML = _frameXML;
		}
	}
	delete _movementXML[BONE][FRAME][AT + A_START];
	_animationXML.appendChild(_movementXML);
}

function generateFrame(_layers, _start, _z, _boneInstance, _boneName, _boneType, _armatureXML, _armatureConnectionXML){
	var _frameXML = <{FRAME}/>;
	//寻找骨骼配置，读取父骨骼关系
	var _boneXML = _armatureXML[BONE].(@name == _boneName)[0];
	var _parentName;
	var _parent;
	if(_boneXML){
		_parentName = _boneXML[AT + A_PARENT][0];
	}else{
		//没有骨骼配置，则寻找内置数据
		_boneConnectionXML = _armatureConnectionXML[BONE].(@name == _boneName)[0];
		if(_boneConnectionXML){
			_parentName = _boneConnectionXML[AT + A_PARENT][0];
		}
	}
	//查找父骨骼
	if(_parentName){
		_parent = getBoneFromLayers(_layers, _parentName, _start);
	}
	if (_parent) {
		transfromParentPoint(pointTemp, _boneInstance, _parent);
		pointTemp.skewX = _boneInstance.skewX - _parent.skewX;
		pointTemp.skewY = _boneInstance.skewY - _parent.skewY;
	}else {
		pointTemp.x = _boneInstance.x;
		pointTemp.y = _boneInstance.y;
		pointTemp.skewX = _boneInstance.skewX;
		pointTemp.skewY = _boneInstance.skewY;
	}
	
	if(!_boneXML){
		//没有骨骼配置，则根据当前骨骼创建
		_boneXML = createBoneXML(_boneName, _parentName, pointTemp, _boneType, _z);
		_armatureXML.appendChild(_boneXML);
	}
	if(!_parent){
		//未找到父骨骼则删除 parent 标签
		//不应出现骨骼扔拥有子骨骼的时候，却在时间轴上删除该骨骼
		delete _boneXML[AT + A_PARENT];
	}
	//x、y、skewX、skewY为相对数据
	_frameXML[AT + A_X] = formatNumber(pointTemp.x - Number(_boneXML[AT + A_X]));
	_frameXML[AT + A_Y] = formatNumber(pointTemp.y - Number(_boneXML[AT + A_Y]));
	_frameXML[AT + A_SKEW_X] = formatNumber(pointTemp.skewX - Number(_boneXML[AT + A_SKEW_X]));
	_frameXML[AT + A_SKEW_Y] = formatNumber(pointTemp.skewY - Number(_boneXML[AT + A_SKEW_Y]));
	_frameXML[AT + A_SCALE_X] = formatNumber(_boneInstance.scaleX);
	_frameXML[AT + A_SCALE_Y] = formatNumber(_boneInstance.scaleY);
	_frameXML[AT + A_Z] = _z;
	
	var _imageItem = _boneInstance.libraryItem;
	var _imageName = formatName(_imageItem);
	var _isArmature = isArmatureItem(_imageItem);
	if(_imageItem.symbolType != MOVIE_CLIP){
		_imageItem.symbolType = MOVIE_CLIP;
	}
	var _displayXML = _boneXML[DISPLAY].(@name == _imageName)[0];
	if(!_displayXML){
		_displayXML = <{DISPLAY} {A_NAME} = {_imageName}/>;
		if(_isArmature){
			_displayXML[AT + A_IS_ARMATURE] = 1;
		}
		_boneXML.appendChild(_displayXML);
	}
	_frameXML[AT + A_DISPLAY_INDEX] = _displayXML.childIndex();
	if(_isArmature){
		generateArmature(_imageName);
	}else{
		createTextureXML(_boneInstance);
	}
	return _frameXML;
}

function createMovementXML(_item, _movementName, _duration){
	if(_item.hasData(ANIMATION_DATA)){
		var _animationXML = XML(_item.getData(ANIMATION_DATA));
		var _xml = _animationXML[MOVEMENT].(@name == _movementName)[0];
	}
	if(!_xml){
		_xml = <{MOVEMENT} {A_NAME} = {_movementName}/>;
		_xml[AT + A_DURATION_TO] = 6;
	}
	_xml[AT + A_DURATION] = _duration;
	if(_duration > 1){
		if(!_xml[AT + A_DURATION_TWEEN][0]){
			_xml[AT + A_DURATION_TWEEN] = _duration > 2?_duration:10;
		}
		if(_duration == 2){
			if(!_xml[AT + A_LOOP][0]){
				_xml[AT + A_LOOP] = 1;
			}
			if(!_xml[AT + A_TWEEN_EASING][0]){
				_xml[AT + A_TWEEN_EASING] = 2;
			}
		}
	}
	return _xml;
}

function createMovementBone(_movementXML, _boneName){
	var _xml = _movementXML[BONE].(@name == _boneName)[0];
	if(!_xml){
		_xml = <{BONE} {A_NAME} = {_boneName}/>;
		_xml[AT + A_MOVEMENT_SCALE] = 1;
		_xml[AT + A_MOVEMENT_DELAY] = 0;
		_movementXML.appendChild(_xml);
	}
	return _xml;
}

function createBoneXML(_name, _parentName, _point, _boneType, _z){
	var _xml = <{BONE} {A_NAME} = {_name} {A_BONE_TYPE} = {_boneType}/>;
	if(_parentName){
		_xml[AT + A_PARENT] = _parentName;
	}
	_xml[AT + A_X] = formatNumber(_point.x);
	_xml[AT + A_Y] = formatNumber(_point.y);
	_xml[AT + A_SKEW_X] = formatNumber(_point.skewX);
	_xml[AT + A_SKEW_Y] = formatNumber(_point.skewY);
	_xml[AT + A_Z] = _z;
	return _xml;
}

//记录贴图
function createTextureXML(_instance){
	var _name = _instance.libraryItem.name;
	var _xml = textureAtlasXML[SUB_TEXTURE].(@name == _name)[0];
	if(!_xml){
		_xml = <{SUB_TEXTURE} {A_NAME} = {_name}/>;
		
		var _scaleX = _instance.scaleX;
		var _scaleY = _instance.scaleY;
		var _skewX = _instance.skewX;
		var _skewY = _instance.skewY;
		
		_instance.scaleX = 1;
		_instance.scaleY = 1;
		_instance.skewX = 0;
		_instance.skewY = 0;
		
		_xml[AT + A_PIVOT_X] = formatNumber(_instance.x - _instance.left);
		_xml[AT + A_PIVOT_Y] = formatNumber(_instance.y - _instance.top);
		_xml[AT + A_WIDTH] = Math.ceil(_instance.width);
		_xml[AT + A_HEIGHT] = Math.ceil(_instance.height);
		
		_instance.scaleX = _scaleX;
		_instance.scaleY = _scaleY;
		_instance.skewX = _skewX;
		_instance.skewY = _skewY;
		textureAtlasXML.appendChild(_xml);
	}
	return _xml;
}

//通过骨架名写入骨架关联数据
function changeArmatureConnection(_armatureName, _data){
	if(errorDOM()){
		return "";
	}
	var _item = library.items[library.findItemIndex(_armatureName)];
	if(!_item){
		trace(ALERT, "未找到 " + _armatureName + " 元件，请确认保持 FLA 文件同步！");
		return "";
	}
	_data = XML(_data).toXMLString();
	_data = replaceString(_data, "&lt;", "<");
	_data = replaceString(_data, "&gt;", ">");
	setArmatureConnection(_item, _data);
}

function changeMovement(_armatureName, _movementName, _data){
	if(errorDOM()){
		return;
	}
	var _item = library.items[library.findItemIndex(_armatureName)];
	if(!_item){
		trace(ALERT, "未找到 " + _armatureName + " 元件，请确认保持 FLA 文件同步！");
		return;
	}
	
	_data = XML(_data).toXMLString();
	_data = replaceString(_data, "&lt;", "<");
	_data = replaceString(_data, "&gt;", ">");
	_data = XML(_data);
	
	var _animationXML;
	if(_item.hasData(ANIMATION_DATA)){
		_animationXML = XML(_item.getData(ANIMATION_DATA));
	}else{
		_animationXML = <{ANIMATION}/>;
	}
	var _movementXML = _animationXML[MOVEMENT].(@name == _movementName)[0];
	if(_movementXML){
		_animationXML[MOVEMENT][_movementXML.childIndex()] = _data;
	}else{
		_animationXML.appendChild(_data);
	}
	delete _data[BONE].*;
	_item.addData(ANIMATION_DATA, STRING, _animationXML.toXMLString());
}

//获取骨架关联数据
function getArmatureConnection(_item){
	if(_item.hasData(ARMATURE_DATA)){
		return _item.getData(ARMATURE_DATA);
	}
	return null;
}

//写入骨架关联数据
function setArmatureConnection(_item, _data){
	_item.addData(ARMATURE_DATA, STRING, _data);
}

//是否复合 armature 结构，如果是返回 mainLayer 和 boneLayers
function isArmatureItem(_item){
	var _layersFiltered = [];
	var _mainLayer;
	for each(var _layer in _item.timeline.layers){
		switch(_layer.layerType){
			case "folder":
			case "guide":
			case "mask":
				break;
			default:
				if(isMainLayer(_layer)){
					_mainLayer = _layer;
				}else if(!isBlankLayer(_layer)){
					_layersFiltered.unshift(_layer);
				}
				break;
		}
	}
	
	if(_mainLayer && _layersFiltered.length > 0){
		_layersFiltered.unshift(_mainLayer);
		return _layersFiltered;
	}
	return null;
}

//是否为主标签层
function isMainLayer(_layer){
	for each(var _frame in filterKeyFrames(_layer.frames)){
		if(isMainFrame(_frame)){
			return true;
		}
	}
	return false;
}

//是否为主关键帧
function isMainFrame(_frame){
	return _frame.labelType == LABEL_TYPE_NAME && !isNoEasingFrame(_frame) && !isSpecialFrame(_frame, EVENT_PREFIX) && !isSpecialFrame(_frame, MOVEMENT_PREFIX);
}

//是否为不补间关键帧
function isNoEasingFrame(_frame){
	return _frame.labelType == LABEL_TYPE_NAME && _frame.name.indexOf(NO_EASING) >= 0;
}

//是否为事件关键帧
function isSpecialFrame(_frame, _framePrefix, _returnName){
	var _b = _frame.labelType == LABEL_TYPE_NAME && _frame.name.indexOf(_framePrefix) >= 0 && _frame.name.length > 1;
	if(_b && _returnName){
		var _arr = _frame.name.split(DELIM_CHAR);
		for each(var _str in _arr){
			if(_str.indexOf(_framePrefix) == 0){
				return _str.substr(1);
			}
		}
		trace(ALERT, "错误的特殊关键帧命名！", _frame.name);
		return false;
	}
	return _b;
}

//是否为空图层
function isBlankLayer(_layer){
	for each(var _frame in filterKeyFrames(_layer.frames)){
		if(_frame.elements.length){
			return false;
		}
	}
	return true;
}

//获取骨骼
function getBoneFromLayers(layers, _boneName, _frameIndex){
	var _symbol;
	var _layerBones = [];
	for each(var _layer in layers){
		if(_layer.name == _boneName){
			return getBoneSymbol(_layer.frames[_frameIndex].elements);
		}
	}
	return null;
}

//过滤符合骨骼的元素
function getBoneSymbol(_elements){
	for each(var _element in _elements){
		if(_element.symbolType == MOVIE_CLIP || _element.symbolType == GRAPHIC){
			return _element;
		}
	}
	return null;
}

//过滤关键帧
function filterKeyFrames(_frames){
	var _framesCopy = [];
	for each(var _frame in _frames){
		if(_framesCopy.indexOf(_frame)>=0){
			continue;
		}
		_framesCopy.push(_frame);
	}
	return _framesCopy;
}

//转换父坐标系
function transfromParentPoint(_point, _boneInstance, _parent){
	var _dX = _boneInstance.x - _parent.x;
	var _dY = _boneInstance.y - _parent.y;
	var _r = Math.atan2(_dY, _dX) - _parent.skewY * Math.PI / 180;
	var _len = Math.sqrt(_dX * _dX + _dY * _dY);
	_point.x = _len * Math.cos(_r);
	_point.y = _len * Math.sin(_r);
}

//避开同名
function formatSameName(_obj, _dic){
	var _i = 0;
	var _name = formatName(_obj);
	while(_dic?_dic[_name]:_i == 0){
		_name = _obj.name + _i;
		_i ++;
	}
	if(_i > 0){
		_obj.name = _name;
	}
	if(_dic){
		_dic[_name] = true;
	}
	return _name;
}

//防止对象未命名
function formatName(_obj){
	var _name = _obj.name;
	if(!_name){
		_obj.name = _name = "unnamed" + Math.round((Math.random()*10000));
	}else if(_name.indexOf(DELIM_CHAR) >= 0){
		_obj.name = _name = replaceString(_name, DELIM_CHAR, "");
	}
	return _name;
}

//保留小数
function formatNumber(_num, _retain){
	_retain = _retain || 100;
	return Math.round(_num * _retain) / 100;
}

function replaceString(_strOld, _str, _rep){
	if(_strOld){
		return _strOld.split(_str).join(_rep);
	}
	return "";
}

function clearTextureSWFItem(_length){
	if(!library.itemExists(TEXTURE_SWF_ITEM)){
		library.addNewItem(MOVIE_CLIP, TEXTURE_SWF_ITEM);
	}
	library.editItem(TEXTURE_SWF_ITEM);
	var _timeline = dom.getTimeline();
	_timeline.currentLayer = 0;
	_timeline.removeFrames(0, _timeline.frameCount);
	_timeline.insertBlankKeyframe(0);
	_timeline.insertFrames(0, _length + 2);
	_timeline.convertToKeyframes(0, _length + 2);
	_timeline.layers[0].frames[0].actionScript = "stop();";
}

function addTextureToSWFItem(_itemName, _index){
	var _timeline = dom.getTimeline();
	_timeline.currentFrame = 0;
	library.addItemToDocument({x:0, y:0}, _itemName);
	_timeline.currentFrame = _index;
	library.addItemToDocument({x:0, y:0}, _itemName);
	_timeline.layers[0].frames[_index].name = _itemName;
}

function packTextures(_textureAtlasXML){
	if(errorDOM()){
		return;
	}
	
	if(!library.itemExists(TEXTURE_SWF_ITEM)){
		return;
	}
	_textureAtlasXML = XML(_textureAtlasXML).toXMLString();
	_textureAtlasXML = replaceString(_textureAtlasXML, "&lt;", "<");
	_textureAtlasXML = replaceString(_textureAtlasXML, "&gt;", ">");
	_textureAtlasXML = XML(_textureAtlasXML);
	
	var _subTextureXMLList = _textureAtlasXML[SUB_TEXTURE];
	
	var _textureItem = library.items[library.findItemIndex(TEXTURE_SWF_ITEM)];
	var _timeline = _textureItem.timeline;
	_timeline.currentFrame = 0;
	var _name;
	var _textureXML;
	for each(var _texture in _textureItem.timeline.layers[0].frames[0].elements){
		if(_texture.symbolType == MOVIE_CLIP || _texture.symbolType == GRAPHIC){
			_textureXML = _subTextureXMLList.(@name == _texture.libraryItem.name)[0];
			if(_textureXML){
				if(_texture.scaleX != 1){
					_texture.scaleX = 1;
				}
				if(_texture.scaleY != 1){
					_texture.scaleY = 1;
				}
				if(_texture.skewX != 0){
					_texture.skewX = 0;
				}
				if(_texture.skewY != 0){
					_texture.skewY = 0;
				}
				_texture.x += Number(_textureXML[AT + A_X]) - _texture.left;
				_texture.y += Number(_textureXML[AT + A_Y]) - _texture.top;
			}
		}
	}
	dom.selectAll();
	dom.selectNone();
}

function exportSWF(){
	if(!library.itemExists(TEXTURE_SWF_ITEM)){
		return;
	}
	var _folderURL = fl.configURI;
	var _pathDelimiter;
	if(_folderURL.indexOf("/")>=0){
		_pathDelimiter = "/";
	}else if(_folderURL.indexOf("\\")>=0){
		_pathDelimiter = "\\";
	}else{
		return "";
	}
	_folderURL = _folderURL + "WindowSWF" + _pathDelimiter + SKELETON_PANEL;
	if(!FLfile.exists(_folderURL)){
		FLfile.createFolder(_folderURL);
	}
	var _swfURL = _folderURL + _pathDelimiter + TEXTURE_SWF;
	library.items[library.findItemIndex(TEXTURE_SWF_ITEM)].exportSWF(_swfURL);
	return _swfURL;
}