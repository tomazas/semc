classdef AudioFile
    %AudioFile Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = public)
        data
        samplingFrequancy
        info
    end
    
    methods
        function AF = AudioFile(filePath)
            if nargin > 0
                [AF.data, AF.samplingFrequancy] = audioread(filePath);
                AF.info = audioinfo(filePath);
            end
        end % AudioFile
        
        function play(AF)
            sound(AF.data, AF.samplingFrequancy);
        end % play
        
    end % methods
end % classdef