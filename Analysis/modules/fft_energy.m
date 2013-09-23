% Compares FFT energy differences encoded with orginal sample
% http://www.mathworks.se/products/matlab/examples.html?file=/products/demos/shipping/matlab/fftdemo.html
function [e desc] = fft_energy(raw_pcm, enc_pcm)

    raw_pcm = double(raw_pcm) / 32676.0;
    enc_pcm = double(enc_pcm) / 32676.0;
    
    desc = {};

    desc.FILE_PATTERN    =  'fft-energy-diff-%s.png';
    desc.Y_TITLE         =  'Average FFT energy diff, DB';
    desc.X_TITLE_PATTERN =  'Average FFT energy diff per sample - %s';


    
    [S,F,T,P] = spectrogram(abs(enc_pcm),2048,512,2048,44100);
    p = sum(S .* conj(S)) / 2048;

    e1 = 10 * log10(p);

    [S,F,T,P] = spectrogram(abs(raw_pcm),2048,512,2048,44100);
    p = sum(S .* conj(S)) / 2048;

    e2 = 10 * log10(p);
    
    e = mean(abs(e1 - e2));
    

end