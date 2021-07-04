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
    readonly property bool existsWindowActive: selectedTracker.lastActiveWindow.isValid && !activeTaskItem.isMinimized
    readonly property bool existsWindowShown: selectedTracker.lastActiveWindow.isValid && !activeTaskItem.isMinimized

    readonly property QtObject selectedTracker: plasmoid.configuration.filterByScreen ? latteBridge.windowsTracker.currentScreen : latteBridge.windowsTracker.allScreens

    readonly property Item activeTaskItem: Item {
        id: taskInfoItem
        readonly property bool isMinimized: selectedTracker.lastActiveWindow.isMinimized
        readonly property bool isMaximized: selectedTracker.lastActiveWindow.isMaximized
        readonly property bool isActive: selectedTracker.lastActiveWindow.isActive
        readonly property bool isOnAllDesktops: selectedTracker.lastActiveWindow.isOnAllDesktops
        readonly property bool isKeepAbove: selectedTracker.lastActiveWindow.isKeepAbove

        readonly property bool isClosable: selectedTracker.lastActiveWindow.hasOwnProperty("isClosable") ? selectedTracker.lastActiveWindow.isClosable : true
        readonly property bool isMinimizable: selectedTracker.lastActiveWindow.hasOwnProperty("isMinimizable") ? selectedTracker.lastActiveWindow.isMinimizable : true
        readonly property bool isMaximizable: selectedTracker.lastActiveWindow.hasOwnProperty("isMaximizable") ? selectedTracker.lastActiveWindow.isMaximizable : true
        readonly property bool isVirtualDesktopsChangeable: selectedTracker.lastActiveWindow.hasOwnProperty("isVirtualDesktopsChangeable") ?
                                                                selectedTracker.lastActiveWindow.isVirtualDesktopsChangeable : true

        readonly property int winId: selectedTracker.lastActiveWindow.hasOwnProperty("winId") ? selectedTracker.lastActiveWindow.winId : -1


        //! appname / title
        property var icon: selectedTracker.lastActiveWindow.icon

        readonly property string appName: modelAppName !== ""  ? modelAppName : discoveredAppName
        readonly property string modelAppName: selectedTracker.lastActiveWindow.appName
        readonly property string modelDisplay: selectedTracker.lastActiveWindow.display

        property string title: ""
        property string discoveredAppName: ""

        function cleanupTitle() {
            var text = modelDisplay;
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

                //if title starts with application name, swap the found records
                if (dTitle.startsWith(modelAppName)) {
                    var firstPart = dTitle;
                    dTitle = discoveredAppName;
                    discoveredAppName = firstPart;
                }
            }

            if (sep>-1) {
                title = dTitle;
            } else {
                title = t;
            }
        }

        onModelAppNameChanged: taskInfoItem.cleanupTitle()
        onModelDisplayChanged: taskInfoItem.cleanupTitle()
        Component.onCompleted: taskInfoItem.cleanupTitle()
    }

    function toggleMaximized() {
        selectedTracker.lastActiveWindow.requestToggleMaximized();
    }

    function toggleMinimized() {
        selectedTracker.lastActiveWindow.requestToggleMinimized();
    }

    function toggleClose() {
        selectedTracker.lastActiveWindow.requestClose();
    }

    function togglePinToAllDesktops() {
        selectedTracker.lastActiveWindow.requestToggleIsOnAllDesktops();
    }

    function toggleKeepAbove(){
        selectedTracker.lastActiveWindow.requestToggleKeepAbove();
    }
}

