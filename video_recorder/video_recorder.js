function videoRecorder() {
};

videoRecorder.saveActive = false;

videoRecorder.canSave = function() {
  return videoRecorder.saveActive;
};

videoRecorder.disableSave = function() {
  videoRecorder.saveActive = false;
  $('a.video-recorder-save').addClass('save-disabled');
};

videoRecorder.enableSave = function() {
    videoRecorder.saveActive = true;
    $('a.video-recorder-save').removeClass('save-disabled');
};
  
Drupal.behaviors.videoRecorderAttachActions = function(context) {
  $('a.video-recorder-save:not(processed)', context)
    .each(function() {
      $(this).click(function() {
        if (!videoRecorder.canSave()) {
          return false;
        }

        var elm =$(this),
          references = elm.attr('id').match(/^(.*)-save-(.*)$/),
          recorder = $('#' + references[1] + '.video-recorder'),
          videoId = references[2];
        recorder.trigger('video-saved', [videoId]);
      })
      .addClass('processed');
    });
};
