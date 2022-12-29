#!/bin/bash

#Get url of image of a random cat
json=$(curl -s https://api.thecatapi.com/v1/images/search?size=full)
url=$(echo $json | jq '.[0].url')
url=${url#*\"}
url=${url%\"*}

#Download and show the cat
curl -s $url --output temp.jpg
catimg -w $(tput cols) temp.jpg
rm temp.jpg

#Get and show random joke about Chuck Norris
json=$(curl -s GET https://api.chucknorris.io/jokes/random)
echo $json | jq '.value'

