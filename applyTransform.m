% APPLYTRANSFORM converts flat panoramic image to tiny planet or tunnel like image.
% result = applyTransform(inImg,operation)
% inImg is a input image
% choice is a user specified operation
% 
function [result] = applyTransform(inImg,choice)

[inImgRows,inImgCols,inImgChnls]=size(inImg);               % calculate image size

resizedImgRows=inImgRows;
resizedImgCols=ceil(2*pi*resizedImgRows);
resizedImg=imresize(inImg,[resizedImgRows,resizedImgCols]);% resize input Image

resizedImg=double(resizedImg);

result=zeros(2*resizedImgRows-1,2*resizedImgRows-1,3);                        % create blank resultant Image

for i=1:2*resizedImgRows-1
    for j=1:2*resizedImgRows-1
        if(sqrt((resizedImgRows-i)^2+(resizedImgRows-j)^2)>=resizedImgRows)   % check condition for the background
            result(i,j,:)= [90,140,240];                                      % fill the back ground colour, for black background make it [0,0,0]            
        else
            switch choice
                case 'tiny'
                    valR=resizedImgRows-round(sqrt((resizedImgRows-i)^2+(resizedImgRows-j)^2))+1;
                case 'tunnel'
                    valR=round(sqrt((resizedImgRows-i)^2+(resizedImgRows-j)^2)); 
            end 
            vect1=[resizedImgRows,resizedImgRows]-[resizedImgRows,2*resizedImgRows];
            vect2=[resizedImgRows,resizedImgRows]-[i,j];
            angle=acos((vect1*vect2')/(norm(vect1)*norm(vect2)));             % find angle           
            if(i>=resizedImgRows)
                valC=round(resizedImgRows*(angle+pi));                        % calculate column position of corresponding pixel
            else
                valC=round(resizedImgRows*(-angle+pi));                      
            end           
            if (valC<=0)
                valC=1;
            end                        
            if ((i~=resizedImgRows) || (j~=resizedImgRows))
                result(i,j,:)=resizedImg(valR,valC,:);
            else
                result(i,j,:)=resizedImg(resizedImgRows,round(resizedImgCols/2),:);                
            end           
        end        
    end
end

result=uint8(result);
