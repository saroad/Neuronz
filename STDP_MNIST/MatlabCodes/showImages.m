function showImages(C, r, imTitle, size)

subplot(size, size, r);
%I = vec2mat(max(C, max(C) / 10), Row);
I = vec2mat(C, 28)';
I = mat2gray(I);
imshow(I);
title(imTitle);