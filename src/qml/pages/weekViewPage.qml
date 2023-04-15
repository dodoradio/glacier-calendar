/*
 * Copyright (C) 2021 Chupligin Sergey <neochapay@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; see the file COPYING.LIB.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

import QtQuick 2.6

import QtQuick.Controls 1.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

import org.nemomobile.calendar 1.0

import "../components"

Item{
    id: weekViewPage
    anchors.fill: parent

    property date viewedDate: new Date()
    property date startDate: QtDate.addDays(viewedDate, -(viewedDate.getDay() == 0 ? 7 : viewedDate.getDay()))
    property bool isToday: compareDate(new Date(), weekViewPage.viewedDate)

    property var daysOfWeek: [qsTr("Mon"),qsTr("Tue"),qsTr("Wed"),qsTr("Thu"),qsTr("Fri"),qsTr("Sat"),qsTr("Sun")]

    Component.onCompleted: {
        var currentDate = new Date();
        currentTimeLine.y = calculateYTime(new Date())
    }
    onHeightChanged: {currentTimeLine.y = calculateYTime(new Date())}

    Text {
        anchors.right: parent.right
        anchors.top: parent.top;
        anchors.rightMargin: Theme.itemSpacingSmall
        anchors.topMargin: Theme.itemSpacingSmall

        text: viewedDate.toLocaleDateString()
        z: 1
        font.pixelSize: Theme.fontSizeTiny
        color: Theme.textColor
    }

    Row {
        Item{
            id: currentTimeLine
            width: weekView.width
            visible: isToday

            z: 1000

            Rectangle{
                id: currentTimeInd
                height : 1
                width : weekView.width
                color : Theme.accentColor
            }
        }
        id: weekView
        anchors.fill: parent
        Repeater {
            model: 7
            delegate: Column {
                width: weekView.width/7
                Item{
                    width: parent.width
                    height: width
                    clip: true

                    Label{
                        text: weekViewPage.daysOfWeek[index]
                        anchors.centerIn: parent
                        color: index > 5 ? Theme.accentColor : Theme.textColor
                        font.pixelSize: (parent.height*0.45 < Theme.fontSizeLarge) ? parent.height*0.45 : Theme.fontSizeLarge
                    }
                }
                DayTimeline {
                    Rectangle {
                        color: index%2 ? "pink" : "brown"
                        anchors.fill: parent
                        z: -100
                    }
                    height: weekView.height * 6/7
                    width: parent.width
                    viewedDate: QtDate.addDays(weekViewPage.startDate, index)
                }
            }
        }
    }

    function calculateYTime(date) {
        var currentHour = date.getHours();
        var currentMin = date.getMinutes();

        var hourY = weekView.height/28
        var minY = hourY/70

        return hourY*currentHour+minY*currentMin+weekView.height/7
    }

    Timer {
        interval: 1000;
        repeat: true
        running: isToday
        onTriggered: {
            currentTimeLine.y = calculateYTime(new Date())
        }
    }
}
