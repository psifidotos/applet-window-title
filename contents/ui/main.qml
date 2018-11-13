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

import QtQuick 2.7
import QtQml.Models 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.taskmanager 0.1 as TaskManager

import org.kde.activities 0.1 as Activities

import "../tools/Tools.js" as Tools

Item {
    id: root
    clip: true

    Layout.fillHeight: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? true : false
    Layout.fillWidth: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? false : true

    Layout.minimumWidth: minimumWidth
    Layout.minimumHeight: minimumHeight
    Layout.preferredHeight: Layout.minimumHeight
    Layout.preferredWidth: Layout.minimumWidth
    Layout.maximumHeight: Layout.minimumHeight
    Layout.maximumWidth: Layout.minimumWidth

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    Plasmoid.onFormFactorChanged: plasmoid.configuration.formFactor = plasmoid.formFactor;

    readonly property int containmentType: plasmoid.configuration.containmentType
    readonly property int minimumWidth: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? contents.width : -1;
    readonly property int minimumHeight: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? -1 : contents.height;

    readonly property bool existsWindowActive: activeTaskItem && tasksRepeater.count > 0 && activeTaskItem.isActive
    readonly property bool isActiveWindowPinned: existsWindowActive && activeTaskItem.isOnAllDesktops
    readonly property bool isActiveWindowMaximized: existsWindowActive && activeTaskItem.isMaximized

    property Item activeTaskItem: null

    //BEGIN Latte Dock Communicator
    property bool isInLatte: false  // deprecated Latte v0.8 API
    property QtObject latteBridge: null // current Latte v0.9 API

    onLatteBridgeChanged: {
        if (latteBridge) {
            plasmoid.configuration.containmentType = 2; /*Latte containment with new API*/
            latteBridge.actions.setProperty(plasmoid.id, "disableLatteSideColoring", true);
        }
    }
    //END  Latte Dock Communicator
    //BEGIN Latte based properties
    readonly property bool enforceLattePalette: latteBridge && latteBridge.applyPalette && latteBridge.palette
    readonly property bool latteInEditMode: latteBridge && latteBridge.inEditMode
    //END Latte based properties

    Component.onCompleted: containmentIdentifierTimer.start();

    // START Tasks logic
    // To get current activity name
    TaskManager.ActivityInfo {
        id: activityInfo
    }

    Activities.ActivityInfo {
        id: fullActivityInfo
        activityId: ":current"
    }

    // To get virtual desktop name
    TaskManager.VirtualDesktopInfo {
        id: virtualDesktopInfo
    }

    TaskManager.TasksModel {
        id: tasksModel
        sortMode: TaskManager.TasksModel.SortVirtualDesktop
        groupMode: TaskManager.TasksModel.GroupDisabled
        screenGeometry: plasmoid.screenGeometry
        activity: activityInfo.currentActivity
        virtualDesktop: virtualDesktopInfo.currentDesktop

        filterByScreen: true
        filterByVirtualDesktop: true
        filterByActivity: true
    }

    Repeater{
        id: tasksRepeater
        model:DelegateModel {
            model: tasksModel
            delegate: Item{
                id: task
                readonly property string appName: AppName
                readonly property bool isMinimized: IsMinimized === true ? true : false
                readonly property bool isMaximized: IsMaximized === true ? true : false
                readonly property bool isActive: IsActive === true ? true : false
                readonly property bool isOnAllDesktops: IsOnAllVirtualDesktops === true ? true : false
                property var icon: decoration

                property string title: ""

                onIsActiveChanged: {
                    if (isActive) {
                        root.activeTaskItem = task;

                        var t = display;
                        var sep = t.lastIndexOf(" —– ");
                        sep = (sep === -1 ? t.lastIndexOf(" -- ") : sep);
                        sep = (sep === -1 ? t.lastIndexOf(" — ") : sep);
                        sep = (sep === -1 ? t.lastIndexOf(" - ") : sep);

                        if (sep >-1) {
                            title = display.substring(0, sep);
                        } else {
                            title = t;
                        }
                    }
                }
            }
        }
    }
    // END Tasks logic

    GridLayout{
        id: contents
        rows: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? 1 : -1
        columns: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? -1 : 1

        readonly property int thickness: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? root.height : root.width

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

            Layout.minimumWidth: contents.thickness
            Layout.maximumWidth: Layout.minimumWidth

            Layout.minimumHeight: contents.thickness
            Layout.maximumHeight: Layout.minimumHeight

            visible: plasmoid.configuration.showIcon

            Loader {
                anchors.fill: parent
                active: !plasmoid.configuration.iconFillThickness
                sourceComponent: PlasmaCore.IconItem{
                    anchors.fill: parent
                    usesPlasmaTheme: true
                    source: existsWindowActive ? activeTaskItem.icon : fullActivityInfo.icon
                }
            }

            Loader {
                anchors.fill: parent
                active: plasmoid.configuration.iconFillThickness
                sourceComponent: QIconItem{
                    anchors.fill: parent
                    icon: existsWindowActive ? activeTaskItem.icon : fullActivityInfo.icon
                }
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

            visible: plasmoid.configuration.style !== 4 /*NoText*/
        }

        Item{
            Layout.minimumWidth: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? -1 : contents.thickness
            Layout.preferredWidth: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? labelTxt.implicitWidth : contents.thickness
            Layout.maximumWidth: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? maximumLength : contents.thickness

            Layout.minimumHeight: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? contents.thickness : -1
            Layout.preferredHeight: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? contents.thickness : labelTxt.implicitWidth
            Layout.maximumHeight: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? contents.thickness : maximumLength
            visible: plasmoid.configuration.style !== 4 /*NoText*/

            readonly property int maximumLength: {
                if (plasmoid.configuration.maximumLength <= 0) {
                    return Infinity;
                }

                return plasmoid.configuration.maximumLength;
            }

            PlasmaComponents.Label{
                id: labelTxt

                anchors.centerIn: parent
                width: {
                    if (plasmoid.configuration.maximumLength <= 0) {
                        return implicitWidth;
                    }

                    return plasmoid.configuration.maximumLength;
                }

                text: existsWindowActive ? windowText : fullActivityInfo.name
                color: enforceLattePalette ? latteBridge.palette.textColor : theme.textColor
                font.capitalization: plasmoid.configuration.capitalFont ? Font.Capitalize : Font.MixedCase
                font.weight: plasmoid.configuration.boldFont ? Font.Bold : Font.Normal
                font.italic: plasmoid.configuration.italicFont
                elide: Text.ElideRight

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

                readonly property string windowText: {
                    if (plasmoid.configuration.style === 0){ /*Application*/
                        return Tools.applySubstitutes(activeTaskItem.appName);
                    } else if (plasmoid.configuration.style === 1){ /*Title*/
                        return activeTaskItem.title;
                    } else if (plasmoid.configuration.style === 2){ /*ApplicationTitle*/
                        var finalText = activeTaskItem.appName === activeTaskItem.title ?
                                    Tools.applySubstitutes(activeTaskItem.appName) :
                                    Tools.applySubstitutes(activeTaskItem.appName) + " - " + activeTaskItem.title;

                        return finalText;
                    } else if (plasmoid.configuration.style === 3){ /*TitleApplication*/
                        var finalText = activeTaskItem.appName === activeTaskItem.title ?
                                    Tools.applySubstitutes(activeTaskItem.appName) :
                                    activeTaskItem.title + " - " + Tools.applySubstitutes(activeTaskItem.appName);

                        return finalText;
                    } else if (plasmoid.configuration.style === 4){ /*NoText*/
                        return "";
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

    MouseArea{
        id: contentsMouseArea
        anchors.fill: contents
        visible: containmentType === 1 /*plasma or old latte containment*/

        onDoubleClicked: {
            if (existsWindowActive) {
                tasksModel.requestToggleMaximized(tasksModel.activeTask);
            }
        }
    }


    //! this timer is used in order to identify in which containment the applet is in
    //! it should be called only the first time an applet is created and loaded because
    //! afterwards the applet has no way to move between different processes such
    //! as Plasma and Latte
    Timer{
        id: containmentIdentifierTimer
        interval: 5000
        onTriggered: {
            if (latteBridge) {
                plasmoid.configuration.containmentType = 2; /*Latte containment with new API*/
            } else {
                plasmoid.configuration.containmentType = 1; /*Plasma containment or Latte with old API*/
            }
        }
    }
}
