#! /usr/bin/python3
#-*- coding: utf-8 -*-
"""

"""

from nltk.corpus import wordnet as wn

TERMS = ['the','of','a','he','his','she','her','so','by','when','an','man','how']




def do_main():

	for synset in list(TERMS):
		synset_results = wn.synsets(synset)
		print(synset_results)




if __name__ == '__main__':
    do_main()
