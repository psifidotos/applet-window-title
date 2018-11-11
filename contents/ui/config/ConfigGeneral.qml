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

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: root

    property alias cfg_showIcon: showIconChk.checked
    property alias cfg_spacing: spacingSpn.value
    property alias cfg_style: root.selectedStyle
    property alias cfg_lengthFirstMargin: lengthFirstSpn.value
    property alias cfg_lengthLastMargin: lengthLastSpn.value
    property alias cfg_lengthMarginsLock: lockItem.locked
    property alias cfg_maximumLength: maximumLengthSpn.value

    // used as bridge to communicate properly between configuration and ui
    property int selectedStyle

    // used from the ui
    readonly property real centerFactor: 0.35
    readonly property int minimumWidth: 220

    ColumnLayout {
        id:mainColumn
        spacing: units.largeSpacing
        Layout.fillWidth: true

        GridLayout{
            columns: 2

            Label{
                Layout.minimumWidth: Math.max(centerFactor * root.width, minimumWidth)
                text: i18n("Style:")
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
                text: i18n("Appearance:")
                horizontalAlignment: Text.AlignRight
            }

            CheckBox{
                id: showIconChk
                text: i18n("Show available icon")
            }
        }

        GridLayout{
            columns: 2
            visible: root.selectedStyle > 0

            Label{
                Layout.minimumWidth: Math.max(centerFactor * root.width, minimumWidth)
                text: i18n("Maximum length:")
                horizontalAlignment: Text.AlignRight
                opacity: maximumLengthSpn.value === 0 ? 0.5 : 1
            }

            SpinBox{
                id: maximumLengthSpn
                minimumValue: 0
                maximumValue: 600
                suffix: " " + i18nc("pixels","px.")
                opacity: maximumLengthSpn.value === 0 ? 0.5 : 1
            }
        }

        ColumnLayout{
            GridLayout{
                columns: 2

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
        }
    }

}
