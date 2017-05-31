function plotPerformance(x, norms, testLabels, clusters)

%subplot(size, size, index);
figure
plot(x, norms);
%legend('W_input_1', 'W_1_2', 'W_2_output');
legend(strcat('Weights ', int2str(x)));

if ~isempty(testLabels)
    
    figure
    silhouette(testLabels, clusters);
    
    y = ones(10, 10);
    [r, ~] = size(clusters);
    
    for i = 1 : r
        y(clusters(i), testLabels(i) + 1) = y(clusters(i), testLabels(i) + 1) + 1;
    end
    
    y = bsxfun(@rdivide, 100 * y ,sum(y));
    
    figure
    h = bar(y);
    xlabel('Cluster');
    ylabel('Frequency percentage of each label out of total label occurences');
    legend(h, num2cell(regexprep(int2str([0 : 9]), '\s', '')));
end