function audioFiles = readAllSampleAudioFiles(folderPath)
%readAllSampleAudioFiles Summary of this function goes here
%   Detailed explanation goes here

currentDir = pwd;
audioDir = [currentDir '\' folderPath '\'];
dirContent = dir(audioDir);
fileNames = {dirContent(~cellfun(@isempty,regexpi({dirContent.name},'.*(mp3|wav)'))).name};

numberOfElements = length(fileNames);
audioFiles = AudioFile.empty(numberOfElements, 0);
for i=1:numberOfElements
    
    try
    
    filePath = [audioDir fileNames{i}];
    AF = AudioFile(filePath);
    
    audioFiles(i).data = AF.data;
    audioFiles(i).samplingFrequancy = AF.samplingFrequancy;
    audioFiles(i).info = AF.info;
    
    catch exception
        error('Error reading file %s', filePath);
    end
end

end
