#################################################################
# 		ReadMe: live service				#
#								#
#################################################################

The live service is an Adobe-built service that lets you stream 
live media to users without writing any code. (Note: this service 
does not support server-side recording or DVR functionality)

Adobe Flash Media Streaming Server only runs Adobe-built services, 
also called "signed" applications.

Adobe Flash Media Interactive Server and Adobe Flash Media 
Development Server support unsigned (user-created) applications. If 
you're using one of these server versions, you can modify the live 
service source code to create your own applications and enable server-
side recording and DVR functionality.

========================================================================
Deploying an unsigned live service 
(Flash Media Interactive Server or Flash Media Development Server only)
========================================================================

To deploy an unsigned version of live service you can either replace 
the existing service, or create a new service:

1. [New Service] Create a new folder in the 
   {FMS-Install-Dir}/applications/ folder.

2. [New Service] (Optional) To make your new folder the default live 
   service, open the file, {FMS-Install-Dir}/conf/fms.ini and edit 
   the LIVE_DIR parameter and point to the new folder you created 
   in step 1.
   
3. [Existing Service] To replace the default Adobe signed 
   live service, first back up the following files from the folder 
   {FMS-Install-Dir}/applications/live: 
   
   * main.far
   * Application.xml
   * allowedHTMLDomains.txt
   * allowedSWFDomains.txt

4. Copy all files from {FMS-Install-Dir}/samples/applications/live to 
   the folder you created in step 1 or to the existing folder, 
   {FMS-Install-Dir}/applications/live.

-------------------------------------------------------------------------

For information about using and configuring the live service, see the 
Developer Guide (flashmediaserver_3.5_dev_guide.pdf) in the 
{FMS-Install-Dir}/documentation folder. 

For information about troubleshooting the live service, see
the Installation Guide (flashmediaserver_3.5_install.pdf) in the same 
location.