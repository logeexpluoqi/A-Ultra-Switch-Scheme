function output = setLayer2Map(chip, inLine, outLine)
% This function is used to set layer 2 map.
% -arg1:
%   chip: Layer 2 switch chip.
% -arg2:
%   inLine: Chip's input line.
% -arg3:
%   outLine: Chip's input line map to this output line.
% -output:
%   The layer 2 map array.
% -example:
%   setLayer2Map(chip, inLine, outLine);
%   layer2MapArray = setLayer2Map(chip, inLine, outLine);

    global mapArrayLayer2;
    if (chip > 4) || (inLine > 160) || (outLine > 160) 
        fprintf('   *  Input arg error! chip no more than 4, inLine and outLine no more than 160.\n');
        fprintf('   ** Error take place in layer 2 <chip: %d, inLine: %d, outLine: %d>.\n', chip, inLine, outLine);
        return;
    end
    mapArrayLayer2(inLine, chip) = outLine;
    output = mapArrayLayer2;
end