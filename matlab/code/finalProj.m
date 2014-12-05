% Coded by HW Lee 2014 Fall

clear all; close;

% Constants
dataPath = '../data';
resultPath = '../results';
testPath = fullfile(dataPath, 'test');
trainSymbPath = fullfile(dataPath, 'trainSymb');
treblePth = fullfile(trainSymbPath, 'trebleClef');
bassPth = fullfile(trainSymbPath, 'bassClef');
feature_params = struct('template_size', 36, 'hog_cell_size', 6);

% Features
trebleFeats = get_features(treblePth, feature_params);
bassFeats = get_features(bassPth, feature_params);

% Training Set Construction
X = [trebleFeats; bassFeats];
y = [ones(size(trebleFeats, 1), 1); -ones(size(bassFeats, 1), 1)];

% SVM
[w b] = vl_svmtrain(X', y, 1e-5);

% Learning evaluation
accuracy = sum( sign(X*w+b) == y ) / length(y);
score = X*w+b;
disp(accuracy);
disp(score);