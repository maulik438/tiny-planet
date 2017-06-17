% APPLYTRANSFORM converts flat panoramic image to tiny planet or tunnel like image.
% result = applyTransform(inImg,operation)
% inImg is a input image
% choice is a user specified operation
%
% function [result] = applyTrans(inImg,choice)



close all;
clear all;
clc;


inImg=imread('input/pano.jpg');

[inImgRows,inImgCols,inImgChnls]=size(inImg);               % calculate image size

resizedImgRows=inImgRows;
resizedImgCols=ceil(2*resizedImgRows);
resizedImg=imresize(inImg,[resizedImgRows,resizedImgCols]);% resize input Image

resizedImg=double(resizedImg);

outputVideo = VideoWriter('video_out.avi');
outputVideo.FrameRate = 1;
open(outputVideo)

center=[resizedImgRows,resizedImgRows];
count=1;

gama0=pi;
% phi0=-pi/2;
for phi0 = -pi/2:0.05:pi/2
    
    
    phi0
    
    result1=zeros(2*resizedImgRows-1,2*resizedImgRows-1);                        % create blank resultant Image
    result2=zeros(2*resizedImgRows-1,2*resizedImgRows-1);
    
    result3=zeros(2*resizedImgRows-1,2*resizedImgRows-1,3);
    
    for i=1:2*resizedImgRows-1
        for j=1:2*resizedImgRows-1
            
            
            c=(sqrt((center(1)-i)^2+(center(2)-j)^2))/(2*resizedImgRows);
            p=sqrt((center(1)-i)^2+(resizedImgRows-j)^2);
            result1(i,j)=asin(cos(c)*sin(phi0)+((center(1)-i)*sin(c)*cos(phi0)/resizedImgRows));
            result2(i,j)=gama0+atan((center(2)-j)*sin(c)/(resizedImgRows*cos(phi0)*cos(c)-(center(1)-i)*sin(phi0)*sin(c)));
            
            
%             if(i>=resizedImgRows)
%                 result1(i,j)=result1(i,j)+pi;                        % calculate column position of corresponding pixel
%             else
%                 result1(i,j)=-result1(i,j)+pi;
%             end
            
        end
    end
    result1(isnan(result1))=1;
    result2(isnan(result2))=1;
    result1(100,100)=(result1(101,100)+result1(99,100)+result1(100,101)+result1(100,99))/4;
    result2(100,100)=(result2(101,100)+result2(99,100)+result2(100,101)+result2(100,99))/4;
    %
    %     result2(result2>=2*resizedImgRows)=2*resizedImgRows-1;
    %     result1(result1>=2*resizedImgRows)=2*resizedImgRows-1;
    minRes1 = min(min(result1));
    minRes2 = min(min(result2));
    maxRes1 = max(max(result1));
    maxRes2 = max(max(result2));
    diff1 = abs(maxRes1-minRes1);
    diff2 = abs(maxRes2-minRes2);
    
    result1=real(floor(((result1-minRes1)*(resizedImgRows-1))/diff1));
    result2=real(floor((result2-minRes2)*(2*resizedImgRows-1)/(diff2)));
    
    % result1(result1>resizedImgRows)=resizedImgRows;
    % result2(result2>2*resizedImgRows)=2*resizedImgRows;
    
    % result1(result1<1)=1;
    % result2(result2<1)=1;
    
    for i=1:2*resizedImgRows-1
        for j=1:2*resizedImgRows-1
            result3(i,j,:)=resizedImg(result1(i,j)+1,result2(i,j)+1,:);
            % result3(i,j,:)=resizedImg(ceil((result1(i,j))*(100/diff1)),ceil((result2(i,j)+pi)*(200/(2*pi))),:);
            % % result3(i,j,:)=resizedImg(ceil((result1(i,j)+pi/2)*(100/pi)),ceil((result2(i,j)+pi)*(200/(2*pi))),:);
        end
    end
    
    % figure();
    % subplot(2,1,1);
    % surf(result1);
    % subplot(2,1,2);
    % surf(result2);
    
    
    figure();
    result3=uint8(result3);
    
    imshow(result3);
    
    writeVideo(outputVideo,result3)
    %  w = waitforbuttonpress;
    
    % imwrite(result3,);
    % center=center- [resizedImgRows/2,resizedImgRows/2]/30;
    
end

close(outputVideo);


display('done...');


