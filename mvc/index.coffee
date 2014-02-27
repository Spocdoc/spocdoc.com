global['$'] = require 'dom-fork'
global['$']['FocusGroup'] = require 'dom_focus_group'
require 'dom_selection'
require 'dom_text'
require 'debug-fork'
require 'es5'
require 'dom_mobile'
require 'html5'

# this is to adjust styling before the page has loaded (so safari doesn't animate the page load)
$(global.document).ready(-> $('body').removeClass 'preload') if global.document
