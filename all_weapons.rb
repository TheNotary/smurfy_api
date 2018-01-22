require 'open-uri'
require "json"

weapons_webpage = open('http://mwo.smurfy-net.de/api/data/weapons.json')
weapons_webpage_text = weapons_webpage.read
weapons_data = JSON.load(weapons_webpage_text)

puts "Here's what the first weapon ID/ data hash looks like"
first_weapon = weapons_data.first
puts first_weapon
puts

puts "Here's how to extract just the weapon's name"
actual_data_hash = first_weapon[1]  # This step has to be done because the data is in an odd format...

name = actual_data_hash["translated_name"]
puts name
puts

puts "Here's it's Cooldown time"
cooldown = actual_data_hash["cooldown"].to_f # converts the string into a floating point decimal value which could let you do math on it
puts cooldown
puts
