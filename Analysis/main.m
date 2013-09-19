clc;
format compact;
clear all; close all;

fp = 'samples.hdf5'; % PCM data source file

raw = h5read(fp, '/info/raw_sample_info');
% uncomment to list HDF5 file contents
% for i=1:length(raw.Path)
%     fprintf('raw stream - path: %s, samplename: %s, bitrate: %d\n', ... 
%         raw.Path{i}, raw.samplename{i}, raw.samplerate(i));
% end

enc = h5read(fp, '/info/encoded_samples');
% uncomment to list HDF5 file contents
% for i=1:length(enc.Path)
%     fprintf('enc stream - path: %s, samplename: %s, codec: %s, bitrate: %d, longname: %s\n', ... 
%         enc.Path{i}, enc.SampleName{i}, enc.Codec{i}, enc.Bitrate(i), enc.LongName{i});
% end

codecs = unique(enc.Codec);
bitrates = unique(enc.Bitrate);

% runs test through all PCM samples, all codecs & all bitrates
% generates a plot for every sample file
for z=1:length(raw.Path)
    samplename = raw.samplename{z};
    quality = zeros(length(codecs), length(bitrates));
   
    for i=1:length(codecs)
        codec = codecs{i};
        for j=1:length(bitrates)
            bitrate = bitrates(j);
            
            fprintf('Analyzing PCM file: %s, codec: %s, bitrate: %d, samplename: %s\n', ...
                raw.Path{z}, codec, bitrate, samplename);
 
            k = findSample(enc, samplename, codec, bitrate); % ensure we find the required one
            if (k == -1) 
                error('Match not found');
            end
            
			% read PCM data
            raw_pcm = h5read(fp, raw.Path{z});
            enc_pcm = h5read(fp, enc.Path{k});
            
            % runs a simple PCM quality analyzer
            score = sq_diff_analyser(raw_pcm, enc_pcm);
            fprintf('Score: %f\n', score);
            
			% store computed score for plotting
            quality(i, j) = score;
        end
    end
    
    % do a plot for this PCM file
    figure(z); hold on; grid on;
    title(samplename);
    xlabel('Bitrate'); ylabel('Score');
    plot(bitrates, quality, 'LineWidth', 2, 'Marker','o');
    legend(codecs);
end

disp('Complete.');
