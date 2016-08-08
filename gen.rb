# Load gem dependencies
require 'byebug'
require 'slim'
require 'sass'
require 'coffee-script'
require 'rerun'

# Load stdlib dependencies
require 'webrick'

# A block is called when the script is run
# It prints no output
Block_To_Run_When_Script_Is_Started = ->() {
  gen = Gen.new
  FILES_TO_RUN = ARGV.map { ARGV.shift }
  if FILES_TO_RUN.empty?
    # no files were specified. Recompile everything
    gen.refresh_gen_out_dir.compile_all

  else
    # if any file paths were provided in ARGV, preprocess only those files
    FILES_TO_RUN.each { |path| gen.preprocess_any_single_file(path) }
  end
}

# Helpers module has instance methods used by Templates
require_relative("./helpers.rb")

# PartialNotFoundError is raised when a partial is not found
# The Helpers#render method can trigger this
# Slim partial filenames need to begin with an underscore
class PartialNotFoundError < StandardError; end
  
# Gen is the main project class
class Gen
  
  # Gen is initialized with no arguments
  attr_reader :gen_out_dir
  def initialize
    self.class.class_exec { include Helpers }
    @gen_out_dir = get_gen_out_dir
  end
  
  # Recompiles source/ to dir/ in entirety
  def compile_all
    preprocess_scripts
    preprocess_styles
    preprocess_slim
    self
  end
  
  # Deletes and recreates dist/
  def refresh_gen_out_dir # => self/,,aw3
    `rm -rf #{gen_out_dir}; mkdir #{gen_out_dir}`
    `mkdir #{gen_out_dir}scripts/`
    `mkdir #{gen_out_dir}styles/`
    self
  end
  
  # .slim => .html
  def preprocess_slim # => self
    slim_files.each { |file| preprocess_slim_file_and_save(file) }
    self
  end
  
  # .sass => .css
  def preprocess_styles # => self
    sass_files.each { |file| preprocess_sass_file_and_save(file) }
    css_files.each { |file| copy_css_file(file) }
    self
  end
  
  # .coffee => .js
  def preprocess_scripts # => self
    coffee_files.each { |file| preprocess_coffee_file_and_save(file) }
    js_files.each { |file| copy_js_file(file) }
    self
  end
  
  # based on the filename, determine how to preprocess the file
  # and save it to dist/
  def preprocess_any_single_file(path)
    case filename_from_path(path).split(".")[1..-1].join
    when "coffee"
      preprocess_coffee_file_and_save(path)
    when "sass"
      preprocess_sass_file_and_save(path)
    when "slim"
      # since slim files can have nested templates, recompile them all
      preprocess_slim
    when "js"
      copy_js_file(path)
    when "css"
      copy_css_file(path)
    else
      compile_all
    end
    self
  end

  private
  
  # .css file paths array
  def css_files
    exclude_dist_folder(Dir.glob("./**/*.css"))
  end
  
  # .js file paths array
  def js_files
    exclude_dist_folder(Dir.glob("./**/*.js"))
  end
  
  # .js files are copied to dist/ without precompilation
  def copy_js_file(path)
    `cp #{path} #{gen_out_dir}scripts/#{filename_from_path(path)}`
  end
  
  # .css files are copied to dist/ without precompilation
  def copy_css_file(path)
    `cp #{path} #{gen_out_dir}styles/#{filename_from_path(path)}`
  end
  
  # filter array of filepaths to exclude dist/
  def exclude_dist_folder(filepaths_array) # => array
    filepaths_array.reject { |path| path.include?("dist/") }
  end
  
  # get an absolute path for the local dist/ folder
  def get_gen_out_dir # => string
    ENV["GEN_OUT_DIR"] || File.join(`pwd`.chomp, "dist/")
  end
  
  # preprocess .sass file and save to dist/ as .css
  def preprocess_sass_file_and_save(path) # => nil
    dest_path = "#{gen_out_dir}styles/#{filename_from_path(path).gsub(".sass", ".css")}"
    File.open(dest_path, 'w') { |f| f.write Sass::Engine.new(File.read(path)).render }
    nil
  end
  
  # preprocess .coffee file and save to dist/ as .js
  def preprocess_coffee_file_and_save(path) # => nil
    dest_path = "#{gen_out_dir}scripts/#{filename_from_path(path).gsub(".coffee", ".js")}"
    File.open(dest_path, 'w') { |f| f.write CoffeeScript.compile(File.read(path)) }
    nil
  end
  
  # .slim file paths array
  def slim_files # => array
    exclude_partials(exclude_dist_folder(Dir.glob("./**/*.slim")))
  end
  
  # .sass file paths array
  def sass_files # => array
    exclude_dist_folder(Dir.glob("./**/*.sass"))
  end
  
  # filter filepaths array to exclude files beginning with an underscore
  def exclude_partials(filepaths_array) # => array
    filepaths_array.reject { |path| filename_from_path(path)[0] == "_" }
  end
  
  #.coffee file paths array
  def coffee_files # => array
    exclude_dist_folder(Dir.glob("./**/*.coffee"))
  end
  
  # gets the filename from a file path.
  # i.e. foo.txt from /my/path/foo.txt
  def filename_from_path(path) # => string or nil
    path.split("/")[-1]
  end

  # preprocess .slim file and save in dist/ as .html
  def preprocess_slim_file_and_save(source) # => nil
    destination = "#{gen_out_dir}#{filename_from_path(source).gsub("slim", "html")}"
    File.open(destination, 'w') { |file| file.write(preprocess_slim_file(source)) }
    nil
  end

  # preprocess .slim file to html string
  def preprocess_slim_file(source) # => string
    Tilt.new(source, {pretty: true}).render(self)
  end

end

# Start the compile process is this script is executed directly, i.e. ruby gen.rb
# if it's loaded using 'require', this block will not run.
Block_To_Run_When_Script_Is_Started.call if __FILE__ == $0
