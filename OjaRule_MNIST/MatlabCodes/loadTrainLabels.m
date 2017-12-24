function result = loadTrainLabels()

[inputFolder, ~, ~] = fileparts(which(mfilename));

inputFolder = fullfile(inputFolder, '..', 'MNISTDatabase');

addpath(inputFolder);

result = loadMNISTLabels('train-labels.idx1-ubyte');
