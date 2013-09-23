function main
    clc;
    format compact;
    clear all; close all;

    config; % load configuration
    global SEMC;
    
    fig_cntr = 0;
    fp = SEMC.SAMPLES_FILE; % PCM data source file

    raw = h5read(fp, '/info/raw_sample_info');
    % uncomment to list HDF5 file contents
    % for i=1:length(raw.Path)
    %     fprintf('raw stream - path: %s, samplename: %s, bitrate: %d\n', ... 
    %         raw.Path{i}, raw.SampleName{i}, raw.SampleRate(i));
    % end

    enc = h5read(fp, '/info/encoded_samples');
    % uncomment to list HDF5 file contents
    % for i=1:length(enc.Path)
    %     fprintf('enc stream - path: %s, samplename: %s, codec: %s, bitrate: %d, longname: %s\n', ... 
    %         enc.Path{i}, enc.SampleName{i}, enc.Codec{i}, enc.Bitrate(i), enc.LongName{i});
    % end

    codecs = unique(enc.Codec);
    bitrates = unique(enc.Bitrate);

    
    addpath(SEMC.MODULES_DIR); % modules must be in execute path
    
    analyse_modules =  findModules();
    len_analyse_modules = length(analyse_modules);
 
    % runs test through all PCM samples, all codecs & all bitrates
    % generates a plot for every sample file
    for z=1:length(raw.Path)
        samplename = raw.SampleName{z};
        
        %quality_diff = zeros(length(codecs), length(bitrates));
        %quality_amp = zeros(length(codecs), length(bitrates));
        
        for analise_module = 1:len_analyse_modules
       
            codec_data = zeros(length(codecs), length(bitrates));
            desc ={};
            
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

                    % ffmpeg adds an offset to transcoded data at the start
                    offset = 2048;
                    a = length(raw_pcm);
                    b = length(enc_pcm)-offset;
                    % transcoded PCM is longer, compare only available length
                    range = min(a, b);
                    raw_signal = raw_pcm(1:range);
                    enc_signal = enc_pcm(offset:(offset+range-1));


                    eval(sprintf('[ codec_data(i,j)  desc]= %s(raw_signal,enc_signal);',analyse_modules{analise_module}));
                    
                    % runs a analysis tests for the PCM data

                    %quality_diff(i, j) = sq_diff_analyser(raw_signal, enc_signal);
                    %quality_amp(i, j) = amplification_analyser(raw_signal, enc_signal);

                    % TODO: add tests here
                end
                
            end
            
            graph(codec_data,strcat(SEMC.RESULTS_DIR,'/',desc.FILE_PATTERN),desc.Y_TITLE,sprintf(desc.X_TITLE_PATTERN,samplename));
            
        end
        % does some form of result plotting
        
        %graph(quality_diff, 'results/diff-%s.png', 'Score (lower is better)', ...
        %    sprintf('Difference analysis - %s', samplename));
        %graph(quality_amp, 'results/amp-%s.png', 'Amplification', ....
        %    sprintf('Amplification analysis - %s', samplename));
        
        % TODO: add more plotting of data here
    end
    
    function h = graph(data, pattern, y_title, plot_title)
        % do a plot for this PCM file
        fig_cntr = fig_cntr+1;
        h = figure(fig_cntr); hold on; grid on;
        title(strrep(plot_title, '_', ' '));
        xlabel('Bitrate'); ylabel(y_title);
        plot(bitrates, data, 'LineWidth', 2, 'Marker','o');
        legend(codecs);
        
        saveas(h, sprintf(pattern, samplename));
        close(h);
    end

    % ability to test/verify data
    function playSound(pcm_data)
        sound((double(pcm_data)./16384.0), 44100);
    end

    disp('Complete.');
end
