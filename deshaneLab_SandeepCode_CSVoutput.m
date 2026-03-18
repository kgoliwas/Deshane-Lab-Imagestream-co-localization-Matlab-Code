% Created by Sandeep Bodduluri (sbodduluri@uabmc.edu) for Dr. Jessy Deshane
% Program to quantify flourescence
% 1. Input should be a imagestream strip of length (1875)
% 2. Place a circular ROI aligning with the cell boundary and double-click
% to proceed
% 3. Code saves the output text file with the numbers in following order
%    Selected Circular ROI center (X,Y)
%    Selected Circular ROI radius 
%    %Green pixels in the selected ROI
%    %Mean Intensity of Green Pixels
%    %Red pixels in the selected ROI
%    %Mean Intensity of Red Pixels
%    %Blue pixels in the selected ROI
%    %Mean Intensity of Blue Pixels
%    %Red-Green Overlap pixels in the selected ROI
%    In the CSV output, paste the first two rows if you plan to change the
%    output file name

clc;
clear;
close all;

[baseFileName,folder]=uigetfile('*.*','Specify an image file','on');
fullimageFileName=fullfile(folder,baseFileName);
img=imread(fullimageFileName);
block=375;

section1=img(:,1:block,:);
section2=img(:,block+1:block*2,:);
section3=img(:,(block*2)+1:block*3,:);
section4=img(:,(block*3)+1:block*4,:);

figure,imshow(section1,[]);
title('Trace the cell boundary and double-click');
ROI = images.roi.Circle(gca);
draw(ROI);
wait(ROI);
mask = createMask(ROI);
maskprop = regionprops(mask,'all');

%% uncomment below two lines only to reproduce previous readings - Specify Centroid and Radius value from previous reading's text file 
% figure,imshow(section1,[]);
% h = images.roi.Circle(gca,'Center',maskprop.Centroid,'Radius',maskprop.MinorAxisLength/2);

overlayimg = imoverlay(mat2gray(section1),bwperim(logical(mask)),'red');
maskid = find(mask>0);


greenimage = section2(:,:,2);
seg2id=find(greenimage>15 & mask>0);
MeanGreenIntensity = nanmean(greenimage(seg2id));
pctGreen=(length(seg2id)/length(maskid))*100;

redimage = section3(:,:,1);
seg3id=find(redimage>15 & mask>0);
MeanRedIntensity = nanmean(redimage(seg3id));
pctRed=(length(seg3id)/length(maskid))*100;

blueimage = section4(:,:,3);
seg4id=find(blueimage>15 & mask>0);
MeanBlueIntensity = nanmean(blueimage(seg4id));
pctBlue=(length(seg4id)/length(maskid))*100;

commonPixels=intersect(seg3id,seg4id);
pctOverlap=(length(commonPixels)/length(maskid))*100;

figure,
subplot(221)
imshow(overlayimg,[]);
title('Selected Cell Region (in Red)');

subplot(222)
imshow(section2,[]);
title2 = sprintf('Green (in selected ROI) Percent = %2.4f',pctGreen);
title(title2);

subplot(223)
imshow(section3,[]);
title3 = sprintf('Red (in selected ROI) Percent = %2.4f',pctRed);
title(title3);

subplot(224)
imshow(section4,[]);
title4 = sprintf('Blue (in selected ROI) Percent = %2.4f',pctBlue);
title(title4);

fprintf('Green (in selected ROI) Percent = %2.4f\n',pctGreen); 
fprintf('Red (in selected ROI) Percent = %2.4f\n',pctRed); 
fprintf('Blue (in selected ROI) Percent = %2.4f\n',pctBlue); 
fprintf('Red-Green Overlap (in selected ROI) Percent = %2.4f\n',pctOverlap); 

out = [maskprop.Centroid maskprop.MinorAxisLength/2 ...
       pctGreen MeanGreenIntensity ...
       pctRed MeanRedIntensity ...
       pctBlue MeanBlueIntensity ...
       pctOverlap];

%% Saving to CSV file

outfilename = 'RESULTS_AUG27_2020.csv';
cT = readtable(outfilename);
fT  = cell2table(cell(0,12), ...
                'VariableNames', {'ImageName','CircleCentroidX', ...
                                'CircleCentroidY','CircleRadius', ...
                                'GreenPct','AvgGreenIntensity', ...
                                'RedPct','AvgRedIntensity', ...
                                'BluePct','AvgBlueIntensity', ...
                                'Red_Green_overlap_Pct','MeasuredDate'});
                            
todayDate = datestr(now,'mm/dd/yyyy');  
                            
fT.ImageName{1} = baseFileName(1:end-4);
fT.CircleCentroidX(1) = maskprop.Centroid(1);
fT.CircleCentroidY(1) = maskprop.Centroid(2);
fT.CircleRadius(1) = maskprop.MinorAxisLength/2;
fT.GreenPct(1) = pctGreen;
fT.AvgGreenIntensity(1) = MeanGreenIntensity;
fT.RedPct(1) = pctRed;
fT.AvgRedIntensity(1) = MeanRedIntensity;
fT.BluePct(1) = pctBlue;
fT.AvgBlueIntensity(1) = MeanBlueIntensity;
fT.Red_Green_overlap_Pct(1) = pctOverlap;
fT.MeasuredDate = todayDate;


fT = [cT;fT];

writetable(fT,outfilename);

