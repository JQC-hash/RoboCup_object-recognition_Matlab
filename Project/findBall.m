% Computer Vision and Image Analysis Assignment 1
% 4 April 2019
% Jia-Qi Chen, u3181913
% funtion: find the ball

function ball = findBall(img_r, img_hsv,fieldMask_outline)

% Modify the fieldMask outline to include lines and ball
se = strel('disk',40,4);
fieldMask_outline_c = imerode(imdilate(fieldMask_outline,se),se);
fieldMask_outline_co = imdilate(imerode(fieldMask_outline_c,se),se);

% Use img hue and saturation chanel to find out red(low h but high s)
% region
low_hue = ~im2bw(img_hsv(:,:,1),0.07); %low hue region
high_s = im2bw(img_hsv(:,:,2),0.6);   %high s region
potentialBall = and(low_hue,high_s);
% figure;
% subplot(1,3,1); imshow(low_hue); title('low hue');
% subplot(1,3,2); imshow(high_s); title('high s');
% subplot(1,3,3); imshow(potentialBall); title('potential ball');

% open operation to fill small holes
se = strel('disk',6,4);
potentialBall = imerode(imdilate(potentialBall,se),se);

ballInField = potentialBall;

% then apply the field mask to rid noises
img_size = size(fieldMask_outline);
for row = 1:img_size(1)
    for col = 1:img_size(2)
        if fieldMask_outline_co(row,col) == 0
            ballInField(row,col) = 0;
        end
    end
end

% figure;
% subplot(1,2,1); imshow(potentialBall); title('candidates');
% subplot(1,2,2); imshow(ballInField); title('ballInField');
ballInField_canny = edge(ballInField,'canny');
% figure; imshow(ballInField_canny);

% circle parameters
Rmin = 10;
Rmax = 60;
% find circle
[centers, radii, metric] = imfindcircles(ballInField_canny,[Rmin Rmax]);

centers = uint16(centers);
numCircles = size(centers);

ball = [0,0,0];

for number = 1:numCircles(1)
    % draw circles only when the red channel value and saturation value is high enough
    if (img_r(centers(number,2), centers(number,1)) >= 130 && high_s(centers(number,2), centers(number,1)) == 1)
        viscircles([centers(number,1) centers(number,2)], radii(number),'EdgeColor','b');
        ball = [centers(number,1), centers(number,2), round(radii(number))];
    end
end
end


            


