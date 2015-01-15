function [ img_bin ] = imgBinarization( img, thresh )
%IMGBINARIZATION Summary of this function goes here
%   Detailed explanation goes here

    if nargin == 1
        thresh = .6;
    end
    range = max(img(:)) - min(img(:));
    img = ( img-min(img(:)) ) / range;
    img_bin = (img < thresh);

end

