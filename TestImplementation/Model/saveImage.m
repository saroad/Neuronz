function saveImage(C)

global inputFolder imageFile Row rawImage

I = vec2mat(C, Row);
I = mat2gray(I);
I = cat(2, I, mat2gray(rawImage));
imwrite(I, fullfile(inputFolder, '..', 'Processed', strcat('processed', imageFile)));