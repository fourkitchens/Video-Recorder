<?php

/**
 * Video recorder admin settings form.
 */
function video_recorder_admin() {
  $form = array();

  $form['video_recorder_server'] = array(
    '#type'           => 'fieldset',
    '#title'          => t('Server Settings'),
    '#collapsed'      => FALSE,
    '#collapsible'    => FALSE,
  );
  $form['video_recorder_server']['video_recorder_rtmp_url'] = array(
    '#type'           => 'textfield',
    '#title'          => t('RTMP URL'),
    '#default_value'  => variable_get('video_recorder_rtmp_url', VIDEO_RECORDER_DEFAULT_RTMP_URL),
    '#description'    => t("The RTMP URL used for recording the live video streams."),
    '#required'       => TRUE,
  );
  $form['video_recorder_server']['video_recorder_http_url'] = array(
    '#type'           => 'textfield',
    '#title'          => t('HTTP URL'),
    '#default_value'  => variable_get('video_recorder_http_url', VIDEO_RECORDER_DEFAULT_HTTP_URL),
    '#description'    => t("The HTTP URL used for fetching the recorded video streams."),
    '#required'       => TRUE,
  );

  $form['video_recorder_camera'] = array(
    '#type'           => 'fieldset',
    '#title'          => t('Video Quality Settings'),
    '#collapsed'      => FALSE,
    '#collapsible'    => FALSE,
  );
  $form['video_recorder_camera']['video_recorder_camera_length'] = array(
    '#type'           => 'textfield',
    '#title'          => t('Maximum Video Length'),
    '#default_value'  => variable_get('video_recorder_camera_length', VIDEO_RECORDER_DEFAULT_CAMERA_LENGTH),
    '#description'    => t("The maximum video length, measured in seconds. <br /> <strong>Default is 600, which is 10 minutes.</strong>"),
    '#required'       => TRUE,
  );
  $form['video_recorder_camera']['video_recorder_camera_bandwidth'] = array(
    '#type'           => 'textfield',
    '#title'          => t('Bandwidth Limit'),
    '#default_value'  => variable_get('video_recorder_camera_bandwidth', VIDEO_RECORDER_DEFAULT_CAMERA_BANDWIDTH),
    '#description'    => t("The bandwidth limit for the Flash video recorder. Measured in Bytes per second.<br /> <strong>Set to 0 for unlimited.</strong>"),
    '#required'       => TRUE,
  );
  $form['video_recorder_camera']['video_recorder_camera_compression'] = array(
    '#type'           => 'textfield',
    '#title'          => t('Minimum Compression Quality'),
    '#default_value'  => variable_get('video_recorder_camera_compression', VIDEO_RECORDER_DEFAULT_CAMERA_COMPRESSION),
    '#description'    => t("The minimum compression quality for the Flash video recorder.<br /> <strong>0 is poor; 100 is full quality.</strong>"),
    '#required'       => TRUE,
  );
  $form['video_recorder_camera']['video_recorder_camera_fps'] = array(
    '#type'           => 'select',
    '#title'          => t('Frames Per Second'),
    '#default_value'  => variable_get('video_recorder_camera_fps', VIDEO_RECORDER_DEFAULT_CAMERA_FPS),
    '#description'    => t("Number of frames per second for the the uploaded videos. Higher values produce smoother video."),
    '#options'        => array(
      '12'  => t('12 fps (Low Quality)'),
      '25'  => t('25 fps (Standard Definition PAL TV)'),
      '30'  => t('30 fps (Standard Definition NTSC TV)'),
      '60'  => t('60 fps (HD TV)'),
    ),
    '#required' => TRUE,
  );
  $form['video_recorder_camera']['video_recorder_camera_keyframe'] = array(
    '#type'           => 'select',
    '#title'          => t('Keyframe Interval'),
    '#default_value'  => variable_get('video_recorder_camera_keyframe', VIDEO_RECORDER_DEFAULT_CAMERA_KEYFRAME),
    '#description'    => t("Number of seconds between each keyframe. This setting will remain accurate as you change FPS."),
    '#options'        => array(
      '1'   => t('1 second'),
      '2'   => t('2 seconds'),
      '3'   => t('3 seconds'),
      '5'   => t('5 seconds'),
      '10'  => t('10 seconds'),
    ),
    '#required'       => TRUE,
  );

  return system_settings_form($form);
}

/**
 * Validate user input for video recorder admin.
 */
function video_recorder_admin_validate($form, &$form_state) {
  /*
  TODO work out if this is really needed - skwashd 2011-03-19
  Drupal's valid_url() doesn't support other schemes - http://api.drupal.org/api/drupal/includes--common.inc/function/valid_url/6
  PHP's parse_url doesn't really validate URLs - http://php.net/parse_url
  */

  $rtmp_parts = @parse_url($form_state['values']['video_recorder_rtmp_url']);
  if (!isset($rtmp_parts['scheme']) || 'rtmp' !== $rtmp_parts['scheme']) {
    form_set_error('video_recorder_rtmp_url', t('The URL must use a RTMP scheme'));
  }

  $http_parts = @parse_url($form_state['values']['video_recorder_http_url']);
  if (!isset($http_parts['scheme']) || 'http' !== substr($http_parts['scheme'], 0, 4)
    || !valid_url($form_state['values']['video_recorder_http_url'])){
    form_set_error('video_recorder_http_url', t('The URL must be a valid HTTP URL'));
  }

  if ($form_state['values']['video_recorder_camera_compression'] < 0 || $form_state['values']['video_recorder_camera_compression'] > 100) {
    form_set_error('video_recorder_camera_compression', t('Compression quality must be a number from 0 to 100. '));
  }
}
