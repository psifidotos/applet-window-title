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

import "../tools/Tools.js" as Tools
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.activities as Activities
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.taskmanager as TaskManager

PlasmoidItem {
    id: root

    readonly property bool inContentsLengthMode: plasmoid.configuration.lengthPolicy === 0 //Contents Length Policy
    readonly property bool inFixedLengthMode: plasmoid.configuration.lengthPolicy === 1 //Fixed Length Policy
    readonly property bool inMaximumLengthMode: plasmoid.configuration.lengthPolicy === 2 //Maximum Length Policy
    readonly property bool inFillLengthMode: plasmoid.configuration.lengthPolicy === 3 //Fill Length Policy
    readonly property bool perScreenActive: plasmoid.configuration.perScreenActive // sticky active window
    readonly property bool inEditMode: plasmoid.userConfiguring || latteInEditMode
    readonly property int containmentType: plasmoid.configuration.containmentType
    readonly property int thickness: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? root.height : root.width
    readonly property int minimumLength: {
        if (broadcaster.hiddenFromBroadcast)
            return 0;

        if (inContentsLengthMode)
            return implicitTitleLength;
        else if (inFixedLengthMode)
            return plasmoid.configuration.fixedLength;
        else if (inMaximumLengthMode)
            return 0;
        else if (inFillLengthMode)
            return inEditMode ? 48 : 0;
    }
    readonly property int preferredLength: {
        if (broadcaster.hiddenFromBroadcast)
            return 0;

        if (inContentsLengthMode)
            return implicitTitleLength;
        else if (inFixedLengthMode)
            return plasmoid.configuration.fixedLength;
        else if (inMaximumLengthMode)
            return Math.min(implicitTitleLength, plasmoid.configuration.maximumLength);
        else if (inFillLengthMode)
            return -1;
    }
    readonly property int maximumLength: {
        if (broadcaster.hiddenFromBroadcast)
            return 0;

        if (inContentsLengthMode)
            return implicitTitleLength;
        else if (inFixedLengthMode)
            return plasmoid.configuration.fixedLength;
        else if (inMaximumLengthMode)
            return plasmoid.configuration.maximumLength;
        else if (inFillLengthMode)
            return Infinity;
    }
    readonly property int implicitTitleLength: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? metricsContents.width : metricsContents.height
    readonly property bool existsWindowActive: windowInfoLoader.item && windowInfoLoader.item.existsWindowActive
    readonly property bool isActiveWindowPinned: existsWindowActive && activeTaskItem.isOnAllDesktops
    readonly property bool isActiveWindowMaximized: existsWindowActive && activeTaskItem.isMaximized
    readonly property Item activeTaskItem: windowInfoLoader.item.activeTaskItem
    property string fallBackText: {
        if (!plasmoid.configuration.filterActivityInfo)
            return plasmoid.configuration.placeHolder;
        else
            return fullActivityInfo.name;
    }
    readonly property string firstTitleText: {
        if (!activeTaskItem)
            return "";

        if (plasmoid.configuration.style === 0) {
            //Application
            return Tools.applySubstitutes(activeTaskItem.appName);
        } else if (plasmoid.configuration.style === 1) {
            //Title
            return activeTaskItem.title;
        } else if (plasmoid.configuration.style === 2) {
            //ApplicationTitle
            return Tools.applySubstitutes(activeTaskItem.appName);
        } else if (plasmoid.configuration.style === 3) {
            //TitleApplication
            var finalText = activeTaskItem.appName === activeTaskItem.title ? Tools.applySubstitutes(activeTaskItem.appName) : activeTaskItem.title;
            return finalText;
        } else if (plasmoid.configuration.style === 4) {
            //NoText
            return "";
        }
        return "";
    }
    readonly property string lastTitleText: {
        if (!activeTaskItem)
            return "";

        if (plasmoid.configuration.style === 2) {
            //ApplicationTitle
            var finalText = activeTaskItem.appName === activeTaskItem.title ? "" : activeTaskItem.title;
            return finalText;
        } else if (plasmoid.configuration.style === 3) {
            //TitleApplication
            var finalText = activeTaskItem.appName === activeTaskItem.title ? "" : Tools.applySubstitutes(activeTaskItem.appName);
            return finalText;
        }
        return "";
    }
    //BEGIN Latte Dock Communicator
    property bool isInLatte: false
    // deprecated Latte v0.8 API
    property QtObject latteBridge: null
    //END  Latte Dock Communicator
    //BEGIN Latte based properties
    readonly property bool enforceLattePalette: latteBridge && latteBridge.applyPalette && latteBridge.palette
    readonly property bool latteInEditMode: latteBridge && latteBridge.inEditMode

    clip: true
    Layout.fillWidth: (inFillLengthMode && plasmoid.formFactor === PlasmaCore.Types.Horizontal) || plasmoid.formFactor === PlasmaCore.Types.Vertical ? true : false
    Layout.fillHeight: (inFillLengthMode && plasmoid.formFactor === PlasmaCore.Types.Vertical) || plasmoid.formFactor === PlasmaCore.Types.Horizontal ? true : false
    Layout.minimumWidth: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? minimumLength : 0
    Layout.preferredWidth: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? preferredLength : -1
    Layout.maximumWidth: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? maximumLength : -1
    Layout.minimumHeight: plasmoid.formFactor === PlasmaCore.Types.Vertical ? minimumLength : 0
    Layout.preferredHeight: plasmoid.formFactor === PlasmaCore.Types.Vertical ? preferredLength : -1
    Layout.maximumHeight: plasmoid.formFactor === PlasmaCore.Types.Vertical ? maximumLength : -1
    preferredRepresentation: fullRepresentation
    Plasmoid.onFormFactorChanged: plasmoid.configuration.formFactor = plasmoid.formFactor
    Plasmoid.status: {
        if ((broadcaster.hiddenFromBroadcast && !inEditMode) || (!inEditMode && fallBackText === "" && !existsWindowActive))
            return PlasmaCore.Types.HiddenStatus;

        return PlasmaCore.Types.PassiveStatus;
    }
    onLatteBridgeChanged: {
        if (latteBridge) {
            plasmoid.configuration.containmentType = 2; //Latte containment with new API
            latteBridge.actions.setProperty(plasmoid.id, "latteSideColoringEnabled", false);
            latteBridge.actions.setProperty(plasmoid.id, "windowsTrackingEnabled", true);
        }
    }
    Component.onCompleted: {
        plasmoid.configuration.appMenuIsPresent = false;
        containmentIdentifierTimer.start();
    }

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

    Loader {
        id: windowInfoLoader

        sourceComponent: latteBridge && latteBridge.windowsTracker && latteBridge.windowsTracker.currentScreen.lastActiveWindow && latteBridge.windowsTracker.allScreens.lastActiveWindow ? latteTrackerComponent : plasmaTasksModel

        Component {
            id: latteTrackerComponent

            LatteWindowsTracker {
            }

        }

        Component {
            id: plasmaTasksModel

            PlasmaTasksModel {
            }

        }

    }

    // This Layout is used to count if the title overceeds the available space
    // in order for the Visible Layout to elide its contents
    TitleLayout {
        //anchors.topMargin: 8

        id: metricsContents

        anchors.top: parent.top
        anchors.left: parent.left
        //visible:false, does not return proper metrics, this is why opacity:0 is preferred
        opacity: 0
        isUsedForMetrics: true
    }

    // This is the reas Visible Layout that is shown to the user
    TitleLayout {
        id: visibleContents

        anchors.top: parent.top
        anchors.left: parent.left
        width: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? (!exceedsAvailableSpace ? metricsContents.width : root.width) : thickness
        height: plasmoid.formFactor === PlasmaCore.Types.Vertical ? (!exceedsAvailableSpace ? metricsContents.height : root.height) : thickness
        exceedsAvailableSpace: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? metricsContents.width > root.width : metricsContents.height > root.height
        exceedsApplicationText: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? metricsContents.applicationTextLength > root.width : metricsContents.applicationTextLength > root.height
        visible: !(!plasmoid.configuration.filterActivityInfo && !root.existsWindowActive && !plasmoid.configuration.placeHolder)
    }

    //! Tooltip Area
    PlasmaCore.ToolTipArea {
        // Try to show only information that are not already shown
        //can not work correctly when showing appmenus

        id: contentsTooltip

        readonly property string text: {
            if (!existsWindowActive || !plasmoid.configuration.showTooltip || broadcaster.cooperationEstablished)
                return "";

            if (plasmoid.configuration.style === 0) {
                //Application
                return activeTaskItem.appName === activeTaskItem.title ? "" : activeTaskItem.title;
            } else if (plasmoid.configuration.style === 1 || plasmoid.configuration.style === 2 || plasmoid.configuration.style === 4) {
                //Title   OR  ApplicationTitle  OR  NoText
                var finalText = activeTaskItem.appName === activeTaskItem.title ? Tools.applySubstitutes(activeTaskItem.appName) : Tools.applySubstitutes(activeTaskItem.appName) + " - " + activeTaskItem.title;
                return finalText;
            } else if (plasmoid.configuration.style === 3) {
                //TitleApplication
                var finalText = activeTaskItem.appName === activeTaskItem.title ? Tools.applySubstitutes(activeTaskItem.appName) : activeTaskItem.title + " - " + Tools.applySubstitutes(activeTaskItem.appName);
                return finalText;
            }
            return "";
        }

        anchors.fill: visibleContents
        active: text !== ""
        interactive: true
        location: plasmoid.location

        mainItem: RowLayout {
            spacing: Kirigami.Units.largeSpacing
            Layout.margins: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                Layout.minimumWidth: Kirigami.Units.iconSizes.medium
                Layout.minimumHeight: Kirigami.Units.iconSizes.medium
                Layout.maximumWidth: Layout.minimumWidth
                Layout.maximumHeight: Layout.minimumHeight
                source: existsWindowActive ? activeTaskItem.icon : fullActivityInfo.icon
                visible: !plasmoid.configuration.showIcon
            }

            PlasmaComponents.Label {
                id: fullText

                Layout.minimumWidth: 0
                Layout.preferredWidth: implicitWidth
                Layout.maximumWidth: 750
                Layout.minimumHeight: implicitHeight
                Layout.maximumHeight: Layout.minimumHeight
                elide: Text.ElideRight
                text: contentsTooltip.text
            }

        }

    }

    Loader {
        id: actionsLoader

        anchors.fill: inFillLengthMode ? parent : visibleContents
        active: containmentType === 1 //plasma or old latte containment

        sourceComponent: ActionsMouseArea {
            anchors.fill: parent
        }

    }

    Broadcaster {
        id: broadcaster

        anchors.fill: parent
    }

    //! this timer is used in order to identify in which containment the applet is in
    //! it should be called only the first time an applet is created and loaded because
    //! afterwards the applet has no way to move between different processes such
    //! as Plasma and Latte
    Timer {
        id: containmentIdentifierTimer

        interval: 5000
        onTriggered: {
            if (latteBridge) {
                plasmoid.configuration.containmentType = 2; //Latte containment with new API
                latteBridge.actions.broadcastToApplet("org.kde.windowappmenu", "isPresent", true);
            } else {
                plasmoid.configuration.containmentType = 1; //Plasma containment or Latte with old API
            }
        }
    }

}
