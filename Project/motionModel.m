% Computer Vision and Image Analysis Assignment 1
% 27 April 2019
% Jia-Qi Chen, u3181913
% Apply brute force search for the field lines, the ball and the goal on video frame. 

function [fieldLines, ball, goalRegion] = motionModel(img)

        img_grayscale = rgb2gray(img);
        img_hsv = rgb2hsv(img);

        % Use the saturation chanel and Hough transform to detect field lines
        img_s_bw = im2bw(img_hsv(:,:,2),0.3);
        
        % segment out the field
        fieldMask_outline = fieldSegmentation(img_hsv,img_s_bw);

        % test:one-line cut field segmentation (1s in field, 0s else)
        rect_cut = findField(img_hsv);

        % draw field lines based on the field mask
        fieldLines = drawFieldLines(img_s_bw,fieldMask_outline);

        % locate the ball
        ball = findBall(img(:,:,1), img_hsv,rect_cut);

        % draw lines of the goal
        % Base on the assumption that the goal is white, input img_grayscale. If
        % the goal is yellow, input img_hsv(:,:,2).
        goalRegion = drawGoalLines(img_grayscale,rect_cut);
end