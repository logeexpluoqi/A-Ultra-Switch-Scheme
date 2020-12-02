function requireTypeNum = signalDistribution(signalTypeCnt)
    % The signalTypeCnt have 4 columns, remark as A_mxn, m is rows and
    % n is columns.The element remark as a_m,n. We need to extract some
    % signals from A_mxn, and we should extract 4 times, every time 
    % extract 160 signals. We should guarantee every time we extracted
    % signals from A_mxn satisfacation sum(a_m,n)|(m=1:40) = 40 and
    % sum(a_m,n)|(n=1:4) = 4.
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
                            if sumOfRequireCol(k) >= 4 && j == 1
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
            end
            [signalTypeCnt, requireTypeNum] = errCorrection(signalTypeCnt, requireTypeNum, i);
        else % the third time allocate signals
            % In this section, because of the divisor is 2, we should consider which
            % result should be carried and which result should be abdicate.
            rowOperationCnt = 0; % record row operation time
            colCnt = zeros(1,4);
            upOrDown = zeros(40, 4); % find this element carry or abdicate, 1: carry, 0: abdicate
            
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
                                % there is no odd elements under the maxElem, include the elements have the absolute value 
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
    end
    requireTypeNum(:,:,4) = signalTypeCnt;
    % The last column element is less than 0, like [1,2,2,-1]
    for k = 40:-1:1
        if requireTypeNum(k,4,4) < 0
            if sum(requireTypeNum(k,1:3,4)) > 4
                requireTypeNum(k,4,4) = requireTypeNum(k,4,4) + 1;
                if requireTypeNum(k,3,4) - 1 >= 0 
                    requireTypeNum(k,3,4) = requireTypeNum(k,3,4) - 1;
                end
            end
        end
    end
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

function [signalTypeCnt, requireTypeNum] = errCorrection(signalTypeCnt, requireTypeNum, i)
    col = sum(requireTypeNum(:,:,i));
    if ~isequal(col,40 * ones(1,4))
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
