function tOut= TestModel()

global image imageFile Row Col filterSize timeValue t_pre t_post t_pre_v t_post_v;

timeValue = 0;
filterSize = 5;

fileList = folderDetails();

%imageFile = fileList{randi(length(fileList))};
imageFile = '65.jpg';
%imageFile = fileList{};
disp(imageFile);
image = readImage();

[outputAplus, outputAminus] = LayerA(image);
[verticalEdges, horizontalEdges] = LayerB(outputAplus, outputAminus);
% verticalEdges = ones(size(verticalEdges))-verticalEdges;
% horizontalEdges = ones(size(horizontalEdges))-horizontalEdges;
showFinalImage(image);
%showFinalImage(verticalEdges);
%showFinalImage(horizontalEdges);
s = verticalEdges + horizontalEdges;
%s = sigmf(s, [1, 0.5]);
%s(s < 0.4) = 0;
showFinalImage(s);

verticalOut = zeros(Row, Col);
horizontalOut = zeros(Row, Col);
t_pre = zeros(1, 5);
t_post = zeros(1, 5);
t_pre_v = zeros(5, 1);
t_post_v = zeros(5, 1);
tOut = [];
c = 2.0;
temp1 = fspecial('gaussian', filterSize, 5.0);

%Lateral connections - Excitatory
verticalKernel = temp1(:, floor(filterSize / 2) + 1) * c;
horizontalKernel = temp1(floor(filterSize / 2) + 1, :) * c;



for i = 1 : 100
    verticalEdges = verticalEdges + verticalOut;
    horizontalEdges = horizontalEdges + horizontalOut;
    [verticalOut, horizontalOut, verticalKernel, horizontalKernel] = LayerC(verticalEdges, horizontalEdges, verticalKernel, horizontalKernel);
end
t = 0.25*(verticalOut + horizontalOut);
%t = mat2gray(t);
%t(t < 0.4) = 0;
showFinalImage(t);

tOut = t_post;
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

para = [1, 0.5];

result1 = sigmf(verticalEdges, para);
result2 = sigmf(horizontalEdges, para);


result1(result1 < 0.4) = 0;
result2(result2 < 0.4) = 0;

end
function [tempresult1, tempsample] = prep(result1, sample, para)
    tempresult1 = sigmf(normalize(result1),para);
    tempsample = sigmf(normalize(sample),para);
    tempresult1(tempresult1<0.3) = 0;
    tempresult1(tempresult1>0.3) = 1;
    tempsample(tempsample<0.3) = 0;
    tempsample(tempsample>0.3) = 1;
end

function [result1, result2, verticalKernel, horizontalKernel] = LayerC(verticalEdges, horizontalEdges, verticalKernel, horizontalKernel)

global timeValue t_pre t_post t_pre_v t_post_v;
timeValue = timeValue + 1;
a =0.002;
b = 0.0;



% sampling a section
[verticalHeight, verticalWdith] = size(verticalEdges);
[horizontalHeight, horizontalWdith] = size(horizontalEdges);

iVertical = floor(0.25*(verticalHeight+verticalWdith));
verticalSample = verticalEdges((iVertical - 2):(iVertical + 2),iVertical);

iHorizontal = floor(0.25*(horizontalHeight+horizontalWdith));
horizontalSample = horizontalEdges(iHorizontal,(iHorizontal - 2):(iHorizontal + 2));



%Lateral connections - Inhibitory
inhibitVertical = [-b, 0, -b]';
inhibitHorizontal = [-b, 0, -b];
para = [1 1];

verticalresult1 = imfilter(verticalSample, verticalKernel);
% oneSet = ones(5,1);
[tempverticalresult1, tempverticalsample] = prep(verticalresult1,  verticalSample, para);
if(tempverticalresult1(3)>0)
    t_post_v = timeValue * ones(size(t_post_v));
end;

t_pre_v(tempverticalsample>0) =timeValue*tempverticalsample(tempverticalsample>0);
verticalKernel = verticalKernel + a*verticalKernel.*stdp(t_pre_v,t_post_v);

horizontalresult1 = imfilter(horizontalSample, horizontalKernel);
% oneSet = ones(1,5);
[temphorizontalresult1,temphorizontalsample] = prep(horizontalresult1, horizontalSample, para);
if(temphorizontalresult1(3)>0)
    t_post = timeValue * ones(size(t_post));
end;

t_pre(temphorizontalsample>0) =timeValue*temphorizontalsample(temphorizontalsample>0) ;
horizontalKernel = horizontalKernel + a*horizontalKernel.*stdp(t_pre,t_post);

result1 = imfilter(verticalEdges, verticalKernel) + imfilter(verticalEdges, inhibitVertical);
result2 = imfilter(horizontalEdges, horizontalKernel) + imfilter(horizontalEdges, inhibitHorizontal);

% plot(horizontalKernel);

% Neuron spiking

para = [0.5, 0.5];


tempresult1 = normalize(result1);
tempresult2 = normalize(result2);


tempresult1pre = sigmoidFunc(verticalEdges);
tempresult2pre = sigmoidFunc(horizontalEdges);

tempresult1pre = sigmf(verticalEdges, para);
tempresult2pre = sigmf(horizontalEdges, para);

tempresult1(tempresult1pre < 0.3) = 0;
tempresult2(tempresult2pre < 0.3) = 0;

end



function showRange(mat)

m1 = min(mat(:));
m2 = max(mat(:));

disp([num2str(m1), ' - ', num2str(m2)]);

end

function sig=sigmoidFunc(mat)

% sig = zeros(size(mat));
sig = 1.0 ./ ( 1.0 + exp(-mat));

end

function norm = normalize(mat)

norm = mat - min(mat(:));
norm = norm ./ max(norm(:));

end

function weights = stdp(t_pre,t_post)

tau = 10;
a_plus = 2;
a_minus = a_plus / 1.07;
weights = (t_post - t_pre)/tau;
weights(weights>=0) = a_plus*exp(-1*abs(weights(weights>=0)));
weights(weights<0) = -1*a_minus*exp(-1*abs(weights(weights<0)));

end