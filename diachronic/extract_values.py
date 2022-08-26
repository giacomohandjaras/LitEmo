#! /usr/bin/python3
#-*- coding: utf-8 -*-
"""

"""


import pickle


years = [ 1810, 1820, 1830, 1840, 1850, 1860, 1870, 1880, 1890, 1900, 1910, 1920, 1930, 1940, 1950, 1960, 1970, 1980, 1990 ]
data = pickle.load( open( "disps.pkl", "rb" ), encoding="bytes" )
fh = open('disps_allyears.txt', 'wt')

for index, word in enumerate(list(data.keys())):
	current_data = data.get(word)
	fh.write("%s" % (word))
	for year in list(years):
		fh.write(",%s" % (current_data[year]))
	fh.write("\n")
fh.close()
