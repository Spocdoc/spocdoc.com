title: Company
public:
css: /doc/535275e4e1238d904534ad75
tldr: See  [Updates] for the latest news on the product and company.

# Guiding principles

1. Simplicity

	- a minimalist design
	- eliminating separate data fields, so you can "just type"

2. Speed

	minimizing the time it takes to: 

	- find what you're looking for and get it into your head
	- find content and change it
	- give and receive feedback and comments
	- make, review and apply edits
	- share and collaborate on related content

3. Portability

	- ensure that whatever you create in Synopsi is accessible and editable everywhere
	- ensure you can take your content and feed it into a workflow and do something useful and unexpected with it

## Design decisions

Portability and simplicity led to the use of markdown with a single editor box containing all the content and the use of escape to switch between the markdown and the rendered content (most sites, even the best competitors, separate the two, which creates a distraction). Speed led to the development of a custom, full-stack JavaScript MVC framework and with a dependency engine. Simplicity also motivated the use of tags rather than folders or collections.

# For Investors

Synopsi is starting small with a clear focus and a narrow target, then working its way up to impact some very large industries.

## Market strategy

1. Get users of current note taking tools

	There are a *ton* of problems with the existing tools.

	- they often require installed software
	- they have terrible UIs
	- you have to manually sync
	- some elegant tools are ridiculously slow with large files
	- the web interfaces are ancient, cumbersome and almost totally unusable
	- they conflate content and presentation, so the content can't be easily transformed
	- the ones that separate content and presentation (like Wikipedia) have a heavy, geeky markup that ordinary people don't understand
	- the content is typically locked into the product
	- it's hard to find what you're looking for (usually a multi-step process)
	- with some, it's not easy to share your own content or get it onto the public web
	- with others, you either can't collaborate or you have to pay to do so
	- making large-scale changes like nesting a range of content underneath another header is labor intensive or confusing
	- large notes are hard to navigate
	- there's often no document history
	- there's no way to edit and merge changes from someone else

	Addressing these issues with a fast, simple, portable solution will capture a lot of customers, possibly by filling a need they didn't realize was there.

2. Blogging

	There is a large amount of content locked into these note and document products already. By making it easy to pull in that content into a better platform, then publish some of it on the web, we can drive more traffic to Synopsi and generate more adoption.

3. Make it social

	This means content discovery, mentions, timelines, etc., possibly within a separate, less minimal domain (like https://explore.synop.si). This would be more visually engaging, like a music discovery service, but focused on the text, images and videos that have been posted.

3. Disrupt small-scale publishing

	Make it extremely simple to publish content to kindle and monetize content created on Synopsi through tips, paid authors, paid content curation, etc.

1. Disrupt the way professional content is published

	This means providing a service to academic journals, book publishers and newspapers, partnering with each to use Synopsi as their preferred platform for submitting, editing and reviewing content and pushing it through their publication pipeline using an API.

## Business model

Revenue will come from various sources, in this order:

 1. subscription to have more than 3 collaborators in a group
 2. hosted blogging service
 3. custom widget service & marketplace
 4. cut of publishing, curation, tips
 5. hosted content management for businesses
 6. selling the web framework to e-commerce companies

## Product development strategy

1.  Produce a *great* editor, focused on the **writing experience**

	The first goal is to make an online editor that so fantastic to use, no one will want to write in anything else (including desktop applications).

	What's fantastic?

	- supporting native customized keystrokes (`DefaultKeyBinding.dict` on a mac)
	- *native* system-wide undo, spell check, and auto correct (not hacky solutions built by the editor)
	- really fast key response (5ms or less). You can *feel* the difference when a key takes more than 10ms to go through (as it does on many online editors)
	- making complex operations accessible and really simple
	- leveraging the separation of content (text) and presentation (formatting)
	- making the edits live and immediate, so you never have to save or sync

2. Make the search *incredibly* fast

	This means reducing the time it takes to find and edit what you want.

3. Make documents collaborative

	- version history
	- forking
	- diffs and merge
	- commenting

4. Make it social

	- groups
	- sharing and following collections (tags)
	- mentions & timeline
	- related content
	- custom blog hosting

5. Integrate with publishers, customize for companies

	- API
	- enhanced metadata
	- metadata associated with tags

## Development Timeline

April 2014: 
 - Beta testing
 - Scaling
 - Editor improvements
 - Outline improvements

May:
 - Better tag display in search
 - Tag display in documents
 - Tag completion in search
 - Add editors via email

June:
 - Version history
 - Forking
 - Diffs & merge
 - Commenting

July:
 - CSS/JS editor
 - Mentions
 - Custom embeddable/editable widgets
 - Sharing collections

August:
 - Custom blog hosting
 - Related content and discovery

September:
 - API & pitching to enterprise

## Monetization Timeline

First subscription sale: June
First premium (widgets) subscription: August
First hosted blog: Late August
First enterprise customer: November

## Numbers

 - Evernote alone is a ~$10 billion company and has raised over $250 million in capital
	there are also over 8 million notes in Evernote
 - Tumblr was recently bought for $1 billion


# Contributors

These are some of the awesome people who have helped to make Synopsi a reality by giving feedback, helping with company logistics, brainstorming strategy, writing code, profiling performance, etc.

![Mike Robertson](e19b3e4f8801179f0d7d099f.png) ![PJ Hubbard](b8761f48184bbda951af31a1.jpg) ![Omar El Amri](96fbb9859d8dbfedf1dd6af9.jpg) ![Khalid Meniri](6faa0267460b7039b4783c93.png) ![Misha Brukman](3729fb0937fec060f751e434.png) ![Franck Nouyrigat](eedcb2b126c9529ec2790d65.jpg) ![David Ernst](6a821cdab8eba605109ec655.jpg)  ![Mark Umina](04740b32e04adcdbe62e6031.jpg) ![Bert Picot](cee5b1ba27a88016a3017234.jpg) ![Kai Mallea](b74087496e1c5bad44f743f1.jpg) ![Tony Qamar](8638a120c62625a6b91e1d5f.jpg) ![Kalpesh Patel](f26426ad0e715b72fa3c32b9.jpg) ![Dmitry Aksenov](787fee35928a9bdab11d285f.jpg) ![Asuquo Obong](e076adaa8b52ab402ecac61d.jpg)

## Inspiration & About the Founder, [Mike Robertson](https://www.linkedin.com/in/mikemotif)

[Mike-LinkedIn]: https://www.linkedin.com/in/mikemotif

# Careers

To apply for these positions, please email <mike@synop.si> with the usual and something to convince me you're crazy enough to work for an early-stage, undercapitalized and ambitious startup aiming to disrupt multi-billion-dollar industries.

These positions are flexible – both internship and full-time candidates are welcome. You'll be paid in lucky charms until the next angel round.

## JavaScript Developer

Synopsi is looking for a full-stack JavaScript/CoffeeScript developer based in New York who will focus on building core infrastructure related to document version history, conflict resolution and differencing.

You will build on top of a well-designed code base with a novel JavaScript web framework, called DaVinci, which features code-sharing, server-side rendering, a dependency calculation engine, and an NPM-based bundler running on top of NodeJS.

## UX Designer

We're looking for someone with a particular talent for creating and conceptualizing simple, elegant solutions to tricky design challenges. The specific challenges now relate to displaying, navigating and organizing large numbers of possibly hierarchical document tags; managing and searching the outline and media views; and adding authors or forming groups. Media search results is another area waiting for innovation. In addition, if you have the prowess to add slick animations and better capitalize on the single-page-app nature of Synopsi, we should talk.

# Press

# Terms

# Privacy


[Updates]: /updates
