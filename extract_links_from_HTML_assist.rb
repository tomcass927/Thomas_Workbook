require 'rubygems'
require 'nokogiri'
require 'uri'

Nokogiri::HTML('')

creative_contents_action = File.open('C:\Users\tomca\Desktop\Hammerhead\temp.html', "r:ASCII-8BIT")
creative_contents = creative_contents_action.read


value = URI.decode(creative_contents)

html = URI.unescape(value)

page = Nokogiri::HTML(html)
page.search('a').each do |link|

single_links = link['href']

single_links_array = ["#{single_links}"]

puts single_links_array

end 