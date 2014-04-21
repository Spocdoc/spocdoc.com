title: Synopsi pre-deployment todos

# before presenting to pedro

 [x] video embedded HTML5 or vimeo if can be private
 [] push uploaded images (or just demo with already uploaded content...)
 [x] log in with angellist for immediate access
 [x] sample content (intro document)
 [x] user icon
 [x] fix google oauth sign-in
 [x] deletion of documents
 [x] blog only shows docs by synopsi user
 [x] ordering of search results (by date)
 [x] if the search result matches the title, the head should be shown (not just first element) in snip

# Bugs
 [x] search snips updating bug -- the snips in the search are being updated for a document even when not shown as I go along
 [] clicking an image should go to the right place in the document
 [] clicking a link in the search results should follow the link

 [] if the intra-document doesn't match anything, it should display nothing (rather than the head -- make it an option)
 [] the within document search doesn't find results in edit mode
 [] the within document search displays wrong list item numbers
 [] hierarchical header parsing is incompatible with fences
 [] something happened updating a document that had the \#blog tag in a block -- whenever \#blog was entered in an inline, the doc stopped updating when the g character was typed... 
 [] **often** after a server refresh, the client doesn't reconnect (?). anyway, document updates aren't pushed out and there's no indication to the user that their updates aren't being saved 
 [] searching for video skips the entire section of bullets following the matched header

	![](9825a9344bfd24a204d76bf2.png)

 [x] the admin page removes the maxactiveusers when you load it in prod...


# user interface issues

 [] the signup takes a long time. people can't tell how to submit (suggestion that I have a giant green button instead of a subtle arrow)
 [x] the compose button should be more obvious and should lead to a dialog instead of a menu with a full screen icon instead of done and edit
 [] the code block should be a different color
 [] capture the keyboard so esc switches modes even if you're not focused on the text
 [] page titles
 [] make sure the sidebar updates and focus on the search when it's opened

# critical

 1. ~~visibility~~
 2. ~~import~~
 3. ~~deletion~~

	[] undo delete
	[] disable delete menu item if not an editor

 3. ~~limit blog to articles from spocdoc user~~
 4. ~~limit search to your authored articles (not all public articles)~~
 4. ~~utility pages~~

	[x] move *Our Story* so it's only accessible from the splash page
	[x] make the logo a color

 1. document references

	[] add linking to documents with @person/1 (where 1 is some short article id) and use this on the homepage to link to contact us

 5. ~~upgrade mongo~~
 6. complete markdown
	including images

		[x] drag multiple images
		[x] import images doesn't work in create menu
		[x] import images
		[x] must be inlined with data URIs
		[] media viewer
		[] image push issue for live blogging
		[] tables
		[] definitions
		[] widgets
		[] drag images from other web pages (so, presumably urls)
		[] upload SVGs
	[x] proper reflinks
	[] editor improvements
	[] checkboxes
		[] as a list item
	[] commenting out blocks of text (so they stay in the source and are parsed for tags, etc. but aren't displayed) (just start of line with // and subsequent indented blocks are nested)
	[] bullet points and numbered lists that style based on the 
	[] asides (e.g., TIP) (just start of line (no space) with all caps, at least 2 letters and use subsequent indented blocks as nested content)
 1. ~~invite emails~~
 9. addition of other editors (authors) to a document
 7. tag and metadata completion in search
 8. tag completion in editor
 1. ~~custom css by url~~
 1. ~~make the homepage a document~~
 1. create a flowcharts widget
 1. subscription
 1. groups
 1. image search (tile view like pinterest)
 1. collections
 1. editor improvements
	[] select & tab, ~, *
	[] autoindent
	[] c-l to center
 1. conflict resolution
 1. history
 1. focus view ("full screen")
 1. comments
	[] highlight sections of an article

# discussion on adding editors

- if editors are directly added, there could be huge spam: anyone could add any document to anyone else's search list by adding them as an editor

## groups
could use groups instead: you create a group and invite someone. 

## twitter follow style
you can only add editors to a document if they follow you

