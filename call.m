
%%
close all;
clear all;
clc;

inImg=imread('input/pano1.jpg');                                  % read input image

display('Enter Operation Name :');                              
display('Enter tiny to create tiny planet image');
display('Enter tunnel to create tunnel like image');
choice=input('ENTER : ');

if (~(strcmp(choice,'tiny') || strcmp(choice,'tunnel')))                %check for prefered operation
    display('Incorrect operation name')
    return
else
    result=applyTransform(inImg,choice);
end

imshow(inImg);
title('Input Image');
figure();
imshow(result);
title('Resultant Image');
imwrite(result,'result/ResPano.png');



