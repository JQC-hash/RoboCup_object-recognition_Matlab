% Computer Vision and Image Analysis Assignment 1
% 27 April 2019
% Jia-Qi Chen, u3181913
% Funtion: linearly segment out the field and return a one-cut field mask

function rect_cut = findField(imgHSV)
% focus on the hue value
imgHue = imgHSV(:,:,1);
% figure;
% subplot(1,2,1); imshow(imgHue);

imgBinaryGreenMask = (imgHue>=0.23)&(imgHue<=0.43);
% subplot(1,2,2); imshow(imgBinaryGreenMask); title('Hue Mask');

se = strel('disk',6,4);
imgBinaryGreenMask = imdilate(imerode(imgBinaryGreenMask,se),se);
imgBinaryGreenMask = imerode(imdilate(imgBinaryGreenMask,se),se);
% figure; imshow(imgBinaryGreenMask); title('After close and open operation');

imSize = size(imgBinaryGreenMask);
rect_cut = zeros(imSize);
for row = 1:imSize(1)
    if(sum(imgBinaryGreenMask(row,:)) > imSize(2)/3)
        for col = 1:imSize(2)
            rect_cut(row,col) = 1;
        end
    else
        for col = 1:imSize(2)
            rect_cut(row,col) = 0;
        end
    end
end

% use median filter to null out possible horrizontal goal frame
rect_cut = medfilt2(rect_cut,[50 50],'symmetric');    

% figure;
% subplot(1,2,1); imshow(imgBinaryGreenMask); title('imgBinaryGreenMask');
% subplot(1,2,2); imshow(copy); title('copy');

end
