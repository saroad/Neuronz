function trainModel_yas_new(layerset, dataSize) % Using Oja's rule

trainingRatio = 0.8;
p = 0;

images = loadTrainImages();
labels = loadTrainLabels();

selected = find(labels == 0 | labels ==1 );
labels = labels(selected);
images = images(:, selected');
[~, c] = size(images);

image_batch = 5;
newDataSize = min(c,dataSize);
newIterations = fix(newDataSize/image_batch);
testImageStartId = newIterations*image_batch;
trainingIterations = 6;
test_image = [];
test_label = [];
size(images(:,testImageStartId ))
[~,d]=size(images);

for i =1:image_batch*1000
    test_image  = [test_image, (images(:,d-i ))];
    test_label = [test_label; labels(d-i)];
    
end

testLabels = [];
clusters = [];

unclassified = 0;
norms = [];

updateTime = 0.0;

net = Network_new([784, layerset, 2]);
numLayers = net.numLayers;
tempW = net.feedforwardConnections;
temp = net.feedforwardConnections;

net.iterationImages = newIterations;
for j =1 : trainingIterations
    shuffle = randperm(c);
    labels = labels(shuffle, :);
    images = images(:, shuffle);
    for r= 1:newIterations
        
        images_new = [];
        
        for k=1:image_batch
            
            image_id = image_batch*(r-1)+k;
            images_new = [images_new mat2gray(images(:, image_id))];
            
        end
        
        results = net.getOutput(images_new,r);
        
        time = tic;
        net.STDP_update(results,r);
        updateTime = updateTime + toc(time);
        for u = 1 : image_batch
            
            norms = [norms; zeros(1, numLayers - 1)];
            
            weights = net.feedforwardConnections;
            for k = 1 : numLayers - 1
                
                norms(end, k) = norm(weights{k}(:,u) - tempW{k}(:,u),'fro') / numel(weights{k}(:,u));
                tempW{k}(:,u) = weights{k}(:,u);
                
            end
            
        end
        
        
    end
end
[~,margin] = size(test_image);

for h = 1: margin/image_batch
    test_image_batch=[];
    
    for k=1:image_batch
        
        image_id = image_batch*(h-1)+k;
        
        test_image_batch = [test_image_batch mat2gray(test_image(:,image_id))];
        
    end
    
    
    results = net.getOutput(test_image_batch,newIterations+1,-1);
    for u=1:image_batch
        
        [m, i] = max(results{numLayers}(:,u));
       
        if(m >= p)
            
            testLabels = [testLabels; test_label((h-1)*image_batch+u)];
            clusters = [clusters; i];
            disp(i)
            
        else
            unclassified = unclassified + 1;
            
        end
        
    end
    
end



plotPerformance([1 : trainingIterations*newIterations*image_batch]', norms, testLabels, clusters, [1, 2, 3]);

for r = 1 : numLayers - 1
    
    disp([int2str(r),': ', int2str(net.ffcheck(r))]);
    sheet=1;
   
end

showFinalImage(abs(weights{1} - temp{1}));

layers = net.layerStruct;
r = randi(layers(3), 1, 1);
W = weights{2}(r, :);
W = vec2mat(W, 28);

figure
surf(W)
colormap(jet);

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


