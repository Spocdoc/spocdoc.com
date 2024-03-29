# UI

 [] make the target area for the menu button larger (see shoptiques.com)
 [] add oauth service icons to the login menu
 [] close the menu when you scroll
 [] allow click and drag to access menu items
 [] small dialogs that overflow cause the title bar to scroll
 [] add "or" text to the HR in the invite dialog
 [] add a graphic showing merge of services see img/2014-02-27-01.JPG
 [] the spocdoc logo shouldn't be a link when you're on the landing page
 [] reorder the sidebar so that the content shows up at the top first
 [] esc key should dismiss the dialog (but keyboard focus should remain unchanged)
 [] when the "log in" text in the menu isn't visible (instead showing just an arrow), the header should be present without back button
 [] when showing the menu navigation, the current tab should be highlighted on the left (blue vertical line)
 [] in firefox, the blur when a dialog is open causes any active menus to become highly translucent...
 [] small dialogs should be centered vertically
 [] make the inviteme button more inviting

    e.g., add a gradient to make it less flat and more i0S 6 button-like. see <http://demo.hongkiat.com/css3-glossy-effect/>

 [] when navigating with the outline, highlight the destination header briefly (or do some animation so you can see if it it can't be scrolled to the top)
 [] figure out what to show when the document is invisible (e.g., you're logged out and it's not public)
 [] stop scrolling the calendar back at the earliest result (i.e., the range shown should only be blocks containing results until today)
 [] make the tags part of the content (the way you'd see keywords in an academic article)
 [] clicking compose on the homepage is a problem with long documents: the menu is fixed position
 [] the require password field blinks when you load the page -- it'll appear when the JavaScript loads then disappear after the userPriv is set
 [] when the sidebar visibility is toggled, the tabs don't recalculate whether they should be side-by-side or stacked
 [] add a command to open the sidebar and highlight the search within in a document
 [] when the sidebar is opened, immediately focus on search and update the tabs layout
 [] set the page title (allows easier history lookup in the browser)
 [] add tabs showing all docs, recent docs, and starred in the search & rename it "docs" then rename "doc" to "working" or "current"
 [] move the compose feather to a separate tab that adds a new document or into the "working" tab

# implementation

 [] currently Google has no way of seeing all the public documents... they need to be in an index somewhere
 [] dialog has a "small" outlet. this was to make the width of the centering div smaller
 [] when correcting a spelling error in the editor, switching back to HTML mode doesn't show the update until a key is pressed
 [] the blue bar isn't in the right place when switching between editor & html modes if you've scrolled the page
 [] evidently you can't get the boundingClientRect of whitespace nodes that don't render. Furthermore, if your cursor is within a non-rendering whitespace node, it will go to the wrong start point (try putting the cursor at the end of a blockquote)
 [] the word search produces erroneous word and sentence matches. e.g., search for gertrude in the hamlet doc
 [] split the editor text search by double newline so the results don't display entire sections
 [] the invite hello screen should use the prefUsername if it's available 
 [] if there's an error creating a document, ace will go into an infinite loop repeatedly trying to create if there's a client-side update pending
 [] sessions are never cleared from the database and there's no way to know which ones are old or out of use...
 [] fix the cheerio data and attributes problem (allow use of `data()` function, but also set the attributes)
 [] image upload:
      - handle text updates or cursor moves during async file read op...
      - show errors on image read or bad drop type
      - add progress meter while uploading to the server
 [] image placement
    should only allow images to be inserted at reasonable offsets (e.g., not in the metadata)
 [] clicking an image in the search results should go to that image. currently it just goes to the top of the article
 [] in search, `public:` should be parsed as a metadata search, not as text...
 [] mixins should be named separately -- `mixin.coffee` so they can be used by both views and controllers...
 [] when selecting 'past the end' of an image or video, the position doesn't map to the end of the element in the text
    [] pressing delete when past the end of an image or video should delete the whole image/video (but it currently deletes the char before start)
 [] the trailing `#` in tags should be optional
    currently tag blocks don't parse if you have a no-space tag ending with `#` (e.g., `#meetup/Media#`)
 [] simplify the process for adding links with selectors. it's overly complex now (to allow for hrefs so you can apple-click). I'd prefer this:

        $foo: link: 'a': ($target) -> @invite $target.attr('...')

    but because the function isn't named, there's no way to invoke it on the server with an href
 [] I'd like a way to refer to the last value within an outlet function, so you could have a function assigned to an outlet and when it runs it can conditionally return whatever the current value is
 [] if a paragraph is turned into a heading at the top of a document (e.g., the polyfills document) all the rest of the content is updated in the
 [] Canonical URL should be separate from redirect URL so pages that just toggle menus, etc don't show up separately in google 
 [] Tags sort by date of last use show limited number with search

## optimization

 [] the new insertPlaceholders algo in marked-fork never uses block update()... so it'll wind up regenerating the entire top-level section (or the whole document if it's in a single section)
 [] the fixDoms routine could reduce the number of dom appendChild and insertBefore calls by generating all the html at once and calling `$.parseHTML` and calling `setDoms`
 [] when the client boots, it rereads everything including the queries at once. this is a problem for the queries: if the server processes the query re-read first, it'll preemptively send a create with the full source of the matching documents because it doesn't know the client has them yet (hasn't seen the re-read). see ![](img/2014-03-25-03.png). solution is to finish doing all the model re-reads before doing queries
 [] the visitor for creating CSS goes through the *entire* html tree (including inlines), which is unnecessary. could have something that tells it not to descend
 [] links in the outline that use defs won't find the def. the outline should reference the defs in the main html document

# improvements

 [] make the sidebar dots less obtrusive -- e.g., move them up to the top as you scroll down so they're not right at the reading level
 [] get rid of the menu button on mobile. instead, wrap the navigation below the site logo see skinnyties.com
 [] consolidate the cookies so there's a single cookie managed by connect

    it should be secure. and in that case you don't have to sign the cookie, just include the session id in the @req.session

    to notify other windows when the session has changed, delete the old session after the new session is present

    modify the `present` outlet in ace_mvc/model so that it shows present only when the document is known to be present on both the server and the client (this will mean using a separate field -- e.g., `clientPresent`) as a spinner (so when you create a new document on the client, this field is true even before it appears on the server)

 [] add control-L to scroll to center the cursor vertically in editor
 [] get smartypants to work with replacements that aren't character-to-character
 [] the text updating algorithm can be very slow in large documents, presumably because it has to classify the whole document
 [] evernote import should support their hierarchical tags
 [] when doing a search, narrow the outline to show only sections containing matches. then navigate to those parts
 [] if the title matches, show the head as a block *and continue to search the rest*
    currently, if the title matches, it just shows the document head
 [] links to local pages within documents should allow apple-click (set the href and do nothing in the function if key pressed)
 [] use for photo blogging (see https://synop.si/doc/Photo-blog-test/5353027139fee3405a9c4567). 
 [] graphical CSS editor
 [] make the search results sort by text ranking then by date. text content match should add 0. title and tag matches should add. then sort by date
 [] narrow search by word count
 [] make it usable offline
 [] prevent duplicate imports

# Mobile

 [] the sidebar can get unusably short. it may be a good idea to zoom it out (just make all the fonts smaller) when it's on mobile (although this would shrink the calendar dates...)

 [] the lack of memory management on the models means the browser crashes after some use


# Browser bugs

 [] scrollIntoView with a fixed position element scrolls the document and the fixed position layer

# server bugs

 [] figure out origin of this error:

        Wed, 09 Apr 2014 01:42:49 GMT error Error: Can't set headers after they are sent.
         Error: Can't set headers after they are sent.
          at ServerResponse.OutgoingMessage.setHeader (http.js:691:11)
          at ServerResponse.res.setHeader (/home/mikerobe/Server/node/app_deployment/2014-04-08-1397006709/node_modules/connect/lib/patch.js:63:22)
          at Cookies.module.exports.Cookies.set (/home/mikerobe/Server/node/app_deployment/2014-04-08-1397006709/node_modules/cookies-fork/index.coffee:11:12)
          at Context.cookieUpdater (/home/mikerobe/Server/node/app_deployment/2014-04-08-1397006709/mvc/models/sessions.coffee:26:20)
          at Outlet.module.exports.Outlet._runFunc (/home/mikerobe/Server/node/app_deployment/2014-04-08-1397006709/node_modules/outlet/index.coffee:327:11)
          at Outlet.module.exports.Outlet._runSource (/home/mikerobe/Server/node/app_deployment/2014-04-08-1397006709/node_modules/outlet/index.coffee:288:16)
          at Function.module.exports.Outlet.closeBlock (/home/mikerobe/Server/node/app_deployment/2014-04-08-1397006709/node_modules/outlet/index.coffee:45:7)
          at /home/mikerobe/Server/node/app_deployment/2014-04-08-1397006709/node_modules/ace_mvc/lib/socket/emulator.coffee:55:18
          at /home/mikerobe/Server/node/app_deployment/2014-04-08-1397006709/lib/mediators/sessions.coffee:54:11
          at /home/mikerobe/Server/node/app_deployment/2014-04-08-1397006709/node_modules/ace_mvc/lib/db/index.coffee:255:11
          at fn (/home/mikerobe/Server/node/app_deployment/2014-04-08-1397006709/node_modules/async/lib/async.js:626:34)
          at Object._onImmediate (/home/mikerobe/Server/node/app_deployment/2014-04-08-1397006709/node_modules/async/lib/async.js:542:34)
          at processImmediate [as _immediateCallback] (timers.js:330:15)

