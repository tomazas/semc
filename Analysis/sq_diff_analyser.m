% compares PCM streams dirrectly by taking a squared difference of the
% sample data and summing the result as score, lower score is better (0 = PCMs match perfectly) 
function score = sq_diff_analyser(raw_pcm, enc_pcm)
    % transcoded PCM is longer, compare only available length
    a = length(raw_pcm);
    b = length(enc_pcm);
    range = min(a,b);
    % ffmpeg adds an offset to transcoded data at the start
    ffmepg_offset = 2048;

    score = 0;
    delta = zeros(1, range);
    for i=1:range
        % squared difference
        delta(i) = enc_pcm(i+ffmepg_offset) - raw_pcm(i);
        score = score + delta(i)*delta(i);
    end

%     plot(1:range, delta, 'b');
%     hold on;
%     plot(1:range, raw_data(1:range), 'r');
%     hold on;
%     x = ffmepg_offset;
%     y = range+ffmepg_offset-1;
%     plot(1:range, transcoded_data(x:y), 'g');
end