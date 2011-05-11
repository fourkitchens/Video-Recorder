function videoRecorder() {
};

videoRecorder.save = function(id, fileName) {
  $('#' + id).trigger('video-saved', [fileName]);
};
