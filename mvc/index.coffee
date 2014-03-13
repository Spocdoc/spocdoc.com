global['$'] = require 'dom-fork'
global['$']['FocusGroup'] = require 'dom_focus_group'
require 'dom_selection'
require 'dom_text'
require 'debug-fork'
require 'es5'
require 'dom_mobile'
require 'html5-fork'

dates = require 'dates-fork'
dates['strToDateRange'] = dates.strToDateRange
dates['strRangeToDateRange'] = dates.strRangeToDateRange
dates['dateToNumber'] = dates.dateToNumber
dates['daysInMonth'] = dates.daysInMonth
dates['dateToStr'] = dates.dateToStr

connectOauth = require 'connect_oauth'
connectOauth['startOauth'] = connectOauth.startOauth
connectOauth['stopOauth'] = connectOauth.stopOauth

Outlet = require 'outlet'
Outlet['block'] = Outlet.block
Outlet['atEnd'] = Outlet.atEnd
Outlet.prototype['addOutflow'] = Outlet::addOutflow

Cookies = require 'cookies-fork'
Cookies.prototype['unset'] = Cookies::.unset

Html = require 'marked-fork/html'
Html.prototype['posToOffset'] = Html::posToOffset
Html.prototype['offsetToPos'] = Html::offsetToPos
Html.prototype['update'] = Html::update

Editor = require 'marked-fork/editor'
Editor.prototype['posToOffset'] = Editor::posToOffset
Editor.prototype['offsetToPos'] = Editor::offsetToPos
Editor.prototype['update'] = Editor::update

strdiff = require 'diff-fork/lib/types/string'
strdiff['equalRanges'] = strdiff.equalRanges

_ = require 'lodash-fork'
_['endsWith'] = _.endsWith
_['makeId'] = _.makeId
_['quote'] = _.quote
_['regexp_S'] = _.regexp_S
_['regexp_s'] = _.regexp_s
_['throttle'] = _.throttle
_['unsafeHtmlEscape'] = _.unsafeHtmlEscape
_['startStop'] = _.startStop
_['startStop'] = _.startStop
_['stringToDateRange'] = _.stringToDateRange
_['dateRangeToString'] = _.dateRangeToString
_['nocaseCmp'] = _.nocaseCmp

# this is to adjust styling before the page has loaded (so safari doesn't animate the page load)
$(global.document).ready(-> $('body').removeClass 'preload') if global.document
