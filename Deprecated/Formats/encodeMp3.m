% encodes WAV data in MP3 format
function encodeMp3(filename, audio_data, frequency)
    addpath('Library/mp3readwrite/mp3readwrite/');
	disp(['Writing mp3 file: ', filename]);
    mp3write(audio_data, frequency, filename);
end % encode