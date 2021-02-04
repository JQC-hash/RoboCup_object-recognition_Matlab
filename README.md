# RoboCup_object-recognition_Matlab

RoboCup is an annual international robotics competition proposed and founded in 1996 by a group of university professors. The aim of the competition is to promote robotics and AI research by offering a publicly appealing but formidable challenge. https://www.robocup.org/

This program was created using Matlab Computer Vision System Toolbox. The aim is to recognize the goal lines, the court boundaries and the soccer ball in 2015 RoboCup settings, with the precondition that the goal is white, and ball is bright red(low hue, high saturation). If the goal and ball is of other color, the source and threshold values need to be adjusted to generate suitable binary images as inputs for functions.

The program utilizes Canny edge detection, Speeded up robust features recognition(SURF), normalized cross correlation (NCC) method and Guassian smoothing techniqu to recognize relevant objects. The objects recognized by the program will be highlighted out. The returning data can be fed to the firmwares that prompt the robots to move accordingly.

Execute the imageProcessing.m and input a name of an image file including the file extension to operate on a image. Likewise, execute the videoProcessing.m to operate on a video.
