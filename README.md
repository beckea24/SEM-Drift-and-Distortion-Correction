# ALDIC-Based-Drift-and-Distortion-Correction

## Introduction
ALDIC-Based Drift and Distortion Correction uses AL-DIC [https://www.mathworks.com/matlabcentral/fileexchange/70499-augmented-lagrangian-digital-image-correlation-and-tracking] to compute the displacement. Additionally, I use a modified main script for the distortion correction.

Both of these scripts are based off of the following paper: 
[https://www.researchgate.net/publication/281852637_Correction_of_image_drift_and_distortion_in_a_scanning_electron_microscopy]


## Drift

The drift correction script (drift_correction.m) must be run after the DIC is run for the two images. The chosen images and DIC results must be edited within the script in lines 19 through 24.
  img_0 = imread("{first_img_taken.tif}");
  base_img = imread("{scnd_img_taken.tif}");
  ...
  results_filename = 'results_{scnd_img_taken_name}_ws{width}_st{step}.mat';

The script then takes the displacement mesh and interpolates the data for the area of the image outside the ROI, as well as the pixels in between the subset steps.

Input the time between image 1 and image 2, as well as the cycle time (dependent on the scan speed and number of iterations).

The script will calculate the real pixel positions and ensure the pixels are within the image, then substitutes the real pixels into the image.


