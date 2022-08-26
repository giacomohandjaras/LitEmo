#! /usr/bin/python3
#-*- coding: utf-8 -*-
"""

"""

from nltk.corpus import wordnet as wn

TERMS = [ 'man.n.01', 'little.n.01', 'two.n.01',  'mother.n.01', 'house.n.01' ]


def do_main():

	hyper = lambda s: s.hypernyms()
	for synset in list(TERMS):
		if len(synset)>3:
			#print(synset)
			word = wn.synset(synset)
			print(list(word.closure(hyper)))
		else:
			print(synset)



if __name__ == '__main__':
    do_main()
