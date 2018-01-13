function showFinalImage(C)

%global Col;

%I = vec2mat(max(C, max(C) / 10), Row);
figure
%I = vec2mat(C, Col);
I = mat2gray(C);
imshow(I);