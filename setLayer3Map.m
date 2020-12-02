function output = setLayer3Map(chip, inLine, outLine)
% This function is used to set layer 3 map.
% -arg1:
%   chip: Layer 3 switch chip.
% -arg2:
%   inLine: Chip's input line.
% -arg3:
%   outLine: Chip's input line map to this output line.
% -output:
%   The layer 3 map array.
% -example:
%   setLayer3Map(chip, inLine, outLine);
%   layer3MapArray = setLayer3Map(chip, inLine, outLine);
    global mapArrayLayer3;
    if (chip > 4) || (inLine > 160) || (outLine > 160)
        fprintf('   *  Input arg error! chip no more than 4, inLine and outLine no more than 160.\n');
        fprintf('   ** Error take place in layer 3 <chip: %d, inLine: %d, outLine: %d>.\n', chip, inLine, outLine);
        return;
    end
    mapArrayLayer3(inLine, chip) = outLine;
    output = mapArrayLayer3;
end