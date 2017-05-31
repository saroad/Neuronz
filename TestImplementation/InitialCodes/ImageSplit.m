folder = fileparts(which(mfilename));
fileName = fullfile(folder, 'TestSample.jpg');
image = imread(fileName);
image = rgb2gray(image);
%imshow(image);

[rows,cols,numberOfColorBands] = size(image);

disp(rows);
disp(cols);

blockSizeR = 10;
blockSizeC = 10;

wholeBlockRows = floor(rows / blockSizeR);
blockVectorR = [blockSizeR * ones(1, wholeBlockRows), rem(rows, blockSizeR)];

wholeBlockCols = floor(cols / blockSizeC);
blockVectorC = [blockSizeC * ones(1, wholeBlockCols), rem(cols, blockSizeC)];

imageArray = mat2cell(image, blockVectorR, blockVectorC);

plotIndex = 1;
numPlotsR = size(imageArray, 1);
numPlotsC = size(imageArray, 2);

disp(numPlotsR);
disp(numPlotsC);

resultFolder = strcat(strcat(folder, '\'), 'ImageSamples2');

for r = 1 : numPlotsR - 1
	for c = 1 : numPlotsC - 1
        imageName = strcat(int2str(plotIndex), '.jpg');
        imwrite(imageArray{r,c},fullfile(resultFolder, imageName));
		
        %{
		subplot(numPlotsR - 1, numPlotsC - 1, plotIndex);
		block = imageArray{r,c};
		imshow(block);
		%}
        
		plotIndex = plotIndex + 1;
	end
end

drawnow;
