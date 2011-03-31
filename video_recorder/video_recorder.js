Drupal.behaviors.videoRecorderAttachActions = function(context) {
  $('a.video-recorder-save:not(processed)', context)
    .each(function() {
      $(this).click(function() {
        var elm =$(this),
          references = elm.attr('id').match(/^(.*)-save-(.*)$/),
          recorder = $('#' + references[1] + '.video-recorder'),
          videoId = references[2];
        recorder.trigger('video-saved', [videoId]);
      })
      .addClass('processed');
    });
};
