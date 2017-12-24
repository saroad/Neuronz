function showImages(C, r, imTitle, size)

global Col;

subplot(size, size, r);
%I = vec2mat(max(C, max(C) / 10), Row);
I = vec2mat(C, Col);
I = mat2gray(I);
imshow(I);
title(imTitle);