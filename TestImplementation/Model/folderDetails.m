function result = folderDetails()

global inputFolder;

[inputFolder, ~, ~] = fileparts(which(mfilename));

inputFolder = fullfile(inputFolder, '..', 'InitialCodes\ImageSamples1');

index = dir(inputFolder);
fileList = {index.name};
fileList = fileList(:, 3 : end);

result = fileList;