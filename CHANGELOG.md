### CHANGELOG

#### Version 0.7.1

* elide title in the middle of text
* change window title dash to n-dash

#### Version 0.7.0

* small fixes all around the stack
* fixes for unity-mode in latte panels

#### Version 0.6.0

* support more window actions with mouse:
  - Double Left Click : Maximize/restore active window
  - Middle Click : Close active window
  - Scroll up : Cycle between tasks
  - Scroll down : Minimize tasks
  - Ctrl + Scroll up : Maximize active window (this is also possible with double left click)
  - Ctrl + Scroll down : Restore active window from maximized state
  
* add a placeholder-text option to be shown when no window is visible and the user does not want the current Activity name to be drawn
* option to disable the title tooltip

#### Version 0.5.2

* fix bold font kerning issues

#### Version 0.5.1

* improve window title discovery for flatpaks 
* do not show empty window title when there are information from the application

#### Version 0.5.0

* use Latte Windows Tracking interface when in Latte v0.9
* do not use icon size in computations when icon is not visible
* do not draw Application Name/Window Title separator when any of these two could not be retrieved

#### Version 0.4.1

* improve signaling for Broadcaster
* close ComboBox popup after selecting an item
* add some debug messages

#### Version 0.4

* dont elide if there is free space in the panel
* improve metrics and calculations for better visual results
* support Unity behavior when used with Window AppMenu 0.4 in latest Latte master
* update Appearance settings

#### Version 0.3

* improve defaults and behavior for Latte edit mode
* elide text if applet exceeds panel space
* elide only title when needed
* improvements for settings window
* synchronize scrolling for substitutions elements
* support new Latte Communicator mechanism from Latte git version

#### Version 0.2

* Fifth Text Style, "Do not show any text"
* Font option to capitalize first letters
* Multi-screen aware in order to locate active window in the current screen or at all screens
* Support user-set maximum icon size
* Double click to maximize/restore active window (for plasma panels)
* Option to hide Activity information when no window is active
* Split settings to Appearance and Behavior
* Show tooltip when hovering to provide more information
* Support Application Name substitutions in Behavior settings page

#### Version 0.1

* Four different text styles, [Application, Title, Application - Title, Title - Application]
* Support both horizontal and vertical alignments
* Show window icon
* Maximize window icon to applet thickness (optional)
* Bold/Italic font
* Set maximum length in pixels or use all the required space to show all contents
* Set spacing between icon and title
* Left/Right or Top/Bottom margins
* Multi-screen ready
* Show activity name/icon when there is not any active window
* Double click in order to maximize/restore active window (for plasma panels)
* Latte v0.9 ready
  * support new painting
  * support maximize/restore active window
  * support dragging active window from latte panel
