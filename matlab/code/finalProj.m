% Coded by HW Lee 2014 Fall

clear all; close;

opt = 2;
symbolTest = 0;
project = 1;
skewTest = 2;

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

if opt == symbolTest
    
    % Features
    trebleFeats = get_features(treblePth, feature_params);
    bassFeats = get_features(bassPth, feature_params);

    % Training Set Construction
    X = [trebleFeats; bassFeats];
    y = [ones(size(trebleFeats, 1), 1); -ones(size(bassFeats, 1), 1)];

    % SVM
    [w b] = vl_svmtrain(X', y, 1e-5);
    n_hog_cells = feature_params.hog_cell_size;
    imhog = vl_hog('render', single(reshape(w, [n_hog_cells n_hog_cells 31])), 'verbose') ;
    figure(1); imagesc(imhog) ; colormap gray; set(1, 'Color', [.988, .988, .988])

    % Learning evaluation
    accuracy = sum( sign(X*w+b) == y ) / length(y);
    score = X*w+b;
    disp(accuracy);
    disp(score);

elseif opt == project
    
    im_original = vl_imreadgray(fullfile( singleScorePth, 'score004.jpg' ));
    im = im_original;
    range = max(im(:)) - min(im(:));
    im = ( im-min(im(:)) ) / range;
    im = (im < .75);
    xx = 1:size(im, 1);
    yy = sum(im, 2);
    imwrite(im_original, fullfile( singleScorePth, 'produce001_pre.jpg' ));
    im_original(yy > .5*max(yy), :) = 1;
    plot(yy, -xx);
    display(max(yy));
    imwrite(im_original, fullfile( singleScorePth, 'produce001_post.jpg' ));
    
elseif opt == skewTest
    
    dataID = '004';
    im_original = vl_imreadgray(fullfile( singleScorePth, ['score' dataID '.jpg'] ));
    im = im_original;
    im = imresize(im, .6);
    %im = imrotate(im, 5);
    tic;
    [imp info] = find_stafflines(im);
    toc;
    x = (1:size(im, 2))';
    slopes = zeros(length(info.centerLine), 1);
    
    
    if exist( fullfile( resultPath, ['produce' dataID] ), 'dir' ) == 0
        mkdir( fullfile( resultPath, ['produce' dataID] ) );
    end
    singleStaffs = cell(length(info.centerLine), 1);
    for ii = 1:length(info.centerLine)
        y = round([x ones(size(x))]*info.centerLine{ii});
        im = markImage(im, x, y, [0 255 0]);
        slopes(ii) = info.centerLine{ii}(1);
        
        imt = imageTruncate(im, [y(:)-1.5*( info.lineSpace(ii)*4+info.lineWidth(ii)*5 ), ...
            y(:)+1.5*( info.lineSpace(ii)*4+info.lineWidth(ii)*5 )], 'vertical');
        imt = imrotate(imt, atan(slopes(ii))*180/pi);
        imtSum = sum(imt, 3);
        imt(sum(imtSum==0, 2) > .8*size(imtSum, 2), :, :) = [];
        imt(:, sum(imtSum==0, 1) > .8*size(imtSum, 1), :) = [];
        singleStaffs{ii} = imt;
    end
    
    hybridImg = hybridImages(singleStaffs, 'vertical');
    
    imwrite(hybridImg, fullfile( resultPath, ['produce' dataID], ['produceStaff' dataID '_detection.jpg'] ));
    imwrite(im, fullfile( resultPath, ['produce' dataID '_detection.jpg'] ));
    
end