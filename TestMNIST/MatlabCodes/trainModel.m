function trainModel(layerset, dataSize) % Using Oja's rule

trainingRatio = 0.7;
p = 0.3;

images = loadTrainImages();
labels = loadTrainLabels();


selected = find(labels == 0 | labels == 1);
labels = labels(selected);
images = images(:, selected');


[~, c] = size(images);
dataSize = min(c, dataSize);
iterations = dataSize;

testLabels = [];
clusters = [];

trainingSize = floor(double(dataSize) * trainingRatio);
unclassified = 0;
norms = [];

updateTime = 0.0;

%{
im = vec2mat(images(:, randi(10000)), 28)';
imshow(im);
drawnow;
%}

%showFinalImage(weights{1});
%temp = weights;

net = Network([784, layerset, 10]);
numLayers = net.numLayers;
tempW = net.feedforwardConnections;
%tempW = net.lateralConnections;

for r = 1 : iterations
    
    results = net.getOutput(mat2gray(images(:, r)));
    
    if(r > trainingSize)
        [m, i] = max(results{numLayers});
        if(m >= p)
            testLabels = [testLabels; labels(r)];
            clusters = [clusters; i];
        else
            unclassified = unclassified + 1;
        end
        
    end
    
    time = tic;
    
    net.STDP_update(results);
    
    updateTime = updateTime + toc(time);
    
    
    norms = [norms; zeros(1, numLayers - 1)];
    
    weights = net.feedforwardConnections;
    %weights = net.lateralConnections;
    
    for k = 1 : numLayers - 1
        
        norms(end, k) = norm(weights{k} - tempW{k},'fro') / numel(weights{k});
        tempW{k} = weights{k};
        
    end
    
    
end

plotPerformance([1 : iterations]', norms, testLabels, clusters, [1, 2, 3]);

disp(['Unclassified: ', int2str(unclassified), ' out of ', int2str(dataSize - trainingSize)]);

disp(['Average STDP update time = ', num2str(updateTime / iterations)]);


for r = 1 : numLayers - 1

    disp([int2str(r),': ', int2str(net.ffcheck(r))]);

end


%{
for i = 1 : numLayers - 1
    
    showFinalImage(weights{i});
   
end
%}

%showFinalImage([temp{1},max(max(weights{1}))* ones(layers(2), 5), weights{1}]);

%showFinalImage(weights{1});

%showFinalImage(abs(weights{1} - temp{1}));

%clust = kmeans(images(:, trainingSize + 1 : dataSize)', 8);

%plotPerformance([1 : iterations]', norms, testLabels, clust, [2, 3]);

%disp(clusters);

function initialise()

global weights numLayers layers;

layers = [784, layers, 8];

[~, numLayers] = size(layers);

weights = cell(numLayers - 1);

for i = 1 : numLayers - 1
    
    %weights{i} = rand(layers(i + 1),layers(i));
    %weights{i} = ones(layers(i + 1),layers(i));
    weights{i} = normr(binornd(1, 0.2, layers(i + 1),layers(i)));
    
end


function initialiseSelective()

global weights numLayers layers;

windowSize = 5;
radius = floor(windowSize / 2);

layers = [784, 784, layers, 10];

[~, numLayers] = size(layers);

weights = cell(numLayers - 1);

weights{1} = zeros(784, 784);

for i = 0 : 783

    for j = max(i - 28 * radius, mod(i, 28)) : 28 : min(i + 28 * radius, 783)

        l = floor(j / 28);
        l1 = 28 * l;
        l2 = 28 * (l + 1) - 1;

        weights{1}(i + 1, max(j - radius, l1) + 1 : min(j + radius, l2) + 1) = ones(1, min(j + radius, l2) - max(j - radius, l1) + 1);

    end

end


for i = 2 : numLayers - 1
    
    %weights{i} = rand(layers(i + 1),layers(i));
    weights{i} = normr(binornd(1, 0.3, layers(i + 1),layers(i)));
    
end


function STDP_update(results)

global t a weights numLayers check;

%{
tResults = cell(numLayers);

for i = 1 : numLayers
    
    tResults{i} = results{i}';
    
end
%}

tempW = weights;
tcheck = check;

parfor r = 1 : numLayers - 1
    
    
    [s, ~] = size(results{r + 1});
    
    %tempW{r} = weights{r} + t * results{r + 1} * (results{r}' - a * results{r + 1}' * weights{r});
    
    temp = results{r + 1} * results{r}' -  a * bsxfun(@times, weights{r}, results{r + 1} .^2);
    
    if any(temp < 0)
        tcheck(r) = check(r) + 1;
    end
    
    tempW{r} = weights{r} + t * (temp);
   
    
end

weights = tempW;
check = tcheck;


function saveWeights()

global weights layers;

fileName = sprintf('%d_', layers);
fileName = strcat(fileName(1 : end - 1), '.mat');
fileName = fullfile(fileparts(which(mfilename)), '..\WeightDatabase\Temp', fileName);

%weights = weights;

save(fileName, 'weights');


