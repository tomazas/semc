% compares PCM streams dirrectly by taking a difference of the
% sample data and summing the result as score, lower score is better (0 = PCMs match perfectly) 
function score = sq_diff_analyser(raw_pcm, enc_pcm)

    % difference
    delta = abs(enc_pcm - raw_pcm);
    score = sum(delta);

%     plot(raw_pcm, 'b');
%     hold on;
%     plot(delta, 'r');
% %     hold on;
% %     plot(enc_pcm, 'g');
end