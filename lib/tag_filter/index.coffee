Outlet = require 'outlet'
_ = require 'lodash-fork'
fuzzyRegex = require './fuzzy_regex'
debug = global.debug "ace:app:tag_filter"

# IE bug: \S includes non-breaking space
regexNonSpace = RegExp(_.regexp_S)
regexWordStart = RegExp(_.regexp_s + _.regexp_S) # (no lookbehinds)

class SearchBase
  constructor: (@filter) ->
    @parts = []
    @rFuzzies = []
    @rWords = []

  matchPart: (i, tag, matchIndex) ->
    part = tag.part
    search = @parts[i]

    if (0 is k = j = part.indexOf(search)) or ~(k = part.search @rWords[i])
      qual = 0
      matchStart = k
      matchLen = search.length
    else if j > 0
      qual = 1
      matchStart = j
      matchLen = search.length
    else if m = @rFuzzies[i].exec part
      qual = 2
      matchStart = m.index
      matchLen = m[0].length
    else
      return -1

    @filter._matchRange[matchIndex] = matchStart
    @filter._matchRange[matchIndex+1] = matchLen
    qual

class SearchFirst extends SearchBase
  update: (search, @searchStart) ->
    @wordStarts ||= [0]
    search = search.substr searchStart if searchStart

    if @filter.prefix.value
      @startIndex = @wordStarts[0] = 0
      @wordStarts.length = 1
      subsearch = _.startsWith search, @parts[0]
      @parts[0] = search
    else
      j = 1
      i = if (subsearch = @parts[0]? and _.startsWith search, @parts[0]) then @wordStarts[(j = @wordStarts.length)-1] else 0

      `for (var k = 0; k < j; ++k) {
        escaped = _.regexpEscape(this.parts[k] = search.substr(this.wordStarts[k]));
        this.rWords[k] = new RegExp("\\b" + escaped);
        this.rFuzzies[k] = fuzzyRegex(escaped);
      }`

      str = @parts[j-1]; len = str.length
      while (nextStart = 1 + str.search regexWordStart) and @filter.minLength < len - nextStart
        escaped = _.regexpEscape @parts[j] = str = str.substr nextStart
        @wordStarts[j] = i += nextStart
        @rWords[j] = new RegExp "\\b#{escaped}"
        @rFuzzies[j] = fuzzyRegex escaped
        subsearch = false
        ++j

      @startIndex = if subsearch then @earlyWord else 0
      @earlyWord = @wordStarts.length = j
    subsearch

  matchStart: ->
    @searchStart + (@wordStarts[@earlyWord] ? @parts[0].length)

  match: (tag, matchIndex) ->
    `for (var j = this.startIndex, jE = this.wordStarts.length, qual; j < jE; ++j) {
      if (~(qual = this.matchPart(j, tag, matchIndex))) {
        this.filter._rowMatchStart = this.searchStart + this.wordStarts[j];
        if (this.earlyWord > j) this.earlyWord = j;
        return qual;
      }
    }`
    -1

class SearchRest extends SearchBase
  update: (searchArr) ->
    subsearch = true
    @length = searchArr.length

    `for (var i = 1, iE = this.length, part, escaped; i < iE; ++i) {
      escaped = _.regexpEscape(part = searchArr[i]);
      this.rFuzzies[i] = fuzzyRegex(escaped);
      this.rWords[i] = new RegExp("\\b" + escaped);
      subsearch = subsearch && (!this.parts[i] || _.startsWith(part,this.parts[i]));
    }`

    @parts = searchArr
    subsearch

  addTags: (tags, depth, qual, filter) ->
    ndepth = depth + 1
    stop = ndepth is @length
    matchIndex = tags.matchIndex
    matched = 0

    for tag in tags when (filter or tag.on) and (stop or tag['expands'])
      if ~(partQual = @matchPart(depth, tag, matchIndex))
        partQual = qual if partQual < qual
        if stop
          matched = 1
          @filter._addTag tag, partQual
        else
          matched |= tag.on = @addTags tag['expands'], ndepth, partQual, filter
      else
        tag.on = 0

    matched

module.exports = class TagFilter
  constructor: (@input, @search, @minLength = 2) ->
    @['results'] = @results = new Outlet []

    @['matchStart'] = 0
    @_matchRange = []

    @_searchFirst = new SearchFirst this
    @_searchRest = new SearchRest this

    @prefix = @['prefix'] = new Outlet ''
    @prefixes = {}

    @_stack = []

    @['input'] = @input
    @['search'] = @search

    @_lastSearch = @_lastPrefix = ''
    @_lastDepth = 0

    @input.addOutflow updateInput = new Outlet @_updateInput, this
    @search.addOutflow updateSearch = new Outlet @_updateSearch, this
    @prefix.addOutflow updateSearch
    updateInput.addOutflow updateSearch

  _updateInput: do ->
    tags = []
    pwd = []

    sortTags = (a,b) -> a.part.localeCompare(b.part)

    ->
      debug "updateInput with length #{@input.value?.length}"
      unless @input.value and @input.value.length
        @prefixes = {}
        return 0

      k = j = pwd.length = 0
      (tags[0] = @prefixes[''] = []).matchIndex = 0
      input = @input.value.concat().sort()

      for text in input
        path = text.split '/'

        if iE = path.length-1
          `for (var i = 0, dirTag; i < iE; ++i) {
            if (pwd[i] !== path[i]) {
              for (k = i+1; k < j; ++k) tags[k].sort(sortTags);
              for (;i < iE; ++i) {
                tags[i].push(dirTag = {'tags': tags[i], on: 1});
                stubTag = {part: '', on: 1};

                dirTag.part = (pwd[i] = path[i]).toLowerCase();
                (stubTag['path'] = dirTag['path'] = path.slice(0,i+1))[i+1] = '';
                (this.prefixes[stubTag['text'] = dirTag['text'] = dirTag['path'].join('/')] = dirTag['expands'] = tags[i+1] = stubTag['tags'] = [stubTag]).matchIndex = 2*i+2;
              }
              break;
            }
          }`
        else
          `for (k = iE+1; k < j; ++k) tags[k].sort(sortTags);`

        j = iE+1

        if path[iE]
          tags[iE].push
            part: path[iE].toLowerCase()
            on: 1
            'text': text
            'path': path
            'tags': tags[iE]

      `for (k = 0; k < j; ++k) tags[k].sort(sortTags);`

      _.makeId()

  _addTag: (tag, qual) ->
    matched = tag['matched'] ||= []
    `for (var i = 0, iE = tag['tags'].matchIndex+1; i <= iE; ++i) matched[i] = this._matchRange[i];`
    tag.on = 2
    tag['matchStart'] = @_rowMatchStart

    results = @results.value
    (results[qual] ||= []).push tag
    ++results['count']
    return

  _searchTags: (tags, depth, filter) ->
    matchIndex = tags.matchIndex
    matched = 0

    for tag in tags when (filter or tag.on) and (!depth or tag['expands'])
      if ~(qual = @_searchFirst.match(tag, matchIndex))
        if depth
          matched |= tag.on = @_searchRest.addTags tag['expands'], 1, qual, filter
        else
          matched = 1
          @_addTag tag, qual
      else if subtags = tag['expands']
        delete @_matchRange[matchIndex]
        delete @_matchRange[matchIndex+1]
        matched |= tag.on = @_searchTags subtags, depth, filter | (tag.on-1)
      else
        tag.on = 0

    matched


  _updateSearch: ->
    search = (@search.value || '').toLowerCase()
    prefix = @prefix.value || ''
    searchStart = search.length unless ~(searchStart = search.search regexNonSpace)
    results = @results.value

    debug "updateSearch: prefix [#{prefix}] searchStart [#{searchStart}] search [#{search}]"

    # check length
    if !prefix and search.length - searchStart < @minLength
      @results.set [] if results.length
      return

    searchArr = search.split '/'
    depth = searchArr.length - 1

    # update search specs
    subsearch = (@_searchFirst.update(searchArr[0], searchStart) & @_searchRest.update(searchArr)) and @_lastSearch and prefix is @_lastPrefix and @_lastDepth is depth

    debug "subsearch: #{!!subsearch}"

    tags = @prefixes[prefix]
    @_searchFirst.startIndex = 0 unless subsearch
    lastDepth = +(subsearch && @_lastDepth)

    unless search # optimization
      results[0] = tags
      results.length = 1
      results['count'] = tags.length
      results['noMatchRange'] = true
      @_searchFirst.earlyWord = 0

    else

      results['noMatchRange'] = false

      if @_lastSearch
        result.length = 0 for result in results when result
      else
        results.length = 0

      @_matchRange.length = 0
      results['count'] = 0
      @_searchTags tags, depth, !subsearch if tags

    @_lastPrefix = prefix
    @_lastSearch = search
    @_lastDepth = depth
    @['matchStart'] = @_searchFirst.matchStart()
    @results.modified()
    return

  'push': Outlet.block (prefix) ->
    @_stack.push {prefix: @prefix.value, search: @search.value}
    @prefix.set prefix
    @search.set ''
    return

  'pop': Outlet.block ->
    if @_stack[0]
      {prefix, search} = @_stack.pop()
      @prefix.set prefix
      @search.set search
      true

  'reset': Outlet.block ->
    @prefix.set ''
    @search.set ''
    @_stack.length = 0
    return


