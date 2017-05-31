function result = loadTestLabels()

[inputFolder, ~, ~] = fileparts(which(mfilename));

inputFolder = fullfile(inputFolder, '..', 'MNISTDatabase');

addpath(inputFolder);

result = loadMNISTLabels('t10k-labels.idx1-ubyte');

disp(size(result));