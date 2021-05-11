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
import QtQuick.Layouts 1.0

import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.kirigami 2.4 as Kirigami

Item {
    id: behaviorPage

    property alias cfg_filterByScreen: filterByScreenChk.checked
    property alias cfg_filterActivityInfo: filterActivityChk.checked

    property alias cfg_showAppMenuOnMouseEnter: showAppMenuChk.checked
    property alias cfg_showTooltip: showTooltip.checked
    property alias cfg_actionScrollMinimize: cycleMinimizeChk.checked

    property alias cfg_subsMatch: behaviorPage.selectedMatches
    property alias cfg_subsReplace: behaviorPage.selectedReplacements

    property alias cfg_placeHolder: placeHolder.text

    // used as bridge to communicate properly between configuration and ui
    property var selectedMatches: []
    property var selectedReplacements: []

    // used from the ui
    readonly property real centerFactor: 0.3
    readonly property int minimumWidth: 220

    ColumnLayout {
        id:mainColumn
        spacing: units.largeSpacing
        width:parent.width - anchors.leftMargin * 2
        height: parent.height
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 2

        GridLayout {
            columns: 2

            Label{
                Layout.minimumWidth: Math.max(centerFactor * behaviorPage.width, minimumWidth)
                text: i18n("Filters:")
                horizontalAlignment: Text.AlignRight
            }

            CheckBox{
                id: filterByScreenChk
                text: i18n("Show only window information from current screen")
            }
        }

        GridLayout {
            columns: 2

            Label{
                Layout.minimumWidth: Math.max(centerFactor * behaviorPage.width, minimumWidth)
                text: i18n("Mouse:")
                horizontalAlignment: Text.AlignRight
            }

            CheckBox{
                id: showTooltip
                text: i18n("Show tooltip on hover")
                enabled: showAppMenuChk.visible && !showAppMenuChk.checked
            }

            Label{
                visible: showAppMenuChk.visible
                enabled: showAppMenuChk.enabled
            }

            CheckBox{
                id: showAppMenuChk
                text: i18n("Show Window AppMenu applet on enter")
                visible: plasmoid.configuration.containmentType === 2 /*Latte Containment*/
                enabled: plasmoid.configuration.appMenuIsPresent
            }

            Label{
                visible: cycleMinimizeChk.visible
            }

            CheckBox {
                id: cycleMinimizeChk
                text: i18n("Scroll to cycle and minimize through your tasks")
                visible: plasmoid.configuration.containmentType === 1 /*Plasma Containment*/
            }
        }

        Kirigami.InlineMessage {
            id: inlineMessage
            Layout.fillWidth: true
            Layout.bottomMargin: 5

            type: Kirigami.MessageType.Warning
            text: cfg_showAppMenuOnMouseEnter ?
                      i18n("Would you like <b>also to activate</b> that behavior to surrounding Window AppMenu?") :
                      i18n("Would you like <b>also to deactivate</b> that behavior to surrounding Window AppMenu?")

            actions: [
                Kirigami.Action {
                    icon.name: "dialog-yes"
                    text: i18n("Yes")
                    onTriggered: {
                        plasmoid.configuration.sendActivateAppMenuCooperationFromEditMode = cfg_showAppMenuOnMouseEnter;
                        inlineMessage.visible = false;
                    }
                },
                Kirigami.Action {
                    icon.name: "dialog-no"
                    text: "No"
                    onTriggered: {
                        inlineMessage.visible = false;
                    }
                }
            ]

            readonly property bool showWindowAppMenuTouched: showAppMenuChk.checked !== plasmoid.configuration.showAppMenuOnMouseEnter

            onShowWindowAppMenuTouchedChanged: {
                if (plasmoid.configuration.containmentType !== 2 /*Latte Containment*/) {
                    visible = false;
                    return;
                }

                if (showWindowAppMenuTouched){
                    inlineMessage.visible = true;
                } else {
                    inlineMessage.visible = false;
                }
            }
        }

        GridLayout {
            columns: 2
            Label{
                Layout.minimumWidth: Math.max(centerFactor * behaviorPage.width, minimumWidth)
                text: i18n("Placeholder:")
                horizontalAlignment: Text.AlignRight
            }

            CheckBox{
                id: filterActivityChk
                text: i18n("Show activity information")
            }

            Label{}

            TextField {
                id: placeHolder
                text: plasmoid.configuration.placeHolder
                Layout.minimumWidth: substitutionsBtn.width * 1.5
                Layout.maximumWidth: Layout.minimumWidth
                enabled: !filterActivityChk.checked

                placeholderText: i18n("placeholder text...")
            }
        }

        GridLayout{
            columns: 2

            Label{
                Layout.minimumWidth: Math.max(centerFactor * behaviorPage.width, minimumWidth)
                text: i18n("Application name:")
                horizontalAlignment: Text.AlignRight
            }

            Button{
                id: substitutionsBtn
                checkable: true
                checked: subsSlidingBox.shown
                text: "  " + i18n("Manage substitutions...") + "  "
                onClicked: {
                    if (subsSlidingBox.shown) {
                        subsSlidingBox.slideOut();
                    } else {
                        subsSlidingBox.slideIn();
                    }
                }

                SubstitutionsPopup {
                    id: subsSlidingBox
                    page: behaviorPage
                    slideOutFrom: PlasmaCore.Types.BottomEdge
                }
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

}
