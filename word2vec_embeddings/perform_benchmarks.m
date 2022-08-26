clear all

SANETOOLBOX='/home/giac/Documents/LAB/In_Corso/CORPORA/SaneNLP_toolbox/';
addpath(SANETOOLBOX);
corpus='corpora_litemo_a05s512w5s1E03_v20220112.mat';

smoothing=0;

%%% Rubenstein & Goodenough (RG-65) dataset
[r, rho,coverage] = SNLP_benchmark_eng_rg65(corpus, smoothing);

%%% Finkelstein et al. (2002)
[r, rho, coverage] = SNLP_benchmark_eng_ws353(corpus, smoothing);

%%% MEN dataset (Bruni et al., 2013)
[r, rho, coverage] = SNLP_benchmark_eng_men(corpus, smoothing);

%%% TOEFL Synonym Questions introduced in Landauer and Dumais (1997)
[acc, dof, coverage] = SNLP_benchmark_eng_toefl(corpus, smoothing);

%%% Lenci et al. (2013)
[r,rho,coverage,RDM_behav,RDM_corpora,concepts_labels]=SNLP_benchmark_eng_lenci2013(corpus,smoothing);

%%% McRae et al. (2005)
[r, rho, acc, RDM_behav, RDM_corpora, concepts_labels, coverage] = SNLP_benchmark_eng_mcrae2005(corpus, smoothing);

%%% Vinson & Vigliocco (2008)
[r, rho, acc, RDM_behav, RDM_corpora, concepts_labels, coverage] = SNLP_benchmark_eng_vinson2008(corpus, smoothing);

%%% Roi Reichart and Anna Korhonen (2015)
[r, rho, coverage] = SNLP_benchmark_eng_simlex999(corpus, smoothing);

%%% Halawi et al. (2012)
[r, rho, coverage] = SNLP_benchmark_eng_mturk771(corpus, smoothing);

%%% Buchanan et al. (2013)
[r, rho, acc, RDM_behav, RDM_corpora, concepts_labels, coverage] = SNLP_benchmark_eng_wordnorms(corpus, smoothing);
