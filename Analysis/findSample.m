function match = findSample(haystack, samplename, codec, bitrate)
    match  = -1;
    for k=1:length(haystack.Path)
        if ((strcmp(haystack.Codec{k}, codec)==1) && (haystack.Bitrate(k) == bitrate) ...
            && (strcmp(haystack.SampleName{k},samplename)==1))
            match = k;
%                 fprintf('match - path: %s, samplename: %s, codec: %s, bitrate: %d, longname: %s\n', ... 
%                     haystack.Path{k}, haystack.SampleName{k}, haystack.Codec{k}, haystack.Bitrate(k), haystack.LongName{k});
            return;
        end
    end
end