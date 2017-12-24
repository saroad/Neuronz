function result = loadTrainImages()

[inputFolder, ~, ~] = fileparts(which(mfilename));

inputFolder = fullfile(inputFolder, '..', 'MNISTDatabase');

addpath(inputFolder);

result = loadMNISTImages('train-images.idx3-ubyte');

%imshow(vec2mat(result(:, randi(60000)), 28)');


