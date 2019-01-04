/*
*  Copyright 2018-2019 Michail Vourlakos <mvourlakos@gmail.com>
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
import QtQml.Models 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents


GridLayout{
    id: titleLayout
    rows: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? 1 : -1
    columns: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? -1 : 1
    columnSpacing: 0
    rowSpacing: 0

    property bool isUsedForMetrics: false
    property bool exceedsAvailableSpace: false

    Item{
        id: firstSpacer
        Layout.minimumWidth: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? plasmoid.configuration.lengthFirstMargin : -1
        Layout.preferredWidth: Layout.minimumWidth
        Layout.maximumWidth: Layout.minimumWidth

        Layout.minimumHeight: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? -1 : plasmoid.configuration.lengthFirstMargin
        Layout.preferredHeight: Layout.minimumHeight
        Layout.maximumHeight: Layout.minimumHeight
    }

    Item {
        id: mainIcon

        Layout.minimumWidth: plasmoid.formFactor === PlasmaCore.Types.Horizontal ?
                                 iconItem.iconSize : root.thickness
        Layout.maximumWidth: Layout.minimumWidth

        Layout.minimumHeight: plasmoid.formFactor === PlasmaCore.Types.Horizontal ?
                                  root.thickness : iconItem.iconSize
        Layout.maximumHeight: Layout.minimumHeight

        visible: plasmoid.configuration.showIcon

        QIconItem{
            id: iconItem
            anchors.fill: parent
            anchors.topMargin: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? thickMargin : 0
            anchors.bottomMargin: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? thickMargin : 0
            anchors.leftMargin: plasmoid.formFactor === PlasmaCore.Types.Vertical ? thickMargin : 0
            anchors.rightMargin: plasmoid.formFactor === PlasmaCore.Types.Vertical ? thickMargin : 0
            icon: existsWindowActive ? activeTaskItem.icon : fullActivityInfo.icon

            readonly property int thickMargin: plasmoid.configuration.iconFillThickness ?
                                                   0 : (root.thickness - iconSize) / 2

            readonly property int iconSize: plasmoid.configuration.iconFillThickness ?
                                                root.thickness : Math.min(root.thickness, plasmoid.configuration.iconSize)
        }
    }

    Item{
        id: midSpacer
        Layout.minimumWidth: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? plasmoid.configuration.spacing : -1
        Layout.preferredWidth: Layout.minimumWidth
        Layout.maximumWidth: Layout.minimumWidth

        Layout.minimumHeight: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? -1 : plasmoid.configuration.spacing
        Layout.preferredHeight: Layout.minimumHeight
        Layout.maximumHeight: Layout.minimumHeight

        visible: mainIcon.visible && plasmoid.configuration.style !== 4 /*NoText*/
    }

    Item{
        Layout.minimumWidth: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? -1 : root.thickness
        Layout.preferredWidth: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? textRow.availableSpace : root.thickness
        Layout.maximumWidth: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? textRow.availableSpace : root.thickness

        Layout.minimumHeight: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? root.thickness : -1
        Layout.preferredHeight: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? root.thickness : textRow.availableSpace
        Layout.maximumHeight: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? root.thickness : textRow.availableSpace
        visible: plasmoid.configuration.style !== 4 /*NoText*/

        RowLayout {
            id: textRow
            anchors.centerIn: parent
            spacing: 0

            width: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? parent.width : parent.height
            height: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? parent.height : parent.width

            readonly property int availableSpace: {
                if (!titleLayout.isUsedForMetrics) {
                    if (plasmoid.formFactor === PlasmaCore.Types.Horizontal) {
                        return titleLayout.width - firstSpacer.width - mainIcon.width - midSpacer.width - lastSpacer.width;
                    } else {
                        return titleLayout.height - firstSpacer.height - mainIcon.height - midSpacer.height - lastSpacer.height;
                    }
                }

                return implicitWidths;
            }

            readonly property int implicitWidths: {
                return firstTxt.implicitWidth + midTxt.implicitWidth + lastTxt.implicitWidth;
            }

            transformOrigin: Item.Center

            rotation: {
                if (plasmoid.formFactor === PlasmaCore.Types.Horizontal) {
                    return 0;
                } else if (plasmoid.location === PlasmaCore.Types.LeftEdge) {
                    return -90;
                } else if (plasmoid.location === PlasmaCore.Types.RightEdge) {
                    return 90;
                }
            }

            PlasmaComponents.Label{
                id: firstTxt
                Layout.fillWidth: elide === Text.ElideNone ? false : true
                width: Text.ElideNone ? implicitWidth : -1
                verticalAlignment: Text.AlignVCenter

                text: existsWindowActive ? root.firstTitleText : fullActivityInfo.name
                color: enforceLattePalette ? latteBridge.palette.textColor : theme.textColor
                font.capitalization: plasmoid.configuration.capitalFont ? Font.Capitalize : Font.MixedCase
                font.weight: plasmoid.configuration.boldFont ? Font.Bold : Font.Normal
                font.italic: plasmoid.configuration.italicFont

                elide: {
                    if (plasmoid.configuration.style === 1 && titleLayout.exceedsAvailableSpace){ /*Title*/
                        return Text.ElideRight;
                    } else if (plasmoid.configuration.style === 3
                               && activeTaskItem.appName !== activeTaskItem.title
                               && titleLayout.exceedsAvailableSpace){ /*TitleApplication*/
                        return Text.ElideRight;
                    }

                    return Text.ElideNone;
                }
            }

            PlasmaComponents.Label{
                id: midTxt
                verticalAlignment: firstTxt.verticalAlignment
                width: implicitWidth

                text: {
                    if (!existsWindowActive) {
                        return "";
                    }

                    if (plasmoid.configuration.style === 2 || plasmoid.configuration.style === 3){ /*ApplicationTitle*/ /*OR*/ /*TitleApplication*/
                        if (activeTaskItem.appName !== activeTaskItem.title) {
                            return " - ";
                        }
                    }

                    return "";
                }

                color: firstTxt.color
                font.capitalization: firstTxt.font.capitalization
                font.weight: firstTxt.font.weight
                font.italic: firstTxt.font.italic

                visible: text !== ""
            }

            PlasmaComponents.Label{
                id: lastTxt
                Layout.fillWidth: elide === Text.ElideNone ? false : true
                width: Text.ElideNone ? implicitWidth : -1
                verticalAlignment: firstTxt.verticalAlignment

                text: existsWindowActive ? root.lastTitleText : ""

                color: firstTxt.color
                font.capitalization: firstTxt.font.capitalization
                font.weight: firstTxt.font.weight
                font.italic: firstTxt.font.italic

                visible: text !== ""

                elide: {
                    if (plasmoid.configuration.style === 2 /*ApplicationTitle*/
                            && activeTaskItem.appName !== activeTaskItem.title
                            && titleLayout.exceedsAvailableSpace){  /*AND is shown*/
                        return Text.ElideRight;
                    }

                    return Text.ElideNone;
                }
            }
        }
    }

    Item{
        id: lastSpacer
        Layout.minimumWidth: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? plasmoid.configuration.lengthLastMargin : -1
        Layout.preferredWidth: Layout.minimumWidth
        Layout.maximumWidth: Layout.minimumWidth

        Layout.minimumHeight: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? -1 : plasmoid.configuration.lengthLastMargin
        Layout.preferredHeight: Layout.minimumHeight
        Layout.maximumHeight: Layout.minimumHeight
    }
}


