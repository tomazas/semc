classdef AudioFile
    %AudioFile Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = public)
        data
        samplingFrequancy
    end
    
    methods
        function AF = AudioFile(filePath)
            [AF.data, AF.samplingFrequancy] = audioread(filePath);
        end % AudioFile
        
        function play(AF)
            sound(AF.data, AF.samplingFrequancy);
        end % play
        
    end % methods
end % classdef

