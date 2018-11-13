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

import QtQuick 2.9
import QtQuick.Controls 1.0
import QtQuick.Controls 2.2 as Controls22
import QtQuick.Layouts 1.0

import org.kde.plasma.core 2.0 as PlasmaCore

import "../../tools/Tools.js" as Tools

Controls22.Popup {
    id: popup
    height: mainColumn.height + 2 * units.largeSpacing

    function textAreaToList(text) {
        var res = text.split("\n");
        return res;
    }

    function listToText(text) {
        var res = text.join("\n");
        return res;
    }

    ColumnLayout{
        id: mainColumn
        width: parent.width
        anchors.margins: units.largeSpacing
        spacing: units.largeSpacing

        Label{
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignHCenter
            font.bold: true
            text: i18n("Application Name Substitutions")
        }

        GridLayout {
            columns: 2
            Label{
                Layout.fillWidth: true
                horizontalAlignment: Qt.AlignHCenter
                font.bold: true
                text: "Search Criteria"
            }
            Label{
                Layout.fillWidth: true
                horizontalAlignment: Qt.AlignHCenter
                font.bold: true
                text: "Replace with"
            }
            TextArea{
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: listToText(root.selectedCriteria)

                onTextChanged: root.selectedCriteria = textAreaToList(text)
            }
            TextArea{
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: listToText(root.selectedReplacements)
                onTextChanged: root.selectedReplacements = textAreaToList(text)
            }
        }

        Label{
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignHCenter
            font.italic: true
            color: "#ff0000"
            text: {
                if (root.selectedCriteria.length !== root.selectedReplacements.length) {
                    return i18n("Warning: Criteria and Replacements do not have the same size...");
                }

                return "";
            }
        }
    }
}
