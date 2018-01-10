function trainModel_yas_new_3_digits(layerset, dataSize) % Using Oja's rule

p = 0;

images = loadTrainImages();
labels = loadTrainLabels();

selected = find(labels == 7 | labels == 1 | labels == 6);
labels = labels(selected);
images = images(:, selected');
[~, c] = size(images);

selected_1 = find( labels == 1 );
images_train_1 = images(:, selected_1');

selected_2 = find( labels == 6 );
images_train_2 = images(:, selected_2');

selected_3 = find( labels ==  7);
images_train_3 = images(:, selected_3');

[~, c_1] = size(images_train_1);
[~, c_2] = size(images_train_2);
[~, c_3] = size(images_train_3);

image_batch = 6;
full_batch = image_batch*3;
intermediateDataSize = min(c_1,c_3);
newDataSize = min(intermediateDataSize,c_2)*3;
newDataSize = min(newDataSize,dataSize);
newIterations = fix(newDataSize/full_batch);
trainingIterations = 5;

testImageStartId = newIterations*full_batch;

test_image = [];
test_label = [];
testCount = full_batch*20;

for i =1:testCount
    test_image  = [test_image, images(:,testImageStartId+i )];
    test_label = [test_label; labels(testImageStartId+i)];
end
xlswrite('lab.xlsx',test_label);
testLabels = [];
clusters = [];

unclassified = 0;
norms = [];

updateTime = 0.0;

net = Network_new_lateral([784, layerset,3]);
numLayers = net.numLayers;
tempW = net.feedforwardConnections;
%tempW = net.lateralConnections;
temp = net.feedforwardConnections;

net.iterationImages = newIterations;

for j=1:trainingIterations
    for r= 1:newIterations
        images_new_1 = [];
        images_new_2 = [];
        images_new_3 = [];
        images_new = [];
        
        
        for k=1:image_batch
            image_id = image_batch*(r-1)+k;
            images_new_1 = [images_new_1 mat2gray(images_train_1(:, image_id))];
            images_new_2 = [images_new_2 mat2gray(images_train_2(:, image_id))];
            images_new_3 = [images_new_3 mat2gray(images_train_3(:, image_id))];
        end
        images_new = [images_new images_new_1];
        images_new = [images_new images_new_2];
        
        results = net.getOutput(images_new,r);
        
        time = tic;
        net.STDP_update(results,(j-1)*newIterations+r);
        updateTime = updateTime + toc(time);
        for u = 1 : full_batch
            
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


for h = 1: margin/full_batch
    
    test_image_batch=[];
    
    for k=1:full_batch
        
        image_id = full_batch*(h-1)+k;
        test_image_batch = [test_image_batch mat2gray(test_image(:,image_id))];
        
    end
    
    [l,m]= size(test_image_batch);
    
    results = net.getOutput(test_image_batch,newIterations+1,-1);
    
    for u=1:full_batch
        
        [m, i] = max(results{numLayers}(:,u));
        
        if(m >= p)
          
            testLabels = [testLabels; test_label(((h-1)*full_batch)+u)];
           
            clusters = [clusters; i];
            
        else
            
            unclassified = unclassified + 1;
            
        end
    end
end
plotPerformance([1 : newIterations*full_batch*trainingIterations]', norms, testLabels, clusters, [1, 2, 3]);

for r = 1 : numLayers - 1
    
    disp([int2str(r),': ', int2str(net.ffcheck(r))]);
    
end




