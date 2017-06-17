#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <iostream>
#include <math.h>
#include <vector>

using namespace cv;
using namespace std;

#define PI 3.14
#define max_frame 100

double * linspace(double min, double max);
double find_max(Mat input);
double find_min(Mat input);

int main( int argc, char** argv )
{ 
	Mat image, resizedImg;
    image = imread("D:\\tinyPlanet\\input\\pano3.png");   // Read the file

    if(! image.data )                              // Check for invalid input
    {
        cout <<  "Could not open or find the image" << std::endl ;
        return -1;
    }

    namedWindow( "input image", WINDOW_AUTOSIZE );// Create a window for display.
    imshow( "input image", image );                   // Show our image inside it.	
	waitKey(1);



	int inImgRows= image.rows;
	int resizedImgRows,resizedImgCols;
	resizedImgRows=200;
	resizedImgCols=ceil(double(2*resizedImgRows));  
	resize(image,resizedImg,Size(resizedImgCols,resizedImgRows),INTER_CUBIC);   // resizing image
	imshow( "resized image", resizedImg );
	waitKey(1);
	//cout<<"size "<<resizedImg.size()<<endl;
	
	Mat rowMat((2*resizedImg.rows-1),(2*resizedImg.rows-1),CV_32FC1);
	Mat colMat(2*resizedImg.rows-1,(2*resizedImg.rows-1),CV_32FC1);
	Mat result((2*resizedImg.rows-1),(2*resizedImg.rows-1),CV_8UC3);
	
	cv::VideoWriter output;
	
	output.open ("D:\\tinyPlanet\\outputVideo.avi", CV_FOURCC('X','V','I','D'), 10, cv::Size (result.rows,result.cols), 1 );  
	
	int valR,valC;
	double gama0=PI,phi0,c,p;
	double minRes1,minRes2,maxRes1,maxRes2,diff1,diff2;
	//double *phiVec;

	//phiVec=(double *) linspace(-PI/2,PI/2);

	//for (int ip=0 ; ip < (sizeof(*phiVec)/sizeof(phiVec[0])); ip++ )
	//{
	//	cout<<phiVec[ip]<<endl;
	//}

	//for (int ip=0 ; ip < (sizeof(phiVec)/sizeof(phiVec[0])); ip++ )


	for (double ip=-PI/2;ip<PI/2;ip+=0.03)
	{
		phi0=ip;					// set phi value
		//cout<<phi0<<endl;
		rowMat.setTo(0);			// set matrix value to zero,  rowMat martix gives the row number  
		colMat.setTo(0);			// colMat gives the column number
		result.setTo(0);			// final transformed image

				
		for(int i=0;i<2*resizedImgRows-1;i++)
		{
			for(int j=0;j<2*resizedImgRows-1;j++)
			{
				c=(2*sqrt(double((resizedImgRows-i-1)*(resizedImgRows-i-1)+(resizedImgRows-j-1)*(resizedImgRows-j-1)))/(1*resizedImgRows));
				p=sqrt(double((resizedImgRows-i-1)*(resizedImgRows-i-1)+(resizedImgRows-j-1)*(resizedImgRows-j-1)));


				rowMat.at<float>(i,j)=asin(cos(c)*sin(phi0)+((resizedImgRows-i-1)*sin(c)*cos(phi0)/p));
				colMat.at<float>(i,j)=atan2(((resizedImgRows-j-1)*sin(c)),(p*cos(phi0)*cos(c)-(resizedImgRows-i-1)*sin(phi0)*sin(c))); 


			}
		}


		rowMat.at<float>(resizedImgRows-1,resizedImgRows-1) = (rowMat.at<float>(resizedImgRows,resizedImgRows-1)
																+rowMat.at<float>(resizedImgRows-2,resizedImgRows-1)
																+rowMat.at<float>(resizedImgRows,resizedImgRows)
																+rowMat.at<float>(resizedImgRows-2,resizedImgRows))/4;
		colMat.at<float>(resizedImgRows,resizedImgRows) = (colMat.at<float>(resizedImgRows,resizedImgRows-1)
																+colMat.at<float>(resizedImgRows-2,resizedImgRows-1)
																+colMat.at<float>(resizedImgRows,resizedImgRows)
																+colMat.at<float>(resizedImgRows-2,resizedImgRows))/4;
    

				
		minRes1=find_min(rowMat);
		minRes2=find_min(colMat);
		maxRes1=find_max(rowMat);
		maxRes2=find_max(colMat);


		
   
		diff1 = abs(maxRes1-minRes1);
		diff2 = abs(maxRes2-minRes2);

		for(int i=0;i<2*resizedImgRows-1;i++)
		{
			for(int j=0;j<2*resizedImgRows-1;j++)
			{
				rowMat.at<float>(i,j)=floor(double(((rowMat.at<float>(i,j)-minRes1)*(resizedImgRows-1))/diff1));
				colMat.at<float>(i,j)=floor(double((colMat.at<float>(i,j)-minRes2)*(2*resizedImgRows-1)/(diff2)));
				result.at<Vec3b>(i,j)=resizedImg.at<Vec3b>(rowMat.at<float>(i,j),colMat.at<float>(i,j));
				
			}
		}

/*
		for(int i=0;i<2*resizedImgRows-1;i++)
		{
			for(int j=0;j<2*resizedImgRows-1;j++)
			{
				result.at<Vec3b>(i,j)=resizedImg.at<Vec3b>(rowMat.at<float>(i,j),colMat.at<float>(i,j));
			}
		}
		*/
		//imshow("result",result3);
		//waitKey(1);
		output.write (result);

	}

	
	return 0;
}


   

double * linspace(double min, double max)
{
 double result[max_frame], temp=0.0;
 // vector iterator
 int iterator = 0;
 
for (int i = 0; i <= max_frame-2; i++)
 {
 temp = min + i*(max-min)/(max_frame - 1);
 result[iterator] =temp;
 //result.insert(result.begin() + temp);
 iterator += 1;
 }
 
//iterator += 1;
 
result[iterator]= max;
 return result;
}



double find_max(Mat input)
{
int i,j;
double max = input.at<float>(0,0);
 
for(i = 0; i < input.rows; i++)
	{
	for(j = 0; j < input.cols; j++)
		{
		if(input.at<float>(i,j) > max)
			{
			max = input.at<float>(i,j);
			}
		}
	}
	return max;
}


double find_min(Mat input)
{
int i,j;
double min = input.at<float>(0,0);
 
for(i = 0; i < input.rows; i++)
	{
	for(j = 0; j < input.cols; j++)
		{
		if(input.at<float>(i,j) < min)
			{
			min = input.at<float>(i,j);
			}
	}
}
return min;
}