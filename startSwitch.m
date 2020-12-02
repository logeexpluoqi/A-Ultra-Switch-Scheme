function output = startSwitch(outputRequire)
% This function is used to simulate the switch process.
% -output:
%   Layer 3 output signals, these signal is switched from input signals.
% -example:
%   outputLines = startSwitch;

    % layer structure: (in, out, chip), used to record switch chip current state.
    % The layer stucture is 3 dimention array, the first dimention is input signal line,
    % the second dimention is output line of this chip, the third dimention is switch 
    % chip number
    layer1 = zeros(16, 2, 40); % layer 1
    layer2 = zeros(160, 2, 4); % layer 2
    layer3 = zeros(160, 2, 4); % layer 3

    global mapArrayLayer1 mapArrayLayer2 mapArrayLayer3;

    inputLines = (1:640)'; % input io, from 1 to 640
    output = zeros(640,1)';
    % input signal connect to layer 1 and layer 1 switch

    %% Find layer2 require signals.
    output3 = zeros(160,4); % record layer3 to output order requires

    for i=1:4 
        output3(:,i) = outputRequire(i*160-159:i*160);
    end
    input3 = output3;

    input3 = sortSignals(input3); % ascending order, 4 group

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
    requireTypeNum = signalDistribution(signalTypeCnt);

    %% Find layer2 input require signals and output require.
    input2 = zeros(160,4);
    output2Require(160,4).signal = 0;
    output2Require(160,4).positon = 0;
    
    for i = 1:4 % layer2 chip input signals
        n = 0;
        for j = 1:4
            for k = 1:40
                while requireTypeNum(k,j,i) > 0 
                    n = n + 1;
                    input2(n,i) = groupSignals(k,j).signals(orgTypeCnt(k,j));
                    output2Require(n,i).signal = input2(n,i);
                    output2Require(n,i).positon = j;
                    orgTypeCnt(k,j) = orgTypeCnt(k,j) - 1;
                    requireTypeNum(k,j,i) = requireTypeNum(k,j,i) - 1;
                end
            end
        end
    end

    %% Debug, record input2 signal type number.
    input2TypeCnt = zeros(40,4);
    for i = 1:4
        for j = 1:160
            N = ceil(input2(j,i) / 16);
            input2TypeCnt(N,i) = input2TypeCnt(N,i) + 1;
        end
    end

    input2 = sortSignals(input2);

    %% Find layer2 output require signals.
    output2 = zeros(160, 4);
    for i = 1:4
        k1 = 1;
        k2 = 41;
        k3 = 81;
        k4 = 121;
        for j = 1:160
            pos = output2Require(j,i).positon;
            if pos == 1
                output2(k1,i) = output2Require(j,i).signal;
                k1 = k1 + 1;
            elseif pos == 2
                output2(k2,i) = output2Require(j,i).signal;
                k2 = k2 + 1;
            elseif pos == 3
                output2(k3,i) = output2Require(j,i).signal;
                k3 = k3 + 1;
            else
                output2(k4,i) = output2Require(j,i).signal;
                k4 = k4 + 1;
            end
        end
    end


    %%  Find layer1 map relationship. 
    for i = 1:40
        for j = 1:16
            p = ceil(j/4); % layer2 chip 
            n = mod(j,4); % layer2 input port
            if n == 0
                n = 4;
            end
            outline = input2(n + 4*(i-1), p);
            outline = mod(outline, 16);
            if outline == 0
                outline = 16;
            end
            setLayer1Map(i,j,outline);
        end
    end

    %% Set layer1 map relationship
    for i=1:40
        layer1(:,1,i) = inputLines((i*16-15):i*16); % input signals connect to layer 1 switch chips
        layer1(:,2,i) = switch16x16(layer1(:,1,i), mapArrayLayer1(:,i)); % layer 1 switch funtion
    end

    %% Layer 2 connect to layer 1
    for i=1:40
        for j=1:4
            layer2(i*4-3:i*4,1,j) = layer1(j*4-3:j*4,2,i);
        end 
    end

    %% Set layer2 map relationship
    for i = 1:4
        for j = 1:160
            for k = 1:160
                if output2(j,i) == input2(k,i)
                    setLayer2Map(i,j,k);
                end
            end
        end
    end

    %% Layer 2 switch function
    for i=1:4
        layer2(:,2,i) = switch160x160(layer2(:,1,i), mapArrayLayer2(:,i));
    end
    
    %% Layer 2 connect to layer 3
    for i=1:4
        for j=1:4
            layer3(i*40-39:i*40,1,j) = layer2(j*40-39:j*40,2,i);
        end
    end

    %% Set layer3 map relationship
    for i = 1:4
        for j = 1:160
            for k = 1:160
                if output3(j,i) == layer3(k,1,i)
                    setLayer3Map(i,j,k);
                end
            end
        end
    end

    %% Layer 3 switch function
    for i=1:4
        layer3(:,2,i) = switch160x160(layer3(:,1,i), mapArrayLayer3(:,i));
    end

    %% Layer 3 output integrated
    for i=1:4
        output(i*160-159:i*160) = layer3(:,2,i);
    end
    output = output';

%% Local function
    function output = sortSignals(input)
        output = zeros(160,4);
        for p1 = 1:4
            output(:,p1) = sort(input(:,p1)); 
        end
    end
end
