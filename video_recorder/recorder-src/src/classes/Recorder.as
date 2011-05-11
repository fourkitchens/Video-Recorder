package classes
{
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
		public var timeLeftText:String="Time Left:";
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
		public var recordTooltipText:String="Start / stop recording";
		public var reviewTooltipText:String="Review recording";
		public var saveText:String="Save";
		public var saveTooltipText:String="Save recording to server";
		public var settingsText:String="Settings";
		public var stopText:String="Stop";
		public var thumbnailSaveURL:String="";
		public var volumeText:String="Volume";
		
		public function Recorder()
		{	timeLeft = maxLength;
			mode="record";
			/*this.maxLength = maxLength;
			this.fileName = fileName;
			this.width = width;
			this.height = height;
			this.server = server;*/
		}
	}
}
