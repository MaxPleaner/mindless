# static

This is a static site building framework

It's mainly intended to create a responsive grid with toggling sections.

There is also the option to filter the visible content according to a selected 'tag', as inspired by [bento.io/grid](https://bento.io/grid)

### General usage, tl;dr

Only .md.erb files are needed to populate the site with content. They can be anywhere in the directory tree except dist/.

A sample file is as follows (say it's test.md.erb)

```md
**METADATA**
TAGS: foo, bar
****

#### this is a markdown page
_use markdown here_

#### it supports erb
<%= "or erb" %>

#### there is a helper method to embed other markdown
<%= embed_markdown("./path/to/file.md.erb") %>
```

Once this file is saved, run `ruby gen.rb` to compile the app into dist/ and `sh push_dist_to_gh_pages` to deploy. `guard` is used to start the development server. The livereload chrome extension should be installed, but is not necessary.

With this markdown file, `foo` and `bar` will appear in the navbar as tags. The markdown file becomes a box in the grid and has these tags applied for the filter-by-tag feature to see. Initially, the box will only have the title visible  (`test`, taken from the filename). When the title is clicked, the markdown content will toggle open/closed. Only one box can be toggled open at the same time. Tags are not essential, though the UI library is geared toward their usage.

### Demo

visit [http://maxpleaner.github.io/mindless](http://maxpleaner.github.io/static), which shows a bunch of youtube playlists that are tagged by genre

### Main components

1. The [genrb](http://github.com/maxpleaner/genrb) guard / livereload setup for compiling apps that are built with coffeescript, sass, and slim. It also provides a static http server
2. A ui library which supports nested markdown and slim templates
3. A simple method for seeding `.md.erb` pages: `Seed.create`
4. A script to deploy to github pages

### How it's organized:

- dist/ is the destination for the compiled app. It has a scripts/ folder which is the destination for all .js files, and a styles/ folder which is the destination for .css. All .html files are copied into the root level of dist/, and since a static server is used, they are routed to urls automatically.
- .md.erb, .coffee, .sass, .css, .js, and .slim source files can be present anywhere in the file tree except dist/. When the app is cloned, slim templates will be present in the root level of source/, and other files are present in source/markdown, source/scripts, and source/styles, but this organization is not hard coded and these files can be moved.
- The ui library is in [source/scripts/app.coffee](./source/scripts/app.coffee). It uses `jquery`, [curry](https://github.com/dominictarr/curry), [isotope](http://isotope.metafizzy.co/) for the responsive grid, and   [pace](http://github.hubspot.com/pace/docs/welcome/) for the loading bar.
- [genrb](http://github.com/maxpleaner/genrb) provides gen.rb and the Guardfile.
  - [gen.rb](./gen.rb) compiles source/ into dist/. If given file paths as arguments, it will only compile those files, but otherwise will compile everything.
  - [Guardfile](./Guardfile) uses [guard-livereload](https://github.com/guard/guard-livereload) and [guard-shell](https://github.com/guard/guard-shell) to make a pleasant development environment. With the livereload chrome extension, the browser won't need to be manually refreshed. The server shouln't need to be manually restarted if source files are changed. Guardfile takes care of starting the static http server as well.
- [helpers.rb](./helpers.rb) provides methods for template nesting and markdown processing
- [push_dist_to_gh_pages](./push_dist_to_gh_pages) is a simple script to push the dist/ folder to the gh-pages branch of the project's `origin`.
- [webrick.rb](./webrick.rb) just starts a static http server with dist/ as the document root.

### API:

**in slim files**:

- _helper methods_
  - `== render('_my_partial.slim')` will compile the slim template to html and embed it.
  - `process_md_erb(absolute_path)` will compile a .md.erb file to html. This method returns `[html, metadata_hash]`
- _grid_
  - the `.grid` class denotes a grid. There should be only one of these.
  - the `.grid-item` class is a box in the grid. There are no exclicit defitions for 'columns' or 'rows' here - all that is handled dynamically by isotope.
  - inside `.grid-item` nodes, `.content` is initially hidden but is toggled open by clicking on the `.grid-item`.
  - Toggling content can be nested - just include another `.grid-item` inside `.content`

**in markdown files**
- _embedding_
  - `embed_md_erb(absolute_path)` is used to embed markdown files in one another.
- _metadata_
  - There is a special syntax used to create tag definitions for markdown files:
```txt
**METADATA**
TAGS: comma, separated, list, of, tags
****
```
  - The 'tag list' for a slim file is the combination of tags in markdown files it contains.
  - These tags are used by the ui library to filter the visible content


**Seed API**
- first `require_relative('./seed.rb')`
- then run `Seed.create(name: '<filename>.md.erb', content: "lorum", tags: ["tag", "list"])`. This will overwrite the file in source/markdown/ if it already exists.


### Starting the app

`clone`, `bundle`, and `guard`, then visit `localhost:8000`
