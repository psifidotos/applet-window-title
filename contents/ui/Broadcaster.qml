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

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item{
    id: broadcaster

    property bool hiddenFromBroadcast: false

    readonly property bool showAppMenuEnabled: plasmoid.configuration.showAppMenuOnMouseEnter
    property bool appMenuRequestsCooperation: false
    property bool menuIsPresent: false

    readonly property bool cooperationEstablished: appMenuRequestsCooperation && isActive
    readonly property bool isActive: plasmoid.configuration.appMenuIsPresent && showAppMenuEnabled

    function sendMessage() {
        if (cooperationEstablished && menuIsPresent) {
            broadcasterDelayer.start();
        }
    }

    function cancelMessage() {
        if (cooperationEstablished) {
            broadcasterDelayer.stop();
        }
    }

    Component.onDestruction: {
        if (latteBridge) {
            latteBridge.actions.broadcastToApplet("org.kde.windowappmenu", "setCooperation", false);
        }
    }

    onCooperationEstablishedChanged: {
        if (!cooperationEstablished) {
            broadcaster.hiddenFromBroadcast = false;
        }
    }

    onIsActiveChanged: {
        if (latteBridge) {
            latteBridge.actions.broadcastToApplet("org.kde.windowappmenu", "setCooperation", isActive);
        }
    }

    Connections {
        target: latteBridge
        onBroadcasted: {
            //console.log(" BROADCASTED FROM APPMENU ::: " + action + " : " + value);

            if (action === "setVisible") {
                if (value === true) {
                    broadcaster.hiddenFromBroadcast = false;
                } else {
                    broadcaster.hiddenFromBroadcast = true;
                }
            } else if (action === "isPresent") {
                plasmoid.configuration.appMenuIsPresent = value;
            } else if (action === "menuIsPresent") {
                broadcaster.menuIsPresent = value;
            } else if (action === "setCooperation") {
                broadcaster.appMenuRequestsCooperation = value;
            }
        }
    }

    Timer{
        id: broadcasterDelayer
        interval: 5
        onTriggered: {
            if (latteBridge) {
                if (broadcasterMouseArea.realContainsMouse && existsWindowActive) {
                    broadcaster.hiddenFromBroadcast = true;
                    latteBridge.actions.broadcastToApplet("org.kde.windowappmenu", "setVisible", true);
                } else {
                    broadcaster.hiddenFromBroadcast = false;
                    latteBridge.actions.broadcastToApplet("org.kde.windowappmenu", "setVisible", false);
                }
            }
        }
    }

    //!!!! MouseArea for Broadcaster
    MouseArea{
        id: broadcasterMouseArea
        anchors.fill: parent
        visible: broadcaster.cooperationEstablished && broadcaster.menuIsPresent
        hoverEnabled: true
        propagateComposedEvents: true

        property int mouseAX: -1
        property int mouseAY: -1

        //! HACK :: For some reason containsMouse breaks in some cases
        //! this hack is used in order to be sure when the mouse is really
        //! inside the MouseArea or not
        readonly property bool realContainsMouse: mouseAX !== -1 || mouseAY !== -1

        onContainsMouseChanged: {
            mouseAX = -1;
            mouseAY = -1;
        }

        onMouseXChanged: mouseAX = mouseX;
        onMouseYChanged: mouseAY = mouseY;

        onRealContainsMouseChanged: {
            if (broadcaster.cooperationEstablished) {
                if (realContainsMouse) {
                    broadcaster.sendMessage();
                } else {
                    broadcaster.cancelMessage();
                }
            }
        }

        onPressed: {
            mouse.accepted = false;
        }

        onReleased: {
            mouse.accepted = false;
        }
    }

}
