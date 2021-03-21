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
    property bool menuIsPresent: false
    property var appMenusRequestCooperation: []
    property int appMenusRequestCooperationCount: 0

    readonly property bool cooperationEstablished: appMenusRequestCooperationCount>0 && isActive
    readonly property bool isActive: plasmoid.configuration.appMenuIsPresent && showAppMenuEnabled && (plasmoid.formFactor === PlasmaCore.Types.Horizontal)

    readonly property int sendActivateAppMenuCooperationFromEditMode: plasmoid.configuration.sendActivateAppMenuCooperationFromEditMode

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

    Component.onDestruction: broadcoastCooperationRequest(false)

    onIsActiveChanged: {
        if (!isActive) {
            hiddenFromBroadcast = false;
        }

        broadcoastCooperationRequest(isActive)
    }

    onCooperationEstablishedChanged: {
        if (!cooperationEstablished) {
            broadcaster.hiddenFromBroadcast = false;
        }
    }

    onSendActivateAppMenuCooperationFromEditModeChanged: {
        if (plasmoid.configuration.sendActivateAppMenuCooperationFromEditMode >= 0) {
            var values = {
                appletId: plasmoid.id,
                cooperation: plasmoid.configuration.sendActivateAppMenuCooperationFromEditMode
            };

            latteBridge.actions.broadcastToApplet("org.kde.windowappmenu",
                                                  "activateAppMenuCooperationFromEditMode",
                                                  values);

            releaseSendActivateAppMenuCooperation.start();
        }
    }

    function broadcoastCooperationRequest(enabled) {
        if (latteBridge) {
            var values = {
                appletId: plasmoid.id,
                cooperation: enabled
            };
            latteBridge.actions.broadcastToApplet("org.kde.windowappmenu", "setCooperation", values);
        }
    }

    Connections {
        target: latteBridge
        onBroadcasted: {
            var updateAppMenuCooperations = false;

            if (broadcaster.cooperationEstablished) {
                if (action === "setVisible") {
                    if (value === true) {
                        broadcaster.hiddenFromBroadcast = false;
                    } else {
                        broadcaster.hiddenFromBroadcast = true;
                    }
                } else if (action === "menuIsPresent") {
                    broadcaster.menuIsPresent = value;
                }
            }

            if (action === "isPresent") {
                plasmoid.configuration.appMenuIsPresent = value;
            } else if (action === "setCooperation") {
                updateAppMenuCooperations = true;
            } else if (action === "activateWindowTitleCooperationFromEditMode") {
                plasmoid.configuration.showAppMenuOnMouseEnter = value.cooperation;
                updateAppMenuCooperations = true;
            }

            if (updateAppMenuCooperations) {
                var indexed = broadcaster.appMenusRequestCooperation.indexOf(value.appletId);
                var isFiled = (indexed >= 0);

                if (value.cooperation && !isFiled) {
                    broadcaster.appMenusRequestCooperation.push(value.appletId);
                    broadcaster.appMenusRequestCooperationCount++;
                } else if (!value.cooperation && isFiled) {
                    broadcaster.appMenusRequestCooperation.splice(indexed, 1);
                    broadcaster.appMenusRequestCooperationCount--;
                }
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

    Timer {
        id: releaseSendActivateAppMenuCooperation
        interval: 50
        onTriggered: plasmoid.configuration.sendActivateAppMenuCooperationFromEditMode = -1;
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
