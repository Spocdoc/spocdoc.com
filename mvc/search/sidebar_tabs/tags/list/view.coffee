_ = require 'lodash-fork'

module.exports =
  inlets: [
    'tags'
  ]

  internal: [
    'sorted': (tags) -> if tags then Object.keys(tags).sort(_.nocaseCmp)
  ]

  outlets: [
    'scrollTop': (sorted) -> 0
  ]

  outletMethods: [
    (scrollTop, inWindow) ->
      if !inWindow
        @_scrollTop = 0
        return
      return if @ace.booting or scrollTop is @_scrollTop

      @$root.scrollTop(scrollTop || 0)
      return

    (sorted) ->
      return if @ace.booting and @template.bootstrapped

      hrefAdd = $.link(this,'depute','addTagToSearch',"XXX_TAG_XXX")
      hrefPush = $.link(this,'depute','push',"XXX_TAG_XXX")

      tags = @tags.value || 0

      html = ''
      if sorted
        for tag in sorted
          # html += """<li><a href="#{$.link(this,'depute','addTagToSearch',tag)}" data-tag="#{tag}" class="tag">#{tag}</a>"""
          html += """<li><a href="#{hrefAdd.replace("XXX_TAG_XXX",encodeURIComponent(tag))}" data-tag="#{tag}" class="tag">#{tag}</a>"""
          if tags[tag]
            html += """<a href="#{hrefPush.replace("XXX_TAG_XXX",encodeURIComponent(tag))}" data-tag="#{tag}" class="chevron"><span>&gt;</span></a>"""
          html += """</li>"""

      @$tags.html html
  ]

  $tags: link: ['a', ($target) ->
    if $target.hasClass 'chevron'
      ['depute','push',$target.attr('data-tag')]
    else
      ['depute','addTagToSearch',$target.attr('data-tag')]
    ]

  constructor: ->
    @$root.on 'scroll', =>
      @scrollTop.set @_scrollTop = @$root.scrollTop()
      return


