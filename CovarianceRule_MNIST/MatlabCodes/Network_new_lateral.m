classdef Network_new_lateral < handle
    %UNTITLED Summary of this class goes here
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
        function createLateral(obj)
            
            obj.lateralConnections = cell([1, obj.numLayers - 1]);
            
            for i = 3 : obj.numLayers - 1
                
                obj.lateralConnections{i} = - normr(binornd(1, 0.2, obj.layerStruct(i + 1), obj.layerStruct(i + 1)));
                
                obj.lateralConnections{i}(1 : obj.layerStruct(i + 1) + 1 : obj.layerStruct(i + 1) * obj.layerStruct(i + 1)) = 1;
                
            end
               
            obj.ltcheck = zeros(1, obj.numLayers - 1);
            
        end
        
        function createFeedforward(obj)
            
            obj.feedforwardConnections = cell([1, obj.numLayers - 1]);
            
            for i = 1 : obj.numLayers - 1
                
                obj.feedforwardConnections{i} = binornd(1, 0.2, obj.layerStruct(i + 1), obj.layerStruct(i));
                
            end
            
            obj.ffcheck = zeros(1, obj.numLayers - 1);
            
        end
        
        
        
        
        function STDP_update_feedforward(obj, layers, iteration)
            weights = obj.feedforwardConnections;
           this_check = obj.ffcheck;

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
              
                temp = 0.001*(total_product -10*n*((mean_A')*(mean_B))');
               
                weights{r} = weights{r} + temp;
                
                if any(temp <= 0)
                    this_check(r) = this_check(r) + 1;
                end
            end
            
            obj.feedforwardConnections = weights;
            obj.ffcheck = this_check;
            
        end
        
        function STDP_update_lateral(obj, layers, iteration)
            
            weights = obj.lateralConnections;
            this_check = obj.ltcheck;
           
            parfor r = 3 : obj.numLayers - 1
                
                temp1 = layers{r+1};
                
                mean_A = mean(temp1');
                mean_B = mean(layers{r+1}');
                
                [m,n] = size(layers{r});
                
                [e,l] = size((mean_A')*(mean_B));
                total_product = zeros(l,e);
                
                for k = 1 : n
                    
                    total_temp  = layers{r+1}(:,k) * (temp1(:,k))';
                    total_product = total_product + total_temp;
                    
                end
                total_product = total_product./n;
                temp = 0.001*(total_product -((mean_A')*(mean_B))');
                weights{r} = (weights{r} - temp*0.5);
                %                 weights{r}(1 : layers{r+1} + 1 : layers{r+1} * layers{r+1}) = 1;
                if any(temp <= 0)
                    this_check(r) = this_check(r) + 1;
                end
            end
            
            obj.lateralConnections = weights;
            obj.ltcheck = this_check;
            
        end
        
        
        function saveWeights(obj)
            
            feedforwardConnections = obj.feedforwardConnections;
            %              lateralConnections = obj.lateralConnections;
            %             save(obj.weightFile, 'feedforwardConnections', 'lateralConnections');
            save(obj.weightFile, 'feedforwardConnections');
            
        end
        
    end
    
    methods
        
        function obj = Network_new_lateral(layerStruct)
            
            obj.layerStruct = layerStruct;
            [~, obj.numLayers] = size(layerStruct);
            obj.totalRounds = 0;
            
            fileName = sprintf('%d_', layerStruct);
            fileName = strcat(fileName(1 : end - 1), '.mat');
            obj.weightFile = fullfile(fileparts(which(mfilename)), '..\WeightDatabase\Temp', fileName);
            
            obj.createFeedforward();
            obj.createLateral();
            obj.saveWeights();
            
        end
        
        function layers = getOutput(obj, input,iteration,label)
            
            [m,n]=size(input);

            layers = cell([1, obj.numLayers]);
            input(input<0) = 0;
            input(input>0) = 1;
            layers{1} = input;

            layers{k + 1} = obj.feedforwardConnections{k}* layers{k};

            if k==obj.numLayers-1

                layers{k + 1} = obj.lateralConnections{k}* layers{k+1};

            end

            layers{k + 1} = zscore(layers{k + 1});

            if k<obj.numLayers-1

                layers{k + 1} = tanh(layers{k + 1});

            else

                layers{k + 1} = sigmf(layers{k + 1}, [10, 0]);

            end

        end
            
        
        
        function STDP_update(obj, layers, r)
            
            obj.totalRounds = obj.totalRounds + 1;
            obj.STDP_update_feedforward(layers, r);
            obj.STDP_update_lateral(layers);
            
        end
        
    end
    
end


