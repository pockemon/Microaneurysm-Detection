% EVALDIARETDB1_CONFIGURE Configures the paths and files for EVALDIARETDB1
%
% See also: EVALDIARETDB1
%

% Fundus mask path
diaretdb1.fmaskpath = '../images/ddb1_fundusmask/';

% Ground truth paths. 
diaretdb1.gtruthpath =  { 
'../images/ddb1_groundtruth/hardexudates/'; ...
'../images/ddb1_groundtruth/softexudates/';...
'../images/ddb1_groundtruth/redsmalldots/'; ...
'../images/ddb1_groundtruth/hemorrhages/'
};

% GT_conf
diaretdb1.evalconfidence = 0.75;

% Evaluation files
%diaretdb1.evalfiles = '/home/kauppi/work/doctoral_studies/resources/database/diaretdb1/ddb1_v1/ddb1_imagestructure/resources/traindatasets/trainevalfiles_example.txt';
diaretdb1.evalfiles = '../testdatasets/testevalfiles_example.txt';

% The evaluation script assumes that every finding type has own set of
% images which share the same filenames, but which are in different
% directories. The number of evaluated finding types is decided using
% the number of evalfilepaths defined.

%e.g.
%diaretdb1.evalfilepath = {
%'/colorlocus/Hard_exudates/';
%'/colorlocus/Soft_exudates/';
%'/colorlocus/Red_small_dots/';
%'/colorlocus/Hemorrhages/';
%};

%example evaluation results with hard exudates
diaretdb1.evalfilepath = {
'../example_evalresults/'; ...
};


