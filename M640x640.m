% THis file is used to simulation the 640x640 full switcher.
clear; clc;
% clf;

%% Switch system basical architecture .
% inoput and output array
inputLines = (1:640)'; % input io, from 1 to 640
% outputRequire = randi(640, 640, 1);
% outputRequire = [(1:160)';(1:160)';(1:160)';(1:160)'];
% outputRequire = (1:640)'; 
outputRequire = randperm(640)';
% outputRequire = (640:-1:1)'; 
% load('test.mat','outputRequire');

% Switch map array, row is map relationship, column is chip number.
% mapArrayLayer1: layer 1 switch chip map array, (mapLine(1-16), chip(1-40))
% mapArrayLayer2: layer 2 switch chip map array, (mapLine(1-160), chip(1-4))
% mapArrayLayer3: layer 3 switch chip map array, (mapLine(1-160), chip(1-4))
% mapArray640: system map array
global mapArrayLayer1 mapArrayLayer2 mapArrayLayer3;
mapArrayLayer1 = zeros(16, 40); % layer 1 relationship
mapArrayLayer2 = zeros(160, 4); % layer 2 relationship
mapArrayLayer3 = zeros(160, 4); % layer 3 relationship


%% Switch process.
outputLines = startSwitch(outputRequire);

%% Verification outputs.
mapRelationship(:,1) = inputLines;
mapRelationship(:,2) = outputRequire;
mapRelationship(:,3) = outputLines;
isMapSuccess(outputRequire, outputLines);
fprintf("   * <%04d> Updated! \n", randi(1e4));
