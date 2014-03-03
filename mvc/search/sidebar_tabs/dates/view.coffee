module.exports =
  outlets: [
    'dateStart'
    'dateEnd'
    'nonEmpty'
  ]

  $calendar: view: -> new @View['calendar'] this, 'calendar',
    dateStart: @dateStart
    dateEnd: @dateEnd
    nonEmpty: @nonEmpty
