% Coded by HW Lee 2014 Fall

clear all; close;

% Constants
dataPath = '../data';
resultPath = '../results';
testPath = fullfile(dataPath, 'test');
singleScorePth = fullfile(testPath, 'singleScore');
multiScoresPth = fullfile(testPath, 'multiScores');
trainSymbPath = fullfile(dataPath, 'trainSymb');
treblePth = fullfile(trainSymbPath, 'trebleClef');
bassPth = fullfile(trainSymbPath, 'bassClef');
feature_params = struct('template_size', 36, 'hog_cell_size', 6);

% Load input image
im_original = vl_imreadgray(fullfile( singleScorePth, 'score001.jpg' ));

% Detect skew degree
tic;
skewDeg = skewDetect(im_original);
toc;

% Rotate the image
if abs(skewDeg) > .2
    im_original = imrotate(im_original, skewDeg);
end

% Get Y projection
Yproj = yAxisProjection(im_original);
plot(Yproj, -(1:length(Yproj)));
im_original(Yproj < max(Yproj)-1, :) = 1;
imwrite(im_original, 'hehe.jpg');