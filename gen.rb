require 'byebug'
require 'slim'
require 'sass'
require 'coffee-script'
require 'webrick'
require 'rerun'

class Gen

  attr_reader :gen_out_dir
  def initialize
    self.class.class_exec { include Helpers }
    @gen_out_dir = get_gen_out_dir
  end

  def start_webrick! # => blocking
    WEBrick::HTTPServer.new(:Port => 8000, :DocumentRoot => gen_out_dir).start
  end
  
  def refresh_gen_out_dir # => self
    `rm -rf #{gen_out_dir}; mkdir #{gen_out_dir}`
    `mkdir #{gen_out_dir}scripts/`
    `mkdir #{gen_out_dir}styles/`
    self
  end

  def preprocess_slim # => self
    slim_files.each { |file| preprocess_slim_file_and_save(file) }
    self
  end
  
  def preprocess_styles # => self
    style_files.each { |file| preprocess_style_file_and_save(file) }
    self
  end
  
  def preprocess_scripts # => self
    script_files.each { |file| preprocess_script_file_and_save(file) }
    self
  end

  private
  
  
  def exclude_dist_folder(&blk) # => array
    blk.call.reject { |path| path.include?("dist/") }
  end
  
  def get_gen_out_dir # => string
    ENV["GEN_OUT_DIR"] || File.join(`pwd`.chomp, "dist/")
  end
  
  def preprocess_style_file_and_save(path) # => nil
    dest_path = "#{gen_out_dir}styles/#{filename_from_path(path).gsub(".sass", ".css")}"
    File.open(dest_path, 'w') { |f| f.write Sass::Engine.new(File.read(path)).render }
    nil
  end
  
  def preprocess_script_file_and_save(path) # => nil
    dest_path = "#{gen_out_dir}scripts/#{filename_from_path(path).gsub(".coffee", ".js")}"
    File.open(dest_path, 'w') { |f| f.write CoffeeScript.compile(File.read(path)) }
    nil
  end
  
  def slim_files # => array
    exclude_partials { exclude_dist_folder { Dir.glob("./**/*.slim") } }
  end
  
  def style_files # => array
    exclude_dist_folder { Dir.glob("./**/*.sass") }
  end
  
  def exclude_partials(&blk) # => array
    blk.call.reject { |path| filename_from_path(path)[0] == "_" }
  end
  
  def script_files # => array
    exclude_dist_folder { Dir.glob("./**/*.coffee") }
  end
  
  def filename_from_path(path) # => string or nil
    path.split("/")[-1]
  end

  def preprocess_slim_file_and_save(source) # => nil
    destination = "#{gen_out_dir}#{filename_from_path(source).gsub("slim", "html")}"
    File.open(destination, 'w') { |file| file.write(preprocess_slim_file(source)) }
    nil
  end

  def preprocess_slim_file(source) # => string
    Tilt.new(source, {pretty: true}).render(self)
  end

end

class PartialNotFoundError < StandardError; end

module Helpers
  def render(filename) # => html string
    source = Dir.glob("**/#{filename}").shift
    raise(PartialNotFoundError, "#{filename} can't be located in this directory's file tree") unless source
    preprocess_slim_file(source)
  end
end

Gen.new.refresh_gen_out_dir
       .preprocess_scripts
       .preprocess_styles
       .preprocess_slim
       .start_webrick_with_rerun!

