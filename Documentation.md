(Copied from README.txt until I have something more useful to put here)

## wifi\_monitor basic documentation ##


**overview:**
> This program is used to execute an HTTP(S) POST when associating to a
> particular SSID, ie logging you in through a web authentication system once
> you associate to the campus wifi network.

**installation:**
> Double-click on the install.command file, enter the requested information,
> then provide your password so that the program can be installed in a
> system directory.  The info required is as follows -
    * **SSID**: the particular SSID which you want to take action on when associating to it
    * **login URL**: the URL you want the program to send data to when associating to the selected SSID
    * **POST data**: the POST data you want to send to the login URL when associating to the selected SSID

**uninstallation:**
> Double-click on the uninstall.command file and enter your password.

**usage:**
> The program will launch at each login and run in the background.

**configuration:**
> If you want to change the preferences after installing, run the program
> manually from Terminal like so (the -v option will give extra feedback),
> using only the preference flags you wish to change -
> > `wifi_monitor -v -storePrefs {prefs...} `


> {prefs}=
    * -ssid=SOME\_SSID
    * -login\_url=SOME\_URL
    * -post\_data=SOME\_DATA
    * -interface=enX
    * -ip\_version=X
> Example for changing the SSID to "super\_hax":
> > `wifi_monitor -storePrefs -ssid=super_hax`

> If you need to use an SSID with a space in the name, configure like so:
> > `defaults write com.wifi_monitor SSID "some ssid"`