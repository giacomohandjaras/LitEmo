#!/bin/bash
colorbar="/home/giac/Documents/LAB/In_Corso/LitEmo/LitEmo/derivatives/RdYlGn_worldmap.png"
template="/home/giac/Documents/LAB/In_Corso/LitEmo/LitEmo/derivatives/template.png"
echo "Rescale, and combine $1 with the colorbar $colorbar..."

X=`identify -format '%w' $1`
Y=`identify -format '%h' $1`

#echo $X $Y
#to avoid the use of float numbers in bash....
let Y_new=(1700000/$X)*$Y
let Y_new=$Y_new/1000
#echo $Y_new

convert $1 -resize 1700x$Y_new\! .temp.png
sleep 1
composite .temp.png $template -gravity Center .temp.png
sleep 1
convert .temp.png -crop 1300x680+220+180  .temp.png
sleep 1
convert .temp.png $colorbar -gravity center -geometry -500+200 -composite $1
rm -f .temp.png


