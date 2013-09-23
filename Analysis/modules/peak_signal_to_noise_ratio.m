function [psnr desc] = peak_siganl_to_noise_ratio(raw_pcm, enc_pcm, bitrate)
%   This function calculates peak signal to noise ratio
%   Uses logic from http://en.wikipedia.org/wiki/Peak_signal-to-noise_ratio
%   Typical values for the PSNR in lossy image and video compression are 
%   between 30 and 50 dB, provided the bit depth is 8 Bit, where higher is 
%   better. For 16 Bit data typical values fot the PSNR are between 
%   60 and 80 dB.[6][7] Acceptable values for wireless transmission quality 
%   loss are considered to be about 20 dB to 25 dB.

    desc = {};

    desc.FILE_PATTERN    =  'pnsr-%s.png';
    desc.Y_TITLE         =  'dB (higher is better)';
    desc.X_TITLE_PATTERN =  'Peak Signal to Noise Ratio analysis - %s';
    
    delta = abs(enc_pcm - raw_pcm).^2;
    mse = sum(delta(:))/numel(raw_pcm);
    max = 2^bitrate - 1;
    psnr = 20*log10(double(max)) - 10*log10(mse);
    
end

