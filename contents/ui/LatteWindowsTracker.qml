/*
*  Copyright 2019 Michail Vourlakos <mvourlakos@gmail.com>
*
*  This file is part of applet-window-title
*
*  Latte-Dock is free software; you can redistribute it and/or
*  modify it under the terms of the GNU General Public License as
*  published by the Free Software Foundation; either version 2 of
*  the License, or (at your option) any later version.
*
*  Latte-Dock is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.7

Item {
    id: latteWindowsTracker
    readonly property bool existsWindowActive:  latteBridge.windowsTracker.existsWindowActive

    function requestToggleMaximized() {
        latteBridge.windowsTracker.requestToggleMaximized();
    }

    readonly property Item activeTaskItem: Item {
        readonly property string appName: latteBridge.windowsTracker.lastActiveWindow.appName
        readonly property bool isMinimized: latteBridge.windowsTracker.lastActiveWindow.isMinimized
        readonly property bool isMaximized: latteBridge.windowsTracker.lastActiveWindow.isMaximized
        readonly property bool isActive: latteBridge.windowsTracker.lastActiveWindow.isActive
        readonly property bool isOnAllDesktops: latteBridge.windowsTracker.lastActiveWindow.isOnAllDesktops
        property var icon: latteBridge.windowsTracker.lastActiveWindow.icon

        readonly property string lastWindowTitle: latteBridge.windowsTracker.lastActiveWindow.display

        readonly property string title: lastWindowTitle !== "" ? cleanupTitle(lastWindowTitle) : ""
        property string discoveredAppName: ""

        function cleanupTitle(text) {
            var t = text;
            var sep = t.lastIndexOf(" —– ");
            var spacer = 4;

            if (sep === -1) {
                sep = t.lastIndexOf(" -- ");
                spacer = 4;
            }

            if (sep === -1) {
                sep = t.lastIndexOf(" -- ");
                spacer = 4;
            }

            if (sep === -1) {
                sep = t.lastIndexOf(" — ");
                spacer = 3;
            }

            if (sep === -1) {
                sep = t.lastIndexOf(" - ");
                spacer = 3;
            }

            var dTitle = "";
            var dAppName = "";

            if (sep>-1) {
                dTitle = text.substring(0, sep);
                discoveredAppName = text.substring(sep+spacer, text.length);

                if (dTitle === appName) {
                    dTitle = discoveredAppName;
                    discoveredAppName = appName;
                }
            }

            if (sep>-1) {
                return dTitle;
            } else {
                return t;
            }
        }
    }
}

