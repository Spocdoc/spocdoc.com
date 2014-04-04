module.exports = (config) ->
  slide = 0

  config.nextSlide = ->
    ++slide
    @$content.css 'left', "#{-slide * 100}%"
    return

  config.prevSlide = ->
    return if $(event.target).hasClass 'no-back'
    --slide
    @$content.css 'left', "#{-slide * 100}%"
    return

  config.constructor.unshift ->
    @$cssSlides.on 'click', '.content > .heading > h1', (event) =>
      @prevSlide()
      false

    @$cssSlides.on 'click', '.next', =>
      @nextSlide()
      false

  return
