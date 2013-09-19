function files = listDirFiles(dirpath, filter)
%% list all certain type files in sub diretory
% usage: array = listDirFiles('./audio', '.*(mp3|wav)')
%
    dirContent = dir(dirpath);
    files = {dirContent(~cellfun(@isempty,regexpi({dirContent.name},filter))).name};
end