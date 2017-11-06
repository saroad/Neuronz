function TestModel()

global image imageFile Row Col filterSize;

filterSize = 5;

fileList = folderDetails();

%imageFile = fileList{randi(length(fileList))};
imageFile = '101.jpg';
%imageFile = fileList{};
disp(imageFile);
image = readImage();

[outputAplus, outputAminus] = LayerA(image);
[verticalEdges, horizontalEdges] = LayerB(outputAplus, outputAminus);

showFinalImage(image);
%showFinalImage(verticalEdges);
%showFinalImage(horizontalEdges);
s = verticalEdges + horizontalEdges;
%s = sigmf(s, [1, 0.5]);
%s(s < 0.4) = 0;
showFinalImage(s);

verticalOut = zeros(Row, Col);
horizontalOut = zeros(Row, Col);

for i = 1 : 100
    verticalEdges = verticalEdges + verticalOut;
    horizontalEdges = horizontalEdges + horizontalOut;
    [verticalOut, horizontalOut] = LayerC(verticalEdges, horizontalEdges);
end

t = verticalOut + horizontalOut;
%t = mat2gray(t);
%t(t < 0.4) = 0;
showFinalImage(t);

end

function [result1, result2] = LayerA(rawImage)

global filterSize;

h = fspecial('gaussian', filterSize, 2.0);

temp = imfilter(rawImage, h);

result1 = rawImage - temp;
result2 = - result1;
result1 = max(result1, 0);
result2 = max(result2, 0);

end


function [result1, result2] = LayerB(outputAplus, outputAminus)

global filterSize;

gamma = 10.0;
omega = 6.0;

temp = fspecial('gaussian', filterSize + 2, 1.0);

rightBiasKernel = temp;
rightBiasKernel = rightBiasKernel(2 : end - 1, 1 : end - 2);

leftBiasKernel = temp;
leftBiasKernel = leftBiasKernel(2 : end - 1, 3 : end);


topBiasKernel = temp;
topBiasKernel = topBiasKernel(3 : end, 2 : end - 1);

bottomBiasKernel = temp;
bottomBiasKernel = bottomBiasKernel(1 : end - 2, 2 : end - 1);
 
rightplus = imfilter(outputAplus, rightBiasKernel);
rightminus = imfilter(outputAminus, rightBiasKernel);

leftplus = imfilter(outputAplus, leftBiasKernel);
leftminus = imfilter(outputAminus, leftBiasKernel);

topplus = imfilter(outputAplus, topBiasKernel);
topminus = imfilter(outputAminus, topBiasKernel);

bottomplus = imfilter(outputAplus, bottomBiasKernel);
bottomminus = imfilter(outputAminus, bottomBiasKernel);

simpleRight = rightplus + leftminus;
simpleLeft = leftplus + rightminus;
simpleTop = topplus + bottomminus;
simpleBottom = bottomplus + topminus;

simpleplus = rightplus + leftplus;
simpleminus = rightminus + leftminus;
temp = simpleplus - simpleminus;
temp1 = max(temp, 0);
temp2 = max(-temp, 0);
r = omega * (temp1 + temp2);

verticalEdges = gamma * max(simpleRight - simpleLeft, 0) + gamma * max(simpleLeft - simpleRight, 0);
horizontalEdges = gamma * max(simpleTop - simpleBottom, 0) + gamma * max(simpleBottom - simpleTop, 0); 

%result1 = mat2gray(verticalEdges);
%result2 = mat2gray(horizontalEdges);

% Neuron spiking

para = [1.0, 0.5];

result1 = sigmf(verticalEdges, para);
result2 = sigmf(horizontalEdges, para);

result1(result1 < 0.4) = 0;
result2(result2 < 0.4) = 0;

end


function [result1, result2] = LayerC(verticalEdges, horizontalEdges)

global filterSize;

c = 2.0;
b = 0.0;

temp1 = fspecial('gaussian', filterSize, 5.0);


%Lateral connections - Excitatory
verticalKernel = temp1(:, floor(filterSize / 2) + 1) * c;
horizontalKernel = temp1(floor(filterSize / 2) + 1, :) * c;

%Lateral connections - Inhibitory
inhibitVertical = [-b, 0, -b]';
inhibitHorizontal = [-b, 0, -b];

result1 = imfilter(verticalEdges, verticalKernel) + imfilter(verticalEdges, inhibitVertical);
result2 = imfilter(horizontalEdges, horizontalKernel) + imfilter(horizontalEdges, inhibitHorizontal);


% Neuron spiking

para = [0.5, 0.5];

%result1 = sigmf(result1, para);
%result2 = sigmf(result2, para);

result1(result1 < 0.2) = 0;
result2(result2 < 0.2) = 0;

end



function showRange(mat)

m1 = min(mat(:));
m2 = max(mat(:));

disp([num2str(m1), ' - ', num2str(m2)]);

end
