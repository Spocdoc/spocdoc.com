_ = require 'lodash-fork'
dates = require 'dates-fork'
constants = require '../constants'

userInviteDateSort = (a,b) ->
  ai = a.invited
  bi = b.invited

  unless ai instanceof Date
    return -1 if bi instanceof Date

    # neither has a date
    return (a.email||'').localeCompare(b.email||'')

  else
    return 1 unless bi instanceof Date

    # both have dates
    ai = ai.getTime()
    bi = bi.getTime()

    return -1 if ai < bi
    return 1 if ai > bi
    0

module.exports =
  mixins: 'mixins/editable val': [ 'maxActiveUsers']
  outlets: [
    'search'
    'error'
    'users'
  ]

  internal: [
    'synopsiUser': -> @Model['users_priv'].read constants.synopsiUser
    'maxActiveUsers'
    'maxActiveUsersNow': -> @synopsiUser.get('maxActiveUsers')
  ]


  $error: 'text'
  $refresh: link: ['refresh']
  $activesForm: link: ['submitActives']
  $maxActiveUsersNow: 'text'

  outletMethods: [
    (error) -> @$root.toggleClass 'has-error', !!error
    (maxActiveUsers, maxActiveUsersNow) ->
      @$submit.toggleClass 'can-submit', (maxActiveUsers isnt maxActiveUsersNow)
  ]

  $pendingUsers:
    html: (users, search) ->
      html = ''
      if users
        # sort users by invited date asc
        for user in users.sort(userInviteDateSort)
          {id, name, email, invited} = user

          id ||= ''
          name ||= ''
          email ||= ''

          if invited instanceof Date
            invited = dates.dateToStr invited
          else
            invited = ''

          if search
            continue unless id.indexOf(search) or name.indexOf(search) or email.indexOf(search)

          quoteId = _.quote _.unsafeHtmlEscape id

          html += """<tr data-id=#{quoteId}>"""
          html += """<td class="invite"><a href="javascript:void(0)" data-id=#{quoteId}>invite</a></td>"""
          html += """<td>#{_.unsafeHtmlEscape invited}</td>"""
          html += """<td>#{_.unsafeHtmlEscape email}</td>"""
          html += """<td>#{_.unsafeHtmlEscape name}</td>"""
          html += """</tr>"""
      html
    link: ['a', ($target) -> ['invite',$target.attr('data-id')]]

  submitActives: ->
    if synopsiUser = @synopsiUser.get()
      @maxActiveUsersNow.set @maxActiveUsers.get()
    return

  invite: (id) ->
    return unless id
    quoteId = _.quote id
    $row = @$root.find("tr[data-id=#{quoteId}]")
    $row.addClass 'sending_row'

    @session.get()?.admin 'invite', id, (err) =>
      $row.removeClass 'sending_row'

      if err?
        @error.set err.msg or "Error"
        $row.addClass 'error-row'
      else
        $row.removeClass 'error'
        $row.addClass 'invited'
      return
      

  refresh: ->
    return if @updating
    @updating = true

    @$refreshDiv.addClass 'in-progress'

    @session.get()?.admin 'pendingUsers', (err, info) =>
      @$refreshDiv.removeClass 'in-progress'
      @updating = false

      if err?
        @error.set err.msg or "Error"
        return

      @users.set info.pendingUsers
      @$numActiveUsers.text numActiveUsers if (numActiveUsers = info.numActiveUsers)?
      return

  constructor: ->
    @refresh()
    return
