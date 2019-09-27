% EVALDIARETDB1 Evaluates the diaretdb1 fundus image database
%
% EVALDIARETDB1 Determines score values and performance measures for
% binary images calculated from diaretdb1 images. Returns evaluation results in 
% 1xnumfindings evaldata structure.  
%
% evaldata fields:
%  
%    numfindings     [1 x 1]	                 Number of findings evaluated
%    numfiles        [1 x 1]                     Number if files evaluated
%    numfmaskpix:    [1 x 1]                     Number of pixels in fundus mask
%    numgtruthpix:   [1 x numfiles]              Number of groundtruth pixels per image
%    numgtruthscore: [1 x numfiles]              score values calculated for groundtruth pixels
%    score:          [numfiles x 1]	         Unique score values
%    Tp:             [numfiles x numscorevalues] True positive images
%    Tn:             [numfiles x numscorevalues] True negative imgaes
%    Fp:             [numfiles x numscorevalues] False positive images
%    Fn:             [numfiles x numscorevalues] False negative images
%    sn:             [1 x numscorevalues]        Sensitivity
%    sp:             [1 x numscorevalues]        Spesicifity
%    eer:            [1 x numscorevalues]        Equal error rate value
%    wer01:          [1 x numscorevalues]        Weighted error (cost 0.1) 
%    wer1:           [1 x numscorevalues]        Weighted error (cost 1)
%    wer10:          [1 x numscorevalues]        Weighted error (cost 10)
%    bestresults:    [3 x 3]                     [1-sp 1-sn wer01
%                                                 1-sp 1-sn wer1 
%                                                 1-sp 1-sn wer10]
%

% See also: EVALDIARETDB1_CONFIGURE
%

clear all

evaldiaretdb1_configure;

imfiles      = textread(diaretdb1.evalfiles,'%s','delimiter','\n');
numfindings  = size(diaretdb1.evalfilepath,1);
numfiles     = size(imfiles,1);

try
 display(['Reading fundus mask file... ']);
 fmaskim  = imread([diaretdb1.fmaskpath 'fmask.tif']);
catch
 display(['Error occured when reading file... ']);
end
for j = 1:numfindings
   evaldata(j).numfindings  =  numfindings;
   evaldata(j).numfiles     =  numfiles;
   evaldata(j).numfmaskpix  =  sum(sum(fmaskim>0));
   evaldata(j).numgtruthpix = 0;
end

for j = 1:numfindings
   for i = 1:numfiles
      fprintf('\rEvaluating finding type %d and image number: %d   ',j,i);
      evalfile = deblank(imfiles{i});
      try
	 evalim = imread([diaretdb1.evalfilepath{j} evalfile]);
	 gtruthim = imread([diaretdb1.gtruthpath{j} evalfile(:,1:end-4) '.png']);
	 gtruthim = double(gtruthim);
      catch
	 display(['Error occured when reading files... ']);
      end
      if sum(sum(gtruthim)) > 0 
         gtruthim = gtruthim/252 >= diaretdb1.evalconfidence;
      end
      evaldata(j).numgtruthpix(i) = sum(sum(gtruthim >0));
      evaldata(j).numgtruthscore(i) = sum(sum(gtruthim >0))./evaldata(j).numfmaskpix;
      result = evalim > 0;
      evaldata(j).score(i,:) = sum(result(:))./evaldata(j).numfmaskpix;
   end
   scorethres = unique(evaldata(j).score);
   scorethres = [0; scorethres]; 
   for k = 1:size(scorethres(:),1);
      presence = evaldata(j).score(:) > scorethres(k);
      evaldata(j).Tp(:,k) = (presence == 1) & (evaldata(j).numgtruthpix(:) > 0);
      evaldata(j).Tn(:,k) = (presence == 0) & (evaldata(j).numgtruthpix(:) == 0);
      evaldata(j).Fp(:,k) = (presence == 1) & (evaldata(j).numgtruthpix(:) == 0);	
      evaldata(j).Fn(:,k) = (presence == 0) & (evaldata(j).numgtruthpix(:) > 0);

      evaldata(j).sn(k) = sum(evaldata(j).Tp(:,k),1)./(sum(evaldata(j).Tp(:,k),1)+sum(evaldata(j).Fn(:,k),1));	
      evaldata(j).sp(k) = sum(evaldata(j).Tn(:,k),1)./(sum(evaldata(j).Tn(:,k),1)+sum(evaldata(j).Fp(:,k),1));
      evaldata(j).eer(k)   = (1-evaldata(j).sn(k))-(1-evaldata(j).sp(k));
      evaldata(j).wer01(k) = ((1-evaldata(j).sn(k))+0.1*(1-evaldata(j).sp(k)))/(1+0.1);
      evaldata(j).wer1(k)  = ((1-evaldata(j).sn(k))+1*(1-evaldata(j).sp(k)))/(1+1);
      evaldata(j).wer10(k) = ((1-evaldata(j).sn(k))+10*(1-evaldata(j).sp(k)))/(1+10);
   end
   [bestwer01 indwer01] = min(evaldata(j).wer01);
   [bestwer1  indwer1]  = min(evaldata(j).wer1); 
   [bestwer10 indwer10] = min(evaldata(j).wer10);  
   %best results FPR FNR WER
   evaldata(j).bestresults = [...
			  1-evaldata(j).sp(indwer01) 1-evaldata(j).sn(indwer01) bestwer01; ...
			  1-evaldata(j).sp(indwer1)  1-evaldata(j).sn(indwer1) bestwer1; ...
			  1-evaldata(j).sp(indwer10) 1-evaldata(j).sn(indwer10) bestwer10; ...
                         ]; 
   fprintf('\n');
end
