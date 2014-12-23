function [ rgbImage ] = gray2rgb( grayImage )
%GRAY2RGB Summary of this function goes here
%   Detailed explanation goes here
    rgbImage = cat(3,grayImage,grayImage,grayImage);
    
end