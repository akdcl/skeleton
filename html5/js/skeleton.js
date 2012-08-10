/**
 * 骨骼动画V1
 * @author ...akdcl
 */
var skeleton = {};
(function(){

var PI = Math.PI,
	HALF_PI = PI * 0.5,
	ANGLE_TO_RADIAN = PI / 180;
	
var ptp;

/**
 * Node
 */
skeleton.Node = function(x, y, rotation){
	this.x = x || 0;
	this.y = y || 0;
	this.rotation = rotation || 0;
}

ptp = skeleton.Node.prototype;
ptp.copy = function(node){
	this.x = node.x;
	this.y = node.y;
	this.rotation = node.rotation;
}

/**
 * FrameNode
 */
skeleton.FrameNode = function(x, y, rotation){
	skeleton.Node.call(this, x, y, rotation);
	this.scaleX = 1;
	this.scaleY = 1;
	this.alpha = 1;
	this.frame = 1;
	this.offR = 0;
}
skeleton.FrameNode.prototype = new skeleton.Node();

ptp = skeleton.FrameNode.prototype;
ptp.copy = function(node){
	this.constructor.prototype.copy.call(this, node);
	if(node.frame){
		this.scaleX = node.scaleX;
		this.scaleY = node.scaleY;
		this.alpha = node.alpha;
		this.frame = node.frame;
		this.offR = node.offR;
	}
}

/**
 * TweenNode
 */
skeleton.TweenNode = function(x, y, rotation){
	skeleton.FrameNode.call(this, x, y, rotation);
	this._sR = 0;
	this._sX = 0;
	this._sY = 0;
	this._sSX = 0;
	this._sSY = 0;
	this._sA = 0;
	
	this._dR = 0;
	this._dX = 0;
	this._dY = 0;
	this._dSX = 0;
	this._dSY = 0;
	this._dA = 0;
}
skeleton.TweenNode.prototype = new skeleton.FrameNode();

ptp = skeleton.TweenNode.prototype;
ptp.betweenValue = function(from, to){
	this._sR = from.rotation;
	this._sX = from.x;
	this._sY = from.y;
	this._sSX = from.scaleX;
	this._sSY = from.scaleY;
	this._sA = from.alpha;
	if(to.offR){
		this._dR = to.rotation + to.offR * 360 - this._sR;
	}else{
		this._dR = to.rotation - this._sR;
	}
	this._dX = to.x - this._sX;
	this._dY = to.y - this._sY;
	this._dSX = to.scaleX - this._sSX;
	this._dSY = to.scaleY - this._sSY;
	this._dA = to.alpha - this._sA;
}
ptp.tweenTo = function(k){
	this.rotation = this._sR + this._dR * k;
	this.x = this._sX + this._dX * k;
	this.y = this._sY + this._dY * k;
	
	if(this._dSX){
		this.scaleX = this._sSX + this._dSX * k;
	}else{
		this.scaleX = NaN;
	}
	if(this._dSY){
		this.scaleY = this._sSY + this._dSY * k;
	}else{
		this.scaleY = NaN;
	}
	if(this._dA){
		this.alpha = this._sA + this._dA * k;
	}else{
		this.alpha = NaN;
	}
}

/**
 * FrameNodeList
 */
skeleton.FrameNodeList = function(delay, scale){
	this.delay = delay || 0;
	this.scale = scale || 1;
	this.frame = 0;
	this.length = 0;
	this._frameList = [];
}

ptp = skeleton.FrameNodeList.prototype;
ptp.addFrame = function(node){
	this._frameList.push(node);
	this.frame += node.frame;
	this.length ++;
}
ptp.getFrame = function(index){
	if(index < 0){
		index = this.length + index;
	}
	return this._frameList[index];
}

/**
 * ProcessBase
 */
skeleton.ProcessBase = function(){
	this.scale = 1;
	this._isComplete = true;
	this._isPause = false;
	this._currentFrame = 0;
	
	this._totalFrames = 0;
	this._listFrames = 0;
	this._rawListFrames = 0;
	this._currentPrecent = 0;
	this._loop = 0;
	this._ease = 0;
	this._toFrameID = 0;
	this._betweenFrame = 0;
	this._listEndFrame = 0;
}

ptp = skeleton.ProcessBase.prototype;
ptp.remove = function(){
	this.scale = 1;
	this._isComplete = true;
	this._isPause = false;
	this._currentFrame = 0;
}
ptp.pause = function(){
	this._isPause = true;
}
ptp.resume = function(){
	this._isPause = false;
}
ptp.stop = function(){
	this._isComplete = true;
	this._currentFrame = 0;
}
ptp.playTo = function(to, toFrames, listFrames, isLoop, ease){
	this._isComplete = false;
	this._isPause = false;
	this._currentFrame = 0;
	this._totalFrames = toFrames;
	this._ease = ease || 0;
}
ptp.update = function(){
	if(this._isComplete || this._isPause){
		return;
	}
	this._currentFrame += this.scale;
	this._currentPrecent = this._currentFrame / this._totalFrames;
	this._currentFrame %= this._totalFrames;
	this._updateHandler();
}

/**
 * Tween
 */
skeleton.Tween = function(){
	this._from = new skeleton.TweenNode();
	this._to = new skeleton.TweenNode();
	//node:TweenNode;
	//tweenList:FrameNodeList;
}
skeleton.Tween.prototype = new skeleton.ProcessBase();

skeleton.Tween._prepared = [];
skeleton.Tween.create = function(){
	if(skeleton.Tween._prepared.length > 0){
		return skeleton.Tween._prepared.pop();
	}
	return new skeleton.Tween();
}
skeleton.Tween._recycle = function(tween){
	if(skeleton.Tween._prepared.indexOf(tween) <0 ){
		return;
	}
	skeleton.Tween._prepared.push(tween);
}

ptp = skeleton.Tween.prototype;
ptp.remove=function(){
	this.constructor.prototype.remove.call(this);
	this.node = null;
	this.tweenList = null;
	skeleton.Tween._recycle(this);
}
ptp.setNode = function(node){
	this.node = node;
}
ptp.playTo = function(to, toFrames, listFrames, isLoop, ease){
	this.constructor.prototype.playTo.call(this, to, toFrames, listFrames, isLoop, ease);
	this.node.rotation %= 360;
	this._from.copy(this.node);
	this.tweenList = to;
	if(to.length == 1){
		this._loop = -4;
		this._to.copy(this.tweenList.getFrame(0));
	}else{
		if(isLoop){
			this._loop = -2;
			this._rawListFrames = this.tweenList.frame;
		}else{
			this._loop = -3;
			this._rawListFrames = this.tweenList.frame - 1;
		}
		this._listFrames = listFrames * this.tweenList.scale;
		if(isLoop && this.tweenList.delay != 0){
			var playedFrames = this._rawListFrames * (1 - this.tweenList.delay);
			var prevFrameID = 0;
			var toFrameID = 0;
			var listEndFrame = 0;
			var betweenFrame = 0;
			do{
				betweenFrame = this.tweenList.getFrame(toFrameID).frame;
				listEndFrame += betweenFrame;
				prevFrameID = toFrameID;
				if(++toFrameID >= this.tweenList.length){
					toFrameID = 0;
				}
			}while(playedFrames >= listEndFrame);
			
			this._to.betweenValue(this.tweenList.getFrame(prevFrameID), this.tweenList.getFrame(toFrameID));
			var currentPrecent = 1 - (listEndFrame - playedFrames) / betweenFrame;
			if(this._ease == 2){
				currentPrecent = 0.5 * (1 - Math.cos(currentPrecent * Math.PI ));
			}else if(this._ease != 0){
				currentPrecent = this._ease > 0?Math.sin(currentPrecent * HALF_PI):(1 - Math.cos(currentPrecent * HALF_PI));
			}
			this._to.tweenTo(currentPrecent);
		}else {
			this._to.copy(this.tweenList.getFrame(0));
		}
	}
	this.node.betweenValue(this._from, this._to);
}
ptp._updateHandler = function(){
	if(this._currentPrecent >= 1){
		switch(this._loop){
			case -3:
				this._loop = -1;
				this._currentPrecent = (this._currentPrecent - 1) * this._totalFrames / this._listFrames;
				if(this._currentPrecent >= 1){
				}else{
					this._totalFrames = this._listFrames;
					this._currentPrecent %= 1;
					this._listEndFrame = 0;
					break;
				}
			case -1:
			case -4:
				this._currentPrecent = 1;
				this._isComplete = true;
				break;
			case -2:
				this._loop = 0;
				this._totalFrames = this._listFrames;
				if(this.tweenList.delay != 0){
					this._currentFrame = (1 - this.tweenList.delay) * this._totalFrames;
					this._currentPrecent += this._currentFrame / this._totalFrames;
				}
				this._currentPrecent %= 1;
				this._listEndFrame = 0;
				break;
			default:
				this._loop += this._currentPrecent >> 0;
				this._currentPrecent %= 1;
				break;
		}
	}else if(this._loop < -1){
		this._currentPrecent = Math.sin(this._currentPrecent * HALF_PI);
	}
	
	if(this._loop >= -1){
		this._updateCurrentPrecent();
	}
	this.node.tweenTo(this._currentPrecent);
}

ptp._updateCurrentPrecent = function(){
	var playedFrames = this._rawListFrames * this._currentPrecent;
	if(playedFrames <= this._listEndFrame-this._betweenFrame || playedFrames > this._listEndFrame){
		this._listEndFrame = 0;
		this._toFrameID = 0;
		var prevFrameID = 0;
		do{
			this._betweenFrame = this.tweenList.getFrame(this._toFrameID).frame;
			this._listEndFrame += this._betweenFrame;
			prevFrameID = this._toFrameID;
			if(++this._toFrameID >= this.tweenList.length){
				this._toFrameID = 0;
			}
		}while(playedFrames >= this._listEndFrame);
		
		this._from.copy(this.tweenList.getFrame(prevFrameID));
		this._to.copy(this.tweenList.getFrame(this._toFrameID));
		this.node.betweenValue(this._from, this._to);
	}
	
	this._currentPrecent = 1 - (this._listEndFrame - playedFrames) / this._betweenFrame;
	if(this._ease == 2){
		this._currentPrecent = 0.5 * (1 - Math.cos(this._currentPrecent * PI));
	}else if(this._ease != 0){
		this._currentPrecent = this._ease > 0?Math.sin(this._currentPrecent * HALF_PI):(1 - Math.cos(this._currentPrecent * HALF_PI));
	}
}

/**
 * Animation
 */
skeleton.Animation = function(){
	//_tweenDic:Object
	//_armatureAniData:Object
	//_boneAniData:Object
	//_aniIDNow:String
	//onAnimation:Function
	//eventTarget
}
skeleton.Animation.prototype = new skeleton.ProcessBase();

ptp = skeleton.Animation.prototype;
ptp.remove = function(){
	this.constructor.prototype.remove.call(this);
	for(var boneName in this._tweenDic){
		this._tweenDic[boneName].remove();
	}
	this.eventTarget = null;
	this.onAnimation = null;
	this._tweenDic = null;
	this._armatureAniData = null;
	this._boneAniData = null;
	this._aniIDNow = null;
}
ptp.pause = function(){
	this.constructor.prototype.pause.call(this);
	for(var boneName in this._tweenDic){
		this._tweenDic[boneName].pause();
	}
}
ptp.resume = function(){
	this.constructor.prototype.resume.call(this);
	for(var boneName in this._tweenDic){
		this._tweenDic[boneName].resume();
	}
}
ptp.stop = function(){
	this.constructor.prototype.stop.call(this);
	for(var boneName in this._tweenDic){
		this._tweenDic[boneName].stop();
	}
}
ptp.setData = function(aniData){
	this.remove();
	this._tweenDic = {};
	this._armatureAniData = aniData;
}
ptp.addTween = function(bone){
	var boneName = bone.name;
	var tween = this._tweenDic[boneName];
	if(!tween){
		this._tweenDic[boneName] = tween = skeleton.Tween.create();
	}
	tween.setNode(bone._tweenNode);
}
ptp.removeTween = function(bone){
	var boneName = bone.name;
	var tween = this._tweenDic[boneName];
	if(tween){
		delete this._tweenDic[boneName];
		tween.remove();
	}
}
ptp.getTween = function(boneName){
	return this._tweenDic[boneName];
}
ptp.updateTween = function(boneName){
	var tween = this._tweenDic[boneName];
	if(tween){
		tween.update();
	}
}
ptp.playTo = function(to, toFrames, listFrames, isLoop, ease){
	this._boneAniData = this._armatureAniData[to];
	if(!this._boneAniData){
		return;
	}
	this.constructor.prototype.playTo.call(this, to, toFrames, listFrames, isLoop, ease);
	this._aniIDNow = to;
	var frameNodeList;
	var tween;
	for(var boneName in this._tweenDic){
		tween = this._tweenDic[boneName];
		frameNodeList = this._boneAniData[boneName];
		if(frameNodeList){
			tween.playTo(frameNodeList, toFrames, listFrames, isLoop, ease);
		}
	}
	this._rawListFrames = this._boneAniData.frame;
	if(this._rawListFrames == 1){
		this._loop = -4;
	}else{
		if(isLoop){
			this._loop = -2;
		}else{
			this._loop = -3;
			this._rawListFrames --;
		}
		this._listFrames = listFrames;
	}
}
ptp._updateHandler = function(){
	if(this._currentPrecent >= 1){
		switch(this._loop){
			case -3:
				this._loop = -1;
				this._currentPrecent = (this._currentPrecent - 1) * this._totalFrames / this._listFrames;
				if(this._currentPrecent >= 1){
				}else{
					this._currentPrecent %= 1;
					this._totalFrames = this._listFrames;
					this._listEndFrame = 0;
					if(this.onAnimation != null){
						this.onAnimation.call(this.eventTarget, "start", this._aniIDNow);
					}
					break;
				}
			case -1:
			case -4:
				this._currentPrecent = 1;
				this._isComplete = true;
				if(this.onAnimation != null){
					this.onAnimation.call(this.eventTarget, "complete", this._aniIDNow);
				}
				break;
			case -2:
				this._loop = 0;
				this._currentPrecent %= 1;
				this._totalFrames = this._listFrames;
				this._listEndFrame = 0;
				if(this.onAnimation != null){
					this.onAnimation.call(this.eventTarget, "start", this._aniIDNow);
				}
				break;
			default:
				this._loop += this._currentPrecent >> 0;
				this._currentPrecent %= 1;
				if(this.onAnimation != null){
					this.onAnimation.call(this.eventTarget, "loopComplete", this._aniIDNow);
				}
				break;
		}
	}
	if(this._loop >= -1 && this._boneAniData.eventFrame){
		this._updateCurrentPrecent();
	}
}
ptp._updateCurrentPrecent = function(){
	var playedFrames = this._rawListFrames * this._currentPrecent;
	if(playedFrames <= this._listEndFrame - this._betweenFrame || playedFrames > this._listEndFrame){
		this._toFrameID = 0;
		this._listEndFrame = 0;
		var prevFrameID;
		do{
			this._betweenFrame = this._boneAniData.eventFrame[this._toFrameID].frame;
			this._listEndFrame += this._betweenFrame;
			prevFrameID = this._toFrameID;
			if(++ this._toFrameID >= this._boneAniData.eventFrame.length){
				this._toFrameID = 0;
			}
		}while(playedFrames >= this._listEndFrame);
		if(this.onAnimation != null){
			this.onAnimation.call(this.eventTarget, "inFrame", this._aniIDNow, this._boneAniData.eventFrame[prevFrameID].name);
		}
	}	
	this._currentPrecent = 1 - (this._listEndFrame - playedFrames) / this._betweenFrame;
}
ptp.setAnimationScale = function(scale, boneName){
	var tween;
	if(boneName){
		tween = this._tweenDic[boneName];
		if(tween){
			tween.scale = scale;
		}
	}else{
		this.scale = scale;
		for(var boneName in this._tweenDic){
			this._tweenDic[boneName].scale = scale;
		}
	}
}

/**
 * Bone
 */
skeleton.Bone=function(){
	this.node = new skeleton.Node();
	this._tweenNode = new skeleton.TweenNode();
	this._transformX = 0;
	this._transformY = 0;
	this._parentX = 0;
	this._parentY = 0;
	this._parentR = 0;
	this._lockX = 0;
	this._lockY = 0;
	this._lockR = 0;
	//this.name;
	//this.display;
	//this._parent;
	
}
skeleton.Bone._prepared = [];
skeleton.Bone.create = function(){
	if(skeleton.Bone._prepared.length > 0){
		return skeleton.Bone._prepared.pop();
	}
	return new skeleton.Bone();
}
skeleton.Bone._recycle = function(bone){
	if(skeleton.Bone._prepared.indexOf() < 0){
		return;
	}
	skeleton.Bone._prepared.push(bone);
}

ptp = skeleton.Bone.prototype;
ptp.remove = function(){
	this.display = null;
	this.name = null;
	this._parent = null;
	this._transformX = 0;
	this._transformY = 0;
	this._parentX = 0;
	this._parentY = 0;
	this._parentR = 0;
	this._lockX = 0;
	this._lockY = 0;
	this._lockR = 0;
	skeleton.Bone._recycle(this);
}
ptp.getGlobalX = function(){
	return this._transformX + this._parentX;
}
ptp.getGlobalY = function(){
	return this._transformY + this._parentY;
}
ptp.getGlobalR = function(){
	return this.node.rotation + this._tweenNode.rotation + this._parentR + this._lockR;
}
ptp.addChild = function(child){
	child._parent = this;
	return child;
}
ptp.setLockPosition=function(x, y, r){
	this._lockX = x;
	this._lockY = y;
	this._lockR = r || 0;
}
ptp.update = function(){
	if(this._parent){
		this._parentX = this._parent.getGlobalX();
		this._parentY = this._parent.getGlobalY();
		this._parentR = this._parent.getGlobalR();
		
		var _dX = this._lockX + this.node.x + this._tweenNode.x;
		var _dY = this._lockY + this.node.y + this._tweenNode.y;
		var _r = Math.atan2(_dY, _dX) + this._parentR * ANGLE_TO_RADIAN;
		var _len = Math.sqrt(_dX * _dX + _dY * _dY);
		this._transformX = _len * Math.cos(_r);
		this._transformY = _len * Math.sin(_r);
	}else{
		this._transformX = this.node.x + this._tweenNode.x;
		this._transformY = this.node.y + this._tweenNode.y;
	}
	this.updateDisplay();
}
ptp.updateDisplay = function(){
	if(this.display){
		this.display.x = this._transformX + this._parentX;
		this.display.y = this._transformY + this._parentY;
		var rotation = this.node.rotation + this._tweenNode.rotation + this._parentR + this._lockR;
		rotation%=360;
		if(rotation<0){
			rotation+=360;
		}
		this.display.rotation = rotation;
		
		if(isNaN(this._tweenNode.scaleX)){
		}else{
			this.display.scaleX = this._tweenNode.scaleX;
		}
		if(isNaN(this._tweenNode.scaleY)){
		}else{
			this.display.scaleY = this._tweenNode.scaleY;
		}
		if(isNaN(this._tweenNode.alpha)){
		}else{
			if(this._tweenNode.alpha){
				this.display.visible = true;
				this.display.alpha = this._tweenNode.alpha;
			}else{
				this.display.visible = false;
			}
		}
	}
}

/**
 * Armature
 */
skeleton.Armature = function(display){
	this.animation = new skeleton.Animation();
	this._display = display;
	this._boneDic = {};
	this._boneList = [];
	//this.name;
}

ptp = skeleton.Armature.prototype;
ptp.update=function(){
	var len = this._boneList.length;
	var bone;
	for(var index = 0; index < len; index++){
		bone = this._boneList[index];
		this.animation.updateTween(bone.name);
		bone.update();
	}
	this.animation.update();
}
ptp.remove = function(){
	for(var index in this._boneList){
		this._boneList[index].remove();
	}
	this.animation.remove();
	this.animation = null;
	this._display = null;
	this._boneDic = null;
	this._boneList = null;
}
ptp.addBone = function(name, parentName, display, index){
	var bone = this._boneDic[name];
	if(!bone){
		bone = skeleton.Bone.create();
		bone.name = name;
		this._boneList.push(bone);
		this._boneDic[name] = bone;
		var boneParent = this._boneDic[parentName];
		if(boneParent){
			boneParent.addChild(bone);
		}
		this.animation.addTween(bone);
	}
	
	if(display){
		if(display.name != name){
			display.name = name;
		}
		var displayOld = bone.display;
		bone.display = display;
		if(displayOld){
			this._display.addChildAt(display, this._display.getChildIndex(displayOld) - 1);
		}else if(index < 0){
			this._display.addChild(display);
		}else{
			this._display.addChildAt(display, index);
		}
	}
	return bone;
}
ptp.removeBone = function(name){
	var bone = this._boneDic[name];
	if(bone){
		this._boneList.splice(this._boneList.indexOf(bone),1);
		if(bone.display && this._display.contains(bone.display)){
			this._display.removeChild(bone.display);
		}
		this.animation.removeTween(bone);
		bone.remove();
	}
}
ptp.getBone = function(name){
	return this._boneDic[name];
}
ptp.getDisplay = function(){
	return this._display;
}

skeleton._textureDatas = {};
skeleton._armarureDatas = {};
skeleton._animationDatas = {};

skeleton.getTextureDisplay = function(image, fullName){
	var textureData = skeleton.getTextureData(fullName);
	if(textureData){
		var display = new Bitmap(image, [textureData.x, textureData.y, textureData.width, textureData.height]);
		display.regX = -textureData.frameX;
		display.regY = -textureData.frameY;
		return display;
	}
	return null;
}

skeleton.addTextureData = function (json){
	var textureData;
	json.SubTexture = skeleton._fixArray(json.SubTexture);
	for(var index in json.SubTexture){
		textureData = json.SubTexture[index];
		skeleton._textureDatas[textureData.name] = textureData;
		json.SubTexture[index] = null;
	}
}

skeleton.getTextureData = function(fullName){
	return skeleton._textureDatas[fullName];
}

skeleton.getTextureList = function(prefix){
	var list = [];
	for(var fullName in skeleton._textureDatas){
		if(fullName.indexOf(prefix + "_") == 0){
			list[skeleton.getTextureSuffix(fullName, prefix)] = skeleton._textureDatas[fullName];
		}
	}
	return list;
}

skeleton.getTexturePreFix = function(fullName){
	var arr = fullName.split("_");
	return arr.length > 1?arr[0]:null;
}

skeleton.getTextureSuffix = function(fullName, prefix){
	if(!prefix){
		prefix = skeleton.getTexturePreFix(fullName);
	}
	if(prefix){
		prefix += "_";
		var index = fullName.indexOf(prefix);
		if(index == 0){
			return fullName.substr(index + prefix.length);
		}
	}
	return null;
}

skeleton.addSkeletonData = function(json){
	json.skeleton = skeleton._fixArray(json.skeleton);
	for(var index in json.skeleton){
		skeleton._addSkeletonData(json.skeleton[index]);
	}
}

skeleton._addSkeletonData = function(skeletonData){
	var name = skeletonData.name;
	var aniData = skeleton._animationDatas[name];
	if(aniData){
		return;
	}
	skeleton._animationDatas[name] = aniData = {};
	var eachMovement,
		eachBoneAni,
		animationList = skeleton._fixArray(skeletonData.animation);
	
	for(var index in animationList){
		eachMovement = animationList[index];
		animationList[index]=null;
		aniData[eachMovement.name] = eachMovement;
		for(var boneName in eachMovement){
			eachBoneAni = eachMovement[boneName];
			if(typeof(eachBoneAni) == "object" && boneName != "eventFrame"){
				eachBoneAni = skeleton._fixArray(eachBoneAni);
				eachMovement[boneName] = skeleton._getFrameNodeList(eachBoneAni);
			}
		}
		
		if(eachMovement.eventFrame){
			eachMovement.eventFrame = skeleton._fixArray(eachMovement.eventFrame);
			var _obj = {};
			var _frame = 0;
			for(var i in eachMovement.eventFrame){
				_frame += eachMovement.eventFrame[i].frame;
			}
			_obj.name = "init";
			_obj.frame = eachMovement.frame - _frame;
			eachMovement.eventFrame.unshift(_obj);
		}
	}
	
	skeleton._armarureDatas[name] = skeleton._fixArray(skeletonData.bone);
	
	delete skeletonData.animation;
	delete skeletonData.bone;
}

skeleton._getFrameNodeList=function(boneAni){
	var nodeList = new skeleton.FrameNodeList();
	nodeList.scale = boneAni[0].scale || nodeList.scale;
	nodeList.delay = boneAni[0].delay || nodeList.delay;
	nodeList._frameList = boneAni;
	nodeList.length = boneAni.length;
	
	var node;
	for(var index in boneAni){
		node=boneAni[index];
		node.rotation = Number(node.rotation) || 0;
		node.scaleX = Number(node.scaleX) || 1;
		node.scaleY = Number(node.scaleY) || 1;
		node.alpha = Number(node.alpha) || 1;
		node.offR = Number(node.offR) || 0;
		node.frame = Number(node.frame) || 1;
		nodeList.frame += node.frame;
	}
	return nodeList;
}

skeleton._fixArray = function(arr){
	if(arr && !(arr instanceof Array)){
		return [arr];
	}
	return arr;
}

skeleton.getArmatureData = function(name){
	return skeleton._armarureDatas[name];
}

skeleton.getAnimationData = function(name){
	return skeleton._animationDatas[name];
}

skeleton.createArmature = function(name, animationName, image){
	var armatureData = skeleton.getArmatureData(name);
	if(!armatureData){
		return null;
	}
	var armatureDisplay = new Sprite();
	armatureDisplay.name = name;
	var armature = new skeleton.Armature(armatureDisplay);
	
	var animationData = skeleton.getAnimationData(animationName);
	if(animationData){
		armature.animation.setData(animationData);
	}
	
	var bone,
		boneData,
		boneName,
		parentName,
		boneDisplay,
		displayHigher,
		indexZ,
		list = [],
		length = armatureData.length;
	for(var indexI = 0; indexI < length; indexI++){
		boneData = armatureData[indexI];
		boneName = boneData.name;
		parentName = boneData.parent;
		indexZ = boneData.z;
		
		boneDisplay = skeleton.getTextureDisplay(image, name + "_" + boneName);
		if(boneDisplay){
			displayHigher = null;
			for(var indexJ = indexZ; indexJ < list.length; indexJ++){
				displayHigher = list[indexJ];
				if(displayHigher){
					break;
				}
			}
			list[indexZ] = boneDisplay;
			if(displayHigher){
				indexZ = armature.getDisplay().getChildIndex(displayHigher);
			}else{
				indexZ = -1;
			}
		}
		
		bone = armature.addBone(boneName, parentName, boneDisplay, indexZ);
		bone.setLockPosition(boneData.x, boneData.y, 0);
	}
	return armature;
}

ptp = null;
})();