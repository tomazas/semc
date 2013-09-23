% compares PCM streams dirrectly by calculating Mean Square Error of two
% signals 
function [mse desc] = sq_diff_analyser(raw_pcm, enc_pcm)

    desc = {};

    desc.FILE_PATTERN    =  'diff-%s.png';
    desc.Y_TITLE         =  'Score (lower is better)';
    desc.X_TITLE_PATTERN =  'Mean Square Error analysis - %s';
    
    % difference
    delta = abs(enc_pcm - raw_pcm).^2;
    mse = sum(delta(:))/numel(raw_pcm);

%     plot(raw_pcm, 'b');
%     hold on;
%     plot(delta, 'r');
% %     hold on;
% %     plot(enc_pcm, 'g');
end