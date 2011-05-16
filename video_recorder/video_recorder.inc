<?php

/**
 * @file Video Recorder common functions.
 */

/**
 * The default RTMP URL for recording the video streams.
 */
define('VIDEO_RECORDER_DEFAULT_RTMP_URL', 'rtmp://localhost/dvr/');

/**
 * The default HTTP URL for fetching recorded video streams.
 */
define('VIDEO_RECORDER_DEFAULT_HTTP_URL', 'http://localhost:8134/live/dvr/');

/**
 * The default bandwidth limit when recording video.
 */
define('VIDEO_RECORDER_DEFAULT_CAMERA_BANDWIDTH', 0);

/**
 * The default compression quality when recording video.
 */
define('VIDEO_RECORDER_DEFAULT_CAMERA_COMPRESSION', 70);

/**
 * Frames per second (FPS) for uploaded videos
 */
define('VIDEO_RECORDER_DEFAULT_CAMERA_FPS', 30);

/**
 * The number of seconds between each keyframe for uploaded videos.
 */
define('VIDEO_RECORDER_DEFAULT_CAMERA_KEYFRAME', 2);

/**
 * The maximum length (in seconds) for uploaded videos.
 */
define('VIDEO_RECORDER_DEFAULT_CAMERA_LENGTH', 600);

/**
 * The height of the video recorder object in pixels.
 */
define('VIDEO_RECORDER_DEFAULT_HEIGHT', 480);

/**
 * The width of the video recorder object in pixels.
 */
define('VIDEO_RECORDER_DEFAULT_WIDTH', 640);

/**
 * The default image cache preset for generating thumbnails.
*/
define('VIDEO_RECORDER_DEFAULT_THUMBNAIL_PRESET', 'brightcove_browser');

/**
 * The path where thumbnail images are stored.
 */
define('VIDEO_RECORDER_THUMBNAIL_PATH', file_directory_path() . '/video_recorder');

/**
 * Registers a video ID with the recorder.
 */
function video_recorder_id_add($video_id) {
  if (!isset($_SESSION['video_recorder']['ids'])
    || !is_array($_SESSION['video_recorder']['ids'])) {
    $_SESSION['video_recorder']['ids'] = array();
  }

  $_SESSION['video_recorder']['ids'][$video_id] = TRUE;
}

/**
 * Generates a unique video identifier.
 */
function video_recorder_id_generate() {
  $id = sha1(video_recorder_random_bytes(128));
  video_recorder_id_add($id);
  return $id;
}

/**
 * Removes a video from the known ID list.
 */
function video_recorder_id_remove($video_id) {
  if (!empty($_SESSION['video_recorder']['ids'])) {
    unset($_SESSION['video_recorder']['ids']);
  }
}

/**
 * Verify that a video ID is legitimate.
 */
function video_recorder_id_verify($video_id) {
  return isset($_SESSION['video_recorder']['ids'][$video_id])
    && $_SESSION['video_recorder']['ids'][$video_id];
}

/**
 * Fetch the HTTP playback URL for a video.
 */
function video_recorder_playback_http_url($video_id) {
  $http_url = variable_get('video_recorder_http_url', VIDEO_RECORDER_DEFAULT_HTTP_URL);
  $url = check_plain($http_url . $video_id . '.flv');
  return $url;
}

/**
 * Fetch the RTMP playback URL for a video.
 */
function video_recorder_playback_rtmp_url($video_id) {
  $rtmp_url = variable_get('video_recorder_rtmp_url', VIDEO_RECORDER_DEFAULT_RTMP_URL);
  $url = check_plain($rtmp_url . $video_id);
  return $url;
}

/**
 * Fetches the file system path for the thumbnail image
 */
function video_recorder_thumbnail_path($video_id) {
  $path = VIDEO_RECORDER_THUMBNAIL_PATH . "/thumb-{$video_id}.png";
  return $path;
}

/**
 * Deletes a file from the filesystem.
 */
function video_recorder_thumbnail_delete($video_id) {
  $path = VIDEO_RECORDER_THUMBNAIL_PATH . "/thumb-{$video_id}.png";
  $deleted = file_delete($path);
  return $deleted;
}

/**
 * Saves image data as a thumbnail.
 */
function video_recorder_thumbnail_save($video_id, $image_data) {
  $dir = VIDEO_RECORDER_THUMBNAIL_PATH;
  file_check_directory($dir, FILE_CREATE_DIRECTORY);

  $path = video_recorder_thumbnail_path($video_id);
  $result = (0 !== file_save_data($image_data, $path, FILE_EXISTS_REPLACE));

  return $result;
}

/**
 * Fetches the URL for the thumbnail image.
 */
function video_recorder_thumbnail_url($video) {
  $path = video_recorder_thumbnail_path($video);
  $preset = variable_get('video_recorder_thumbnail_preset', VIDEO_RECORDER_DEFAULT_THUMBNAIL_PRESET);
  $url = imagecache_create_url($preset, $path);
  return $url;
}

/**
 * Returns a string of highly randomized bytes (over the full 8-bit range).
 *
 * This function is better than simply calling mt_rand() or any other built-in
 * PHP function because it can return a long string of bytes (compared to < 4
 * bytes normally from mt_rand()) and uses the best available pseudo-random source.
 *
 * Copied verbatim from drupal_random_bytes() from D7
 *  @link http://api.drupal.org/api/drupal/includes--bootstrap.inc/function/drupal_random_bytes/7
 *
 * @param $count
 *   The number of characters (bytes) to return in the string.
 */
function video_recorder_random_bytes($count) {
  // $random_state does not use drupal_static as it stores random bytes.
  static $random_state, $bytes;
  // Initialize on the first call. The contents of $_SERVER includes a mix of
  // user-specific and system information that varies a little with each page.
  if (!isset($random_state)) {
    $random_state = print_r($_SERVER, TRUE);
    if (function_exists('getmypid')) {
      // Further initialize with the somewhat random PHP process ID.
      $random_state .= getmypid();
    }
    $bytes = '';
  }
  if (strlen($bytes) < $count) {
    // /dev/urandom is available on many *nix systems and is considered the
    // best commonly available pseudo-random source.
    if ($fh = @fopen('/dev/urandom', 'rb')) {
      // PHP only performs buffered reads, so in reality it will always read
      // at least 4096 bytes. Thus, it costs nothing extra to read and store
      // that much so as to speed any additional invocations.
      $bytes .= fread($fh, max(4096, $count));
      fclose($fh);
    }
    // If /dev/urandom is not available or returns no bytes, this loop will
    // generate a good set of pseudo-random bytes on any system.
    // Note that it may be important that our $random_state is passed
    // through hash() prior to being rolled into $output, that the two hash()
    // invocations are different, and that the extra input into the first one -
    // the microtime() - is prepended rather than appended. This is to avoid
    // directly leaking $random_state via the $output stream, which could
    // allow for trivial prediction of further "random" numbers.
    while (strlen($bytes) < $count) {
      $random_state = hash('sha256', microtime() . mt_rand() . $random_state);
      $bytes .= hash('sha256', mt_rand() . $random_state, TRUE);
    }
  }
  $output = substr($bytes, 0, $count);
  $bytes = substr($bytes, $count);
  return $output;
}
