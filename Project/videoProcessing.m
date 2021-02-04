% Computer Vision and Image Analysis Assignment 1
% 27 April 2019
% Jia-Qi Chen, u3181913
% Apply brute force search on the first frame. From the sencond frame on,
% call the findMovement function to predict the direction and range of
% movement, then do a limited search on the cropped regions

clear all;
close all;

% Lod video and get its matadata
v = VideoReader('Robocup2015_12s.mp4');
height = v.height;
width = v.width;
numberOfFrames = v.NumberOfFrame;

% currAxes = axes;
ballMotionX = 0;
ballMotionY = 0;
prevBallX = 0;
prevBallY = 0;
radius = 0;
 
for n = 1 : numberOfFrames	
    vidFrame = read(v,n);
    
    % Displate the frame
    imshow(vidFrame); axis on; hold on;
    
    % Preprocess to unify frames across the video
    frame = preProcess(vidFrame);
       
    % Apply brute force search on the first frame to start 
    % and every 13 frames to prevent drifting
    if (n == 1 || mod(n,13) == 0)
        % Counters for frames where ball is not found
        noBallCounter = 0;
        
        % Remodeling and redesignate the goal frame as a template to later do the SURF
        % matching
        [fieldLines, ball, goalRegion] = motionModel(frame);   
        patch1 = frame(goalRegion(:,1):goalRegion(:,2),goalRegion(:,3):goalRegion(:,4));
        
        % If no ball was found in the remodeling, let take the previsou
        % ball actual coordinates and radius as a makeshift
        if (ball(:,1) ~= 0 && ball(:,2) ~= 0 && ball(:,3) ~= 0)
            prevBallX = ball(:,1);
            prevBallY = ball(:,2);
            radius = ball(:,3);
        else           
            noBallCounter = noBallCounter+1;
        end

    % Implement SURF on the goal regions to find the camera motion between
    % 2 frames. With the camera motion know, the location of goal and field lines
    % can be quickly predicted.
    else
        patch2 = frame(goalRegion(:,1):goalRegion(:,2),goalRegion(:,3):goalRegion(:,4));
        [camMotionX, camMotionY] = camMotion(patch1,patch2);
        
        % Relocate the goal
        goalRegion(:,1) = goalRegion(1)+camMotionY; % upperBound
        goalRegion(:,2) = goalRegion(2)+camMotionY; % lowerBound
        goalRegion(:,3) = goalRegion(3)+camMotionX; % leftBound
        goalRegion(:,4) = goalRegion(4)+camMotionX; % rightBound
        
        plot([goalRegion(3), goalRegion(4)], [goalRegion(1),goalRegion(1)],'LineWidth',2,'color','blue'); % upper
        plot([goalRegion(3), goalRegion(3)], [goalRegion(1),goalRegion(2)],'LineWidth',2,'color','blue'); % left
        plot([goalRegion(4), goalRegion(4)], [goalRegion(1),goalRegion(2)],'LineWidth',2,'color','blue'); % right
        
        % Relocate the field lines
        for line = 1:length(fieldLines)
            xy = [fieldLines(line).point1;fieldLines(line).point2];
            xy(1,1) = xy(1,1) + camMotionX;
            xy(2,1) = xy(2,1) + camMotionX;
            xy(1,2) = xy(1,2) + camMotionY;
            xy(2,2) = xy(2,2) + camMotionY;
            % plot the lines
            plot(xy(:,1),xy(:,2),'LineWidth',2,'color','red');

            % plot the end points of lines
            plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
            plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','black');

        end
        
        %% Relocate the ball       
        
        % Only relocate when ball has been fonud in previous frames
        if (prevBallX~= 0 && prevBallY~= 0 && radius~= 0)
        % Predicted new location
        predictedBallX = max(prevBallX + camMotionX +ballMotionX, 1); 
        predictedBallY = max(prevBallY + camMotionY +ballMotionY, 1);

        % Create a small window to reduce effort on tracking the ball
        % noBallCounter: the longer the ball is not found, the larger the
        % window
        window = frame(max((predictedBallY-(2+noBallCounter/2)*radius),1):min((predictedBallY + (2+noBallCounter/2)*radius),height),...
                       max((predictedBallX -(2+noBallCounter/2)*radius),1):min((predictedBallX  + (2+noBallCounter/2)*radius),width),:);
        
        % Use h and s channels to sift out potential ball locations
        window_hsv = rgb2hsv(window);
        window_h_bw = ~im2bw(window_hsv(:,:,1),0.07); % low hughe
        window_s_bw = im2bw(window_hsv(:,:,2),0.6); % high saturation
        map = and(window_h_bw, window_s_bw);
        map_canny = edge(map,'canny');
        [center_map, new_radius, new_metric] = imfindcircles(map_canny,[radius-5 radius+5]);
        
        if (isempty(center_map))
            % If no circles are foudn
            viscircles([predictedBallX predictedBallY], radius+5,'EdgeColor','magenta','LineStyle','--');
            noBallCounter = noBallCounter + 1;
            prevBallX = predictedBallX;
            prevBallY = predictedBallY;
            
        else 
            % If circles are found in the small window
            % Calculate the actual coordinate on the frame.
            ballActualX = center_map(:,1) + max((predictedBallX - (2+noBallCounter/2)*radius),1);
            ballActualY = center_map(:,2) + max((predictedBallY - (2+noBallCounter/2)*radius),1);
            viscircles([ballActualX ballActualY], new_radius+5,'EdgeColor','b');
            
            % Update the ball motion
            ballMotionX = ballActualX - predictedBallX;
            ballMotionY = ballActualY - predictedBallY;
            % Update the ball location
            prevBallX = ballActualX;
            prevBallY = ballActualY;
            radius = round(new_radius);
        end
        end
        drawnow;
    end
    
    % Replace the template with current patch on goal
    patch1 = frame(goalRegion(:,1):goalRegion(:,2), goalRegion(:,3):goalRegion(:,4));
    hold off;

end

