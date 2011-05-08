Drupal.behaviors.brightcoveRecorderAttachActions = function(context) {
  $('input.brightcove-recorder-record-button:not(.processed)', context)
    .each(function() {
      $(this).click(function() {
        var button = $(this),
          idParts = button.attr('id').match(/edit-(.+)-(\d+)-record-(.+)/),
          fieldName = idParts[1],
          delta = idParts[2],
          videoId = idParts[3],
          rerecord = Drupal.t('Rerecord');
        if (button.val() == rerecord) {
          var input = $('#edit-' + fieldName + '-' + delta + '-video-id'),
            brightcoveId = input.val().match(/\[id:(\d+)\]/);
          if (null !== brightcoveId && brightcoveId.length) {
            var requestURL = Drupal.settings.basePath + 'brightcove_recorder/delete/' + brightcoveId[1] + '/' + videoId;
            $.post(requestURL, '', function(data) {});
          }
          $('#brightcove-recorder-thumbnail-' + videoId).html('');
          input.val('');
        }
        Drupal.modalFrame.open({url: Drupal.settings.basePath + 'video_recorder/record/popup/' + videoId, width: 700});
        button.val(rerecord);
        return false;
      })
      .addClass('processed');
    });

  $('object.video-recorder:not(processed)', context)
    .each(function() {
      $(this).bind('video-saved', {}, function(e, data) {
        var elm = $(this),
	  videoId = data,
	  requestURL = Drupal.settings.basePath + 'brightcove_recorder/upload/' + videoId;
          $('.throbber').show();
	  $.post(requestURL, '', function(data) {
	    if (data.brightcove_id) {
	      var input = $('input.brightcove-video-' + videoId, window.parent.document),
                thumbnail = $('#brightcove-recorder-thumbnail-' + videoId, window.parent.document);
	      input.val('[id:' + data.brightcove_id + ']');
              thumbnail.html('<img src="' + Drupal.settings.basePath + 'video_recorder/thumbnail/' + videoId + '"/>');
	      window.parent.Drupal.modalFrame.close();
	      return false;
	    }
	    window.alert(Drupal.t('Unable to save video. Please try again'));
            $('.throbber').hide();
            return false;
	  }, 'json');
      })
      .addClass('processed');
    });
};
