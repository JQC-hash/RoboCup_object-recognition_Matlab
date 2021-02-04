% Computer Vision and Image Analysis Assignment 1
% 27 April 2019
% Jia-Qi Chen, u3181913
% funtion: detect features of 2 images and do likeobject recognition
% Tool: Speeded-Up Robust Features(SURF), which isa series built-in functions in Matlab Computer Vision System Toolbox.


function [camMotionX, camMotionY] = camMotion(img1,img2)

% img1 = rgb2gray(img1);
% img2 = rgb2gray(img2);
% find SURF features
points1 = detectSURFFeatures(img1);
points2 = detectSURFFeatures(img2);   

% extract neighborhood features
[features1,valid_points1] = extractFeatures(img1,points1);
[features2,valid_points2] = extractFeatures(img2,points2);

% match the features
indexPairs = matchFeatures(features1,features2);
% retrieve the locations of matched points.
matchedPoints1 = valid_points1(indexPairs(:,1));
matchedPoints2 = valid_points2(indexPairs(:,2));

% Find the camera motion between 2 images
diff_x = matchedPoints2.Location(:,1)-matchedPoints1.Location(:,1);
diff_y = matchedPoints2.Location(:,2)-matchedPoints1.Location(:,2);
camMotionX = round(double(median(diff_x)));

x = matchedPoints1.Location(1,1);
y = matchedPoints1.Location(1,2);
camMotionY = round(double(median(diff_y)));

% % display the matching points
% figure; showMatchedFeatures(img1,img2,matchedPoints1,matchedPoints2);
% legend('matched points 1','matched points 2');
end
