To start using the video recorder module install it like any other module
then visit admin/settings/video_recorder to configure the flasg server ports.
You must have a working flash media server to use this module.

The remainder of this file explains how to set a flash server up if you
don't already have one running.  The open source red5 server is adequate 
for most use cases and is a lot cheaper than the Adobe FMS.

This document is formatted using Markdown.

## Red5 Media Server

Red5 is an open source Flash media server, released under the terms of the 
LGPL.  It is written in Java and can be as a standalone server or in a 
container under Tomcat or Jetty.  For local development work the quickest 
way to get up and running is to use the standalone version.  These 
instructions cover the standalone version under Linux. OSX and Windows 
are also supported.

*   Download the Red5 tarball from
    <http://trac.red5.org/downloads/1_0/red5-1.0.0-RC1.tar.gz>

*   Extract tarball somewhere sane

*   Download the Record project from
    <http://garagetech.googlecode.com/files/Recorder.zip>

*   Extract the Record.zip

*   Change into the Record directory

*   Run `ant`

*   Copy the ./web/ directory to /path/to/red5-1.0.0/webapps/recorder 
    (note the name change for the directory)

*   `cd /path/to/red5-1.0.0/`

*   Run `./red5.sh`

*   Wait for the server to startup

*   To verify the server is listening on the right ports, in another
    terminal run "netstat -tlnp | grep java", the output should be similar 
    to this:

<pre>
    tcp6   0   0 :::48669    :::*   LISTEN      1234/java
    tcp6   0   0 :::1935     :::*   LISTEN      1234/java
    tcp6   0   0 :::9999     :::*   LISTEN      1234/java
    tcp6   0   0 :::5080     :::*   LISTEN      1234/java
</pre>

*   The red5 server page should be displayed if you point your browser 
    at <http://example.com:5080/>

The RTMP URL for recording streams using the recorder is 
rtmp://example.com/recorder/ Subdirectories are permitted
and streams will be saved in the subdirectory.

The HTTP playback URL is 
<http://localhost:5080/recorder/streams/[video-id].flv>  The .flv extension 
is appended to the file name of the video stream recorded, it is not need for 
RTMP playback.  If a subdirectory is specified in the path, the HTTP URL 
would be <http://localhost:5080/recorder/streams/[subdir]/[video-id].flv>

## Adobe Flash Development Server 4

AFMS is developed by Adobe. It is an expensive proprietary Flash server, but
Adobe throws some crumbs to developers via the crippled developer edition. To
install this awful piece of software follow these steps:

*   Visit the <http://http://www.adobe.com/go/tryflashmediaserver>
    and start jumping through the registration hoops

*   Once you have downloaded FlashMediaServer_4_all.zip, (all 450Mb of it), 
    unzip it

*   Extract either the FlashMediaServer4.tar.gz (i386) or 
    FlashMediaServer4_x64.tar.gz (amd64) tarballs from the 
    FlashMediaServer_4_all/FlashMediaServer_4_all/linux/ directory

*   cd /path/to/extracted/tarball/FMS_4_0_0_r1121

*   Run `./installFMS` to start the installer

*   Answer the questions as best you can - if in doubt go with the defaults

*   Unzip /opt/adobe/fms/applications/live/main.far

*   Copy the contents of the far file to /opt/adobe/fms/applications/recorder

*   Change the value of `<StreamRecord override="no">false</StreamRecord>`
    in /opt/adobe/fms/applications/recorder/Application.xml to true

*   Merge the contents of /opt/adobe/fms/applications/live/Application.xml into
    /opt/adobe/fms/applications/recorder/Application.xml

*   The recorder application can't be distributed in source or binary due to
    Adobe's restrictive licensing policies. Contact dave@fourkitchens.com
    if you wish to collaborate on a clean room implementation.

*   Start the server by running `cd /opt/adobe/fms; sudo ./server start`

*   Run `sudo netstat -tlnp | grep fms` and the output shoould be similar to:

<pre>
    tcp    0   0 0.0.0.0:8800      0.0.0.0:*    LISTEN      3456/fmsedge
    tcp    0   0 127.0.0.1:11110   0.0.0.0:*    LISTEN      4567/fmsadmin
    tcp    0   0 0.0.0.0:1935      0.0.0.0:*    LISTEN      3456/fmsedge
    tcp    0   0 127.0.0.1:19350   0.0.0.0:*    LISTEN      3456/fmsedge
    tcp    0   0 0.0.0.0:1111      0.0.0.0:*    LISTEN      4567/fmsadmin
</pre>

**changes might need to be made to conf/fms.ini which I have forgotten about**
