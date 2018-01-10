function result = readImage()

global inputFolder imageFile rawImage Row Col;

rawImage = imread(fullfile(inputFolder, imageFile));

if(size(rawImage, 3) == 3)
    rawImage = rgb2gray(rawImage);
end

result = mat2gray(double(rawImage));

[Row, Col] = size(result);

%{
result = result';
result = result(:);
%}