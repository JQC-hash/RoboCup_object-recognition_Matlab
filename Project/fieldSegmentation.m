% Computer Vision and Image Analysis Assignment 1
% 27 April 2019
% Jia-Qi Chen, u3181913
% funtion: segment out the field and return a field mask

function fieldMask_outline_r =fieldSegmentation(imgHSV,img_s_bw)
% focus on the hue value
imgHue = imgHSV(:,:,1);
% figure;
% subplot(1,2,1); imshow(imgHue);

imgBinaryGreenMask = (imgHue>=0.23)&(imgHue<=0.43);
% subplot(1,2,2); imshow(imgBinaryGreenMask); title('Hue Mask');

% Apply erosion then dilation to remove the small wholes on the upper part
% of the image(ie, other brighter hue outside the targeted grass field)
se = strel('disk',6,4);

% close first then open
% close operation to remove small spots
imgEroded1_co = imerode(imgBinaryGreenMask,se);
imgDilated1_co = imdilate(imgEroded1_co,se);
% open operation to close small holes
imgDilated2_co = imdilate(imgDilated1_co,se);
imgEroded2_co = imerode(imgDilated2_co,se);

% open first then close
% open operation to close small holes
imgDilated1_oc = imdilate(imgBinaryGreenMask,se);
imgEroded1_oc = imerode(imgDilated1_oc,se);
% close operation to remove small spots
imgEroded2_oc = imerode(imgEroded1_oc,se);
imgDilated2_oc = imdilate(imgEroded2_oc,se);
% close operation on the img_s_bw
img_s_bw_c = imdilate(imerode(img_s_bw,se),se);
% % open operation on the img_s_bw
% img_s_bw_co = imerode(imdilate(img_s_bw_c,se),se);

% % compare the different open-close process result
% figure;
% subplot(1,2,1); imshow(imgEroded2_co); title('Mask close open');
% subplot(1,2,2); imshow(imgDilated2_oc); title('Mask open close');

fieldMask = and(and(imgEroded2_co,imgDilated2_oc),img_s_bw_c);
% figure; imshow(hueMask); title('Hue Mask');

% figure; imshow(finalMask); title('HueMask and finalMask');

% further procee the fieldMask to get the outline
se = strel('disk',30,4);
fieldMask_outline = imerode(imdilate(fieldMask,se),se);
fieldMask_outline = imdilate(imerode(fieldMask_outline,se),se);

img_size = size(fieldMask);
for row = 1:img_size(1)
    for col = 1:img_size(2)
        if fieldMask_outline(row,col) == 0
            fieldMask(row,col) = 0;
        end
    end
end

% figure;
% subplot(1,2,1); imshow(fieldMask_outline); title('fieldMask_outline');
% subplot(1,2,2); imshow(fieldMask); title('fieldMask');

% fieldMask_r = fieldMask;
fieldMask_outline_r = fieldMask_outline;

end
