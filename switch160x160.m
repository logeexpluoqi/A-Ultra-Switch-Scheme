function output = switch160x160(inputArray, mapArray)
% This is 160 x 160 switch chip model.
% -arg1: 
%   Chip input lines, 160 column array.
% -arg2:
%   Chip map array, 160 column array.
% -output:
%   Chip output line mapped from input array, 160 column array.
% -example:
%   output = Switch160x160(inputArray, mapArray);
    output = zeros(160,1);
    for i = 1:160
        output(i) = inputArray(mapArray(i));
    end
end
