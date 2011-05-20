// ActionScript file
import com.fourkitchens.Recorder;

import components.gauge.events.GaugeEvent;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.ContextMenuEvent;
import flash.external.ExternalInterface;
import flash.media.Camera;
import flash.net.URLRequest;
import flash.ui.ContextMenu;
import flash.utils.Timer;

import mx.controls.Alert;
import mx.core.Application;
import mx.graphics.codec.PNGEncoder;

NetConnection.defaultObjectEncoding = flash.net.ObjectEncoding.AMF3;
SharedObject.defaultObjectEncoding  = flash.net.ObjectEncoding.AMF3;

public var nc:NetConnection;
public var ns:NetStream;
[Bindable] public var so_chat:SharedObject;
public var camera:Camera;
public var mic:Microphone;
public var nsOutGoing:NetStream;
public const ROOMMODEL:String="models";
[Bindable] public var myRecorder:Recorder;
public var DEBUG:Boolean=false;
public var recordingTimer:Timer = new Timer( 1000 , 0 );
[Bindable] public var timeLeft:String="";

protected var thumbnailBytes:ByteArray;

protected var customMenuItem:ContextMenuItem;

protected var maxTimer:String = '';

public function init():void {
	myRecorder = new Recorder(Application.application.parameters);

	Application.application.width = myRecorder.width;
	Application.application.height = myRecorder.height;
	
	addContextMenuItems();

	recordingTimer.addEventListener('timer', decrementTimer);

	timeLeft = myRecorder.maxLength.toString();
  	nc = new NetConnection();		
	nc.client = this;		
	nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
	nc.connect(myRecorder.server);

	currentState = '';
	if ('player' == myRecorder.mode) {
		currentState = 'player';
	}
	
	maxTimer = formatTime(myRecorder.maxLength);
	setTimer(myRecorder.maxLength, maxTimer);
}

protected function recClicked():void { 
	if (rec_btn.selected) {
		captureThumbnail();
		recordStart();
	} else {
		recordFinished();
	}
}

protected function videoIsComplete():void {
	videoPlayer.stop();
	playPauseBut.selected = true;
}

protected function thumbClicked(e:MouseEvent):void {
	videoPlayer.playheadTime = position.value;	
}

public function stopVideo():void {
	var s:String = myRecorder.server+myRecorder.fileName+".flv";
	videoPlayer.source = s;
	playPause();
	videoPlayer.stop();
	// selecting this button was the only way I found to cause it to reset to "Play" when the user hits Stop - rupl 20110514
	playPauseBut.selected = true;
}

protected function replay():void {
	rec_btn.selected = false;
	recClicked();
	currentState="player";
	var s:String = myRecorder.server+myRecorder.fileName+".flv";
	videoPlayer.source = s;
	// start the video
	playPauseBut.selected = false;
	playPause();
}

protected function save():void {
	nsOutGoing.close();
	publishThumbnail();
	var jsFunction:String = 'videoRecorder.save("' + myRecorder.id + '", "' + myRecorder.fileName + '")';
	ExternalInterface.call(jsFunction);
}

protected function playPause():void{
	if (videoPlayer.playing) {
		videoPlayer.pause();
	} else {
		videoPlayer.play();
	}
}

protected function thumbPressed():void {
	playPauseBut.selected = true;
	videoPlayer.pause();
}	


protected function thumbReleased():void {
	videoPlayer.playheadTime = position.value;
	return;
		
	videoPlayer.playheadTime = position.value;	
	if (playPauseBut.selected) {
		videoPlayer.pause();
	} else {
		videoPlayer.play();	
	}
}

protected function formatPositionToolTip(value:Number):String{
	return value.toFixed(2) +" s";
}

protected function handleGaugeEvent( event:GaugeEvent ) : void{	
	videoPlayer.volume = event.value/100;
}

protected function rollOut(e:MouseEvent):void {
}

protected function rollOver(e:MouseEvent):void {
} 

protected function netStatusHandler(event:NetStatusEvent):void {
	switch (event.info.code) {
		case "NetConnection.Connect.Failed":
			Alert.show("ERROR:Could not connect to server : " + myRecorder.server);
			break;	
		case "NetConnection.Connect.Success":
			prepareStreams();
			break;
		default:
			nc.close();
			break;
	}
}

public function recordStart():void {
	if (outOfTime()) {
		return recordFinished(true);
	}
	rec_btn.selected = true;
	recordingTimer.start();
}

public function recordFinished(exceeded:Boolean=false):void {
	if (exceeded) {
		Alert.show(myRecorder.recordingTimeExceededText);
	}

	recordingTimer.stop();
	rec_btn.selected = false;
	myRecorder.hasRecorded = true;
}

/*
 Timer functions
 */

protected function decrementTimer(event:TimerEvent ):void {

	myRecorder.timeLeft--;
	setTimer(myRecorder.timeLeft, maxTimer);
	if (outOfTime()) {
		return recordFinished(true);
	}
}

public function setTimer(remaining:int, total:String):void {
	timeLeft = formatTime(remaining) + '/' + total;
}

protected function formatTime(time:int):String { 
	var minutes:int, 
	seconds:int,
	min:String,
	sec:String;
	
	minutes = time / 60;
	seconds = time % 60;
	
	min = '' + minutes;
	if (minutes < 10) {
		min = '0' + minutes;
	}
	
	sec = '' + seconds;
	if (seconds < 10) {
		sec = '0' + seconds;
	}
	
	return min + ':' + sec; 
}

/**
* Checks to see if the user has exceeded the time limit.
*/
protected function outOfTime():Boolean { 
	return (myRecorder.timeLeft <= 0);
}

public function webcamParameters():void {
	Security.showSettings(SecurityPanel.DEFAULT);
}

protected function drawMicLevel(evt:TimerEvent):void {
		var ac:int=mic.activityLevel;
		micLevel.setProgress(ac,100);
}

private function prepareStreams():void {
	nsOutGoing = new NetStream(nc); 
	camera=Camera.getCamera();
	if (camera==null) {
		Alert.show("Webcam not detected !");
	}

	if (camera.muted) 	{
		Security.showSettings(SecurityPanel.DEFAULT);
	}
	camera.setQuality(myRecorder.bandwidth,myRecorder.compression);
	camera.setMode(myRecorder.width,myRecorder.height,myRecorder.fps);
	camera.setKeyFrameInterval(myRecorder.keyframe);
	myWebcam.attachCamera(camera);
	nsOutGoing.attachCamera(camera);
	myRecorder.cameraDetected=true;
	camera.addEventListener(StatusEvent.STATUS, cameraStatus); 

	mic=Microphone.getMicrophone(0);
	if (mic!=null) {
        mic.rate=myRecorder.microRate;
        var timer:Timer=new Timer(50);
		timer.addEventListener(TimerEvent.TIMER, drawMicLevel);
		timer.start();
		nsOutGoing.attachAudio(mic);
	}
	nsOutGoing.publish(myRecorder.fileName, "record");
}
   
protected function cameraStatus(evt:StatusEvent):void {
	switch (evt.code) {
		case "Camera.Muted":
			myRecorder.cameraDetected=false;
			break;
		case "Camera.Unmuted":
			myRecorder.cameraDetected=true;
			break;
	}
}

/*
 Thumbnail functions
*/

protected function captureThumbnail():void {
	if (!myRecorder.thumbnailSaveURL) {
		return;
	}

	var thumbnailData:BitmapData = new BitmapData(myRecorder.width, myRecorder.height);
	thumbnailData.draw(myWebcam);
	var imageEncoder:PNGEncoder = new PNGEncoder();
	thumbnailBytes = imageEncoder.encode(thumbnailData);
}

protected function publishThumbnail():void {
	if (!myRecorder.thumbnailSaveURL) {
		return;
	}

	var header:URLRequestHeader = new URLRequestHeader("Content-type", "image/jpeg");
	var saveImage:URLRequest = new URLRequest(myRecorder.thumbnailSaveURL + myRecorder.fileName);
	saveImage.requestHeaders.push(header);
	saveImage.method = URLRequestMethod.POST;
	saveImage.data = thumbnailBytes;
	
	var urlLoader:URLLoader = new URLLoader();
	urlLoader.load(saveImage);
}

/*
 Context menu functions
 */
protected function addContextMenuItems():void {
	if (!contextMenu) {
		contextMenu = new ContextMenu();
	}
	contextMenu.hideBuiltInItems();

	customMenuItem = new ContextMenuItem('Drupal Video Recorder', true);
	customMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, projectMenuItemSelected);
	
	contextMenu.customItems.push(customMenuItem);
}

/**
 * Handle the drupal.org project menu item being clicked.
 * 
 * This has to be public for the event to handler work - skwashd 20110512.
 */ 
public function projectMenuItemSelected(event:ContextMenuEvent):void {
	var URL:URLRequest = new URLRequest('http://drupal.org/project/video_recorder');
	navigateToURL(URL);
}

