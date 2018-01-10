function trainModel(layerset, iterations) % Using Oja's rule

trainingRatio = 0.7;
p = 0.5;

images = loadTrainImages();
labels = loadTrainLabels();


selected = find(labels == 0 | labels == 9);
labels = labels(selected);
images = images(:, selected');


[~, dataSize] = size(images);

shuffle = randperm(dataSize);
labels = labels(shuffle, :);
images = images(:, shuffle);

%{
disp('Labels');
i = randi(dataSize, 1);
showFinalImage(mat2gray(images(:, i)));
disp(labels(i));
i = randi(dataSize, 1);
showFinalImage(mat2gray(images(:, i)));
disp(labels(i));
i = randi(dataSize, 1);
showFinalImage(mat2gray(images(:, i)));
disp(labels(i));
%}

testLabels = [];
clusters = [];
testLabelsT = [];
clustersT = [];

trainingSize = floor(double(iterations) * trainingRatio);
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

lastLayer = 3;

net = Network([784, layerset, lastLayer]);
numLayers = net.numLayers;
tempW = net.feedforwardConnections;
%tempW = net.lateralConnections;
temp = net.feedforwardConnections;

pow = 1;
res = 0;

oneList = [];
zeroList = [];

stdList = zeros(1, numLayers);
outputList = zeros(1, lastLayer);
varStd = [];
isTraining = 0;
distData = cell(1, numLayers);

for it = 1 : iterations
    
    r = randi(dataSize, 1);
    results = net.getOutput(prepImage(mat2gray(images(:, r))));
    
    %{
    for l = 1 : numLayers
        
        distData{l}(end + 1 : end + size(results{l}, 1)) = results{l};
        
    end
    %}
    
    %{
    S = [1; 1];
    
    if it <= trainingSize
        if labels(r) == 0
            S(1) = 0;
        else
            S(2) = 0;
        end
    end
    %}
    
    if(it > trainingSize)
        isTraining = 1;
        
        Ind = find(results == 1);
        
        [B, I] = sort(results,'descend');
        
        if binornd(1, 0.01, 1, 1) == 1
            
            if labels(r) == 1
                oneList = [oneList, I];
            else
                zeroList = [zeroList, I];
            end
            
        end
        
        outputList = outputList + B';
        
        if(size(Ind, 1) == 1)
            testLabels = [testLabels; labels(r)];
            clusters = [clusters; Ind];
        else
            unclassified = unclassified + 1;
        end
        
              
        %{
        [m, i] = max(results{numLayers - 1});
        [l, ~] = min(results{numLayers - 1});
        
        if(m >= p)
            testLabelsT = [testLabelsT; labels(r)];
            clustersT = [clustersT; i];
        end
        %}
        
    end
    
    time = tic;
    
    %net.STDP_update(results, isTraining);
    
    updateTime = updateTime + toc(time);
    
    
    norms = [norms; zeros(1, numLayers - 1)];
    
    weights = net.feedforwardConnections;
    %weights = net.lateralConnections;
    
    for k = 1 : numLayers - 1
        
        norms(end, k) = norm(weights{k} - tempW{k},'fro') / numel(weights{k});
        %norms(end, k) = sum(abs(weights{k}(:))) / numel(weights{k});
        tempW{k} = weights{k};
        
    end
    
    %{
    if r == pow
        showFinalImage(abs(weights{1} - temp{1}));
        pow = pow * 10;
    end
    %}
    
end

plotPerformance([1 : iterations]', norms, testLabels, clusters, [1, 2, 3]);
%plotPerformance([1 : iterations]', norms, testLabelsT, clustersT, [3]);

disp(['Unclassified: ', int2str(unclassified), ' out of ', int2str(iterations - trainingSize)]);

disp(['Average STDP update time = ', num2str(updateTime / iterations)]);

disp(['Res: ', num2str(res)]);

for r = 1 : numLayers - 1

    disp([int2str(r),': ', int2str(net.ffcheck(r))]);

end

%disp('oneList:');
%disp(oneList);
%disp('zeroList:');
%disp(zeroList);
disp('Output Sorted:');
disp(outputList / (iterations - trainingSize));
%disp('Weights:');
%disp(weights{numLayers - 1});

layers = net.layerStruct;
r = randi(layers(2), 1, 1);
W = weights{1}(r, :);
W = vec2mat(W, 28);

W = weights{2};

figure
surf(W)
colormap(jet);

%{
figure
for i = 1 : 28
    
    subplot(4, 7, i);
    plot(W(i, :));
    title(num2str(i));
    
end

for i = 1 : 28
    
    subplot(4, 7, i);
    plot(W(:, i));
    title(num2str(i));
    
end
%}

%{
for i = 1 : numLayers - 1
    
    showFinalImage(weights{i});
   
end
%}

%{
for i = 1 : numLayers
    
    figure
    histfit(distData{i});
   
end
%}

%showFinalImage([temp{1}, max(max(weights{1}))* ones(layers(2), 5), weights{1}]);

%showFinalImage(weights{1});

%showFinalImage(abs(weights{1} - temp{1}));
%{
t = [1: (iterations - trainingSize)]';
varStd = bsxfun(@rdivide, varStd, t);
figure
plot(t, varStd);
%}

%clust = kmeans(images(:, trainingSize + 1 : dataSize)', 8);

%plotPerformance([1 : iterations]', norms, testLabels, clust, [2, 3]);

%disp(clusters);

end

function result = prepImage(I)

    I(I < 0.5) = 0;
    I(I > 0.5) = 1;
    
    result = I;
    
end
