package com.fourkitchens
{
	import mx.controls.Alert;
	[Bindable] public class Recorder
	{
		public var maxLength:int=90;
		public var fileName:String="video";
		public var width:int=320;
		public var height:int=240;
		public var server:String="rtmp://127.0.0.1/red5recorder/";
		public var fps:int=15;
		public var microRate:int=22;
		public var showVolume:Boolean=true;
		public var recordingText:String="Recording...";
		public var timeLeft:int;
		public var mode:String="record";
		public var hasRecorded:Boolean=false;
		public var backToRecorder:Boolean=true;
		public var backText:String="Back";
		public var cameraDetected:Boolean=false;
		
		// Drupal module extensions
		public var bandwidth:int=0;
		public var compression:int=70;
		public var id:String='video_recorder';
		public var keyframe:int=30; // every 2 seconds @ 15fps (default)
		public var playText:String="Play";
		public var recText:String="Rec";
		public var recordingTimeExceededText:String = 'Recording stopped. Time exceeded.';
		public var recordTooltipText:String="Start / stop recording";
		public var reviewTooltipText:String="Review recording";
		public var saveText:String="Save";
		public var saveTooltipText:String="Save recording to server";
		public var settingsText:String="Settings";
		public var stopText:String="Stop";
		public var thumbnailSaveURL:String="";
		public var volumeText:String="Volume";
		
		public function Recorder(params:Object):void {
			var option:String,
			key:String,
			options:Array = [
				'backText', 'backToRecorder', 'bandwidth', 'compression', 'fileName', 'fps',
				'height', 'id', 'keyframe', 'maxLength', 'microRate', 'mode', 'playText', 
				'recText', 'recordingTimeExceededText', 'recordingText', 'recordTooltipText',
				'reviewTooltipText', 'saveText', 'saveTooltipText', 'server', 'showVolume',
				'timeLeft', 'width'
			];

			for (option in options) {
				key = options[option];
				if (undefined !== params[key]) {
					this[key] = params[key]; 
				}
			}
			timeLeft = maxLength;
		}
	}
}