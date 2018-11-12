# Window Title Applet

This is a Plasma 5 applet that shows the current window title and icon in your panels. This plasmoid is coming from [Latte land](https://phabricator.kde.org/source/latte-dock/repository/master/) but it can also support Plasma panels.

<p align="center">
<img src="https://i.imgur.com/Zdjshmt.png" width="580"><br/>
<i>Window Title left to Plasma 5 global menu</i>
</p>

<p align="center">
<img src="https://i.imgur.com/jrClIrl.png" width="580"><br/>
<i>Settings window</i>
</p>

# Features

- Four different styles, [Application, Title, Application - Title, Title - Application]
- Support both horizontal and vertical alignments
- Show window icon
- Maximize window icon to applet thickness (optional)
- Bold/Italic font
- Set maximum length in pixels or use all the required space to show all contents
- Set spacing between icon and title
- Left/Right or Top/Bottom margins
- Multi-screen ready
- Double click in order to maximize/restore active window (for plasma panels)
- Show activity name/icon when there is not any active window
- Latte v0.9 ready
  * support new painting
  * support maximize/restore active window
  * support dragging active window from latte panel

# Requires

- Plasma >= 5.8
- KDeclarative (optional)

# Install

This is a QML applet and as such it can be easily installed from Plasma 5 Widgets Explorer or alternative you can execute `plasmapkg2 -i .` in the root directory of the applet.


