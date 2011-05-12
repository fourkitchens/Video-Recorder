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
//public var nsInGoing:NetStream;
public const ROOMMODEL:String="models";
[Bindable] public var myRecorder:Recorder;
public var DEBUG:Boolean=false;
public var recordingTimer:Timer = new Timer( 1000 , 0 );
[Bindable] public var timeLeft:String="";

protected var thumbnailBytes:ByteArray;

protected var customMenuItem:ContextMenuItem;

public function init():void {
	myRecorder = new Recorder(Application.application.parameters);

	Application.application.width = myRecorder.width;
	Application.application.height = myRecorder.height;

	recordingTimer.addEventListener("timer" , decrementTimer);

	timeLeft = myRecorder.maxLength.toString();
  	nc=new NetConnection();		
	nc.client=this;		
	nc.addEventListener(NetStatusEvent.NET_STATUS,netStatusHandler);
	nc.connect(myRecorder.server);	

	if (myRecorder.mode=="player") {
		currentState="player";
	} else {
		currentState="";
	}
	
	addContextMenuItems();
}

protected function recClicked():void { 
	if (rec_btn.selected) {
		recordingTimer.start();
		captureThumbnail();
		recordStart();
	} else {
		recordingTimer.stop();
		recordFinished();
		publishThumbnail();
	}
}

protected function videoIsComplete():void {
	playPauseBut.selected=true;
	playPause();
}

protected function thumbClicked(e:MouseEvent):void {
	videoPlayer.playheadTime = position.value;	
}

public function stopVideo():void {
	var s:String = myRecorder.server+myRecorder.fileName+".flv";
	videoPlayer.source = s;
	videoPlayer.stop();
	playPauseBut.selected = false;
}

protected function replay():void {
	rec_btn.selected=false;
	recClicked();
	currentState="player";
	var s:String = myRecorder.server+myRecorder.fileName+".flv";
	videoPlayer.source = s;
	// and start the video !
	playPauseBut.selected=false;
	playPause();
}

protected function save():void {
	var jsFunction:String = 'videoRecorder.save("' + myRecorder.id + '", "' + myRecorder.fileName + '")';
	ExternalInterface.call(jsFunction);
}

protected function playPause():void{
	if (playPauseBut.selected) {
		videoPlayer.pause();
	} else {
		videoPlayer.play();
	}
}

protected function thumbPressed():void {
	playPauseBut.selected=true;
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
			Alert.show("ERROR:Could not connect to: "+myRecorder.server);
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
	nsOutGoing.publish(myRecorder.fileName, "record");
	myRecorder.hasRecorded = true;
}

public function recordFinished():void {
	nsOutGoing.close();
}

private  function decrementTimer( event:TimerEvent ):void {
	var minutes:int;
	var seconds:int;
	myRecorder.timeLeft--;
	minutes = myRecorder.timeLeft / 60;
	seconds = myRecorder.timeLeft % 60;
	if (minutes<10) timeLeft="0"+ minutes+":" else timeLeft=minutes+":";
	if (seconds<10) timeLeft=timeLeft+"0"+ seconds else timeLeft=timeLeft+seconds;

	
	// format to display mm:ss format
	if (myRecorder.timeLeft==0) {
		recordFinished();
	}
}

public function webcamParameters():void {
	Security.showSettings(SecurityPanel.DEFAULT);
}

protected function drawMicLevel(evt:TimerEvent):void {
		var ac:int=mic.activityLevel;
		micLevel.setProgress(ac,100);
}

private  function prepareStreams():void {
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
	Alert.show("Event Fired!");
	var URL:URLRequest = new URLRequest('http://drupal.org/project/video_recorder');
	navigateToURL(URL);
}