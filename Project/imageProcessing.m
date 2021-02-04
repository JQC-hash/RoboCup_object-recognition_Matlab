% Computer Vision and Image Analysis Assignment 1
% 27 April 2019
% Jia-Qi Chen, u3181913
% This program displays the text in prompt first and waits for the user to
% input a image file name
% Assumptoin: the goal is white and the ball is bright red

clear all;
close all;

prompt = 'Please input a image file name: \n';
fileName = input(prompt,'s');

% load image
img = imread(fileName);

% Pre-process the input image
img_rgb = preProcess(img);
% Convert to grayscale and hsv space for later use
img_grayscale = rgb2gray(img_rgb);
img_hsv = rgb2hsv(img_rgb);

% figure#1 for observation and analysis
% figure; 
% subplot(2,3,1); imshow(img_rgb); title('Oringinal Image');
% subplot(2,3,2); imshow(img_grayscale); title('Grayscale Image');
% subplot(2,3,4); imshow(img_hsv(:,:,1)); title('Image in hsv-hue chanel'); 
% subplot(2,3,5); imshow(img_hsv(:,:,2)); title('Image in hsv-saturation chanel');
% subplot(2,3,6); imshow(img_hsv(:,:,3)); title('Image in hsv-value chanel');
% subplot(2,3,3); imshow(im2bw(img_hsv(:,:,2),0.33)); title('bw_s');

% Use the saturation chanel and Hough transform to detect field lines
img_s_bw = im2bw(img_hsv(:,:,2),0.3);

% segment out the field
fieldMask_outline = fieldSegmentation(img_hsv,img_s_bw);
% figure; imshow(fieldMask_outline); title('field segmentation');

% test:one-line cut field segmentation (1s in field, 0s else)
rect_cut = findField(img_hsv);

% display the image 
figure;
imshow(img_rgb); hold on;

% draw field lines based on the field mask
fieldLines = drawFieldLines(img_s_bw,fieldMask_outline);

% locate the ball
ball = findBall(img_rgb(:,:,1), img_hsv,rect_cut);

% draw lines of the goal
% Base on the assumption that the goal is white, input img_grayscale. If
% the goal is yellow, replace grayscale with img_hsv(:,:,2).
goalRegion = drawGoalLines(img_grayscale,rect_cut);

