module.exports =
  name: (service) ->
    switch service
      when 'twitter' then 'Twitter'
      when 'evernote' then 'Evernote'
      when 'linkedin' then 'LinkedIn'
      when 'tumblr' then 'Tumblr'
      when 'github' then 'GitHub'
      else false

