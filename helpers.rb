require 'redcarpet'
require 'erb'

module Helpers
  def render(filename) # => html string
    source = Dir.glob("**/#{filename}").shift
    raise(PartialNotFoundError, "#{filename} can't be located") unless source
    preprocess_slim_file(source)
  end
  
  # This method is used in .slim files.
  def process_md_erb(filename) # => html string
    markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions = {})
    markdown.render(embed_md_erb(filename))
  end
  
  # This method is used inside .md.erb files. It concatenates them.
  def embed_md_erb(filename) # => markdown string
    ERB.new(File.read(filename)).result(binding)
  end
end
