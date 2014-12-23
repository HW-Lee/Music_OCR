function [ degree ] = skewDetect( im )
%SKEWDETECT Summary of this function goes here
%   Detailed explanation goes here
    [im info] = find_stafflines(im);
    x = (1:size(im, 2))';
    if length(info.centerLine) < 2
        degree = 0;
        warning('Inaccurate detection.');
        return;
    end
    slopes = zeros(length(info.centerLine), 1);
    
    im = gray2rgb(im);
    for ii = 1:length(info.centerLine)
        y = round([x ones(size(x))]*info.centerLine{ii});
        y = min(y, size(im, 1));
        y = max(y, 1);
        yunique = unique(y);
        for jj = 1:length(yunique)
            im(yunique(jj), x(y==yunique(jj)), [1 3]) = 0;
            im(yunique(jj), x(y==yunique(jj)), 2) = 255;
        end
        slopes(ii) = info.centerLine{ii}(1);
    end
    
    degree = atan(mean(slopes))*180/pi;
    fprintf('Modification Rotation Degree: %f\n', degree);

end

