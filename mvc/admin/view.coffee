_ = require 'lodash-fork'

module.exports =
  outlets: [
    'search'
    'error'
    'users'
  ]

  $error: 'text'
  $refresh: link: ['refreshPending']

  outletMethods: [
    (error) -> @$root.toggleClass 'has-error', !!error
  ]

  $pendingUsers:
    html: (users, search) ->
      html = ''
      if users
        for user in users
          {id, name, email} = user

          id ||= ''
          name ||= ''
          email ||= ''

          if search
            continue unless id.indexOf(search) or name.indexOf(search) or email.indexOf(search)

          quoteId = _.quote _.unsafeHtmlEscape id

          html += """<tr data-id=#{quoteId}>"""
          html += """<td class="invite"><a href="javascript:void(0)" data-id=#{quoteId}>invite</a></td>"""
          html += """<td>#{_.unsafeHtmlEscape email}</td>"""
          html += """<td>#{_.unsafeHtmlEscape name}</td>"""
          html += """</tr>"""
      html
    link: ['a', ($target) -> ['invite',$target.attr('data-id')]]

  invite: (id) ->
    return unless id
    quoteId = _.quote id
    @session.get()?.admin 'invite', id, (err) =>
      $row = @$root.find("tr[data-id=#{quoteId}]")

      if err?
        @error.set err.msg or "Error"
        $row.addClass 'error-row'
      else
        $row.removeClass 'error'
        $row.addClass 'invited'
      return
      

  refreshPending: ->
    return if @updating
    @updating = true

    @session.get()?.admin 'pendingUsers', (err, users) =>
      if err?
        @error.set err.msg or "Error"
        return
      @users.set users
      @updating = false

  constructor: ->
    @refreshPending()
    return
