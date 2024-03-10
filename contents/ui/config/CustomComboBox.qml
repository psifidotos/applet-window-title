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
import QtQuick.Controls as Controls22
import QtQuick.Layouts

Controls22.ComboBox {
    id: combobox

    property var choices: []

    signal choiceClicked(int index)

    Layout.minimumWidth: 270
    Layout.preferredWidth: 350
    Layout.maximumWidth: 0.3 * root.width
    model: choices

    Connections {
        target: popup
        onClosed: root.forceActiveFocus()
    }

    delegate: MouseArea {
        width: combobox.width
        height: combobox.height
        hoverEnabled: true
        onClicked: {
            combobox.currentIndex = index;
            combobox.choiceClicked(index);
            combobox.popup.close();
        }

        Rectangle {
            id: delegateBackground

            readonly property color selectedColor: Qt.rgba(palette.highlight.r, palette.highlight.g, palette.highlight.b, 0.5)

            anchors.fill: parent
            color: {
                if (containsMouse)
                    return palette.highlight;

                if (combobox.currentIndex === index)
                    return selectedColor;

                return "transparent";
            }

            Label {
                id: label

                anchors.left: parent.left
                anchors.leftMargin: units.smallSpacing
                anchors.verticalCenter: parent.verticalCenter
                text: choices[index]
                color: containsMouse ? palette.highlightedText : palette.text
            }

        }

    }

}
