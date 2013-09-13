classdef AudioFile
    %AudioFile Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = public)
        file
        samplingFrequancy
    end
    
    methods
        function AF = AudioFile(filePath)
            [AF.file, AF.samplingFrequancy] = audioread(filePath);
        end % AudioFile
        
        function play(AF)
            sound(AF.file, AF.samplingFrequancy);
        end % play
        
    end % methods
end % classdef

