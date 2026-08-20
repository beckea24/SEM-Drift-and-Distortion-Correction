# ALDIC-Based-Drift-and-Distortion-Correction

## Introduction
ALDIC-Based Drift and Distortion Correction uses[AL-DIC](https://www.mathworks.com/matlabcentral/fileexchange/70499-augmented-lagrangian-digital-image-correlation-and-tracking) to compute the displacement. Additionally, I use a modified main ALDIC script for the distortion correction.

Both of these scripts are based off of the following paper: [Correction of image drift and distortion](https://www.researchgate.net/publication/281852637_Correction_of_image_drift_and_distortion_in_a_scanning_electron_microscopy)


## Drift

The drift correction script (drift_correction.m) must be run after the DIC is run for the two images. The chosen images and DIC results must be edited within the script in lines 19 through 24. Image 0 is the first image taken, and the base_img is the image that the DIC is named after/second image taken.
  
  >img_0 = imread("{first_img_taken.tif}");
>
  >base_img = imread("{scnd_img_taken.tif}");
>
  >...
>
  >results_filename = 'results_{scnd_img_taken_name}_ws{width}_st{step}.mat';

The script then takes the displacement mesh and interpolates the data for the area of the image outside the ROI, as well as the pixels in between the subset steps.

Input the time between image 0 and base_img, as well as the cycle time (dependent on the scan speed and number of iterations).

The script will calculate the real pixel positions and ensure the pixels are within the image, then substitutes the real pixels into the image.

## Distortion

The distortion correction script (distortion_correction.m) has the ALDIC run implemented within the script. The chosen images must be edited within the script in lines 7 through 10. 'im0' is equivalent to 'img_0' in the drift correction script, and 'im1' is equivalent to 'base_img'.
  
  >im0_name = 'distortion_04.tif';
>
  >im1_name = 'distortion_05.tif';
>
  >img_0 = imread("distortion_04.tif");
>
  >img_1 = imread('distortion_05.tif');
>

The user then needs to select the ROI region. Image 0 will be displayed, and the user should click the lower left corner of the region shared between the two images. Image 1 will be displayed after, and the user should click the upper left corner of the region shared between the two images. 

Then the user will be asked to input the subset size and step for the DIC run. See the [ALDIC Section](#aldic) for more information on subset size and step. The modified ALDIC main script 'ALDIC_dist.m' will automatically run. Follow the ALDIC section instructions.

The results will be loaded automatically and the distortion parameters will be calculated. Carefully check lines 84 through 120, as these polynomials may contain the typos from the paper. Both versions are currently within the script, with the uncommented having the multiple of twos, and not 3s. 

The corrections are then applied, and the remainder of the image is interpolated. Images are saved as "corrected_(img_num_name).tif".

## ALDIC

Further information on ALDIC is available at the [ALDIC code manual](https://www.researchgate.net/publication/344796296_Augmented_Lagrangian_Digital_Image_Correlation_AL-DIC_Code_Manual/link/60c9a083a6fdcc0c5c8690c3/download?_tp=eyJjb250ZXh0Ijp7ImZpcnN0UGFnZSI6InB1YmxpY2F0aW9uIiwicGFnZSI6InB1YmxpY2F0aW9uIn19)

### ALDIC Recommendations

_Subset Width_: Recommended range 20-50. 

_Subset Step_: Recommended to be 1/4 to 1 times the subset_width. I use about 1/3 or 1/2. 

My most used width/step is 30/10.

_Method to slove ALDIC global step_: Use option 1: Finite difference

_Parallel Pools_: For our purposes, running more than 1 CPU is not necessary. Just input 1.

