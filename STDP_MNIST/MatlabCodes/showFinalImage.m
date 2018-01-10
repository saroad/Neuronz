function showFinalImage(C)

%global Col;

%I = vec2mat(max(C, max(C) / 10), Row);
figure
%I = C;
I = vec2mat(C, 28);
I = mat2gray(I');
imshow(I);