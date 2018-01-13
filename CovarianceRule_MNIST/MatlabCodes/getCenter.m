function result = getCenter(images) 
[~,n]=size(images);
images_final = [];
for k = 1:n
images_new = zeros(400,1);
temp = images(:,k);
count = 0;
for i =1:28
    if i>=5 && i<=24
    for j=1:28
        if j>=5 && j<=24
            
        count = count+1;
        images_new(count,:) = temp(i*j,:);
        end
    end
    end
end

images_final = [images_final, images_new];
end
result = images_final;