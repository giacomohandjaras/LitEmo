# LitEmo v1.00

#################################################<br>
STEP A: from single books to a collection of documents, each one corresponding to an author<br>
#################################################<br>

1) <i>additional_scripts/aggregate_books_by_authors.m</i>: merge books from the same author and create a unique document.

2) <i>additional_scripts/get_vocabulary_multiplefiles.sh</i>: Require UTF-8 documents. Create a dictionary file from each document using word2vec command and counting the occurrences of all the words

3) <i>additional_scripts/get_vocabulary_singlefile.sh</i>: create a dictionary from a single file, as a corpus. The cutoff here is 40 occurrences as in Google Books

4) The terms in #3 (~70k) were manually inspected: 25 terms were still corrupted despite UTF-8 and digital format and thus they were removed. The file ALL_TERMS/all_terms_v20220112.txt contains the words of interest used in the subsequent analyses

5) <i>measure_multiplefiles_freqs.m</i>: evaluate occurrences, ranks and basic stats of each document pertaining to the words identified in #4. Results were saved in ALL_TERMS/all_terms_v20220112.mat

6) <i>extract_author_covariates.m</i>: recover author information (name, sex, country of origin, publication year) using the data enclosed in corpus_v20220112.xlsx. Results were included in file authors_info_v20220112.mat

#################################################<br>
STEP B: Creation of 3 corpora for word-embeddings<br>
#################################################<br>

1) Create 3 corpora, one using all the authors (<i>generate_corpora_litemo.sh</i>), one male-only (<i>generate_corpora_litemo_male.sh</i>), and one female-only (<i>generate_corpora_litemo_female.sh</i>), by concatenating authors in chronological order (curriculum learning)

2) Creation of word embeddings using word2vec and the dictionary of STEP A4 (~70k): -read-vocab word2vec_embeddings/corpora_litemo_curriculum_learning_v20220112.dic -alpha 0.05 -iter 10 -size 512 -window 5 -sample 1e-3 -negative 0 -hs 1 -binary 0 -cbow 0 (see word2vec_embeddings/run_word2vec*)

3) Conversion of word embeddings from word2vec (text format) to Matlab using <i>SaneNLP_toolbox/SNLP_convertW2VtoMAT.m</i>

#################################################<br>
STEP C: main analyses <br>
#################################################<br>

1) <i>plot_basic_stats.m</i>: descriptive statistic (e.g., authors, prizes, words used, Zipf's and Heaps' laws), mainly reported in Figure 1 and Supplementary Figure 1

2) <i>plot_graph.m</i>: create graphs of Figure 1. Requires a list of 25k common words generated in STEP C6

3) <i>plot_cohen_sex_historical_period.m</i>: create Panel A of Figure 2. Requires a list of 25k common words generated in STEP C6

4) <i>plot_wordclouds.m</i>: create Panel B of Figure 2. Requires a list of 25k common words generated in STEP C6

5) <i>plot_HDI.m</i>: create Panel C-D of Figure 2. Requires HDI data in directory HDI/ and a list of 25k common words generated in STEP C6

6) <i>main_analysis.m</i>:  a) find a list of common terms (~25k), which are used at least by 10% of male or females authors.
                            b) for each term we defined a GLM: freq ~ intercept + sex + historical_period + sex*historical_period + translated + continent
                            c) we identified from the previous step a set of 576 terms (p<0.05 FWE corected)
                            d) for these terms we extracted word-embeddings, perform t-SNE and plot the results in Figure 3 and Supplementary Figure 3 (<i>plot_tSNE.m</i>)

7) <i>main_analysis_retest.m</i>: same as STEP C6, but here using ranks instead of frequencies

8) <i>plot_wordnet_clustering.m</i>: from the list of 576 words identified in STEP C6, we extracted synsets and hyperonyms using wordnet and defined 11 semantic categories which represented the majority of nouns in the list

9) <i>plot_wordnet_intime.m</i>: we represented the historical trends of the Cohen's d related to the semantic categories (plots in Figure 3)

10) <i>plot_warriner.m</i>: from the list of 576 words, we evaluated valence and arousal and their trends in time (Figure 4A-D)

11) <i>plot_sentiment.m</i>: we performed a sentiment analysis to extract average valence and arousal per author and plot their trends in time (Figure 4E-G)

#################################################<br>
STEP D: additional analyses <br>
#################################################<br>

1) <i>measure_sentiment_dodds.m</i>: perform a sentiment analysis using Happiness score from Dodds et al.(2015), instead of Warriner et al., (2013). Results are reported in Supplementary Figure 4 and 6

2) <i>plot_diachronic_words.m</i>: measure the number of diachronic words in the list of 576 words identified in STEP C6

3) <i>plot_google_freq.m</i>, <i>plot_google_trends_allwords.m</i>, <i>plot_google_trends.m</i>, <i>plot_terms_intime_with_google.m</i>: comparisons with Google Fiction 2020. Results are mainly reported in Supplementary Figure 2

4) <i>plot_liwc.m</i>: sentiment analysis performed using LIWC 2015. Results are reported in Supplementary Figure 5

5) <i>plot_terms_inspace.m</i>: worldmap mapping the Cohen's d of the sex effect for each term of interest (Supplementary Figure 7A)

6) <i>plot_terms_intime.m</i>: historical trends of word frequency for each sex (Supplementary Figure 7B)

7) <i>plot_terms_semantic_shifts.m</i>: sankey plot related to the semantic shifts of words (Supplementary Figure 7C)

8) <i>measure_author_dictionary_bootstrap.m</i>: bootstrap measure of the vocabulary size (Supplementary Figure 1F)
<br>
<br>

Figures and supplementary tables are available in directory <i>figures/</i> and <i>supplementary tables/</i>. <br>
Large MAT files, figures and supplementary tables are available in the OSF repository of the project: https://osf.io/mcx5a/ <br>
Website to explore results: https://www.sane-elab.eu/litemo/welcome.php <br>



