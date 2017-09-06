function SampleImages()

global outputFolder index rawImage;

[inputFolder, ~, ~] = fileparts(which(mfilename));
inputFolder = fullfile(inputFolder, 'ImageSamples');
outputFolder = fullfile(inputFolder, 'Sampled');


index = dir(inputFolder);
fileList = {index.name};
fileList = fileList(:, 3 : end);

index = 1;

for i = 1 : length(fileList)
    k = strfind(fileList{i}, '.jpg');
    if  k
        rawImage = imread(fullfile(inputFolder, fileList{i}));
        createSubImages();
    end
end
    
disp('Done');

end
    
function createSubImages()

global outputFolder index rawImage;

n = 20;
L = 50;

if(size(rawImage, 3) == 3)
    rawImage = rgb2gray(rawImage);
end

[r, c]= size(rawImage);

for i = 1 : n
    
    crop = rawImage(randi(r - L + 1) + (0 : L - 1), randi(c - L + 1) + (0 : L - 1));
    
    fileName = sprintf('%d.jpg', index);
    fileName = fullfile(outputFolder, fileName);
    crop = mat2gray(crop);
    imwrite(crop, fileName);
    
    index = index + 1;

end
    

end

