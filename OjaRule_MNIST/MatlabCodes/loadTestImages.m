function result = loadTestImages()

[inputFolder, ~, ~] = fileparts(which(mfilename));

inputFolder = fullfile(inputFolder, '..', 'MNISTDatabase');

addpath(inputFolder);

result = loadMNISTImages('t10k-images.idx3-ubyte');


%{
im = vec2mat(result(:, randi(10000)), 28)';


disp(mat2gray(im));
imshow(im);
%}

