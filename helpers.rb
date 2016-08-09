require 'redcarpet'
require 'erb'
require 'ostruct'
require 'active_support/all'

module Helpers
  
  # Compile a slim template to html
  # Is used in slim templates to nest views
  def render(filename) # => html string
    source = Dir.glob("**/#{filename}").shift
    raise(PartialNotFoundError, "#{filename} can't be located") unless source
    preprocess_slim_file(source)
  end
  
  # This method is used in .slim files.
  # Processes a markdown file, including nesting other md files
  # and creating a tags list from the metadata of the included files
  # returns an array: [result_html, tags]
  def process_md_erb(filename) # => html string
    renderer = Redcarpet::Render::HTML
    markdown ||= Redcarpet::Markdown.new(renderer, md_extensions)
    concatenated_md = embed_md_erb(filename)
    result_md, metadata = extract_metadata(concatenated_md)
    result_html = markdown.render(result_md)
    [result_html, metadata]
  end
  
  # In .md.erb files, metadata is stored in a custom format:
  # It looks like: **METADATA**
  #                  <content>
  #                ****
  # The content of the block has key-val pairs separated by newlines
  # Accepted key-val pairs are:
  #   TAGS: < a comma separated list >
  # This method finds all metadata in a concatenated markdown string
  # and removes it from the result.
  # Returns an Array: [result md, metadata hash]
  def extract_metadata(markdown_string)
    metadata_results = OpenStruct.new
    result = markdown_string.split("**METADATA**").map do |section|
      metadata, content = section.split("****")
      parse_metadata_section(section).each do |key,results_array|
        metadata_results[key] ||= []
        metadata_results[key].concat results_array
      end
      content
    end.join("\n\n")
    [result, metadata_results]
  end
  
  # Get results of parsing a single metadata section
  # Returns a hash
  def parse_metadata_section(metadata_string)
    metadata_string.split("\n").reduce({}) do |result, line|
      key, val = line.split(": ")
      if [key, val].none? { |str| str.blank? }
        result[key.strip.downcase.to_sym] = val.strip.split(", ")
      end
      result
    end
  end
  
  # Extensions to Redcarpet's markdown renderer
  def md_extensions
    # empty for now
    {}
  end
  
  # Embed a markdown file in another markdown file
  # Concatenates markdown. Doesn't convert to html.
  def embed_md_erb(filename) # => markdown string
    ERB.new(File.read(filename)).result(binding)
  end
  
  # A list of .md.erb file paths
  def md_erb_files
    Dir.glob("./source/markdown/*.md.erb")
  end
  
  # Transform /my/path/name.txt into 'name'
  def file_title(path)
    filename_from_path(path).split(".")[0]
  end
  
end
