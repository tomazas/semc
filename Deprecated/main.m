function main
    % dont' forget - easier to debug in a clean screen
    clc; clear all; close all;
    format compact;
    
    addpath('./Formats/');
    
    % get all wave files
    audioDir = [pwd '\Audio\'];
    fileNames = listDirFiles(audioDir, '.*(wav)$');

    % load all audio files from subdirectory , play & encode them to mp3 format
    numberOfElements = length(fileNames);
    for i=1:numberOfElements
        try
            filePath = [audioDir fileNames{i}];
            fprintf('Loading WAV file: %s\n', filePath)
            
            [audio_data, frequency] = wavread(filePath);
            
            % list file information
            fprintf('File: %s loaded, frequency: %d, pcm data size: %d bytes\n', ...
                filePath, frequency, length(audio_data));
            
            % uncomment to hear how it plays :P
            %disp('Playing the sound - demo'); 
            %playSound(audio_data, frequency);
            
            % encode with different encoders - generate data
            %TODO: add more encoders here
            %TODO: need to specify birate(kbps)
            %TODO: need more WAV files: longer, different kbps, etc.
            disp('Encoding file...'); 
            encodeMp3([filePath '.mp3'], audio_data, frequency);
            
        catch exception
            disp(getReport(exception, 'extended'));
        end
    end

    fprintf('Main completed.\n');

end % end of main


