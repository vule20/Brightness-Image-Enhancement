% sigma = 15 for htc
clc; close all; clear all;
addpath(genpath('./'));

source_img = "./test_img/hive_ntu_6.png";

sigma_BM3D = 10;
[htc_img, htc_bm3d_img] = HTC_BM3D(source_img, sigma_BM3D);
imshow(htc_img);
figure
imshow(htc_bm3d_img);



