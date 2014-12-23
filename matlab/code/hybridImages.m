function [ hybridImg ] = hybridImages( imgsData, opt )
%HYBRIDIMAGES Summary of this function goes here
%   Detailed explanation goes here
    switch lower(opt)
        case 'vertical'
            opt = 1;
        case 'horizontal'
            opt = 0;
    end
    
    if isempty(imgsData)
        warning('WTF! Are you testing my foolproof system?');
    end
    
    sizeList = zeros(length(imgsData), size(imgsData{1}, 3));
    for ii = 1:length(imgsData)
        sizeList(ii, 1:length(size(imgsData{ii}))) = size(imgsData{ii});
    end
    
    if opt
        hybridImg = zeros(sum(sizeList(:, 1)), round(mean(sizeList(:, 2))), size(imgsData{1}, 3));
        for ii = 1:length(imgsData)
            hybridImg(sum(sizeList(1:ii-1, 1))+1:sum(sizeList(1:ii, 1)), :, :) = ... 
                imresize(imgsData{ii}, [sizeList(ii, 1) size(hybridImg, 2)]);
        end
    else
        hybridImg = zeros(round(mean(sizeList(:, 1))), sum(sizeList(:, 2)), size(imgsData{1}, 3));
        for ii = 1:length(imgsData)
            hybridImg(:, sum(sizeList(1:ii-1, 2))+1:sum(sizeList(1:ii, 2)), :) = ...
                imresize(imgsData{ii}, [size(hybridImg, 1) sizeList(ii, 2)]);
        end
    end

end

