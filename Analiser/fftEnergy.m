function [tm e] = fftEnergy(x,window,overlap,Fs,Pr)
% Returns energy DB
% x -signal
% window - signal window
% overlap - overlaping part
% Fs - frequency (used for returning time slot)
% Pr - reference power factor
% returns:
% tm - time slice
% e - energy values

% http://www.mathworks.se/products/matlab/examples.html?file=/products/demos/shipping/matlab/fftdemo.html

% calculating by 
[S,F,T,P] = spectrogram(x,window,overlap,window,Fs);

%calculating power
p = sum(S .* conj(S)) / window;
tm = T;
e = 10 * log10(p / Pr);

end