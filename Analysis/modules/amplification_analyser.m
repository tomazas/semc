% Estimates signal level change (amplification).
% Amplification of k = 1 - means that the compared signal levels have not
% changed, k < 1 - signal aplitude is 1/k times lower(muted), 
% k > 1 - amplitude is k times greater(boosted).
function [k desc] = amplification_analyser(raw_pcm, enc_pcm, bitrate)

    desc = {};
    
    desc.FILE_PATTERN    = 'amp-%s.png';
    desc.Y_TITLE         = 'Amplification';
    desc.X_TITLE_PATTERN = 'Amplification analysis - %s';

    % variance of both signals
    var_signal = var(double(raw_pcm));
    var_noise = var(double(enc_pcm));
    
    % amplification
    k = 1/sqrt(var_signal/var_noise);

end