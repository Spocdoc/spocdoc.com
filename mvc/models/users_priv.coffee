TagList = require '../../lib/tag_list'
TagMap = require 'tag_map'
tagUtils = require '../../lib/tags'
Outlet = require 'outlet'
_ = require 'lodash-fork'

module.exports =
  getDisplayTags: (tags) ->
    @tagListDep.get()
    @tagMapDep.get()
    tagUtils.getDisplayTags tags, @tagMap, @tagList

  getSearchTags: (tags) ->
    @tagMapDep.get()
    tagUtils.getSearchTags tags, @tagMap

  addTags: (tags) ->
    modified = false

    for tag in tags
      modified = @tagList.add(tag) || modified

    if modified
      if (outlet = @get('tagList')).value
        outlet.modified()
      else
        outlet.set @tagList.tagList

      if (outlet = @get('tagCase')).value
        outlet.modified()
      else
        outlet.set @tagList.tagCase

    return

  caseTag: (tag) -> @tagList.case tag

  removeTag: (tag) ->
    if @tagList.remove(tag)
      @get('tagList').modified()
    return

  constructor: ->
    tagListOutlet = @get('tagList')
    tagCaseOutlet = @get('tagCase')
    tagMapOutlet = @get('tagMap')

    @tagList = new TagList tagListOutlet.value, tagCaseOutlet.value
    @tagMap = new TagMap tagMapOutlet.value?.toLowerCase()

    tagListOutlet.addOutflow @tagListDep = new Outlet =>
      @tagList.update tagListOutlet.value, tagCaseOutlet.value
      _.makeId()

    tagCaseOutlet.addOutflow @tagListDep

    tagMapOutlet.addOutflow @tagMapDep = new Outlet =>
      @tagMap.update tagMapOutlet.value?.toLowerCase()
      _.makeId()

