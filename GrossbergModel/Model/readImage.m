function [result, r, c] = readImage()

global inputFolder imageFile rawImage;

rawImage = imread(fullfile(inputFolder, imageFile));

if(size(rawImage, 3) == 3)
    rawImage = rgb2gray(rawImage);
end

result = double(rawImage);

[r, c] = size(result);

result = result';
result = result(:);
