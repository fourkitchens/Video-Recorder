// ActionScript file
import com.fourkitchens.Recorder;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.ContextMenuEvent;
import flash.external.ExternalInterface;
import flash.media.Camera;
import flash.net.URLRequest;
import flash.ui.ContextMenu;
import flash.utils.Timer;

import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.graphics.codec.PNGEncoder;

NetConnection.defaultObjectEncoding = flash.net.ObjectEncoding.AMF3;
SharedObject.defaultObjectEncoding  = flash.net.ObjectEncoding.AMF3;

public var nc:NetConnection;
public var ns:NetStream;
public var camera:Camera;
public var mic:Microphone;
public var nsOutGoing:NetStream;
[Bindable] public var recorderConfig:Recorder;
public var DEBUG:Boolean=false;
public var recordingTimer:Timer = new Timer( 1000 , 0 );
[Bindable] public var timeLeft:String="";

protected var thumbnailBytes:ByteArray;
protected var customMenuItem:ContextMenuItem;
protected var maxTimer:String = '';

public function init():void {
	recorderConfig = new Recorder(FlexGlobals.topLevelApplication.parameters);

	FlexGlobals.topLevelApplication.width = recorderConfig.width;
	FlexGlobals.topLevelApplication.height = recorderConfig.height;
	
	addContextMenuItems();

	recordingTimer.addEventListener('timer', decrementTimer);

  	nc = new NetConnection();		
	nc.client = this;		
	nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
	nc.connect(recorderConfig.server);

	currentState = 'recorder';
	if ('player' == recorderConfig.mode) {
		currentState = 'player';
	}
}

/*
 Recording functions
 */
protected function recClicked():void { 
	if (recordButton.selected) {
		captureThumbnail();
		recordStart();
	} else {
		recordFinished();
		playback();
	}
}

public function recordStart():void {
	if (outOfTime()) {
		return recordFinished(true);
	}

	recordButton.selected = true;
	nsOutGoing.publish(recorderConfig.fileName, "record");

	recorderConfig.timeLeft = recorderConfig.maxLength;
	maxTimer = formatTime(recorderConfig.maxLength);
	setTimer(recorderConfig.maxLength, maxTimer);
	recordingTimer.start();
}

public function recordFinished(exceeded:Boolean=false):void {
	if (exceeded) {
		Alert.show(recorderConfig.recordingTimeExceededText);
	}
	
	recordingTimer.stop();
	recordButton.selected = false;
	recorderConfig.hasRecorded = true;
	nsOutGoing.close();
}

public function rerecord():void {
	videoPlayer.stop();
	recordButton.selected = false;
	currentState = "recorder";
}

/*
 Playback functions
 */
protected function playback():void {
	currentState = "player";
	var s:String = recorderConfig.server+recorderConfig.fileName+".flv";
	videoPlayer.source = s;
	playPause();
}

protected function playbackPause():void {
	playButton.selected = false;
	videoPlayer.pause();	
}

protected function playbackPlay():void {
	playButton.selected = true;
	videoPlayer.play();
}

protected function playPause():void{
	if (videoPlayer.playing) {
		playbackPause();
	} else {
		playbackPlay();
	}
}

protected function videoIsComplete():void {
	videoPlayer.stop();
}

protected function thumbReleased():void {
	videoPlayer.playheadTime = position.value;
}

protected function rollOut(e:MouseEvent):void {
}

protected function rollOver(e:MouseEvent):void {
} 

protected function netStatusHandler(event:NetStatusEvent):void {
	switch (event.info.code) {
		case "NetConnection.Connect.Failed":
			// FIXME: Translation needed
			Alert.show("ERROR:Could not connect to server.");
			break;	
		case "NetConnection.Connect.Success":
			prepareStreams();
			break;
		default:
			nc.close();
			break;
	}
}

/*
 Timer functions
 */

protected function decrementTimer(event:TimerEvent ):void {

	recorderConfig.timeLeft--;
	setTimer(recorderConfig.timeLeft, maxTimer);
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
	return (recorderConfig.timeLeft <= 0);
}

public function webcamParameters():void {
	Security.showSettings(SecurityPanel.DEFAULT);
}

protected function drawMicLevel(evt:TimerEvent):void {
		var actvity:int = mic.activityLevel;
		micLevel.setProgress(actvity, 100);
}

private function prepareStreams():void {
	nsOutGoing = new NetStream(nc); 
	camera=Camera.getCamera();
	if (camera==null) {
		// FIXME: Translation needed
		Alert.show("Webcam not detected!");
	}

	if (camera.muted) 	{
		Security.showSettings(SecurityPanel.DEFAULT);
	}
	camera.setQuality(recorderConfig.bandwidth,recorderConfig.compression);
	camera.setMode(recorderConfig.width,recorderConfig.height,recorderConfig.fps);
	camera.setKeyFrameInterval(recorderConfig.keyframe);
	webcam.attachCamera(camera);
	nsOutGoing.attachCamera(camera);
	recorderConfig.cameraDetected = true;
	camera.addEventListener(StatusEvent.STATUS, cameraStatus); 

	mic = Microphone.getMicrophone();
	if (mic!=null) {
        mic.rate=recorderConfig.microRate;
        var timer:Timer=new Timer(50);
		timer.addEventListener(TimerEvent.TIMER, drawMicLevel);
		timer.start();
		nsOutGoing.attachAudio(mic);
	}
}
   
protected function cameraStatus(evt:StatusEvent):void {
	switch (evt.code) {
		case "Camera.Muted":
			recorderConfig.cameraDetected=false;
			break;
		case "Camera.Unmuted":
			recorderConfig.cameraDetected=true;
			break;
	}
}

/*
 Thumbnail functions
*/

protected function captureThumbnail():void {
	if (!recorderConfig.thumbnailSaveURL) {
		return;
	}

	var thumbnailData:BitmapData = new BitmapData(recorderConfig.width, recorderConfig.height);
	thumbnailData.draw(webcam);
	var imageEncoder:PNGEncoder = new PNGEncoder();
	thumbnailBytes = imageEncoder.encode(thumbnailData);
}

protected function publishThumbnail():void {
	if (!recorderConfig.thumbnailSaveURL) {
		return;
	}

	var header:URLRequestHeader = new URLRequestHeader("Content-type", "image/jpeg");
	var saveImage:URLRequest = new URLRequest(recorderConfig.thumbnailSaveURL + recorderConfig.fileName);
	saveImage.requestHeaders.push(header);
	saveImage.method = URLRequestMethod.POST;
	saveImage.data = thumbnailBytes;
	
	var urlLoader:URLLoader = new URLLoader();
	urlLoader.load(saveImage);
}

/*
  Save functions
 */

protected function save():void {
	nsOutGoing.close();
	publishThumbnail();
	var jsFunction:String = 'videoRecorder.save("' + recorderConfig.id + '", "' + recorderConfig.fileName + '")';
	ExternalInterface.call(jsFunction);
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

