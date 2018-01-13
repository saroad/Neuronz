function trainModel_yas_new_final(layerset, dataSize) % Using covariance rule

p = 0;

images = loadTrainImages();
labels = loadTrainLabels();

selected = find(labels == 8  | labels == 5 );
labels = labels(selected);
images = images(:, selected');
[~, c] = size(images);

selected_1 = find( labels == 8 );
labels_train_1 = labels(selected_1);
images_train_1 = images(:, selected_1');

selected_2 = find( labels == 5 );
labels_train_2 = labels(selected_2);
images_train_2 = images(:, selected_2');

[~, c_1] = size(images_train_1);
[~, c_2] = size(images_train_2);

half_image_batch = 5;%half
image_batch = 2*half_image_batch;
newDataSize = min(c_1,c_2)*2;
newDataSize = min(newDataSize,dataSize);
newIterations = fix(newDataSize/image_batch);
trainingIterations = 1;

testImageStartId = newIterations*image_batch/2;

test_image = [];
test_label = [];
testCount = image_batch*200;
[~,size_train_1] = size( images_train_1);
[~,size_train_2] = size( images_train_2);
testMin = min(size_train_1*2,size_train_1*2);
testCount = min(testCount,testMin);
testCount
for i =1:testCount/2
%     
%     test_image  = [test_image, images_train_1(:,testImageStartId+i )];
%     test_image  = [test_image, images_train_2(:,testImageStartId+i )];
%     test_label = [test_label; labels_train_1(testImageStartId+i)];
%     test_label = [test_label; labels_train_2(testImageStartId+i)];
    
    test_image  = [test_image, images_train_1(:,size_train_1-i )];
    test_image  = [test_image, images_train_2(:,size_train_2-i )];
    test_label = [test_label; labels_train_1(size_train_1-i)];
    test_label = [test_label; labels_train_2(size_train_2-i)];
end
[~, d] = size(test_image);

shuffle_t = randperm(d);
test_label = test_label(shuffle_t, :);
test_image = test_image(:, shuffle_t);
xlswrite('test_label.xlsx',test_label);
testLabels = [];
clusters = [];

unclassified = 0;
norms = [];

updateTime = 0.0;

net = Network_new([784, layerset,2]);
numLayers = net.numLayers;
tempW = net.feedforwardConnections;
%tempW = net.lateralConnections;
temp = net.feedforwardConnections;
net.iterationImages = newIterations;

for j=1:trainingIterations
    for r= 1:newIterations
        images_new_1 = [];
        images_new_2 = [];
        images_new = [];
        
        
        for k=1:half_image_batch
            
            image_id = half_image_batch*(r-1)+k;
            images_new_1 = [images_new_1 mat2gray(images_train_1(:, image_id))];
            images_new_2 = [images_new_2 mat2gray(images_train_2(:, image_id))];
            
        end
        
        images_new = [images_new images_new_1];
        images_new = [images_new images_new_2];
   
        results = net.getOutput(images_new,r);
        
        time = tic;
        net.STDP_update(results,r);
        updateTime = updateTime + toc(time);
        
        for u = 1 : image_batch
            
            norms = [norms; zeros(1, numLayers - 1)];
            weights = net.feedforwardConnections;
%             if r==1  
%             for b = 1 : 50
%                     
%                 xlswrite('weights_1.xlsx',weights{1}(:,b));
%                 xlswrite('weights_2.xlsx',weights{2}(:,b));
%                 xlswrite('weights_3.xlsx',weights{3}(:,b));
%                 
%                
%             end
%             end
%             
%              if r==1  
%             for b = 1 : 50
%                     
%                 xlswrite('weights_1_1ast.xlsx',weights{1}(:,b));
%                 xlswrite('weights_2_1ast.xlsx',weights{2}(:,b));
%                 xlswrite('weights_3_1ast.xlsx',weights{3}(:,b));
%                 
%                
%             end
%             end
            
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
    
    [l,m]= size(test_image_batch)
    
    results = net.getOutput(test_image_batch,newIterations+1,-1);

    for u=1:image_batch
     
        [m, i] = max(results{numLayers}(:,u));
        
        if(m >= p)
            %                 image_id = image_batch*(r-1)+u;
            testLabels = [testLabels; test_label(((h-1)*image_batch)+u)];
            %               testLabels = [testLabels; labels(r)];
            clusters = [clusters; i];
                   else
            unclassified = unclassified + 1;
        end
    end
end

plotPerformance([1 : newIterations*image_batch*trainingIterations]', norms, testLabels, clusters, [1, 2, 3]);

% disp(['Unclassified: ', int2str(unclassified), ' out of ', int2str(dataSize - trainingSize)]);
%
% disp(['Average STDP update time = ', num2str(updateTime / iterations/image_batch)]);

for r = 1 : numLayers - 1
    
    disp([int2str(r),': ', int2str(net.ffcheck(r))]);
    sheet=1;
    %     xlswrite('weight_2.xlsx','new layer',sheet);
    %     xlswrite('weight_2.xlsx',weights{r},sheet);
    
end


% for i = 1 : numLayers - 1
%
%     showFinalImage(weights{i});
%
% end


%showFinalImage([temp{1}, max(max(weights{1}))* ones(layers(2), 5), weights{1}]);

%showFinalImage(weights{1});

% showFinalImage(abs(weights{1} - temp{1}));

%clust = kmeans(images(:, trainingSize + 1 : dataSize)', 8);

%plotPerformance([1 : iterations]', norms, testLabels, clust, [2, 3]);

%disp(clusters);
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
r_1 = randi(layers(2), 1, 1);
W_1 = weights{1}(r_1, :);
W_1 = vec2mat(W_1, 28);

figure
surf(W_1)
colormap(jet);

figure
for i = 1 : 28
    
    subplot(4, 7, i);
    plot(W_1(i, :));
    title(num2str(i));
    
end

for i = 1 : 28
    
    subplot(4, 7, i);
    plot(W_1(:, i));
    title(num2str(i));
    
end







