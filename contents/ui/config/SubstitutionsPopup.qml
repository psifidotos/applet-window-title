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

SlidingBox {
    id: popup
    width: Tools.qBound(400, 0.6*page.width, 750)

    property QtObject page: null

    function textAreaToList(text) {
        var res = text.split("\n");
        return res;
    }

    function listToText(text) {
        var res = text.join("\n");
        return res;
    }

    contentItem: ColumnLayout{
        id: mainColumn
        width: popup.availableWidth
        anchors.margins: units.largeSpacing
        anchors.centerIn: parent
        spacing: units.largeSpacing

        Label{
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignHCenter
            font.bold: true
            text: i18n("Substitutions")
        }

        GridLayout {
            columns: 2
            Label{
                Layout.fillWidth: true
                horizontalAlignment: Qt.AlignHCenter
                font.bold: true
                text: "Match"
            }
            Label{
                Layout.fillWidth: true
                horizontalAlignment: Qt.AlignHCenter
                font.bold: true
                text: "Replace with"
            }
            TextArea{
                id: textAreaMatch

                Layout.fillWidth: true
                Layout.fillHeight: true
                text: listToText(page.selectedMatches)

                onTextChanged: page.selectedMatches = popup.textAreaToList(text)

                flickableItem.onContentYChanged: {
                  textAreaReplace.flickableItem.contentY = flickableItem.contentY
                }
            }
            TextArea{
                id: textAreaReplace

                Layout.fillWidth: true
                Layout.fillHeight: true
                text: listToText(page.selectedReplacements)
                onTextChanged: page.selectedReplacements = popup.textAreaToList(text)

                flickableItem.onContentYChanged: {
                  textAreaMatch.flickableItem.contentY = flickableItem.contentY
                }
            }
        }

        Label{
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignHCenter
            font.italic: true
            color: "#ff0000"
            text: {
                if (page.selectedMatches.length !== page.selectedReplacements.length) {
                    return i18n("Warning: Matches and Replacements do not have the same size...");
                }

                return "";
            }
        }
    }
}
