# containerdesktop
The main container around the VCDE stack (Github rayvtoll/vcde).

This container has a Windows Look & Feel but runs Linux LXDE with a different window manager (Metacity). 
You can access the container desktop in a browser. It is using the Guacamole protocol to do so. 
Some applications (LibreOffice and Firefox) are additional containers that will launch automatically if needed and are displayed by forwarding X through SSH.
