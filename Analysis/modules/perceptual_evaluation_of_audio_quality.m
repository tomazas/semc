function [score desc] = perceptual_evaluation_of_audio_quality(raw_pcm, enc_pcm, bitrate)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    desc = {};

    desc.FILE_PATTERN    =  'peaq-%s.png';
    desc.Y_TITLE         =  'Score (lower is better)';
    desc.X_TITLE_PATTERN =  'PEAQ analysis - %s';
    
    addpath('Library\PQevalAudio-v1r0\PQevalAudio', 'Library\PQevalAudio-v1r0\PQevalAudio\CB', 'Library\PQevalAudio-v1r0\PQevalAudio\MOV', 'Library\PQevalAudio-v1r0\PQevalAudio\Misc', 'Library\PQevalAudio-v1r0\PQevalAudio\Patt');
    
    % create temp dir if not exist
    if ~(exist('temp','dir'))
        mkdir('temp');
    end
    
    currentDir = pwd;
    tempFile1 = [currentDir '\temp\temp1.wav'];
    tempFile2 = [currentDir '\temp\temp2.wav'];
    
    audiowrite(tempFile1, raw_pcm, 48000);
    audiowrite(tempFile2, enc_pcm, 48000);
    
    score = PQevalAudio(tempFile1, tempFile2);
    
    delete(tempFile1);
    delete(tempFile2);
end

