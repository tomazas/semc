% Configuration file

global SEMC;

SEMC.SAMPLES_FILE ='samples.hdf5';

SEMC.MODULES_DIR  = strcat(pwd,'/modules');

SEMC.RESULTS_DIR  ='results';

% amplification_analyser, 
% fft_energy, 
% peak_siganl_to_noise_ratio, 
% sq_diff_analyser
SEMC.RESTRICT = ''; % leave empty to run all
