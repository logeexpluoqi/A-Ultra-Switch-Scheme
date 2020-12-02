% This file is used to find model errors.
% Use this scrip to find error or test accuracy.
% Model = 0: find error;
% Model = 1: test accuracy.
Model = 0;

cycIndex = 0;
if Model == 0
    clearvars -except cycIndex; clc;
    while(1)
        temp_test;
        cycIndex = cycIndex + 1;
        if ~isequal(C1, 40*ones(1,4)) || ...
           ~isequal(C2, 40*ones(1,4)) || ...
           ~isequal(C3, 40*ones(1,4)) || ...
           ~isequal(C4, 40*ones(1,4)) || ...
           ~isequal(sum(requireTypeNum < 0), zeros(1,4,4))

           break;
        end

    end
    fprintf("-* Number of execut: [%d] times.\n",cycIndex);
elseif Model == 1
    clearvars -except cycIndex testTimes errorCnt; clc;
    testTimes = 10000;
    errorCnt = 0;
    while(testTimes > 0)
        temp_test;
        cycIndex = cycIndex + 1;
        if ~isequal(C1, 40*ones(1,4)) || ...
           ~isequal(C2, 40*ones(1,4)) || ...
           ~isequal(C3, 40*ones(1,4)) || ...
           ~isequal(C4, 40*ones(1,4)) || ...
           ~isequal(sum(requireTypeNum < 0), zeros(1,4,4))

           errorCnt = errorCnt + 1;
           clc;
        end
        testTimes = testTimes - 1;
    end
    fprintf("-* Model accuracy is: [%.4f].\n",(cycIndex - errorCnt) / cycIndex);
end
