function trainModel(layerset, iterations, p1, p2) % Using Oja's rule

trainingRatio = 0.7;
p = 0.5;

images = loadTrainImages();
labels = loadTrainLabels();

images1 = loadTestImages();
labels1 = loadTestLabels();

%p1 = 2;
%p2 = 4;

selected = find(labels == p1 | labels == p2);
labels = labels(selected);
images = images(:, selected');

selected = find(labels1 == p1 | labels1 == p2);
labels1 = labels(selected);
images1 = images(:, selected');

[~, dataSize] = size(images);

shuffle = randperm(dataSize);
labels = labels(shuffle, :);
images = images(:, shuffle);

tr = size(labels, 1);

labels = [labels; labels1];
images = [images, images1];

iterations = size(labels, 1);

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

%trainingSize = floor(double(iterations) * trainingRatio);
trainingSize = tr;
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

lastLayer = 2;

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
    
    %r = randi(dataSize, 1);
    r = it;
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
        [m, i] = max(results{numLayers});
        [l, ~] = min(results{numLayers});
        res = max(res, abs(m / l));
        
        [B, I] = sort(results{numLayers},'descend');
        
        if binornd(1, 0.01, 1, 1) == 1
            
            if labels(r) == 1
                oneList = [oneList, I];
            else
                zeroList = [zeroList, I];
            end
            
        end
        
        outputList = outputList + B';
        
        if(m >= p)
            testLabels = [testLabels; labels(r)];
            clusters = [clusters; i];
        else
            unclassified = unclassified + 1;
        end
        
        tempStd = [];
        
        for i = 1 : numLayers
            
            stdList(i) = stdList(i) + std(results{i});
            tempStd = [tempStd, stdList(i)];
            
        end
        
        varStd = [varStd; tempStd];
        
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
    
    if(it <= tr) 
        net.STDP_update(results, isTraining);
    end
       
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
disp('Standard deviations:');
stdList = stdList / (iterations - trainingSize);
disp(stdList);
disp('Output Sorted:');
disp(outputList / (iterations - trainingSize));
%disp('Weights:');
%disp(weights{numLayers - 1});


layers = net.layerStruct;


c =[667, 686, 140, 382, 366, 167, 602, 180, 140, 3];

for i = 1 : 10
    
    W = weights{1}(:, c(1, i));
    m = mean(W);
    s = std(W);
    
    disp(['Mean: ', num2str(m), ', ', 'Std: ', num2str(s)]);
    disp(num2str(s / m));
    
end

stdStr = ['Layer wise std: '];
for i = 1 : numLayers
    
    stdStr = [stdStr, num2str(stdList(i)), ', '];
    
end

disp(stdStr);

r = randi(layers(2), 1, 1);
W = weights{1}(r, :);
W = vec2mat(W, 28);

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


for i = 1 : numLayers - 1
    
    showFinalImage(weights{i});
   
end


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
