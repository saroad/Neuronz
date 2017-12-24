function Test()

global image imageFile Row Col;

fileList = folderDetails();

imageFile = fileList{randi(length(fileList))};
%imageFile = fileList{};
image = readImage();

h = [0, 1, 0; 1, -4, 1; 0, 1, 0];

disp(h);

I = imfilter(image, h);

showFinalImage(image);
showFinalImage(I);

end

