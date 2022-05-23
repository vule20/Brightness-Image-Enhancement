function [htc, htc_bm3d, valid_rgb] = HTC_BM3D(img_path, sigma)
% Input: RGB image file, sigma for denoising
% Output: optimally enhanced image RGB
% the purpose of this function is to find the optimal k to maximize image information measured by entroypy
% BM3D is then applied to remove noise from the image enhanced by HTC

    norm_img = im2double(imread(img_path));
    [~, ~, ch] = size(norm_img);
    valid_rgb = 0;
    htc = zeros(size(norm_img));
    htc_bm3d = zeros(size(norm_img));
    if ch == 3
        valid_rgb = 1;
        p = 0.5*(sqrt(5) - 1);  % iteration coefficient
        t = 0.01;
        k_l = 0.1;
        k_h = 9;
        delta_k = k_h - k_l;
        k1 = k_l + (1 - p)*delta_k;
        k2 = k_l + p*delta_k;
        
        J1 = entropy(rgb2gray(HTC(norm_img, k1)));
        J2 = entropy(rgb2gray(HTC(norm_img, k2)));
        % golden search algorithm
        while delta_k > t
            if J1 > J2
                k_h = k2;
                delta_k = k_h - k_l;
                k1 = k_l + (1 - p)*delta_k;
                k2 = k_l + p*delta_k;
                J2 = J1;
                J1 = entropy(rgb2gray(HTC(norm_img, k1)));
            else
                k_l = k1;
                delta_k = k_h - k_l;
                k1 = k_l + (1 - p)*delta_k;
                k2 = k_l + p*delta_k;
                J1 = J2;

                J2 = entropy(rgb2gray(HTC(norm_img, k2)));
            end
        end
        htc = 0.5*(HTC(norm_img, k1) + HTC(norm_img, k2));
        YUV = rgb2ycbcr(htc);
        Y = YUV(:, :, 1);
        [~, Y_d] = BM3D(Y, Y, sigma, 'lc', 0);
        htc_bm3d = ycbcr2rgb(cat(3, Y_d, YUV(:, :, 2:3)));
    end
end
function htc_img = HTC(img, k)
    % Input: normalized RGB image, k
    % Output: hyperbolic enhanced image
    [~, ~, ch] = size(img);
    if ch == 1
      disp("cannot execute gray image");
      htc_img = 0;
    else
      omega = mean(mean(mean(img)));
      img_w = omega.*img + (1 - omega).*tanh(k*img);
      htc_img = (img_w - min(img_w, [], 'all'))/(max(img_w, [], 'all') - min(img_w, [], 'all'));
    end
end