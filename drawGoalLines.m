% Computer Vision and Image Analysis Assignment 1
% 27 April 2019
% Jia-Qi Chen, u3181913
% funtion: draw the lines of hte goal
% Assumption: the goal is white color
% Idea: in grayscale, the goal frame has values>0.68

function goalRegion = drawGoalLines(img_grayscale,rect_cut)

img_size = size(img_grayscale);
guassY = img_size(2)/60;
guassX = guassY;

% inverse the fieldMask_outline to get the mask for outside field
inverseMask = ~rect_cut;
img_gray_bw = im2bw(img_grayscale,0.68);

% mask out the field
for row = 1:img_size(1)
    for col = 1:img_size(2)
        if inverseMask(row,col) == 0
            img_gray_bw(row,col) = 0;
        end
    end
end

% find out the rect_cut line
cutLine = sum(inverseMask(:,1));

% apply Guassian smooth on x and y axis respectively
img_gray_bw = im2double(img_gray_bw);
img_GuassX = imgaussfilt(img_gray_bw,[guassX 1]);
img_GuassY = imgaussfilt(img_gray_bw,[1 guassY]);

% non-linear increase contrast, increase the grayscale of the white color
% to nearly 1
img_GuassX = img_GuassX.^0.2;
img_GuassY = img_GuassY.^0.2;

% figure;
% subplot(1,2,1); imshow(img_GuassX); title('Guassian Smooth x');
% subplot(1,2,2); imshow(img_GuassY); title('Guassian Smooth y');

% turn into bw with high threshold
img_GuassX_bw = im2bw(img_GuassX,0.95);
img_GuassY_bw = im2bw(img_GuassY,0.95);

% edge detection before Hough transform
goal_vertical = edge(img_GuassX_bw,'canny');
goal_horizontal = edge(img_GuassY_bw,'canny');

% Hough transform on the horizontal Guassian-smoothed bw image
%   The horizontal bar of hte goal is rarely occluded and is usually continuous,
%   sopick only top 2 peaks and set high MinLength
[h,t,r] = hough(goal_horizontal);
peaks_h = houghpeaks(h,2,'threshold',0.3*max(h(:)));
lines_h = houghlines(goal_horizontal,t,r,peaks_h,'FillGap',60,'MinLength',60);
% figure;
%  subplot(1,2,2); imshow(img_GuassY_bw); title('Guassian Smooth y bw'); hold on;

% UpperBound will be where the top bar is
upperBound = 0;
% 2 ends of the bar, usually shorter than the acutual length
leftEnd = 0;
rightEnd = 0;
if (~isempty(lines_h)) 
for line = 1:length(lines_h)
    xy = [lines_h(line).point1;lines_h(line).point2];
    % plot(xy(:,1),xy(:,2),'LineWidth',2,'color','green');
    
    % Only consider low-slope lines
    if (abs((xy(1,2)-xy(2,2))/(xy(1,1)-xy(2,1))) <=1)
%     % Find the end points of lines
%     plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%     plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    
    % Determin the upper bound    
    %     Considering the features observed from training images, when new line is
    %     lower then the current upperBound, accept only when they are far
    %     enough. But when new line is higher than the current upperBound,
    %     accept only when they are close enough.
    higherPoint = min(xy(1,2), xy(2,2));
        if (upperBound == 0 ||... 
            (higherPoint>upperBound && higherPoint - upperBound > img_size(1)/5) ||... 
            (upperBound > higherPoint && upperBound-higherPoint < img_size(1)/7))
            
            % Accept and update the ends
            upperBound = higherPoint;
            leftEnd = min(xy(1,1),xy(2,1));
            rightEnd = max(xy(1,1),xy(2,1));
        end
    end    
end
% 
% % plot the 2 ends of the horizontal bar
% viscircles([leftEnd upperBound], 20,'EdgeColor','b');
% viscircles([rightEnd upperBound], 20,'EdgeColor','b');
end
    

% Hough transform on the vertical Guassian-smoothed bw image to determine the left and right bounds
%   Because there are occlusion and/or noises from robots, fence,etc, so pick
%   more hough peaks and set lower MinLength
[H,T,R] = hough(goal_vertical);
peaks_v = houghpeaks(H,6,'threshold',0.3*max(H(:)));
lines_v = houghlines(goal_vertical,T,R,peaks_v,'FillGap',20,'MinLength',20);

% subplot(1,2,1); imshow(img_GuassX_bw); title('Guassian Smooth x bw'); hold on;

%% Investigate the left and right bounds
% Initial values
leftBound = 1;
rightBound = img_size(2);

% If there was no horizontal lines and therefore neither leftEnd or
% rightEnd was found, assign a random value to start
if (leftEnd == 0 && rightEnd == 0)
    xy = [lines_v(1).point1;lines_v(1).point2];
    leftEnd = min(xy(1,1),xy(2,1));
    rightEnd = max(xy(1,1),xy(2,1));
end

% If the vertical lines fall in between the end and bound, move the bound
% to where the line is
    for line = 1:length(lines_v)
        xy = [lines_v(line).point1;lines_v(line).point2];


        % Only consider high-slope lines
        if (abs((xy(1,2)-xy(2,2))/(xy(1,1)-xy(2,1))) >5)
            
            mid = (xy(1,1)+xy(2,1))/2;
                if (mid>rightEnd && mid< rightBound )
                    rightBound = max(xy(1,1),xy(2,1));
                elseif (mid < leftEnd && mid > leftBound)
                    leftBound = min(xy(1,1),xy(2,1));
                end 
        end    
    end

% draw the rectangle to mark the location of goal
% figure; imshow(img_grayscale); hold on;
plot([leftBound, rightBound], [upperBound,upperBound],'LineWidth',2,'color','blue');
plot([leftBound, leftBound], [upperBound,cutLine],'LineWidth',2,'color','blue');
plot([rightBound, rightBound], [upperBound,cutLine],'LineWidth',2,'color','blue');
goalRegion = [upperBound, cutLine, leftBound, rightBound];

end