trainModel(layers, dataSize) : layers - a row vector of the number of neurons in each hidden layer. 
dataSize - Number of images to be considered in training and testing. 
testingSize = . Number of images to be considered in testing. 

Eg: trainModel([1000, 100], 10000) will train a model with 3 hidden layers. First hidden layer 1000 neurons and second hidden layer 100 neurons and third hidden layer varies with the number of clusters to be in the final output.

trainModel.m and the network.m matlab files were changed according to following pattern while other main files stays the same.

1) Cluster 2 digits
	i/ Without Lateral Connections - trainModel_yas_new_2_digits and network_new
	ii/ With Lateral Connections - trainModel_yas_new_2_digits and network_new_lateral

3) Cluster 3 digits
	i/ Without Lateral Connections - trainModel_yas_new_3_digits and network_new
	ii/ With Lateral Connections - trainModel_yas_new_3_digits and network_new_lateral
	
5) Cluster all 10 digits - 
	i/ Without Lateral Connections  - trainModel_yas_new_10_digits and network_new
	ii/ With Lateral Connections - trainModel_yas_new_10_digits and network_new_lateral

