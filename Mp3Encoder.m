classdef Mp3Encoder < Encoder
    %Mp3Encoder Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
        function AF = encodeAudioFile(~, audioFile)
            addpath('Library/mp3readwrite/mp3readwrite/');
            
            % create temp dir if not exist
            if ~(exist('temp','dir'))
                mkdir('temp');
            end
            
            currentDir = pwd;
            tempFile = [currentDir '\temp\temp.mp3'];
            
            mp3write(audioFile.data, audioFile.samplingFrequancy, tempFile);
            AF = AudioFile;
            [AF.data, AF.samplingFrequancy] = mp3read(tempFile);
            % TODO: add info for encoded file
            % AF.info = audioinfo(tempFile);
            
            delete(tempFile);
        end % encode
    end
    
end