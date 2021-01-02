/*
*  Copyright 2020 Michail Vourlakos <mvourlakos@gmail.com>
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

MouseArea {
    id: actionsArea
    acceptedButtons: Qt.LeftButton | Qt.MidButton

    property bool wheelIsBlocked: false

    onClicked: {
        if (existsWindowActive && mouse.button === Qt.MidButton) {
            windowInfoLoader.item.requestClose();
        }
    }

    onDoubleClicked: {
        if (existsWindowActive && mouse.button === Qt.LeftButton) {
            windowInfoLoader.item.toggleMaximized();
        }
    }

    onWheel: {
        if (wheelIsBlocked || !plasmoid.configuration.actionScrollMinimize) {
            return;
        }

        wheelIsBlocked = true;
        scrollDelayer.start();

        var delta = 0;

        if (wheel.angleDelta.y>=0 && wheel.angleDelta.x>=0) {
            delta = Math.max(wheel.angleDelta.y, wheel.angleDelta.x);
        } else {
            delta = Math.min(wheel.angleDelta.y, wheel.angleDelta.x);
        }

        var angle = delta / 8;

        var ctrlPressed = (wheel.modifiers & Qt.ControlModifier);

        if (angle>10) {
            //! upwards
            if (!ctrlPressed) {
                windowInfoLoader.item.activateNextPrevTask(true);
            } else if (windowInfoLoader.item.activeTaskItem
                       && !windowInfoLoader.item.activeTaskItem.isMaximized){
                windowInfoLoader.item.toggleMaximized();
            }
        } else if (angle<-10) {
            //! downwards
            if (!ctrlPressed) {
                if (windowInfoLoader.item.activeTaskItem
                        && !windowInfoLoader.item.activeTaskItem.isMinimized
                        && windowInfoLoader.item.activeTaskItem.isMaximized){
                    //! maximized
                    windowInfoLoader.item.activeTaskItem.toggleMaximized();
                } else if (windowInfoLoader.item.activeTaskItem
                           && !windowInfoLoader.item.activeTaskItem.isMinimized
                           && !windowInfoLoader.item.activeTaskItem.isMaximized) {
                    //! normal
                    windowInfoLoader.item.activeTaskItem.toggleMinimized();
                }
            } else if (windowInfoLoader.item.activeTaskItem
                       && windowInfoLoader.item.activeTaskItem.isMaximized) {
                windowInfoLoader.item.activeTaskItem.toggleMaximized();
            }
        }
    }

    //! A timer is needed in order to handle also touchpads that probably
    //! send too many signals very fast. This way the signals per sec are limited.
    //! The user needs to have a steady normal scroll in order to not
    //! notice a annoying delay
    Timer{
        id: scrollDelayer

        interval: 200
        onTriggered: actionsArea.wheelIsBlocked = false;
    }
}
