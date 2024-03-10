/*
*  Copyright 2018 Michail Vourlakos <mvourlakos@gmail.com>
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

import QtQuick
import QtQuick.Controls
// import QtGraphicalEffects
import QtQuick.Controls as Controls22
import QtQuick.Layouts
import org.kde.kirigami 2.0 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: box

    property QtObject contentItem: null
    property int slideOutFrom: PlasmaCore.Types.TopEdge
    property bool shown: false
    readonly property int availableWidth: width - 2 * 12 - 2 * Kirigami.Units.largeSpacing
    readonly property int availableHeight: contentItem.childrenRect.height + 2 * Kirigami.Units.largeSpacing
    readonly property int maximumHeight: availableHeight + 2 * 12

    function slideIn() {
        if (slideOutFrom === PlasmaCore.Types.TopEdge) {
            height = maximumHeight;
            y = -maximumHeight;
        } else {
            height = maximumHeight;
            y = parent.height;
        }
        opacity = 1;
        shown = true;
    }

    function slideOut() {
        if (slideOutFrom === PlasmaCore.Types.TopEdge) {
            height = 0;
            y = 0;
        } else {
            height = 0;
            y = parent.height;
        }
        opacity = 0;
        shown = false;
    }

    clip: true
    x: parent.width / 2 - width / 2
    /*y: slideOutFrom === PlasmaCore.Types.BottomEdge ? 0
    height: 0*/
    opacity: 0
    onContentItemChanged: {
        if (contentItem)
            contentItem.parent = centralItem;

    }

    SystemPalette {
        id: palette
    }

    Item {
        id: mainElement

        width: parent.width
        height: contentItem ? maximumHeight : 100

        Rectangle {
            // layer.effect: DropShadow {
            //     id: shadowElement
            //     radius: 12
            //     fast: true
            //     samples: 2 * radius
            //     color: palette.shadow
            // }

            id: centralItem

            anchors.fill: parent
            anchors.margins: 12
            color: palette.alternateBase
            border.width: 1
            border.color: palette.mid
            radius: 1
            layer.enabled: true
        }

    }

    Behavior on y {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }

    }

    Behavior on height {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }

    }

    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }

    }

}
