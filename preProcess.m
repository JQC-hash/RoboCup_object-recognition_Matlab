% Computer Vision and Image Analysis Assignment 1
% 27 April 2019
% Jia-Qi Chen, u3181913
% funtion: pre-process input rgb image

function img_processed = preProcess(img)

% Denoise with median filter
img(:,:,1) = medfilt2(img(:,:,1));
img(:,:,2) = medfilt2(img(:,:,2));
img(:,:,3) = medfilt2(img(:,:,3));

% Sharpening
img = imsharpen(img);

% Find the minimum and maximum pixel value. Divide by 255 to rescale in the range of 0 to 1.
minPixelValue = double(min(min(img)))/255.0;
maxPixelValue = double(max(max(img)))/255.0;

% Rescale the image
img_processed = imadjust(img, ...
                    [minPixelValue(1) minPixelValue(2) minPixelValue(3); ...
                     maxPixelValue(1) maxPixelValue(2) maxPixelValue(3)], ...
                 []);
end

