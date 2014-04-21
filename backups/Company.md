title: Company
public:
css: /doc/535275e4e1238d904534ad75
tldr: See  [Updates] for the latest news on the product and company.

# Guiding principles

1. Simplicity

	- a minimalist design
	- reducing the number of inputs so you can "just type"

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

	This means content discovery, mentions, timelines, etc., possibly within a separate, less minimalist site (like https://explore.synop.si). This would be more visually engaging, like a music discovery service, but focused on the text, images and videos that have been posted.

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
	- *native* system-wide undo, spell check, and auto correct (not hacky solutions written in JavaScript)
	- really fast key response (5ms or less). You can *feel* the difference when a key takes more than 10ms to go through (as it does on many online editors)
	- making complex operations accessible and simple
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

## Competitive Advantages

There are a number of key competitive advantages for Synopsi, many of which are technology-based and hard to reproduce.

1. Everything is live and pushed to the browser. This is extremely important and creates a novel, incredible user experience. 

2. Finding text, navigating to it within a document and changing it is a *single* click, faster and easier than anyone else.

3. The content and presentation are separated, making the content portable and presentable in lots of ways and easily pipelined over an API to other services.

4. The editor is incredible, but also native, unlike hacky JavaScript solutions present in almost every other online editor. This has a lot of advantages.

5. The interface encourages a focus on content, rather than bombarding the user with options and features. Focused writing tools are a big desktop app market; Synopsi brings that to a live web where it belongs.

6. Adding media content is instantaneous. You drag in an image and it uploads in the background, letting you see and use it while it's uploading. (This was a key insight in Instagram, but not widely used elsewhere.)

## Development Timeline

April 2014: 
 - Beta testing
 - Scaling
 - Editor improvements
 - Outline improvements
 - Search engine optimizations

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
 - Groups
 - Custom embeddable/editable widgets
 - Sharing collections

August:
 - Custom blog hosting
 - Related content and discovery

September:
 - API & pitching to enterprise

## Monetization Timeline

First collaboration subscription sale: June
First widgets subscription sale: August
First paid hosted blog: Late August
First enterprise customer: November

## Numbers

 - Evernote alone is valued at well over $2 billion and has raised over $250 million in capital
	They have 86 million users and likely over 8 *billion* notes stored in a custom XML format called ENML
 - Tumblr was recently bought for $1 billion and generates $15 million a year in revenues


# Contributors

These are some of the awesome people who have helped to make Synopsi a reality by giving feedback, helping with company logistics, brainstorming strategy, writing code, profiling performance, etc.

![Mike Robertson](e19b3e4f8801179f0d7d099f.png) ![PJ Hubbard](b8761f48184bbda951af31a1.jpg) ![Omar El Amri](96fbb9859d8dbfedf1dd6af9.jpg) ![Khalid Meniri](6faa0267460b7039b4783c93.png) ![Misha Brukman](3729fb0937fec060f751e434.png) ![Franck Nouyrigat](eedcb2b126c9529ec2790d65.jpg) ![David Ernst](6a821cdab8eba605109ec655.jpg)  ![Mark Umina](04740b32e04adcdbe62e6031.jpg) ![Bert Picot](cee5b1ba27a88016a3017234.jpg) ![Kai Mallea](b74087496e1c5bad44f743f1.jpg) ![Tony Qamar](8638a120c62625a6b91e1d5f.jpg) ![Kalpesh Patel](f26426ad0e715b72fa3c32b9.jpg) ![Dmitry Aksenov](787fee35928a9bdab11d285f.jpg) ![Asuquo Obong](e076adaa8b52ab402ecac61d.jpg)

## Inspiration & About the Founder, [Mike Robertson](https://www.linkedin.com/in/mikemotif)

Synopsi is the product of a "slow-moving epiphany" that started as early as 2007 when I first started taking notes in text files, word documents and sending myself emails to write down stories and jokes; take notes on books, movies, and papers; and record code samples and stock valuation formulas so I could use them for work (I worked as a trader at the time at a hedge fund called Weiss Capital in Boston). Other people were doing similar things. One person took copious notes in Excel every time he talked to a broker, so he had a huge log of all his interactions, which he was very proud of. But I dare say, it probably wasn't very useful. 

Even today – years later with lots of solutions on the market going after this problem of recording and finding your own thoughts and notes – I still see people sitting in meetings and at conferences writing down notes in Apple's Notes program on their iPhone. Those notes are quarantined to Apple and hard to find and extract later. The most likely outcome is the person writing them will just forget about it. And certainly no one else at the conference knows about it.

After working for another company where people were sending themselves email attachments with notes on procedures that would be far more useful if colleagues could see and edit them, and realizing that no one was using the corporate wiki at two finance companies I'd worked for, I decided something needed to be done.

There are existing solutions skirting around this problem and doing a great job with some aspects – like tagging or collaboration – but failing to hit a home run at all of them. My goal is to hit a home run in every dimension while keeping the product simple and usable.

I'm also inspired by GitHub's incredible collaborative tools for *coding* like forking, merging, version control. I want to bring all of that to documents online. A major problem – again seen at a company I worked at, this time mostly doing software – is that software specs are written up in (binary) Word documents and put into source control systems. This breaks the version control entirely and as a developer you can't easily keep track of what's changed since the last time you looked at a document. Bringing forking to documents stored in plain text (markdown) solves this problem in a compelling way. And it'll be incredibly useful for publishers. 

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

![Logo SVG](f6e9b89f5151e2caab03c3a5.svg)

# Terms

By using the Synopsi web service (“Service”), you are agreeing to be bound by the following terms and conditions (“Terms of Use”) set forth by Spocdoc, LLC (“We”).

## Basic terms

You are responsible for keeping your login credentials safe. The Service should not be used to store sensitive information such as bank account numbers, credit card information, or passwords. We are not responsible for any information stored with the Service.

## General terms

We reserve the right to modify the Service for any reason, without notice. We reserve the right to alter these Terms of Use. We reserve the right to refuse service to anyone for any reason.

# Privacy Policy

Spocdoc, LLC provides this Privacy Policy to inform users of our policies and procedures regarding the collection, use and disclosure of personally identifiable information received from users of this website, located at https://synop.si (“Site” or "Service"). This Privacy Policy may be updated from time to time for any reason; each version will apply to information collected while it was in place. You are advised to consult this Privacy Policy regularly for any changes.

By using our Site and Service you are consenting to our processing of your information as set forth in this Privacy Policy now and as amended by us. “Processing” means using cookies on a computer or using or touching information in any way, including, but not limited to, collecting, storing, deleting, using, combining and disclosing information, all of which activities will take place in the United States. If you reside outside the U.S. your personally identifiable information will be transferred to the U.S., and processed and stored there under U.S. privacy standards. By visiting our Site and providing information to us, you consent to such transfer to, and processing in, the US.

## Use of Contact Information

In addition, we may use your contact information to provide you with information about our products and services, including but not limited to our Service. If you decide at any time that you no longer wish to receive such information or communications from us, please follow the unsubscribe instructions provided in any of the communications. We will never sell your contact information to third parties.

## Visitor Data

When you visit the Site and Service, our servers automatically record information that your browser sends whenever you visit a website (“Log Data”). This Log Data may include information such as your IP address, browser type or the domain from which you are visiting, the web-pages you visit, the search terms you use, and any advertisements you click. We use Log Data to monitor the use of the Site and of our Service, and for the Site’s technical administration. We do not associate your IP address with any other personally identifiable information to identify you personally, except in case of violation of the Terms of Service.

## Cookies

Like many websites, we also use “cookie” technology to collect additional website usage data and to improve the Site and our service. A cookie is a small data file that we transfer to your computer’s hard disk. We do not use cookies to collect personally identifiable information. Synopsi may use both session cookies and persistent cookies to better understand how you interact with the Site and our Service, to monitor aggregate usage by our users and web traffic routing on the Site and Service, and to improve them. A session cookie enables certain features of the Site and Service and is deleted from your computer when you disconnect from or leave the Site or Service. A persistent cookie remains after you close your browser and may be used by your browser on subsequent visits to the Site or Service. Persistent cookies can be removed by following your web browser help file directions. Most Internet browsers automatically accept cookies. You can instruct your browser, by editing its options, to stop accepting cookies or to prompt you before accepting a cookie from the websites you visit.

## Service Providers

We may engage certain trusted third parties to perform functions and provide services to us, including, without limitation, hosting and maintenance, customer relationship, database storage and management, and direct marketing. We may share your personally identifiable information with these third parties, but only to the extent necessary to perform these functions and provide such services, and only pursuant to binding contractual obligations requiring such third parties to maintain the privacy and security of your data.

## Compliance with Laws and Law Enforcement

Spocdoc, LLC cooperates with government and law enforcement officials or private parties to enforce and comply with the law. We may disclose any information about you to government or law enforcement officials or private parties as we, in our sole discretion, believe necessary or appropriate to respond to claims, legal process (including subpoenas), to protect the property and rights of Spocdoc, LLC or a third party, the safety of the public or any person, to prevent or stop any illegal, unethical, or legally actionable activity, or to comply with the law.

## Business Transfers

Spocdoc, LLC may sell, transfer or otherwise share some or all of its assets, including your personally identifiable information, in connection with a merger, acquisition, reorganization or sale of assets or in the event of bankruptcy. You will have the opportunity to opt out of any such transfer if the new entity’s planned processing of your information differs materially from that set forth in this Privacy Policy.

## Security

Spocdoc, LLC is very concerned about safeguarding the confidentiality of your  information. We employ administrative, physical and electronic measures designed to protect your information from unauthorized access.

In the event of a breach of the security, confidentiality, or integrity of your unencrypted electronically stored personal data, we will make any legally-required disclosures to you via email or conspicuous posting in the Service in the most expedient time possible and without unreasonable delay, consistent with (i) the legitimate needs of law enforcement or (ii) any measures necessary to determine the scope of the breach and restore the reasonable integrity of the data system.

[Updates]: /updates
