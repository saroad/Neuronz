function result = loadTestImages()

[inputFolder, ~, ~] = fileparts(which(mfilename));

inputFolder = fullfile(inputFolder, '..', 'MNISTDatabase');

addpath(inputFolder);

result = loadMNISTImages('t10k-images.idx3-ubyte');


