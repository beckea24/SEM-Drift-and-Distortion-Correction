%%%Distortion Correction using ALDIC and P. Jin and X. Li Methodology%%%


%% Section Zero -- Import Images and calculate ROI for DIC
close all; clear; clc;
%Import images
im0_name = 'distortion_04.tif';
im1_name = 'distortion_05.tif';
img_0 = imread("distortion_04.tif");
img_1 = imread('distortion_05.tif');

img_width = size(img_0, 2);
img_height = size(img_0, 1);

%Pick bottom right and top left coordinates of shared scene
disp('--- Define shared corner point at the bottom-left ---')
imshow(img_0);
title('Click bottom-left shared corner point','fontweight','normal','fontsize',16);

gridx = zeros(1,2); gridy = zeros(1,2);
[gridx(1), gridy(1)] = ginput(1);


imshow(img_1)
title('Click top-right shared corner point','fontweight','normal','fontsize',16);
[gridx(2), gridy(2)] = ginput(1);

close; 
gridx = round(gridx); gridy = round(gridy);
fprintf('Coordinates of bottom-left corner point are (%d,%d)\n',gridx(1), gridy(1))
fprintf('Coordinates of top-right corner point are (%d,%d)\n',gridx(2), gridy(2))

%Calculate a and b
a = gridx(1) - gridx(2)
b = gridy(1) - gridy(2)
%ROI Calc
subset_width = input("Input subset size: (even number)");
subset_step = input("Input subset step: (integer = 1/4 to 1 of subset_width): ");
m = subset_width/2;
%subset half-width m
%m≤x≤W−∣a∣−m,m≤y≤H−∣b∣−m
%Calculate x range and y range
% x_min = m;
% x_max = img_width - abs(a) - m;
% y_min = m;
% y_max = img_height - abs(b)-m;
x_min =  abs(a) + m;
x_max = img_width - m;
y_min = abs(b) + m;
y_max = img_height -m;
%% Section One -- ALDIC call
fprintf("Please enter the following parameters when prompted:\nSubset size = %d\nSubset Step = %d\nROI x minimum = %d" + ...
    "\nROI x maximum = %d\nROI y minimum = %d\nROI y maximum = %d", subset_width, subset_step, x_min, x_max, y_min, y_max);
fprintf("\n------------ ALDIC Running ------------\n");
save('distpara.mat','subset_width','subset_step','x_min','x_max','y_min','y_max','a','b', 'img_width', 'img_height', 'img_1','img_0', 'im0_name', 'im1_name');
run("ALDIC_dist.m");
S = load('distpara.mat');
subset_width = S.subset_width; subset_step = S.subset_step;x_min = S.x_min; x_max = S.x_max; y_min = S.y_min; y_max = S.y_max; a = S.a; b = S.b; 
img_width = S.img_width; img_height = S.img_height; img_1 = S.img_1;img_0=S.img_0;
im0_name=S.im0_name; im1_name = S.im1_name;
%% Section Two -- Distortion Parameter Calculation

%Import DIC correction

results_filename = "results_" + extractBefore(im1_name, ".") + "_ws" + subset_width + "_st" + subset_step + ".mat";
load(results_filename);

U_all = ResultDisp{1}.U;
u = U_all(1:2:end);        % horizontal displacement (odd entries)
v = U_all(2:2:end);        % vertical displacement (even entries)
% v= -v; %Fit paper convention

js = DICmesh.coordinatesFEM(:,1);
is = DICmesh.coordinatesFEM(:,2);

%Ensure all points are good
good = ~isnan(u) & ~isnan(v);
js = js(good); is = is(good);
u  = u(good);  v  = v(good);

xs = js - img_width/2;
ys = is - img_height/2;
%Variable set up
function [QU, QV] = buildQ(x, y, a, b)
% param order: A = [B; C; D; F; f; e]
% % shared polynomial that multiplies D and F in V:
P_shared = -a^2*b + 2*a*b*x - b*x^2 + a^2*y - 2*a*x*y;
% % polynomial multiplying C and D in U
% P_lin    = -a + 3*a^2*x - 3*a*x^2;
% %polynomial multiplying c and e in V
P_cub    = -a^3 + 3*a^2*x - 3*a*x^2;
%Polynomials
P_c = -a^3 +3*a^2.*x - 3*a.*x.^2;
P_xysq = -a*b^2 +b^2.*x-a*y.^2+2*a*b.*y-2*b.*x.*y;
P_s = -a^2*b+2*a*b.*x - b.*x.^2+a^2.*y-2*a.*x.*y;
P_ycub = -b^3+3*b^2..*y - 3*b.*y.^2;

% ---- U row ----
U_B = -a^3 - a*b^2 + 3*a^2*x + b^2*x - 3*a*x^2 + 2*a*b*y - 2*b*x*y - a*y^2;
% U_C = 2*P_lin;                         % from (2C+D+E), E dropped
% U_D = 1*P_lin;                         % from (2C+D+E)
% U_F = -3*a^3 - a*b^2 + 9*a^2*x + b^2*x - 9*a*x^2 + 2*a*b*y - 2*b*x*y - a*y^2;
% U_f = -2*a^2*b + 4*a*x - 2*b*x^2 + 2*a^2*y - 4*a*x*y;
U_e = 0;

U_C = 2*P_c;
U_D = P_c;
U_F = 2*P_c+P_xysq;
U_f = 2*P_s;


QU = [U_B, U_C, U_D, U_F, U_f, U_e];

% ---- V row ----
V_B = -a^2*b - b^3 + 2*a*b*x - b*x^2 + a^2*y + 3*b^2*y - 2*a*x*y - 3*b*y^2;
V_C = 0;
V_D = P_shared;
V_F = 2*P_shared;
V_f = -a^3 - 3*a*b^2 + 3*a^2*x + 3*b^2*x - 3*a*x^2 + 6*a*b*y - 6*b*x*y - 3*a*y^2;
V_e = P_cub;
QV = [V_B, V_C, V_D, V_F, V_f, V_e];
end

n = numel(xs);
Q = zeros(2*n, 6);
d = zeros(2*n, 1);
for k = 1:n
    [QU, QV] = buildQ(xs(k), ys(k), a, b);
    Q(2*k-1, :) = QU;    %Qu = odd rows
    Q(2*k,   :) = QV;    %Qv = even rows
    d(2*k-1) = u(k); %U displacement at this point
    d(2*k)   = v(k); %V displacement at this point
end
d(1:2:end) = u - mean(u);    % remove horizontal rigid shift
d(2:2:end) = v - mean(v);     

%Calculate Distortion Parameters
A = Q\d;
resid = norm(Q*A-d)/norm(d);
cond(Q);

%% Displacement Value calculations
function [dx, dy] = distortion_field(x, y, A)
    B = A(1); C=A(2); D=A(3); F=A(4); f=A(5); e=A(6);
    dx = B*(x.^2+y.^2).*x+F*(2*x.^2+y.^2).*x+2*f.*x.^2.*y+(2*C+D).*x.^3;
    dy = B*(x.^2+y.^2).*y+2*F.*x.^2.*y+f*(x.^2+3.*y.^2).*x+D.*y.*x.^2+e.*x.^3;
end
%Calculate displacement values 
[X, Y] = meshgrid(1:img_width, 1:img_height);
[dx, dy] = distortion_field(X - img_width/2, Y - img_height/2, A); 

%% Section Three -- Apply Corrections
corrected_img0 = interp2(X, Y, double(img_0), X - dx, Y - dy, 'linear', NaN);
corrected_img1 = interp2(X, Y, double(img_1), X - dx, Y - dy, 'linear', NaN);
% Display the corrected image
[~, name0] = fileparts(im0_name);
[~, name1] = fileparts(im1_name);

figure;
imagesc(corrected_img0); colormap gray; axis image;
title('Corrected Image 0');
save_img = mat2gray(corrected_img0);
imwrite(save_img, "corrected_"+name0+".tif");

figure;
imagesc(corrected_img1); colormap gray; axis image;
title('Corrected Image 1')
save_img2 = mat2gray(corrected_img1);
imwrite(save_img2, "corrected_"+name1+".tif");

figure;
imshow(img_1);
title('Base Image 1');
figure;
imshow(img_0);
title('Base Image 0');

disp('Files Saved and Displayed');