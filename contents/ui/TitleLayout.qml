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
    property bool exceedsApplicationText: false

    property int applicationTextLength: {
        var applicationLength = 0;

        var midSpacerLength = midSpacer.visible ?
                    (plasmoid.formFactor === PlasmaCore.Types.Horizontal ? midSpacer.width : midSpacer.height) : 0;

        if (plasmoid.configuration.style === 0 /*Application*/
                || plasmoid.configuration.style === 2) { /*ApplicationTitle*/
            applicationLength = firstTxt.implicitWidth;
        } else if (plasmoid.configuration.style === 3) { /*TitleApplication*/
            applicationLength = lastTxt.implicitWidth + midSpacerLength;
        }

        var iconLength = mainIcon.visible ?
                    (plasmoid.formFactor === PlasmaCore.Types.Horizontal ? mainIcon.width : mainIcon.height) : 0;

        var subElements = plasmoid.formFactor === PlasmaCore.Types.Horizontal ?
                    firstSpacer.width + iconLength + midSpacerLength + lastSpacer.width:
                    firstSpacer.height + iconLength + midSpacerLength + lastSpacer.height;

        return subElements + applicationLength;
    }

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

        PlasmaCore.IconItem{
            id: iconItem
            anchors.fill: parent
            anchors.topMargin: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? thickMargin : 0
            anchors.bottomMargin: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? thickMargin : 0
            anchors.leftMargin: plasmoid.formFactor === PlasmaCore.Types.Vertical ? thickMargin : 0
            anchors.rightMargin: plasmoid.formFactor === PlasmaCore.Types.Vertical ? thickMargin : 0
            roundToIconSize: !root.isInLatte
            source: existsWindowActive ? activeTaskItem.icon : fullActivityInfo.icon


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
        id: textsContainer
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
                        var iconL = mainIcon.visible ? mainIcon.width : 0;
                        var midL = midSpacer.visible ? midSpacer.width : 0;
                        return titleLayout.width - firstSpacer.width - iconL - midL - lastSpacer.width;
                    } else {
                        var iconL = mainIcon.visible ? mainIcon.height : 0;
                        var midL = midSpacer.visible ? midSpacer.height : 0;
                        return titleLayout.height - firstSpacer.height - iconL - midL - lastSpacer.height;
                    }
                }

                return implicitWidths;
            }

            readonly property int implicitWidths: {
                return Math.ceil(firstTxt.implicitWidth) + Math.ceil(midTxt.implicitWidth) + Math.ceil(lastTxt.implicitWidth);
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

            Label{
                id: firstTxt
                Layout.fillWidth: elide === Text.ElideNone ? false : true
                width: Text.ElideNone ? implicitWidth : -1
                verticalAlignment: Text.AlignVCenter

                text: existsWindowActive ? root.firstTitleText : root.fallBackText
                color: enforceLattePalette ? latteBridge.palette.textColor : theme.textColor
                font.capitalization: plasmoid.configuration.capitalFont ? Font.Capitalize : Font.MixedCase
                font.bold: plasmoid.configuration.boldFont
                font.italic: plasmoid.configuration.italicFont

                readonly property bool showsTitleText: plasmoid.configuration.style === 1 /*Title*/
                                                       || plasmoid.configuration.style === 3 /*TitleApplication*/

                readonly property bool showsApplicationText: plasmoid.configuration.style === 0 /*Application*/
                                                             || plasmoid.configuration.style === 2 /*ApplicationTitle*/

                elide: {
                    if (plasmoid.configuration.style === 1 && titleLayout.exceedsAvailableSpace){ /*Title*/
                        return Text.ElideMiddle;
                    } else if (plasmoid.configuration.style === 3
                               && activeTaskItem
                               && activeTaskItem.appName !== activeTaskItem.title
                               && titleLayout.exceedsAvailableSpace){ /*TitleApplication*/
                        return Text.ElideMiddle;
                    } else if (showsApplicationText && !isUsedForMetrics && exceedsApplicationText) {
                        return Text.ElideMiddle;
                    }

                    return Text.ElideNone;
                }

                visible: {
                    if (!isUsedForMetrics && showsTitleText && exceedsApplicationText) {
                        return false;
                    }

                    return true;
                }
            }

            Label{
                id: midTxt
                verticalAlignment: firstTxt.verticalAlignment
                width: implicitWidth
                visible: !exceedsApplicationText && text !== ""

                text: {
                    if (!existsWindowActive) {
                        return "";
                    }

                    if (plasmoid.configuration.style === 2 || plasmoid.configuration.style === 3){ /*ApplicationTitle*/ /*OR*/ /*TitleApplication*/
                        if (activeTaskItem.appName !== activeTaskItem.title && activeTaskItem.appName !== "" && activeTaskItem.title !== "") {
                            return " – ";
                        }
                    }

                    return "";
                }

                color: firstTxt.color
                font.capitalization: firstTxt.font.capitalization
                font.bold: firstTxt.font.bold
                font.italic: firstTxt.font.italic
            }

            Label{
                id: lastTxt
                Layout.fillWidth: elide === Text.ElideNone ? false : true
                width: Text.ElideNone ? implicitWidth : -1
                verticalAlignment: firstTxt.verticalAlignment

                text: existsWindowActive ? root.lastTitleText : ""

                color: firstTxt.color
                font.capitalization: firstTxt.font.capitalization
                font.bold: firstTxt.font.bold
                font.italic: firstTxt.font.italic

                visible: text !== "" && !(showsTitleText && exceedsApplicationText)

                readonly property bool showsTitleText: plasmoid.configuration.style === 2 /*ApplicationTitle*/


                elide: {
                    if (activeTaskItem
                            && activeTaskItem.appName !== activeTaskItem.title
                            && plasmoid.configuration.style === 2 /*ApplicationTitle*/
                            && titleLayout.exceedsAvailableSpace){  /*AND is shown*/
                        return Text.ElideMiddle;
                    } else if(plasmoid.configuration.style === 3 /*TitleApplication*/
                              /*&& exceedsApplicationText*/) {
                        return Text.ElideNone;
                    }

                    return Text.ElideMiddle;
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


