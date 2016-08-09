# mindless

This is a website for browsing youtube playlists.

It's built with [static](http://github.com/maxpleaner/static), a small framework I've built for making this kind of tag/grid site.

It also uses [genrb](http://github.com/maxpleaner/genrb), a build system i concocted to compile slim, coffeescript, and sass files and watch changes using [guard](https://github.com/guard/guard)

This site alters [static](http://github.com/maxpleaner/static) only slightly:

- an additional method is added to [seed.rb](./seed.rb) to scrape data off youtube
- This seed has been run a bunch of times, so there are many markdown files in [source/markdown/](./source/markdown/)
- [source/scripts/app.coffee](./source/scripts/app.coffee) has been customized to improve performance when many youtube videos are embedded on the page

and really that's it. 

Definitely see [static](http://github.com/maxpleaner/static) for more info on the framework.
