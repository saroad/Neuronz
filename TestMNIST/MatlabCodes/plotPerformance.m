function plotPerformance(x, norms, testLabels, clusters, graphs)

if ismember(1, graphs)
    figure
    plot(x, norms);
    legend(strcat('Weights ', int2str(x)));
    xlabel('Iterations');
    ylabel('Average change in weights w(t + 1) - w(t)');
    %ylim([0, 0.00005]);
end

if ~isempty(testLabels)
    
    if ismember(2, graphs) 
        figure
        silhouette(testLabels, clusters);
    end
    
    if ismember(3, graphs)
        uniqueClust = unique(clusters);
        uniqueLbl = unique(testLabels);
        numClust = numel(uniqueClust);
        numLabels = numel(uniqueLbl);

        clusInd = arrayfun(@(x) find(uniqueClust == x, 1), clusters);
        lblInd = arrayfun(@(x) find(uniqueLbl == x, 1), testLabels);
        
        y = zeros(numClust, numLabels);
        [r, ~] = size(clusters);
        
        
        for i = 1 : r
            y(clusInd(i), lblInd(i)) = y(clusInd(i), lblInd(i)) + 1;
        end
    
        %y = bsxfun(@rdivide, 100 * y ,sum(y, 2));
        
        [yr, yc] = size(y);
        
        if yr == 1 && yc > 1
            y = [y; zeros(1, yc)];
        end
        
        if yc == 1 && yr > 1
            y = [y, zeros(yr, 1)];
        end
        
        figure
        h = bar(y);
        %set(gca,'xticklabel',num2cell(regexprep(int2str(uniqueClust'), '\s', '')));
        set(gca,'xticklabel',strsplit(int2str(uniqueClust')));
        xlabel('Cluster');
        ylabel('Frequency of each label');
        legend(h, num2cell(regexprep(int2str(uniqueLbl'), '\s', '')));
    end
end