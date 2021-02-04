% Computer Vision and Image Analysis Assignment 1
% 27 April 2019
% Jia-Qi Chen, u3181913
% Funtion: find field lines by apply color masks and Hough transform

function lines = drawFieldLines (img_s_bw,fieldMask_outline)

% apply the field mask to rid noises
img_size = size(fieldMask_outline);
for row = 1:img_size(1)
    for col = 1:img_size(2)
        if fieldMask_outline(row,col) == 0
            img_s_bw(row,col) = 1;
        end
    end
end

% implement Canny edge detection to detect edges
field_canny = edge(img_s_bw,'canny');

% apply hough transform
[H,T,R] = hough(field_canny);
% figure;
% subplot(1,3,1); imshow(field_canny);
% subplot(1,3,2); imshow(imadjust(mat2gray(H)),'XData',T,'YData',R,'InitialMagnification','fit');
% xlabel('\theta'), ylabel('\rho'); 
% axis on, axis normal, hold on;
% colormap(hot);

% find hough peaks
peaks = houghpeaks(H,6,'threshold',0.3*max(H(:)));

% draw hough lines
lines = houghlines(field_canny,T,R,peaks,'FillGap',40,'MinLength',70);

for line = 1:length(lines)
    xy = [lines(line).point1;lines(line).point2];
    plot(xy(:,1),xy(:,2),'LineWidth',2,'color','red');
    
    % plot the end points of lines
    plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
    plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','black');
    
end


% % Tried to draw the circular curve on the field
% Rmin = 50;
% Rmax = 200;
% % find circle
% [centers, radii, metric] = imfindcircles(field_canny,[Rmin Rmax]);
% viscircles(centers, radii,'EdgeColor','b');
end

