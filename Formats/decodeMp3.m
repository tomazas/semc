% decodes MP3 file & returns WAV PCM data
% TODO: specify bitrate (kbps)
function [audio_data, frequency] = decodeMp3(filename)
    addpath('Library/mp3readwrite/mp3readwrite/');

    [audio_data, frequency] = mp3read(tempFile);
end % encode