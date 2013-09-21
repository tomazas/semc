% compares PCM streams dirrectly by taking a difference of the
% sample data and summing the result as score, lower score is better (0 = PCMs match perfectly) 
function score = sq_diff_analyser(raw_pcm, enc_pcm)
    % ffmpeg adds an offset to transcoded data at the start
    offset = 2048;
    a = length(raw_pcm);
    b = length(enc_pcm)-offset;
    % transcoded PCM is longer, compare only available length
    range = min(a, b);
    
    original_signal = raw_pcm(1:range);
    encodec_signal = enc_pcm(offset:(offset+range-1));
    
    % difference
    delta = abs(encodec_signal - original_signal);
    score = sum(delta);

%     plot(original_signal, 'b');
%     hold on;
%     plot(delta, 'r');
% %     hold on;
% %     plot(encodec_signal, 'g');
end