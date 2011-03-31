<?php

/**
 * Video recorder admin settings form.
 */
function video_recorder_admin() {
  $form = array();

  $form['video_recorder_rtmp_url'] = array(
    '#type' => 'textfield',
    '#title' => t('RTMP URL'),
    '#default_value' => variable_get('video_recorder_rtmp_url', VIDEO_RECORDER_DEFAULT_RTMP_URL),
    '#description' => t("The RTMP URL used for recording the live video streams."),
    '#required' => TRUE,
  );

  $form['video_recorder_http_url'] = array(
    '#type' => 'textfield',
    '#title' => t('HTTP URL'),
    '#default_value' => variable_get('video_recorder_http_url', VIDEO_RECORDER_DEFAULT_HTTP_URL),
    '#description' => t("The HTTP URL used for fetching the recorded video streams."),
    '#required' => TRUE,
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
}
