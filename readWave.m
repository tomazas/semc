% wrapper for reading a WAVE file, usage: 
%     [pcmdata, frequency, info] = readWave('/data/hello.wav')
function [data, frequency, info] = readWave(filePath)
	[data, frequency] = audioread(filePath);
	%info = audioinfo(filePath);
end