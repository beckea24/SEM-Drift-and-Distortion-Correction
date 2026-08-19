%%%Drift Correction using ALDIC and P. Jin and X. Li Methodology%%%

%%%
% Equations from text
% X_real,K(i,j) = x(j) - u_12(tK(i,j) - TK) - U_1K(i,j)
% Y_real,K(i,j) = y(i) - u_12(tK(i,j) - TK) - V_1K(i,j)
% 
% tK(i, j ) = TK + (ni + j )dt, (1)
% TK = image time where T1 = 0
% m = number of columns
% (i, j) = pixel coordinates (0,0) is top left corner
% dt = pixel dwell time
% 
% u_12 = sum_DIC(U_12(x,y))/[(T2-T1)N]
% v_12 = sum_DIC(V_12(x,y))/[(T2-T1)N]
%%%

%-----Import correcting image and extract line and column information
img_0 = imread("lineint_ss3_num10_0.tif");
base_img = imread('lineint_ss3_num10_1.tif');
img_width = size(base_img, 2);
img_height = size(base_img, 1);
%-----Import DIC data from AL DIC output
results_filename = 'results_lineint_ss3_num10_1_ws50_st20.mat';
load(results_filename);
U_full = ResultDisp{1}.U;

%-----Parse for X Y displacement
disp_x_col = U_full(1:2:end); % Grabs odds: 1, 3, 5... (X-displacements)
disp_y_col = U_full(2:2:end); % Grabs evens: 2, 4, 6... (Y-displacements)

m = DICmesh.M;
n = DICmesh.N; 

U_12 = reshape(disp_x_col, m, n);
V_12 = reshape(disp_y_col, m, n);

%-----I J displacement equivalent
disp_i = U_12;
disp_j = V_12;

disp(size(disp_i));

%-----Interpolate Displacement Data
x_min = min(DICmesh.x0(:));
x_max = max(DICmesh.x0(:));
y_min = min(DICmesh.y0(:));
y_max = max(DICmesh.y0(:));

x_fine_vec = x_min : 1 : x_max;
y_fine_vec = y_min : 1 : y_max;


[X_fine, Y_fine] = meshgrid(x_fine_vec, y_fine_vec);

I_itp = interp2(DICmesh.x0', DICmesh.y0', disp_i', X_fine, Y_fine, "cubic");
J_itp = interp2(DICmesh.x0', DICmesh.y0', disp_j', X_fine, Y_fine, "cubic");

% figure;
% pcolor(X_fine, Y_fine, I_itp);
% shading flat;
% 
% figure;
% pcolor(X_fine, Y_fine, J_itp);
% shading flat


%% 

%-----SEM Parameters -- time between images, cycle time (convert to dwell time)
T_12 = input('Input time between image 1 and image 2: ');
cycle_time = input('Input cycle time (s): ');
dt = cycle_time/(img_width*img_height); %dwell time (s/pixel)

im_check = input("Enter 1 to correct the first image taken (press enter to skip): ");

%-----Pixel capture time solve
num_cols = length(x_fine_vec); 
num_rows = length(y_fine_vec);

[J, I] = meshgrid(1:num_cols, 1:num_rows);

tK = T_12 + (num_cols .* (I - 1) + (J - 1)) .* dt;

%-----Average Velocity Calculations
u_12 = mean(U_12(:)) / (T_12);
v_12 = mean(disp_j(:), 'omitnan') / (T_12);

if im_check == 1
    t1 = (num_cols .* (I - 1) + (J - 1)) .* dt;
    X_real = (X_fine - img_width/2) - u_12.*(t1);
    Y_real = (Y_fine - img_height/2) - v_12.*(t1);

    j_real = round((X_real + img_width/2));
    i_real = round((Y_real + img_height/2));

    corrected_img = img_0;
    orig_img = img_0;
else

    %-----Real Position Calculation
    
    X_real = (X_fine - img_width/2) - u_12.*(tK - T_12) - I_itp;
    Y_real = (Y_fine - img_height/2) - v_12.*(tK - T_12) - J_itp;
    
    %-----Apply corrections
    
    j_real = round((X_real + img_width/2));
    i_real = round((Y_real + img_height/2));

    corrected_img = base_img;
    orig_img = base_img;
end

%check for bounds
check = i_real >= 1 & i_real < img_height & j_real >= 1 & j_real <= img_width;

source_idx = sub2ind(size(base_img), Y_fine(check), X_fine(check));
new_idx = sub2ind(size(base_img), i_real(check), j_real(check));

corrected_img(new_idx) = base_img(source_idx);

%-----Display and save new image
figure; 
imshow(corrected_img);
title('Corrected Image');

figure;
imshow(orig_img);
title('Original Image');

if im_check ~= 1
    figure;
    im_0 = imread('lineint_ss3_num10_0.tif');
    imshow(im_0);
    title('Original Image')
end