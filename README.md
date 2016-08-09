# static

This is a static site building framework

It's mainly intended to create a responsive grid with toggling sections.

There is also the option to filter the visible content according to a selected 'tag', as inspired by [bento.io/grid](https://bento.io/grid)

### There are a few components:

1. The [genrb](http://github.com/maxpleaner/genrb) guard / livereload setup for compiling apps built with coffeescript, sass, and slim. It also provides a static http server
2. A ui library which supports nested markdown and slim templates
3. An API for seeding data
4. A script to deploy to github pages

### How it's organized:

- `dist/` is the destination for the compiled app. It has a `scripts/` folder which is the destination for all `.js` files, and a `styles/` folder which is the destination for `css`. All `html` files are copied into the root level of `dist/`, and since a static server is used, they are routed to urls automatically.
- `.md.erb`, `.coffee`, `.sass`, `.css`, `.js`, and `.slim` source files can be present _anywhere in the file tree except `dist/`_. In this app, slim templates are written in the root level of `source/`, and other files are placed in `source/markdown`, `source/scripts`, and `source/styles`, but this organization is _not hard coded_.
- The ui library is in `source/scripts/app.coffee`. It uses [isotope](http://isotope.metafizzy.co/) for the responsive grid,  `jquery`, [pace](http://github.hubspot.com/pace/docs/welcome/), and [curry](https://github.com/dominictarr/curry).
- [genrb](http://github.com/maxpleaner/genrb) provides `gen.rb` and the `Guardfile`.
  - `gen.rb` compiles `source/` into `dist/`. If given file paths as arguments, it will only compile those files, but otherwise will compile everything.
  - `Guardfile` uses [guard-livereload](https://github.com/guard/guard-livereload) and [guard-shell](https://github.com/guard/guard-shell) to make a pleasant development environment. With the livereload chrome extension, the browser won't need to be manually refreshed. The server shouln't need to be manually restarted if source files like `gen.rb` or `helpers.rb` are changed. `Guardfile` takes care of starting the static http server as well.
- `helpers.rb` provides methods for template nesting and markdown processing
- `push_dist_to_gh_pages` is a simple script to push the `dist/` folder to the `gh-pages` branch of the projects `origin`
- `webrick.rb` just starts a static http server with `dist/` as the document root.

### API:

**in slim files**:

- _helper methods_
  - `== render('_my_partial.slim')` will compile the slim template to html and embed it.
  - `process_md_erb(absolute_path)` will compile a `.md.erb` file to html. This method returns `[html, metadata_hash]`
- _grid_
  - `.grid` denotes a grid. There should be only one of these.
  - `.grid-item` is a box in the grid. There are no exclicit defitions for 'columns' or 'rows' here - all that is handled dynamically by isotope.
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
  - These tags are used by the ui to filter the visible content


**Seed API**
- first `require_relative('./seed.rb')`
- then run `Seed.create(name: '<filename>.md.erb', content: "lorum", tags: ["tag", "list"])`. This will overwrite the file at `source/markdown` if it already exists.


### Starting the app

`clone`, `bundle`, and `guard`, then visit `localhost:8000`

To start over (and delete the demo code), just delete all the files in `source/markdown`

### Demo

visit [http://maxpleaner.github.io/static](http://maxpleaner.github.io/static), which shows a bunch of youtube playlists that are tagged by genre
