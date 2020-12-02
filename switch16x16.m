function output = switch16x16(inputArray, mapArray)
% This is 16 x 16 switch chip model.
% -arg1: 
%   Chip input lines, 16 column array.
% -arg2:
%   Chip map array, 16 column array.
% -output:
%   Chip output line mapped from input array, 16 column array.
% -example:
%   output = Switch16x16(inputArray, mapArray);

    output = zeros(16,1);
    for i=1:16
        output(i) = inputArray(mapArray(i));
    end
end
