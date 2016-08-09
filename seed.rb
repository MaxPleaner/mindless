require 'nokogiri'
require 'open-uri'

module Seed
  def self.create(options={})
    name, content, tags = options.values_at(:name, :content, :tags)
    raise ArgumentError unless [name, content].all? { |x| x.is_a?(String) && x.length > 0 }
    raise ArgumentError unless tags.is_a?(Array) && tags.length > 0
    path = `pwd`.chomp + "/source/markdown/#{name}.md.erb"
    metadata_string = "**METADATA**\nTAGS: #{tags.join(", ")}\n****\n"
    File.open(path, 'w') { |file| file.write("#{metadata_string}#{content}") }
  end
  
  def self.seed_youtube_playlists(search_terms_array)
    search_terms_array.each do |tag|
      url = "https://www.youtube.com/results?search_query=#{tag.gsub(" ", "+")}%3Aplaylist"
      page = Nokogiri.parse open(url)
      links = page.css(".yt-lockup-title").map do |node|
        link = node.css("a")
        [link.text, link.attr("href").value]
      end
      
      links.each do |link|
        title = link[0].gsub(/[^a-zA-Z1-9]/) { |x| " " }
        href = link[1]
        vid_id = href.split("list=")[-1]
        content = <<-HTML
<iframe width="560" height="315" data-src="https://www.youtube.com/embed/videoseries?list=#{vid_id}" frameborder="0" allowfullscreen></iframe>
        HTML
        create(name: title, content: content, tags: [tag])
      end
    end
  end
  
end

Seed.seed_youtube_playlists ["grindcore"]
