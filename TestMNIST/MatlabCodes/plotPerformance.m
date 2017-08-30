function plotPerformance(x, norms, testLabels, clusters)

figure
plot(x, norms);
legend(strcat('Weights ', int2str(x)));
xlabel('Iterations');
ylabel('Average change in weights w(t + 1) - w(t)');

if ~isempty(testLabels)
    
    figure
    silhouette(testLabels, clusters);
    
    y = ones(10, 10);
    [r, ~] = size(clusters);
    
    for i = 1 : r
        y(clusters(i), testLabels(i) + 1) = y(clusters(i), testLabels(i) + 1) + 1;
    end
    
    y = bsxfun(@rdivide, 100 * y ,sum(y, 2));
    
    figure
    h = bar(y);
    xlabel('Cluster');
    ylabel('Frequency percentage of each label in cluster (Precision for each cluster)');
    legend(h, num2cell(regexprep(int2str([0 : 9]), '\s', '')));
end