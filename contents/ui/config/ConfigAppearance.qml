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
// import QtGraphicalEffects
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore

import "../../tools/Tools.js" as Tools

Item {
    id: root

    property alias cfg_boldFont: boldChk.checked
    property alias cfg_italicFont: italicChk.checked
    property alias cfg_capitalFont: capitalChk.checked
    property alias cfg_showIcon: showIconChk.checked
    property alias cfg_iconFillThickness: iconFillChk.checked
    property alias cfg_iconSize: iconSizeSpn.value
    property alias cfg_lengthPolicy: root.selectedLengthPolicy
    property alias cfg_spacing: spacingSpn.value
    property alias cfg_style: root.selectedStyle
    property alias cfg_lengthFirstMargin: lengthFirstSpn.value
    property alias cfg_lengthLastMargin: lengthLastSpn.value
    property alias cfg_lengthMarginsLock: lockItem.locked
    property alias cfg_fixedLength: fixedLengthSlider.value
    property alias cfg_maximumLength: maxLengthSlider.value

    property alias cfg_subsMatch: root.selectedMatches
    property alias cfg_subsReplace: root.selectedReplacements

    // used as bridge to communicate properly between configuration and ui
    property int selectedLengthPolicy
    property int selectedStyle
    property var selectedMatches: []
    property var selectedReplacements: []

    // used from the ui
    readonly property real centerFactor: 0.3
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
        spacing: Kirigami.Units.largeSpacing
        Layout.fillWidth: true

        GridLayout{
            columns: 2

            Label{
                Layout.minimumWidth: Math.max(centerFactor * root.width, minimumWidth)
                text: i18n("Text style:")
                horizontalAlignment: Text.AlignRight
            }

            CustomComboBox{
                id: styleCmb

                choices: [
                    i18n("Application"),
                    i18n("Title"),
                    i18n("Application - Title"),
                    i18n("Title - Application"),
                    i18n("Do not show any text"),
                ];

                Component.onCompleted: currentIndex = plasmoid.configuration.style;
                onChoiceClicked: root.selectedStyle = index;
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

            Label{
            }

            RowLayout{
                enabled: !iconFillChk.checked

                SpinBox{
                    id: iconSizeSpn
                    from: 16
                    to: 128
                    textFromValue: function() {
                        return value + " " + i18nc("pixels","px.");
                    }
                    // suffix: " " + i18nc("pixels","px.")
                    enabled: !iconFillChk.checked
                }

                Label {
                    Layout.leftMargin: Kirigami.Units.smallSpacing
                    text: "maximum"
                }
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
                id: lengthLbl2
                Layout.minimumWidth: Math.max(centerFactor * root.width, minimumWidth)
                text: i18n("Length:")
                horizontalAlignment: Text.AlignRight
            }

            CustomComboBox{
                id: lengthCmb

                choices: [
                    i18n("Based on contents"),
                    i18n("Fixed size"),
                    i18n("Maximum"),
                    i18n("Fill available space")
                ];

                Component.onCompleted: currentIndex = plasmoid.configuration.lengthPolicy
                onChoiceClicked: root.selectedLengthPolicy = index;
            }

            Label{
                visible: lengthCmb.currentIndex === 1 /*Fixed Length Policy*/
            }

            RowLayout{
                visible: lengthCmb.currentIndex === 1 /*Fixed Length Policy*/

                Slider {
                    id: fixedLengthSlider
                    Layout.minimumWidth: lengthCmb.width
                    Layout.preferredWidth: Layout.minimumWidth
                    Layout.maximumWidth: Layout.minimumWidth

                    from: 24
                    to: 1500
                    stepSize: 2
                }
                Label {
                    id: fixedLengthLbl
                    text: fixedLengthSlider.value + " " + i18n("px.")
                }
            }

            Label{
                visible: lengthCmb.currentIndex === 2 /*Maximum Length Policy*/
            }

            RowLayout{
                visible: lengthCmb.currentIndex === 2 /*Maximum Length Policy*/
                Slider {
                    id: maxLengthSlider
                    Layout.minimumWidth: lengthCmb.width
                    Layout.preferredWidth: Layout.minimumWidth
                    Layout.maximumWidth: Layout.minimumWidth

                    from: 24
                    to: 1500
                    stepSize: 2
                }
                Label {
                    id: maxLengthLbl
                    text: maxLengthSlider.value + " " + i18n("px.")
                }
            }

            Label{
            }

            Label {
                id: lengthDescriptionLbl
                Layout.minimumWidth: lengthCmb.width - 10
                Layout.preferredWidth: 0.5 * root.width
                Layout.maximumWidth: Layout.preferredWidth

                font.italic: true
                wrapMode: Text.WordWrap

                text: {
                    if (lengthCmb.currentIndex === 0 /*Contents*/){
                        return i18n("Contents provide an exact size to be used at all times.")
                    } else if (lengthCmb.currentIndex === 1 /*Fixed*/) {
                        return i18n("Length slider decides the exact size to be used at all times.");
                    } else if (lengthCmb.currentIndex === 2 /*Maximum*/) {
                        return i18n("Contents provide the preferred size and length slider its highest value.");
                    } else { /*Fill*/
                        return i18n("All available space is filled at all times.");
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
                    from: 0
                    to: 36
                    // suffix: " " + i18nc("pixels","px.")
                    textFromValue: function() {
                        return value + " " + i18nc("pixels","px.");
                    }
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
                    from: 0
                    to: 24
                    // suffix: " " + i18nc("pixels","px.")
                    textFromValue: function() {
                        return value + " " + i18nc("pixels","px.");
                    }

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
                    from: 0
                    to: 24
                    // suffix: " " + i18nc("pixels","px.")
                    textFromValue: function() {
                        return value + " " + i18nc("pixels","px.");
                    }
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
    } //mainColumn
}
