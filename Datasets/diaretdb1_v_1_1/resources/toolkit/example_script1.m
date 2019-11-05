% Here is an example script for cl_classify function
% provided with DiaRetDB1 toolkit

load traindata traindatahist
img = imread('../images/ddb1_fundusimages/image019.png');
result = cl_classify(traindatahist, img, 0.05);
result = bwareaopen(result,10);
result = imfill(result,'holes'); 
subplot(1,3,1); image(double(img)/255); 
subplot(1,3,2); image(repmat(result,[1 1 3]).*(double(img)/255));
subplot(1,3,3); imagesc(result);

