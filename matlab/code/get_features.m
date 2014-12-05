% Starter code prepared by James Hays
% This function should return all positive training examples (faces) from
% 36x36 images in 'train_path_pos'. Each face should be converted into a
% HoG template according to 'feature_params'. For improved performance, try
% mirroring or warping the positive training examples.

function features_pos = get_features(train_path, feature_params)
% 'train_path_pos' is a string. This directory contains 36x36 images of
%   faces
% 'feature_params' is a struct, with fields
%   feature_params.template_size (probably 36), the number of pixels
%      spanned by each train / test template and
%   feature_params.hog_cell_size (default 6), the number of pixels in each
%      HoG cell. template size should be evenly divisible by hog_cell_size.
%      Smaller HoG cell sizes tend to work better, but they make things
%      slower because the feature dimensionality increases and more
%      importantly the step size of the classifier decreases at test time.


% 'features_pos' is N by D matrix where N is the number of faces and D
% is the template dimensionality, which would be
%   (feature_params.template_size / feature_params.hog_cell_size)^2 * 31
% if you're using the default vl_hog parameters

% Useful functions:
% vl_hog, HOG = VL_HOG(IM, CELLSIZE)
%  http://www.vlfeat.org/matlab/vl_hog.html  (API)
%  http://www.vlfeat.org/overview/hog.html   (Tutorial)
% rgb2gray

    image_files = dir( fullfile( train_path, 'clef*') ); %Caltech Faces stored as .jpg
    num_images = length(image_files);
    features_pos = zeros(num_images, (feature_params.template_size / feature_params.hog_cell_size)^2 * 31 );
    
    for ii = 1:num_images
        if mod(ii, round(.1*num_images)) == 0
            fprintf('Extract %d images features...\n', ii);
        end
        im = vl_imreadgray( fullfile( train_path, image_files(ii).name ) );
        if sum(size(im) ~= feature_params.template_size) > 0
            im = imresize(im, feature_params.template_size*[1 1]);
        end
        feats = vl_hog(single(im), feature_params.hog_cell_size);
        features_pos(ii, :) = feats(:)';
    end

end
