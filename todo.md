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

# implementation

 [] dialog has a "small" outlet. this was to make the width of the centering div smaller

# improvements

 [] make the sidebar dots less obtrusive -- e.g., move them up to the top as you scroll down so they're not right at the reading level
 [] get rid of the menu button on mobile. instead, wrap the navigation below the site logo see skinnyties.com
 [] consolidate the cookies so there's a single cookie managed by connect

    it should be secure. and in that case you don't have to sign the cookie, just include the session id in the @req.session

    to notify other windows when the session has changed, delete the old session after the new session is present

    modify the `present` outlet in ace_mvc/model so that it shows present only when the document is known to be present on both the server and the client (this will mean using a separate field -- e.g., `clientPresent`) as a spinner (so when you create a new document on the client, this field is true even before it appears on the server)

