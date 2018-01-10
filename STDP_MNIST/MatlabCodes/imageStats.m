function imageStats()

images = loadTrainImages();
labels = loadTrainLabels();

%individual(images, labels);
pairWise(images, labels);


end

function result = prepImage(I)

    I(I < 0.5) = 0;
    I(I > 0.5) = 1;
    
    result = I;
    
end

function individual(images, labels)

data = cell(1, 10);

c = size(images, 2);

for i = 1 : c
    
    I = prepImage(images(:, i));
    data{labels(i) + 1}(end + 1) = sum(I);
    
end

figure

for i = 1 : 10
    
    subplot(2, 5, i);
    histfit(data{i});
    title(num2str(i - 1));
    [~, m, std] = zscore(data{i});
    disp([num2str(i - 1), ': ', num2str(m), ', ', num2str(std)]);

end

end


function pairWise(images, labels)

data = cell(10, 10);

c = size(images, 2);

t = 1000;

for i = 1 : c
    images(:, i) = prepImage(images(:, i));
end

for i = 1 : t
    
    r = randi(c, 1, 1);
    
    I1 = images(:, r);
    l1 = labels(r);
    
    for j = 1 : t
        
        k = randi(c, 1, 1);
        
        I2 = images(:, k);
        l2 = labels(k);
        
        data{l1 + 1, l2 + 1}(end + 1) = sum(abs(I1 - I2));
        
        
    end
    
end 

results = zeros(10, 10);

for i = 1 : 10
    
    for j = 1 : 10
        
        results(i, j) = std(data{i, j});
        
    end
    
end

disp(results);

end