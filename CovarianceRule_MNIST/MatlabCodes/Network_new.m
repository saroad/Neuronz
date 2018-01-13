classdef Network_new < handle
    %
    %   Detailed explanation goes here
    
    properties (GetAccess = private)
        
        weightFile;
        
    end
    
    properties (SetAccess = public)
        
        layerStruct;
        numLayers;
        totalRounds;
        ffcheck;
        ltcheck;
        fbcheck;
        iterationImages;
        
        feedforwardConnections;
        lateralConnections;
        feedbackConnections;
        
    end
    
    properties
        
        
    end
    
    methods (Access = private)
        
        function createFeedforward(obj) % create feedforward connections using binornd
            
            obj.feedforwardConnections = cell([1, obj.numLayers - 1]);
            
            for i = 1 : obj.numLayers - 1
                
                obj.feedforwardConnections{i} = binornd(1, 0.2, obj.layerStruct(i + 1), obj.layerStruct(i));
                
            end
            
            obj.ffcheck = zeros(1, obj.numLayers - 1);
            
        end
        
        function STDP_update_feedforward(obj, layers, iteration) % STDP feedforward update
            
            weights = obj.feedforwardConnections;
            this_check = obj.ffcheck;
            this_totalRounds = obj.iterationImages;
            %
            parfor r = 1 : obj.numLayers - 1
                
                temp1 = layers{r} .^2;
                
                mean_A = mean(temp1');
                mean_B = mean(layers{r+1}');
                
                [m,n] = size(layers{r});
                
                [e,l] = size((mean_A')*(mean_B));
                total_product = zeros(l,e);
                %                 total_product = [];
                for k = 1 : n
                    
                    total_temp  = layers{r+1}(:,k) * (temp1(:,k))';
                    total_product = total_product + total_temp;
                    
                end
                
                total_product = total_product./n;
                
                temp = 0.001*(total_product -5*n*((mean_A')*(mean_B))');
                if(iteration == this_totalRounds && r==1)
                    xlswrite('temp_1_layer_final_iteration.xlsx',temp);
                    xlswrite('weight_1_tot',weights{r}(:,1:50));
                end
                if(iteration == this_totalRounds && r==2)
                    xlswrite('temp_2_layer_final_iteration.xlsx',temp);
                    xlswrite('weight_2_tot.xlsx',weights{r}(:,1:50));
                end
                if(iteration == this_totalRounds && r==3)
                    xlswrite('temp_3_layer_final_iteration.xlsx',temp);
                    xlswrite('weight_3_tot.xlsx',weights{r});
                end
                if(iteration == 1 && r==1)
                    xlswrite('temp_1_layer_first_iteration.xlsx',temp);
                    xlswrite('weight_1_tot',weights{r}(:,1:50));
                end
                if(iteration == 1 && r==2)
                    xlswrite('temp_2_layer_first_iteration.xlsx',temp);
                    xlswrite('weight_2_tot.xlsx',weights{r}(:,1:50));
                end
                if(iteration == 1 && r==3)
                    xlswrite('temp_3_layer_first_iteration.xlsx',temp);
                    xlswrite('weight_3_tot.xlsx',weights{r});
                end
                
                weights{r} = weights{r} + temp;
                if(iteration == 1 && r==1)
                    
                    xlswrite('weight_1_iteration_gap_1.xlsx',weights{r}(:,1:100));
                    
                end
                if(iteration == 1 && r==2)
                    
                    xlswrite('weight_1_iteration_gap_2.xlsx',weights{r}(:,1:100));
                    
                end
                if(iteration == 1 && r==3)
                    
                    xlswrite('weight_1_iteration_gap_3.xlsx',weights{r}(:,1:100));
                    
                end
                if(iteration == this_totalRounds && r==1)
                    
                    xlswrite('weight_final_iteration_gap_1.xlsx',weights{r}(:,1:100));
                    
                end
                if(iteration == this_totalRounds && r==2)
                    
                    xlswrite('weight_final_iteration_gap_2.xlsx',weights{r}(:,1:100));
                end
                if(iteration == this_totalRounds && r==3)
                    
                    xlswrite('weight_final_iteration_gap_3.xlsx',weights{r}(:,1:100));
                end
                
                if any(temp <= 0)
                    this_check(r) = this_check(r) + 1;
                end
            end
            
            obj.feedforwardConnections = weights;
            obj.ffcheck = this_check;
            
        end
        
        function saveWeights(obj)
            
            feedforwardConnections = obj.feedforwardConnections;
            save(obj.weightFile, 'feedforwardConnections');
            
        end
        
    end
    
    methods
        
        function obj = Network_new(layerStruct)
            
            obj.layerStruct = layerStruct;
            [~, obj.numLayers] = size(layerStruct);
            obj.totalRounds = 0;
            
            fileName = sprintf('%d_', layerStruct);
            fileName = strcat(fileName(1 : end - 1), '.mat');
            obj.weightFile = fullfile(fileparts(which(mfilename)), '..\WeightDatabase\Temp', fileName);
            
            obj.createFeedforward();
            
            obj.saveWeights();
            
        end
        
        function layers = getOutput(obj, input,iteration,label)
            
            this_totalRounds = obj.iterationImages;
            
            [m,n]=size(input);
            
            layers = cell([1, obj.numLayers]);
            input(input<0) = 0;
            input(input>0) = 1;
            
            layers{1} = input;
            
            sheet =1;
            
            for k = 1 : obj.numLayers - 1
                
                
                if k<obj.numLayers
                    layers{k + 1} = obj.feedforwardConnections{k}* layers{k};
                end
                
                layers{k + 1} = zscore(layers{k + 1});
                if k<obj.numLayers-1
                    layers{k + 1} = tanh(layers{k + 1});
                else
                    layers{k + 1} = sigmf(layers{k + 1}, [10, 0]);
                end
                
            end
            
            if(iteration>this_totalRounds)
                
                xlswrite('final_1_5.xlsx',layers{1});
                xlswrite('final_2_5.xlsx',layers{2});
                xlswrite('final_3_5.xlsx',layers{3});
                xlswrite('final_4_9.xlsx',layers{4});
            end
            
        end
        
        function STDP_update(obj, layers, r)
            
            obj.totalRounds = obj.totalRounds + 1;
            obj.STDP_update_feedforward(layers, r);
            
        end
        
    end
    
end

