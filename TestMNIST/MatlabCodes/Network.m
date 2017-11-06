classdef Network < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = private)
    
        weightFile;
        
        t = 0.001;
        a1 = 10.0;
        a2 = 10.0;
        e = 0.0001;
        b1 = [0.001, 0.001, 0.025, 0.005];
        b2 = [0.0, 0.0, 0.0, 0.0];
        
    end
    
    properties (SetAccess = public)
        
        layerStruct;
        numLayers;
        totalRounds;
        ffcheck;
        ltcheck;
        fbcheck;
        
        feedforwardConnections;
        lateralConnections;
        feedbackConnections;
        
    end
    
    properties
        
        
    end
    
    methods (Access = private)
        
        function createFeedforward(obj)
            
            if exist(obj.weightFile, 'file') == 2 && ismember('feedforwardConnections', who('-file', obj.weightFile))
                load(obj.weightFile, 'feedforwardConnections');
                obj.feedforwardConnections = feedforwardConnections;
            else
                            
                obj.feedforwardConnections = cell([1, obj.numLayers - 1]);

                for i = 1 : obj.numLayers - 1

                    %obj.feedforwardConnections{i} = rand(layerStruct(i + 1),layerStruct(i));
                    obj.feedforwardConnections{i} = normr(binornd(1, 0.2, obj.layerStruct(i + 1), obj.layerStruct(i)));
                    %obj.feedforwardConnections{i} = binornd(1, 0.2, obj.layerStruct(i + 1), obj.layerStruct(i)) / obj.layerStruct(i);

                end
                
            end
            
            obj.ffcheck = zeros(1, obj.numLayers - 1);
            
        end
        
        function createLateral(obj)
            
            if exist(obj.weightFile, 'file') == 2  && ismember('lateralConnections', who('-file', obj.weightFile))
                load(obj.weightFile, 'lateralConnections');
                obj.lateralConnections = lateralConnections;
            else
            
                obj.lateralConnections = cell([1, obj.numLayers - 1]);

                for i = 1 : obj.numLayers - 1

                    %obj.lateralConnections{i} = rand(layerStruct(i + 1),layerStruct(i + 1));
                    %obj.lateralConnections{i} = - normr(binornd(0.1, 0.2, obj.layerStruct(i + 1), obj.layerStruct(i + 1)));
                    
                    obj.lateralConnections{i} = - normr(ones(obj.layerStruct(i + 1), obj.layerStruct(i + 1)));

                    obj.lateralConnections{i}(1 : obj.layerStruct(i + 1) + 1 : obj.layerStruct(i + 1) * obj.layerStruct(i + 1)) = 1;

                end
                
            end
            
            obj.ltcheck = zeros(1, obj.numLayers - 1);
            
        end
        
        function createFeedback(obj)
        end
        
        function STDP_update_feedforward(obj, layers)
            
            this_a = obj.a1;
            this_t = obj.t;
            this_b = obj.b1;
            this_check = obj.ffcheck;
            weights = obj.feedforwardConnections;

            parfor r = 1 : obj.numLayers - 1
                
                x = layers{r} .^ 2;
                y = layers{r + 1};

                %temp = layers{r + 1} * layers{r}' - this_b(r) * weights{r} - this_a * bsxfun(@times, weights{r}, layers{r + 1} .^2);
                temp = (y * x') .* sigmf(weights{r}, [5, mean(weights{r}(:))]) - weights{r} * mean(layers{r + 1}); %bsxfun(@times, weights{r}, layers{r + 1} .^2);
                weights{r} = weights{r} + this_t * temp;
                weights{r} = normr(weights{r});
                
                if any(temp < 0)
                    this_check(r) = this_check(r) + 1;
                end
                

            end

            obj.feedforwardConnections = weights;
            obj.ffcheck = this_check;
  
        end
        
        
        function STDP_update_lateral(obj, layers)
            
            this_a = obj.a2;
            this_t = obj.t;
            this_b = obj.b2;
            this_e = obj.e;
            this_layerStruct = obj.layerStruct;
            this_check = obj.ltcheck;
            weights = obj.lateralConnections;

            parfor r = 1 : obj.numLayers - 1

                temp = layers{r + 1} * layers{r + 1}' - this_b(r) * weights{r} - this_a * bsxfun(@times, weights{r}, layers{r + 1} .^2);
                weights{r} = weights{r} - this_e * temp;
                
                weights{r}(1 : this_layerStruct(r + 1) + 1 : this_layerStruct(r + 1) * this_layerStruct(r + 1)) = 1;
                
                if any(temp < 0)
                    this_check(r) = this_check(r) + 1;
                end
                

            end

            obj.lateralConnections = weights;
            obj.ltcheck = this_check;
  
        end
        
        
        function weightBlackout(obj)
            
            r = randi(10 * (obj.numLayers - 1), 1);
            if r >= obj.numLayers
                return;
            end
            
            i = randi(obj.layerStruct(r), 1);
            c = binornd(1, 0.5, obj.layerStruct(r + 1), 1);
            %c = zeros(obj.layerStruct(r + 1), 1);
            obj.feedforwardConnections{r}(:, i) = obj.feedforwardConnections{r}(:, i) .* c; 
            
            
        end
            
            
        
        function result = scale(obj, input)
            
            result = input / max(input);
            result = max(result, 0);
            
        end
        
        function result = spike(obj, input)
            
            result = zscore(input);
            result = sigmf(result, [1, 0]);
            
        end
        
        
        function saveWeights(obj)
            
            feedforwardConnections = obj.feedforwardConnections;
            lateralConnections = obj.lateralConnections;
            save(obj.weightFile, 'feedforwardConnections', 'lateralConnections');
            
        end
        
        
    end
    
    methods
        
        function obj = Network(layerStruct)
            
            obj.layerStruct = layerStruct;
            [~, obj.numLayers] = size(layerStruct);
            obj.totalRounds = 0;          
            
            fileName = sprintf('%d_', layerStruct);
            fileName = strcat(fileName(1 : end - 1), '.mat');
            obj.weightFile = fullfile(fileparts(which(mfilename)), '..\WeightDatabase\Temp', fileName);
            
            obj.createFeedforward();
            obj.createLateral();
         
            %obj.saveWeights();
            
        end
        
        function layers = getOutput(obj, input)
            
            layers = cell([1, obj.numLayers]);
            layers{1} = normc(input);
            %layers{1} = obj.scale(input);
            
            for k = 1 : obj.numLayers - 1
        
                layers{k + 1} = obj.feedforwardConnections{k} * layers{k};
                %layers{k + 1} = obj.lateralConnections{k} * layers{k + 1};
                
                %layers{k + 1} = mat2gray(layers{k + 1});
                %layers{k + 1} = normc(layers{k + 1});
                layers{k + 1} = obj.spike(layers{k + 1});
                %layers{k + 1} = layers{k + 1} / norm(layers{k + 1}, 2.0);
                %layers{k + 1} = obj.scale(layers{k + 1});
                %layers{k + 1} = sigmf(layers{k + 1}, [3, 0.5]);

            end
            
        end
        
        function STDP_update(obj, layers, isTraining)
            
            %layers{obj.numLayers} = layers{obj.numLayers} .* S; 
            
            if isTraining == 0 
                %obj.weightBlackout();
            end
                       
            obj.totalRounds = obj.totalRounds + 1;
            
            obj.STDP_update_feedforward(layers);
            %obj.STDP_update_lateral(layers);
            
        end
        
    end
    
end

