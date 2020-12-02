function output = setLayer1Map(chip, inLine, outLine)
% This function is used to set layer 1 map.
% -arg1:
%   chip: Layer 1 switch chip.
% -arg2:
%   inLine: Chip's input line.
% -arg3:
%   outLine: Chip's input line map to this output line.
%   The layer 1 map array.
% -example:
%   setLayer1Map(chip, inLine, outLine);
%   layer1MapArray = setLayer1Map(chip, inLine, outLine);
    global mapArrayLayer1;
    if (chip > 40) || (inLine > 16) || (outLine > 16) 
        fprintf('   *  Input arg error! chip no more than 40, inLine and outLine no more than 16.\n');
        fprintf('   ** Error take place in layer 1 <chip: %d, inLine: %d, outLine: %d>.\n', chip, inLine, outLine);
        return;
    end
    mapArrayLayer1(inLine, chip) = outLine;
    output = mapArrayLayer1;
end