require 'open-uri'

all_weapons = open('http://mwo.smurfy-net.de/api/data/weapons.json')
contents = all_weapons.read
puts contents
