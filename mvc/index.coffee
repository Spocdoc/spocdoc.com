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

Inline = require 'marked-fork/html/inline'
Inline.prototype['highlight'] = Inline::highlight

Editor = require 'marked-fork/editor'
Editor.prototype['posToOffset'] = Editor::posToOffset
Editor.prototype['offsetToPos'] = Editor::offsetToPos
Editor.prototype['update'] = Editor::update

Snips = require 'marked-fork/snips'
Snips.prototype['posToOffset'] = Snips::posToOffset

Outline = require 'marked-fork/outline'
Outline.prototype['update'] = Outline::update
Outline.prototype['posToOffset'] = Outline::posToOffset
Outline.prototype['offsetToPos'] = Outline::offsetToPos

utils = require '../lib/utils'
utils['splitLengths'] = utils.splitLengths
utils['checkEmail'] = utils.checkEmail
utils['defaultArr'] = utils.defaultArr
utils['makeDoc'] = utils.makeDoc
utils['makePublic'] = utils.makePublic

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
_['makeCssClass'] = _.makeCssClass
_['imgMime'] = _.imgMime
_['uint8ToB64'] = _.uint8ToB64

# this is to adjust styling before the page has loaded (so safari doesn't animate the page load)
$(global.document).ready(-> $('body').removeClass 'preload') if global.document
