#/bin/bash


urls_file='/net/per610a/export/das11f/plsang/dataset/videostory/datasets/VideoStory46K/urls.txt'

#count number of lines = number of videos 
total_urls=$(wc -l $urls_file | awk '{print $1}')

count=0

while read line; do 
    echo [$count/$total_urls], 'Downloading '$line
    url=$(echo "${line}" | tr -d '\r')
    echo $url
    ./youtube_wget.pl "$url"
    let count++
done < $urls_file

