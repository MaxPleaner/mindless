module Seed
  def self.create(options={})
    name, content, tags = options.values_at(:name, :content, :tags)
    raise ArgumentError unless [name, content].all? { |x| x.is_a?(String) && x.length > 0 }
    raise ArgumentError unless tags.is_a?(Array) && tags.length > 0
    path = `pwd`.chomp + "/source/markdown/#{name}.md.erb"
    metadata_string = "**METADATA**\nTAGS: #{tags.join(", ")}\n****\n"
    File.open(path, 'w') { |file| file.write("#{metadata_string}#{content}") }
  end
end
