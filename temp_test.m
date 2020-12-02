clearvars -except cycIndex testTimes errorCnt; clc;

%% Output requires
% output = 1:640;
% output = randi(6 40, 640, 1);
% output(1:10) = ones(1,10);
%  load('sss.mat','output');
output = randperm(640)'; 

%% Some variables
output3 = ones(160,4);
output2 = ones(160,4);

%% Layer3 input signals requires
for i = 1:4
    output3(:,i) = output(i*160-159:i*160);
end
input3 = output3;

% First sort signals by using asending order, for next step
input3 = sortSignals(input3);

global signalTypeCnt requireTypeNum;

%% Find layer2 chip need signals destribution
% Sort layer3 input signals requires

% Divided layer3 signals to 40 types, each type is corresponding to layer1 signals.
groupSignals(40,4).signals = 0; % layer3 signal located 
signalTypeCnt = zeros(40,4); % layer3 chip signals in groups counter
for i = 1:4
    for j = 1:160
        N = ceil(input3(j,i) / 16); % where is the signal lacated in layer1
        signalTypeCnt(N, i) = signalTypeCnt(N, i) + 1;
        groupSignals(N,i).signals(signalTypeCnt(N,i)) = input3(j,i);
    end
end
orgTypeCnt = signalTypeCnt;

%% Find layer2 chip needs signals number about 40 signal types.
requireTypeNum = zeros(40,4,4);

for i = 1:3
    sumOfCol = zeros(40,1); 
    sumOfRequireCol = zeros(40,1); 
    sumOfRow = zeros(1,4);
    sumOfRequireRow = zeros(1,4);
    
    if i ~= 3
        for k = 1:40 % rows
            sumOfRow = sumOfRow + signalTypeCnt(k,:);
            % The first and second time allocate signals.
            for j = 1:4 % columns
                if j < 4
                    sumOfCol(k) = sumOfCol(k) + signalTypeCnt(k,j);
                    if isequal(signalTypeCnt(k, (j+1):4), zeros(1, 4 - j))
                        colFirst = 1;
                    else
                        colFirst = 0;
                    end

                    if mod(j,2) == 1 % odd column or even column
                        if k == 1 || colFirst == 1 % the first row
                            num = ceil(sumOfCol(k) / (4 - i + 1)) - sumOfRequireCol(k);
                        else
                            num = ceil(sumOfRow(j) /  (4 - i + 1)) - sumOfRequireRow(j);
                        end
                    else
                        if k == 1 || colFirst == 1
                            num = floor(sumOfCol(k) /  (4 - i + 1)) - sumOfRequireCol(k);
                        else
                            num = floor(sumOfRow(j) /  (4 - i + 1)) - sumOfRequireRow(j);
                        end
                    end
                    
                    if num < 0 
                        num = 0;
                    elseif signalTypeCnt(k,j) - num < 0
                        num = signalTypeCnt(k,j);
                        sumOfRequireCol(k) = sumOfRequireCol(k) + num;
                        if sumOfRequireCol(k) >= 4 
                            sumOfRequireCol(k) = sumOfRequireCol(k) - num;
                            num = 4 - sumOfRequireCol(k);
                            sumOfRequireCol(k) = 4;
                        end
                    else
                        sumOfRequireCol(k) = sumOfRequireCol(k) + num;
                        if sumOfRequireCol(k) > 4 && j == 1
                            num = 4;
                            sumOfRequireCol(k) = 4;
                        elseif sumOfRequireCol(k) >= 4 && j > 1
                            sumOfRequireCol(k) = sumOfRequireCol(k) - num;
                            num = 4 - sumOfRequireCol(k);
                            sumOfRequireCol(k) = 4;
                        end
                    end
                    
                    sumOfRequireRow(j) = sumOfRequireRow(j) + num;
                    requireTypeNum(k,j,i) = num;
                else % deal with the fourth column
                    requireTypeNum(k,j,i) = 4 - sumOfRequireCol(k);
                    sumOfRequireRow(j) = sumOfRequireRow(j) + num;
                end
                
                signalTypeCnt(k,j) = signalTypeCnt(k,j) - requireTypeNum(k,j,i);

                % The reuqire elements is over to surplus elements.
                if signalTypeCnt(k,j) < 0 
                    [~,maxElemPos] = max(signalTypeCnt(k,:));
                    requireTypeNum(k,maxElemPos,i) = requireTypeNum(k,maxElemPos,i) + 1;
                    requireTypeNum(k,j,i) = requireTypeNum(k,j,i) - 1;
                    sumOfRequireRow(maxElemPos) = sumOfRequireRow(maxElemPos) + 1;
                    signalTypeCnt(k,maxElemPos) = signalTypeCnt(k,maxElemPos) - 1;
                    signalTypeCnt(k,j) = signalTypeCnt(k,j) + 1;
                end
            end
            % The 4th column has one more element.
            if sum(requireTypeNum(k,:,i)) > 4 && sum(requireTypeNum(k,1:3,i) < 4)
                requireTypeNum(k,4,i) = requireTypeNum(k,4,i) - 1;
                sumOfRequireCol(4) = sumOfRequireCol(4) - 1;
            end
        end
        
        [signalTypeCnt, requireTypeNum] = errCorrection(signalTypeCnt, requireTypeNum, i);
    else % the third time allocate signals
        % In this section, because of the divisor is 2, we should consider which
        % result should be carried and which result should be abdicate.
        maxColPos = 0; 
        rowOperationCnt = 0; % record row operation time
        colCnt = zeros(1,4);
        upOrDown = zeros(40, 4); % indicate this element carry or abdicate, 1: carry, 0: abdicate
        
        oddOrEven = mod(signalTypeCnt, 2); % find odd element position, 1: odd, 0: even
        for k = 1:40
            rowCnt = 0;
            if ~isequal(oddOrEven(k,:),zeros(1,4))
                if colCnt == zeros(1,4) % the first time odd element appear, sum of each column is 0
                    for j = 1:4
                        if oddOrEven(k,j) == 1 && rowCnt == 0
                            colCnt(j) = colCnt(j) + 1;
                            rowCnt = rowCnt + 1;
                            upOrDown(k,j) = 1;
                        elseif oddOrEven(k,j) == 1 && rowCnt == 1
                            upOrDown(k,j) = -1;
                            colCnt(j) = colCnt(j) - 1;
                            rowCnt = rowCnt - 1;
                        end
                    end
                else % column imbalance, sum of each column is not 0
                    % abs(colCnt) = 1 1 1 1, oddOrEven = 1 1 1 1
                    if isequal(abs(colCnt),oddOrEven(k,:)) && isequal(oddOrEven(k,:), ones(1,4)) 
                        for j = 1:4
                            if colCnt(j) < 0
                                upOrDown(k,j) = 1;
                                colCnt(j) = colCnt(j) + 1;
                            else
                                upOrDown(k,j) = -1;
                                colCnt(j) = colCnt(j) - 1;
                            end
                        end
                    % colCnt have 2 elements and oddOrEven(k,:) = 1 1 1 1
                    elseif sum(abs(colCnt)) == 2 && isequal(oddOrEven(k,:), ones(1,4))  
                        for j = 1:4
                            if colCnt(j) < 0 
                                upOrDown(k,j) = 1;
                                colCnt(j) = colCnt(j) + 1;
                                rowCnt = rowCnt + 1;
                            elseif colCnt(j) > 0
                                upOrDown(k,j) = -1;
                                colCnt(j) = colCnt(j) -1;
                                rowCnt = rowCnt - 1;
                            end
                        end
                        for j = 1:4
                            if upOrDown(k,j) == 0 && rowCnt == 0
                                upOrDown(k,j) = 1;
                                colCnt(j) = colCnt(j) + 1;
                                rowCnt = rowCnt + 1;
                            elseif upOrDown(k,j) == 0 && rowCnt ~= 0
                                upOrDown(k,j) = -1;
                                colCnt(j) = colCnt(j) - 1;
                                rowCnt = rowCnt - 1;
                            end
                        end
                    else
                        [maxElem, maxColPos] = max(abs(colCnt)); % find the first considerate postion in this row
                        % if the element under the maxColPos is a odd element, we can determine this element
                        if oddOrEven(k,maxColPos) == 1 
                            if colCnt(maxColPos) < 0
                                upOrDown(k,maxColPos) = 1;
                                colCnt(maxColPos) = colCnt(maxColPos) + 1;
                                rowCnt = rowCnt + 1;
                            else
                                upOrDown(k,maxColPos) = -1;
                                colCnt(maxColPos) = colCnt(maxColPos) - 1;
                                rowCnt = rowCnt - 1;
                            end
                            for j = 1:4 % find remanent elements
                                if oddOrEven(k,j) == 1 && j ~= maxColPos
                                    if rowCnt > 0
                                        upOrDown(k,j) = -1;
                                        colCnt(j) = colCnt(j) - 1;
                                        rowCnt = rowCnt - 1;
                                    else
                                        upOrDown(k,j) = 1;
                                        colCnt(j) = colCnt(j) + 1;
                                        rowCnt = rowCnt + 1;
                                    end
                                end
                            end
                        % if the element under the maxColPos is not a odd element
                        else 
                            % if maxElem have more than 2, find next maxElem postion
                            for j = 1:4
                                if abs(colCnt(j)) == maxElem && oddOrEven(k,j) == 1
                                    pos = j;
                                    break;
                                else
                                    pos = 0;
                                end
                            end
                            % if some element under the maxElem
                            if pos ~= 0
                                if colCnt(pos) < 0
                                    upOrDown(k,pos) = 1;
                                    colCnt(pos) = colCnt(pos) + 1;
                                    rowCnt = rowCnt + 1;
                                else
                                    upOrDown(k,pos) = -1;
                                    colCnt(pos) = colCnt(pos) - 1;
                                    rowCnt = rowCnt - 1;
                                end
                                for j = 1:4
                                    if oddOrEven(k,j) == 1 && j ~= pos
                                        if rowCnt > 0
                                            upOrDown(k,j) = -1;
                                            colCnt(j) = colCnt(j) - 1;
                                            rowCnt = rowCnt - 1;
                                        else
                                            upOrDown(k,j) = 1;
                                            colCnt(j) = colCnt(j) + 1;
                                            rowCnt = rowCnt + 1;
                                        end
                                    end
                                end
                            else
                            % there is no odd elements under the maxElem
                                for j = 1:4
                                    if oddOrEven(k,j) == 1 
                                        if rowOperationCnt == 0
                                            if colCnt(j) < 0
                                                upOrDown(k,j) = 1;
                                                colCnt(j) = colCnt(j) + 1;
                                                rowCnt = rowCnt + 1;
                                            else
                                                upOrDown(k,j) = -1;
                                                colCnt(j) = colCnt(j) - 1;
                                                rowCnt = rowCnt - 1;
                                            end
                                            rowOperationCnt = rowOperationCnt + 1;
                                        else
                                            if rowCnt < 0
                                                upOrDown(k,j) = 1;
                                                colCnt(j) = colCnt(j) + 1;
                                                rowCnt = rowCnt + 1;
                                            else
                                                upOrDown(k,j) = -1;
                                                colCnt(j) = colCnt(j) - 1;
                                                rowCnt = rowCnt - 1;
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        % Allocate signals, if upOrDown element equal to 1,
        % this requireTypeNum will round up to an integer, 
        tempTypeNum = signalTypeCnt / 2;
        for j = 1:4
            for k = 1:40
                if upOrDown(k,j) == 1
                    requireTypeNum(k,j,i) = ceil(tempTypeNum(k,j));
                else
                    requireTypeNum(k,j,i) = floor(tempTypeNum(k,j));
                end
            end
        end
        signalTypeCnt = signalTypeCnt - requireTypeNum(:,:,i);

        % Solve the 4th column element less than 0 problem.
        for k = 40:-1:1
            if requireTypeNum(k,4,i) < 0
                if sum(requireTypeNum(k,1:3,i)) > 4
                    requireTypeNum(k,4,i) = requireTypeNum(k,4,i) + 1;
                    if requireTypeNum(k,3,i) - 1 >= 0 
                        requireTypeNum(k,3,i) = requireTypeNum(k,3,i) - 1;
                    end
                end
            end
        end

        [signalTypeCnt, requireTypeNum] = errCorrection(signalTypeCnt, requireTypeNum, i);

        % Solve the problem about the sum of column is [38,41,39,42]
        col = sum(requireTypeNum(:,:,i));
        if ~isequal(col,40 * ones(1,4))
            errPos = find(col ~= 40);
            errNum = 40 - col(errPos);
            errElemNum = size(errPos);
            for k = 1:40
                for j = 1:errElemNum(2)
                    if errNum(j) > 0 && signalTypeCnt(k,errPos(j)) >= 0
                        requireTypeNum(k,errPos(j),i) = requireTypeNum(k,errPos(j),i) + 1;
                        signalTypeCnt(k,errPos(j)) = signalTypeCnt(k,errPos(j)) - 1;
                        errNum(errPos(j)) = errNum(errPos(j)) - 1;
                    elseif errNum(j) < 0 && signalTypeCnt(k,errPos(j)) >= 1
                        requireTypeNum(k,errPos(j),i) = requireTypeNum(k,errPos(j),i) - 1;
                        signalTypeCnt(k,errPos(j)) = signalTypeCnt(k,errPos(j)) + 1;
                        errNum(errPos(j)) = errNum(errPos(j)) + 1;
                    elseif isequal(errNum, zeros(1,4))
                        break;
                    end
                end
            end
        end
        for k = 1:40
            pos = find(requireTypeNum(k,:,i) < 0);
            if ~isempty(pos)
                [~,posMax] = max(requireTypeNum(k,:,i));
                requireTypeNum(k,pos,i) = requireTypeNum(k,pos,i) + 1;
                requireTypeNum(k,posMax,i) = requireTypeNum(k,posMax,i) - 1;
            end
        end
        [signalTypeCnt, requireTypeNum] = errCorrection(signalTypeCnt, requireTypeNum, i);
    end
    requireTypeNum(:,:,4) = signalTypeCnt;
      % Some elements are less than 0 in a row, like [1,-1,2,2], [1,3,0,-1] etc.
    for k = 1:40
        pos = find(requireTypeNum(k,:,4) < 0);
        if ~isempty(pos)
            [~,posMax] = max(requireTypeNum(k,:,4));
            requireTypeNum(k,pos,4) = requireTypeNum(k,pos,4) + 1;
            requireTypeNum(k,posMax,4) = requireTypeNum(k,posMax,4) - 1;
        end
    end
    [~, requireTypeNum] = errCorrection(signalTypeCnt, requireTypeNum, 4);
end


%% Display results.
A1 = orgTypeCnt - requireTypeNum(:,:,1);
A2 = orgTypeCnt - (requireTypeNum(:,:,1) + requireTypeNum(:,:,2));
A3 = orgTypeCnt - (requireTypeNum(:,:,1) + requireTypeNum(:,:,2) + requireTypeNum(:,:,3));

C1 = sum(requireTypeNum(:,:,1));
C2 = sum(requireTypeNum(:,:,2));
C3 = sum(requireTypeNum(:,:,3));
C4 = sum(requireTypeNum(:,:,4));

D1 = sum(oddOrEven);
D2 = [sum(upOrDown(:,1) == 1)...
      sum(upOrDown(:,2) == 1)...
      sum(upOrDown(:,3) == 1)...
      sum(upOrDown(:,4) == 1)];

%% Find some answer looks like a correct, but it's note correct.
if ~isequal(sum(requireTypeNum < 0), zeros(1,4,4))
    fprintf("-* Error !!!\n * There is some elements less than 0.\n");
    [x,y] = find(requireTypeNum < 0);
    s = size(x);
    for i = 1:s(1)
       Y = mod(y(i),4);
       if Y == 0
           Y = 4;
       end
        fprintf(" * Location is: <%d %d %d>.\n", x(i), Y, ceil(y(i)/4));
    end
end

if ~isequal(C1, 40*ones(1,4)) || ...
   ~isequal(C2, 40*ones(1,4)) || ...
   ~isequal(C3, 40*ones(1,4)) || ...
   ~isequal(C4, 40*ones(1,4))

    C = [C1; C2; C3; C4];
    [x,y] = find(C ~= 40);
    s = size(x);
    fprintf("-* Signal distribute error !!!\n");
    for i = 1:s(1)
        fprintf(" * Distribute time: [%d], Column: [%d]\n",x(i), y(i));
    end
end

%% Display update information.
fprintf("-*******************************\n * <%04d> Updated! \n", randi(1e4));

%% Local function.
function output = sortSignals(input)
    output = zeros(160,4);
    for i = 1:4
        output(:,i) = sort(input(:,i)); 
    end
end

function [signalTypeCnt, requireTypeNum] = errCorrection(signalTypeCnt, requireTypeNum, i)
    col = sum(requireTypeNum(:,:,i));
    if ~isequal(col, 40 * ones(1,4))
        errPos = find(col ~= 40);
        errElemNum = size(errPos);
        errNum = 40 - col(errPos);
        for k = 40:-1:1
            if errElemNum(2) == 1
                if signalTypeCnt(k,errPos(1)) >= errNum(1) && requireTypeNum(k,errPos(1),i) - errNum(1) >= 0
                    requireTypeNum(k, errPos(1), i) = requireTypeNum(k, errPos(1), i) + errNum(1);
                    signalTypeCnt(k, errPos(1)) = signalTypeCnt(k, errPos(1)) + errNum(1);
                    break;
                end
            elseif errElemNum(2) == 2
                if signalTypeCnt(k,errPos(1)) >= errNum(1) && signalTypeCnt(k,errPos(2)) >= errNum(2) && ...
                    requireTypeNum(k,errPos(1),i) + errNum(1) >= 0 && requireTypeNum(k,errPos(2),i) + errNum(2) >= 0

                    requireTypeNum(k, errPos(1),i) = requireTypeNum(k, errPos(1),i) + errNum(1);
                    signalTypeCnt(k, errPos(1)) = signalTypeCnt(k, errPos(1)) - errNum(1);

                    requireTypeNum(k, errPos(2),i) = requireTypeNum(k, errPos(2),i) + errNum(2);
                    signalTypeCnt(k, errPos(2)) = signalTypeCnt(k, errPos(2)) - errNum(2);
                    break;
                end
            elseif errElemNum(2) == 3
                if signalTypeCnt(k,errPos(1)) >= errNum(1) && signalTypeCnt(k,errPos(2)) >= errNum(2) && ...
                    signalTypeCnt(k,errPos(3)) >= errNum(3) && requireTypeNum(k,errPos(1),i) + errNum(1) >= 0 && ...
                    requireTypeNum(k,errPos(2),i) + errNum(2) >= 0 && requireTypeNum(k,errPos(3),i) + errNum(3) >= 0

                    requireTypeNum(k, errPos(1),i) = requireTypeNum(k, errPos(1),i) + errNum(1);
                    signalTypeCnt(k, errPos(1)) = signalTypeCnt(k, errPos(1)) - errNum(1);

                    requireTypeNum(k, errPos(2),i) = requireTypeNum(k, errPos(2),i) + errNum(2);
                    signalTypeCnt(k, errPos(2)) = signalTypeCnt(k, errPos(2)) - errNum(2);

                    requireTypeNum(k, errPos(3),i) = requireTypeNum(k, errPos(3),i) + errNum(3);
                    signalTypeCnt(k, errPos(3)) = signalTypeCnt(k, errPos(3)) - errNum(3);
                    break;
                end
            elseif errElemNum(2) == 4
                if signalTypeCnt(k,errPos(1)) >= errNum(1) && signalTypeCnt(k,errPos(2)) >= errNum(2) && ...
                    signalTypeCnt(k,errPos(3)) >= errNum(3) && signalTypeCnt(k,errPos(4)) >= errNum(4) && ...
                    requireTypeNum(k,errPos(1),i) + errNum(1) >= 0 && requireTypeNum(k,errPos(2),i) + errNum(2) >= 0 && ...
                    requireTypeNum(k,errPos(3),i) + errNum(3) >= 0 && requireTypeNum(k,errPos(4),i) + errNum(4) >= 0

                    requireTypeNum(k, errPos(1),i) = requireTypeNum(k, errPos(1),i) + errNum(1);
                    signalTypeCnt(k, errPos(1)) = signalTypeCnt(k, errPos(1)) - errNum(1);

                    requireTypeNum(k, errPos(2),i) = requireTypeNum(k, errPos(2),i) + errNum(2);
                    signalTypeCnt(k, errPos(2)) = signalTypeCnt(k, errPos(2)) - errNum(2);

                    requireTypeNum(k, errPos(3),i) = requireTypeNum(k, errPos(3),i) + errNum(3);
                    signalTypeCnt(k, errPos(3)) = signalTypeCnt(k, errPos(3)) - errNum(3);

                    requireTypeNum(k, errPos(4),i) = requireTypeNum(k, errPos(4),i) + errNum(4);
                    signalTypeCnt(k, errPos(4)) = signalTypeCnt(k, errPos(4)) - errNum(4);

                    break;
                end
            end
        end
    end
end
