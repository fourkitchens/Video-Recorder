core = 6.x
api = 2

projects[pressflow][type] = "core"
projects[pressflow][download][type] = "get"
projects[pressflow][download][url] = "http://files.pressflow.org/pressflow-6-current.tar.gz"

projects[admin][version] = 2.0
projects[admin][subdir] = "contrib"

projects[cck][version] = 2.9
projects[cck][subdir] = "contrib"

projects[ctools][version] = 1.8
projects[ctools][subdir] = "contrib"

projects[jquery_ui][version] = 1.4
projects[jquery_ui][subdir] = "contrib"

projects[lightbox2][version] = 1.11
projects[lightbox2][subdir] = "contrib"

; Don't use a later version of modalframe - it breaks stuff
projects[modalframe][version] = "1.6"
projects[modalframe][subdir] = "patched"

; Stop admin being displayed in the modalframe - backported fix
projects[modalframe][patch][admin-fix][url] = "http://209.20.76.162/modalframe-admin.diff"
projects[modalframe][patch][admin-fix][md5] = "45405c28d971bace4408fe57fe5eaa69"

projects[brightcove][type] = "module"
projects[brightcove][download][type] = "git"
projects[brightcove][download][url] = "http://git.drupal.org/project/brightcove.git"
projects[brightcove][download][revision] = "1308219"
projects[brightcove][subdir] = "patched"

projects[ajn][type] = "module"
projects[ajn][download][type] = "git"
projects[ajn][download][url] = "git@github.com:aljazeera/AJ-Sharek.git"
projects[ajn][subdir] = "custom"

libraries[jquery_ui][download][type] = "get"
libraries[jquery_ui][download][url] = "http://jquery-ui.googlecode.com/files/jquery-ui-1.7.zip"
libraries[jquery_ui][directory_name] = "jquery.ui"
libraries[jquery_ui][destination] = "modules/contrib/jquery_ui"

libraries[brightcove][download][type] = "get"
libraries[brightcove][download][url] = "http://download.github.com/BrightcoveOS-PHP-MAPI-Wrapper-2.0.4-0-g237c407.tar.gz"
libraries[brightcove][download][md5] = "fd5640f1db55d66579a1afe8376d6dc3"

