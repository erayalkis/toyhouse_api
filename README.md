# README

# Project: Toyhouse API

After seeing that a [Toyhouse](https://toyhou.se) API has been requested by users for a decent while, following the request of a client, I started building an API for it.
[Toyhouse](https://toyhou.se) is a site which lets you create pages for your fictional characters that contain information about them. This information can range from their name, age etc. to entire stories written about them.
This API uses [Kimurai](https://github.com/vifreefly/kimuraframework), a webscraping gem that couples powerful functionalities from the Capybara and Nokogiri gems into one gem.

# Usage

Using this API is quite simple, there are 3 routes available, and each of them return a unique response:

- Making a call to `/character/:id` returns info that can be gather from the main page.
- Making a call to `/character/:id/gallery` returns the entire gallery for the character.
- Making a call to `/character/:id/favorites` returns the favorites of the character.
- Making a call to `/user/:id` returns info that can be gathered from the main page of a user.
- Making a call to `/user/:id/subscribers` return the subscribers of a user.

All of these routes return a JSON object with the requested characters information.

# Challenges

Figuring out how Kimurai worked at first was quite confusing, as it abstracted a lot from the user. However after quickly reading some [documentation](https://www.rubydoc.info/gems/kimurai/1.4.0) and looking around on stack overflow, I was able to get it running simply.

The part that took me a long time was deciding which engine to use for the webscraper. Kimurai gives you four options:

- [Mechanize](https://github.com/sparklemotion/mechanize), a pure ruby fake HTTP browser. It can't render javascript so doesn't know what a DOM is, but is also the fastest option.
- [Poltergeist](https://github.com/teampoltergeist/poltergeist): A [PhantomJs](https://github.com/ariya/phantomjs) headless browser. Faster than the other two options, but has memory leak issues.
- Selenium-Chrome: Chrome in headless mode driven by selenium.
- Selenium-Firefox: irefox in headless mode driven by selenium. Uses up more memory than other drivers, but is useful for certain scenarios.

I was first planning on using Selenium-Chrome for this project, but after realising that Mechanize still mimicks a real browser - meaning that most Capybara functionalities work with it - and that Toyhouse doesn't use JS for any content rendering, I decided to use Mechanize for this app.

The most recent challenge I faced - which ended up getting reverted- was updating the app to use send_file instead of managing the download on the front end. This would create inconsistencies for users in the future and would also create a few potential security risks.
After reading through some documentation and reading through some Stack Overflow threads, I was able to get it working. The newest version of the app now uses [rubyzip](https://github.com/rubyzip/rubyzip) and [open-uri](https://ruby-doc.org/stdlib-2.6.3/libdoc/open-uri/rdoc/OpenURI.html) to fetch and save images to a zip file locally, which then gets sent to the user through send_file. This zip file then gets deleted by a function that runs periodically.
This created a performance increase of ~20% while also preventing the aformentioned security problems.

After publishing the app to Heroku however, I unfortunately soon realised that they don't allow the creation and deletion of files and had to revert the application back to it's original state. 
This *did* revert the performance patches, but the security issues were handled swiftly following the update.

# Technologies used

This app is written in Rails and uses [Kimurai](https://github.com/vifreefly/kimuraframework) for webscraping.
