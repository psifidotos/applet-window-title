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
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.0

import org.kde.plasma.core 2.0 as PlasmaCore

import "../../tools/Tools.js" as Tools

Item {
    id: root

    property alias cfg_boldFont: boldChk.checked
    property alias cfg_italicFont: italicChk.checked
    property alias cfg_capitalFont: capitalChk.checked
    property alias cfg_showIcon: showIconChk.checked
    property alias cfg_iconFillThickness: iconFillChk.checked
    property alias cfg_spacing: spacingSpn.value
    property alias cfg_style: root.selectedStyle
    property alias cfg_lengthFirstMargin: lengthFirstSpn.value
    property alias cfg_lengthLastMargin: lengthLastSpn.value
    property alias cfg_lengthMarginsLock: lockItem.locked
    property alias cfg_maximumLength: maximumLengthSpn.value
    property alias cfg_subsCriteria: root.selectedCriteria
    property alias cfg_subsCriteriaReplace: root.selectedReplacements

    // used as bridge to communicate properly between configuration and ui
    property int selectedStyle
    property var selectedCriteria: []
    property var selectedReplacements: []

    // used from the ui
    readonly property real centerFactor: 0.35
    readonly property int minimumWidth: 220

    onSelectedStyleChanged: {
        if (selectedStyle === 4) { /*NoText*/
            showIconChk.checked = true;
        }
    }

    SystemPalette {
        id: palette
    }

    ColumnLayout {
        id:mainColumn
        spacing: units.largeSpacing
        Layout.fillWidth: true

        GridLayout{
            columns: 2

            Label{
                Layout.minimumWidth: Math.max(centerFactor * root.width, minimumWidth)
                text: i18n("Text style:")
                horizontalAlignment: Text.AlignRight
            }

            StyleComboBox{
                Layout.minimumWidth: 220
                Layout.preferredWidth: 0.25 * root.width
                Layout.maximumWidth: 320
            }
        }

        GridLayout{
            columns: 2

            Label{
                Layout.minimumWidth: Math.max(centerFactor * root.width, minimumWidth)
                text: i18n("Icon:")
                horizontalAlignment: Text.AlignRight
            }

            CheckBox{
                id: showIconChk
                text: i18n("Show when available")
                enabled: root.selectedStyle !== 4 /*NoText*/
            }

            Label{
            }

            CheckBox{
                id: iconFillChk
                text: i18n("Fill thickness")
                enabled: showIconChk.checked
            }
        }

        GridLayout{
            columns: 2
            enabled : root.selectedStyle !== 4 /*NoText*/

            Label{
                Layout.minimumWidth: Math.max(centerFactor * root.width, minimumWidth)
                text: i18n("Font:")
                horizontalAlignment: Text.AlignRight
            }

            CheckBox{
                id: boldChk
                text: i18n("Bold")
            }

            Label{
                id: italicLbl
                font.italic: true
            }

            CheckBox{
                id: italicChk
                text: i18n("Italic")
            }

            Label{
            }

            CheckBox{
                id: capitalChk
                text: i18n("First letters capital")
            }
        }

        GridLayout{
            columns: 2
            enabled : root.selectedStyle !== 4 /*NoText*/

            Label{
                id: lengthLbl
                Layout.minimumWidth: Math.max(centerFactor * root.width, minimumWidth)
                text: i18n("Length:")
                horizontalAlignment: Text.AlignRight
            }

            Controls22.SpinBox{
                id: maximumLengthSpn
                Layout.minimumWidth: spacingSpn.width
                from: 0
                to: 600
                stepSize: 1
                editable: true
                textFromValue: function(value) {
                    return value===0 ? maximumStr : value + suffix
                }

                readonly property string suffix: " " + i18nc("pixels","px.")
                readonly property string maximumStr: i18nc("maximum length", "maximum");

                valueFromText: function(text, locale) {
                    if (text === maximumStr) {
                        return 0;
                    }

                    if (text.endsWith(suffix)) {
                        var number = text.replace(suffix,'');
                        return Number.fromLocaleString(locale, number);
                    }
                    return 0;
                }

                validator: IntValidator {
                    locale: maximumLengthSpn.locale.name
                    bottom: Math.min(maximumLengthSpn.from, maximumLengthSpn.to)
                    top: Math.max(maximumLengthSpn.from, maximumLengthSpn.to)
                }

                contentItem: TextInput {
                    text: maximumLengthSpn.textFromValue(maximumLengthSpn.value, maximumLengthSpn.locale)
                    opacity: maximumLengthSpn.enabled ? 1 : 0.6

                    leftPadding: 2
                    horizontalAlignment: Qt.AlignLeft
                    verticalAlignment: Qt.AlignVCenter

                    readOnly: !maximumLengthSpn.editable
                    validator: maximumLengthSpn.validator
                    inputMethodHints: Qt.ImhFormattedNumbersOnly

                    font: maximumLengthSpn.value === 0 ? italicLbl.font : lengthLbl.font
                    color: palette.text
                    selectionColor: palette.highlight
                    selectedTextColor: palette.highlightedText

                    MouseArea{
                        anchors.fill: parent
                        cursorShape: Qt.IBeamCursor
                        hoverEnabled: true

                        onClicked: {
                            var lastNumber = parent.text.indexOf(maximumLengthSpn.suffix);

                            parent.forceActiveFocus();

                            if (lastNumber === -1) {
                                parent.selectAll();
                            } else {
                                parent.select(0, lastNumber);
                            }
                        }

                        onWheel: {
                            var angle = wheel.angleDelta.y / 8;
                            if (angle > 12) {
                                maximumLengthSpn.increase();
                            } else if (angle < -12) {
                                maximumLengthSpn.decrease();
                            }
                        }
                    }
                }
            }
        }

        ColumnLayout{
            GridLayout{
                id: visualSettingsGroup1
                columns: 2
                enabled: showIconChk.checked && root.selectedStyle !== 4 /*NoText*/

                Label{
                    Layout.minimumWidth: Math.max(centerFactor * root.width, minimumWidth)
                    text: i18n("Spacing:")
                    horizontalAlignment: Text.AlignRight
                }

                SpinBox{
                    id: spacingSpn
                    minimumValue: 0
                    maximumValue: 36
                    suffix: " " + i18nc("pixels","px.")
                }
            }

            GridLayout{
                id: visualSettingsGroup2

                columns: 3
                rows: 2
                flow: GridLayout.TopToBottom
                columnSpacing: visualSettingsGroup1.columnSpacing
                rowSpacing: visualSettingsGroup1.rowSpacing

                property int lockerHeight: firstLengthLbl.height + rowSpacing/2

                Label{
                    id: firstLengthLbl
                    Layout.minimumWidth: Math.max(centerFactor * root.width, minimumWidth)
                    text: plasmoid.configuration.formFactor===PlasmaCore.Types.Horizontal ?
                              i18n("Left margin:") : i18n("Top margin:")
                    horizontalAlignment: Text.AlignRight
                }

                Label{
                    Layout.minimumWidth: Math.max(centerFactor * root.width, minimumWidth)
                    text: plasmoid.configuration.formFactor===PlasmaCore.Types.Horizontal ?
                              i18n("Right margin:") : i18n("Bottom margin:")
                    horizontalAlignment: Text.AlignRight

                    enabled: !lockItem.locked
                }

                SpinBox{
                    id: lengthFirstSpn
                    minimumValue: 0
                    maximumValue: 24
                    suffix: " " + i18nc("pixels","px.")

                    property int lastValue: -1

                    onValueChanged: {
                        if (lockItem.locked) {
                            var step = value - lastValue > 0 ? 1 : -1;
                            lastValue = value;
                            lengthLastSpn.value = lengthLastSpn.value + step;
                        }
                    }

                    Component.onCompleted: {
                        lastValue = plasmoid.configuration.lengthFirstMargin;
                    }
                }

                SpinBox{
                    id: lengthLastSpn
                    minimumValue: 0
                    maximumValue: 24
                    suffix: " " + i18nc("pixels","px.")
                    enabled: !lockItem.locked
                }

                LockItem{
                    id: lockItem
                    Layout.minimumWidth: 40
                    Layout.maximumWidth: 40
                    Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                    Layout.minimumHeight: visualSettingsGroup2.lockerHeight
                    Layout.maximumHeight: Layout.minimumHeight
                    Layout.topMargin: firstLengthLbl.height / 2
                    Layout.rowSpan: 2
                }
            }
        } // ColumnLayout

        GridLayout{
            columns: 2

            Label{
                Layout.minimumWidth: Math.max(centerFactor * root.width, minimumWidth)
                text: i18n("Application name:")
                horizontalAlignment: Text.AlignRight
            }

            Button{
                text: "  " + i18n("Manage sustitutions...") + "  "
                onClicked: subspopup.open();
            }
        }
    } //mainColumn

    Rectangle{
        x: subspopup.x
        y: subspopup.y
        width: subspopup.width
        height: subspopup.height
        color: palette.base

        layer.enabled: true
        layer.effect: DropShadow {
            radius: 12
            fast: true
            samples: 2 * radius
            color: "#999999"
        }

        visible: subspopup.visible
        opacity: subspopup.opacity
    }

    SubstitutionsPopup{
        id: subspopup
        width: Tools.qBound(400, 0.6*root.width, root.width-150)

        x: root.width/2 - width/2
        y: root.height/2 - height/2
    }


}
