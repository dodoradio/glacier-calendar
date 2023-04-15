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

Item{
    id: dayTimeline

    property date viewedDate: new Date()
    property bool isToday: compareDate(new Date(), dayTimeline.viewedDate)


    AgendaModel{
        id: agendaModel
        startDate: viewedDate
        endDate: QtDate.addDays(viewedDate, 1)
    }

    Repeater{
        id: eventsRepeater
        model: agendaModel
        property int eventsWidth: parent.width //- Theme.itemWidthSmall - Theme.itemSpacingExtraSmall

        delegate: Rectangle{
            id: eventView
            color: model.event.color
            border.color: Theme.textColor
            width:  (eventsRepeater.eventsWidth / getNumberOfOverlapping(model.event.startTime, model.event.endTime)) - Theme.itemSpacingExtraSmall
            height: calculateHeightTime(model.event.startTime,model.event.endTime)
            y: calculateYTime(model.event.startTime)
            x: getIndexOfOverlapping(model.event.startTime,model.event.endTime, model.event.uniqueId) * (width + Theme.itemSpacingExtraSmall)
            z: 2
            clip: true;

            Label{
                id: eventLabel
                text: model.event.displayLabel

                anchors.fill: parent;
                anchors {
                    fill: parent;
                    topMargin: (eventView.height > Theme.itemHeightSmall) ?  Theme.itemSpacingExtraSmall : 0;
                    bottomMargin: anchors.topMargin;
                    leftMargin: Theme.itemSpacingExtraSmall
                    rightMargin: Theme.itemSpacingExtraSmall;
                }

            }
            MouseArea {
                anchors.fill: parent;
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("AddEventPage.qml"), { oldEvent: model.event })
                }
            }
        }
    }

    function getNumberOfOverlapping(start, end) {
        var num = 0;
        for (var i = 0; i < agendaModel.count; i++) {
            var event = agendaModel.get(i, AgendaModel.EventObjectRole);
            if (((start < event.endTime) && (start >= event.startTime)) || ((end > event.startTime) && (end <= event.endTime))) {
                num++;
            }

        }
        return num;
    }

    function getIndexOfOverlapping(start, end, uniqueId) {
        var num = 0;
        for (var i = 0; i < agendaModel.count; i++) {
            var event = agendaModel.get(i, AgendaModel.EventObjectRole);
            if (event.uniqueId === uniqueId) {
                break;
            }
            if (((start < event.endTime) && (start >= event.startTime)) || ((end > event.startTime) && (end <= event.endTime))) {
                num++;
            }
        }
        return num;
    }

    function calculateYTime(date) {
        var currentHour = date.getHours();
        var currentMin = date.getMinutes();

        var hourY = dayTimeline.height/24
        var minY = hourY/60

        return hourY*currentHour+minY*currentMin
    }

    function calculateHeightTime(start, end) {
        var duration = (end.getTime() - start.getTime()) / 1000;
        var eventHeight = dayTimeline.height * duration / 86400;
//        console.log("duration: " + duration + " " + eventHeight)
        return eventHeight;
    }
}
