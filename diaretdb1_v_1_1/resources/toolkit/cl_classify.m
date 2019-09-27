%resultim = CL_CLASSIFY(modelhist, testimg, confidence) Classifies image color
%data using M x N x 1 color histogram modelled from training data into
%binary image, where pixel either belongs to the class or not.
%
%Parameters: 
% modelhist 	intensity normalized red-green histogram produced from training data
% testimg	RGB image   
% confidence	Use a 'trash class' based on training data   density
%	        quantile(1-confidence). Range [0, 1], If a sample goes to the trash
%		class: class label = 0
%
% References: 
% [1] K. Schwerdt and J. L. Crowley, Robust Face Tracking
% using color, Proc. of 4th IEEE Int. Conf. on Automatic Face 
% and Gesture Recognition, 2000.
% [2] M.J. Swain and D.H. Ballard, Indexing via color histogram,
% Proc. of 3rd Int. Conf. on Computer Vision, 1990 
% [3] A. Hadid A and M. Pietikäinen and B. Martinkauppi B,
% Color-Based Face Detection Using Skin Locus Model and
% Hierarchical Filtering, Proc. 16th Int. Conf. on Pattern Recognition,
% 2002
%
% Author(s): Tomi Kauppi <tomi.kauppi@lut.fi

function resultim = cl_classify(modelhist,testimg, confidence)

if nargin < 3
	txt = textread('readme.txt','%s', 'delimiter', '\n', 'whitespace','');
	for i = 1:size(txt,1)
		fprintf('%s\n', txt{i});
	end
else

imsize  = size(testimg);
testimg = double(testimg);
Ptest   = reshape(testimg, [imsize(1)*imsize(2) 3]);

numfindings = size(modelhist,3);
histsize    = size(modelhist);
imghist     = zeros([histsize(1) histsize(2)]); 
%fmaskim    = traindata.fmaskim;
resultim    = zeros([imsize(1) imsize(2) numfindings]);
confidence  = 1-confidence;

%%% Color(Skin) locus Classification
display(['Classifying image using Color(Skin) locus'])
%Normalize r+g+b=1
ind = find(sum(Ptest,2) == 0);
foo = Ptest;
foo(ind,:) = 1;
Ptest_norm = Ptest./repmat(sum(foo,2),[1 3]);
i_r = zeros([imsize(1)*imsize(2) 1]);
i_g = zeros([imsize(1)*imsize(2) 1]);

%%Image histogram   
for k = 1:size(Ptest,1)
   i_r(k) = floor(Ptest_norm(k,1)*(histsize(1)-1))+1;
   i_g(k) = floor(Ptest_norm(k,2)*(histsize(2)-1))+1;
   imghist(i_r(k), i_g(k)) = imghist(i_r(k), i_g(k)) + 1;
end
imghist(1,1) = 0;

%Histogram ratio + backprojection
result = zeros([imsize(1)*imsize(2) 1]);
for l = 1:numfindings
       for x = 1:size(modelhist(:,:,l),2)
          for y = 1:size(modelhist(:,:,l),1)
             if imghist(y,x) == 0
                R(y,x,l) = 0;
             else
                R(y,x,l) = modelhist(y,x,l)/imghist(y,x);
           end
       end
   end

   modelhist_norm = modelhist(:,:,l)./sum(sum(modelhist(:,:,l)));
   R_norm(:,:,l) = R(:,:,l)./sum(sum(R(:,:,l)));

   for ind = 1:size(Ptest,1)
      result(ind) = R_norm(i_r(ind), i_g(ind),l);
   end

   conf = gmmb_frac2lhood({sort(modelhist_norm(modelhist_norm>0))},confidence);
   resultim(:,:,l) = reshape((result >= conf),[imsize(1) imsize(2)]);
end
end
