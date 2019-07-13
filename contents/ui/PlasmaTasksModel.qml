/*
*  Copyright 2019 Michail Vourlakos <mvourlakos@gmail.com>
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

import org.kde.taskmanager 0.1 as TaskManager

Item {
    id: plasmaTasksItem
    readonly property bool existsWindowActive: root.activeTaskItem && tasksRepeater.count > 0 && activeTaskItem.isActive
    property Item activeTaskItem: null

    function requestToggleMaximized() {
        tasksModel.requestToggleMaximized(tasksModel.activeTask);
    }

    TaskManager.TasksModel {
        id: tasksModel
        sortMode: TaskManager.TasksModel.SortVirtualDesktop
        groupMode: TaskManager.TasksModel.GroupDisabled
        screenGeometry: plasmoid.screenGeometry
        activity: activityInfo.currentActivity
        virtualDesktop: virtualDesktopInfo.currentDesktop

        filterByScreen: plasmoid.configuration.filterByScreen
        filterByVirtualDesktop: true
        filterByActivity: true
    }

    Repeater{
        id: tasksRepeater
        model:DelegateModel {
            model: tasksModel
            delegate: Item{
                id: task
                readonly property string appName: modelAppName !== "" ? modelAppName : discoveredAppName
                readonly property bool isMinimized: IsMinimized === true ? true : false
                readonly property bool isMaximized: IsMaximized === true ? true : false
                readonly property bool isActive: IsActive === true ? true : false
                readonly property bool isOnAllDesktops: IsOnAllVirtualDesktops === true ? true : false
                property var icon: decoration

                readonly property string modelAppName: AppName
                readonly property string modelDisplay: display

                property string title: ""
                property string discoveredAppName: ""

                function cleanupTitle() {
                    var text = display;
                    var t = modelDisplay;
                    var sep = t.lastIndexOf(" —– ");
                    var spacer = 4;

                    if (sep === -1) {
                        sep = t.lastIndexOf(" -- ");
                        spacer = 4;
                    }

                    if (sep === -1) {
                        sep = t.lastIndexOf(" -- ");
                        spacer = 4;
                    }

                    if (sep === -1) {
                        sep = t.lastIndexOf(" — ");
                        spacer = 3;
                    }

                    if (sep === -1) {
                        sep = t.lastIndexOf(" - ");
                        spacer = 3;
                    }

                    var dTitle = "";
                    var dAppName = "";

                    if (sep>-1) {
                        dTitle = text.substring(0, sep);
                        discoveredAppName = text.substring(sep+spacer, text.length);

                        //if title starts with application name, swap the found records
                        if (dTitle.startsWith(modelAppName)) {
                            var firstPart = dTitle;
                            dTitle = discoveredAppName;
                            discoveredAppName = firstPart;
                        }
                    }

                    if (sep>-1) {
                        title = dTitle;
                    } else {
                        title = t;
                    }
                }

                onIsActiveChanged: {
                    if (isActive) {
                        plasmaTasksItem.activeTaskItem = task;
                    }
                }

                onModelAppNameChanged: task.cleanupTitle()
                onModelDisplayChanged: task.cleanupTitle()
                Component.onCompleted: task.cleanupTitle()
            }
        }
    }
}
