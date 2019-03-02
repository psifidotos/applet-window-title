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

function qBound(min,value,max)
{
    return Math.max(Math.min(max, root.width - 150), min);
}

function cleanStringListItem(item)
{
    //console.log(item + " * " + item.length + " * " + item.indexOf('"') + " * " + item.lastIndexOf('"'));
    if (item.length>=2 && item.indexOf('"')===0 && item.lastIndexOf('"')===item.length-1) {
        return item.substring(1, item.length-1);
    } else {
        return item;
    }
}

function applySubstitutes(text)
{
    var minSize = Math.min(plasmoid.configuration.subsMatch.length, plasmoid.configuration.subsReplace.length);

    for (var i = 0; i<minSize; ++i){
        var fromS = cleanStringListItem(plasmoid.configuration.subsMatch[i]);
        var toS = cleanStringListItem(plasmoid.configuration.subsReplace[i]);
        var regEx = new RegExp(fromS, "ig"); //case insensitive
        text = text.replace(regEx,toS);
    }

    return text;
}
