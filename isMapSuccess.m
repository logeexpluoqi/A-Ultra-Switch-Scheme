function output = isMapSuccess(mapArray, outLinesArray)
% This function is used to juge the switch map.
% -arg1:
%   mapArray: A column vector, the expected map.
% -arg2:
%   outLinesArray: A colum vector, the actual map.
% -output:
%   If map success, output is 0, else output is 1.
% -example:
%   flag = isMapSuccess(mapArray, outLinesArray);  
    if nargout == 0
        arraySize = size(outLinesArray);
        fprintf('   * Array size is: <%d x %d>.\n', arraySize(1), arraySize(2));
    end
    if ~isequal(mapArray, outLinesArray) 
        fprintf('   ** There are some errors in map!\n')
        if(nargout == 0)
            diffElement = mapArray - outLinesArray;
            for i = 1:arraySize(1)
                if diffElement(i) ~= 0 
                    fprintf('   ** Error signal line is: %d, expected is: %d, actual is: %d.\n', i, mapArray(i), outLinesArray(i));
                end
            end
            fprintf('\n');
        else
            output = 1;
        end
    else
        if nargout == 0 
            fprintf('   * Switch successfully !\n');
        else
            output = 0;
        end
    end
end
