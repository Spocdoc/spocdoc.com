fs = require 'fs'
path = require 'path'
hash = require 'hash-fork'

module.exports = (manifest) ->
  spinnerGif = "img/spinner.gif"

  fileHash = (relPath) ->
    hash(fs.readFileSync path.resolve(manifest.private.assetRoot, relPath)).substr(0,24)

  if manifest.options.hashAssets
    spinnerGif = "#{fileHash spinnerGif}/#{spinnerGif}"

  spinner:
    """
    <svg width="2em" height="1em"><image style="height: 1em; width: 2em;" width="100%" height="100%" xlink:href="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBzdGFuZGFsb25lPSJubyI/PjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZlcnNpb249IjEuMSIgd2lkdGg9IjMycHgiIGhlaWdodD0iMTZweCI+PGc+PGNpcmNsZSBzdHlsZT0ib3BhY2l0eTowIiBjeD0iNiIgY3k9IjkiIHI9IjIiPjxhbmltYXRlIGF0dHJpYnV0ZVR5cGU9IkNTUyIgYXR0cmlidXRlTmFtZT0ib3BhY2l0eSIgZnJvbT0iMSIgdG89IjAiIGR1cj0iMS41cyIgcmVwZWF0Q291bnQ9ImluZGVmaW5pdGUiIGJlZ2luPSIwcyIgLz48L2NpcmNsZT48Y2lyY2xlIHN0eWxlPSJvcGFjaXR5OjAiIGN4PSIxNiIgY3k9IjkiIHI9IjIiPjxhbmltYXRlIGF0dHJpYnV0ZVR5cGU9IkNTUyIgYXR0cmlidXRlTmFtZT0ib3BhY2l0eSIgZnJvbT0iMSIgdG89IjAiIGR1cj0iMS41cyIgcmVwZWF0Q291bnQ9ImluZGVmaW5pdGUiIGJlZ2luPSIwLjJzIiAvPjwvY2lyY2xlPjxjaXJjbGUgc3R5bGU9Im9wYWNpdHk6MCIgY3g9IjI2IiBjeT0iOSIgcj0iMiI+PGFuaW1hdGUgYXR0cmlidXRlVHlwZT0iQ1NTIiBhdHRyaWJ1dGVOYW1lPSJvcGFjaXR5IiBmcm9tPSIxIiB0bz0iMCIgZHVyPSIxLjVzIiByZXBlYXRDb3VudD0iaW5kZWZpbml0ZSIgYmVnaW49IjAuNHMiIC8+PC9jaXJjbGU+PC9nPjwvc3ZnPgo=" src="#{manifest.options.assetServerRoot||''}/#{spinnerGif}"></image></svg>
    """

  asset: (relPath) ->
    "#{manifest.options.assetServerRoot}/#{fileHash relPath}/#{relPath}"

  transparentGif: 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7'

  progress:
    """
    <div class="progress-meter"><div class="progress-meter-bar"></div></div>
    """


