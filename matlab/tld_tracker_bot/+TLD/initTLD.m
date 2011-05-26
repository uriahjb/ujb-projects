% Copyright 2011 Zdenek Kalal
%
% This file is part of TLD.
% 
% TLD is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% TLD is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with TLD.  If not, see <http://www.gnu.org/licenses/>.


% This version of the TLD run_TLD.m code was edited by: Uriah Baalke
%   it initializes the TLD frame and pulls data from a wireless 
%   camera

function [tld, opt] = initTLD(IP)

    addpath(genpath('~/TLD/OpenTLD'))    

    % A hack -U
    imwrite(imread(IP), ['+TLD/_bot/' num2str(1,'%05d') '.png']);

    addpath(genpath('.')); init_workspace; 
    opt.source          = struct('tcp_stream',0,'input','+TLD/_bot/'); % camera/directory with, directory_name, initial_bounding_box (if empty, it will be selected by the user)
    opt.output          = '+TLD/_output/'; mkdir(opt.output); % output directory that will contain bounding boxes + confidence

    min_win             = 10; % minimal size of the object's bounding box in the scanning grid, it may significantly influence speed of TLD, set it to minimal size of the object
    patchsize           = [15 15]; % size of normalized patch in the object detector, larger sizes increase discriminability, must be square
    fliplr              = 0; % if set to one, the model automatically learns mirrored versions of the object
    maxbbox             = 1; % fraction of evaluated bounding boxes in every frame, maxbox = 0 means detector is truned off, if you don't care about speed set it to 1
    update_detector     = 1; % online learning on/off, of 0 detector is trained only in the first frame and then remains fixed
    opt.plot            = struct('pex',0,'nex',0,'dt',1,'confidence',1,'target',0,'replace',0,'drawoutput',3,'draw',0,'pts',1,'help', 0,'patch_rescale',1,'save',0); 

    % Do-not-change -----------------------------------------------------------

    opt.model           = struct('min_win',min_win,'patchsize',patchsize,'fliplr',fliplr,'ncc_thesame',0.95,'valid',0.5,'num_trees',10,'num_features',13,'thr_fern',0.5,'thr_nn',0.65,'thr_nn_valid',0.7);
    opt.p_par_init      = struct('num_closest',10,'num_warps',20,'noise',5,'angle',20,'shift',0.02,'scale',0.02); % synthesis of positive examples during initialization
    opt.p_par_update    = struct('num_closest',10,'num_warps',10,'noise',5,'angle',10,'shift',0.02,'scale',0.02); % synthesis of positive examples during update
    opt.n_par           = struct('overlap',0.2,'num_patches',100); % negative examples initialization/update
    opt.tracker         = struct('occlusion',10);
    opt.control         = struct('maxbbox',maxbbox,'update_detector',update_detector,'drop_img',1,'repeat',1);



    global tld; % holds results and temporal variables ... bad form, but i'll deal -U

    % INITIALIZATION ----------------------------------------------------------

    opt.source = tldInitSource(opt.source); % select data source, camera/directory

    figure(2); set(2,'KeyPressFcn', @handleKey); % open figure for display of results
    finish = 0; function handleKey(~,~), finish = 1; end % by pressing any key, the process will exit

    while 1
        source = tldInitFirstFrame(tld,opt.source,opt.model.min_win); % get initial bounding box, return 'empty' if bounding box is too small
        if ~isempty(source), opt.source = source; break; end % check size
    end

    tld = tldInit(opt,[]); % train initial detector and initialize the 'tld' structure
    tld = tldDisplay(0,tld); % initialize display

    % Run TLD -----------------------------------------------------------------
    %profile on;
    %[bb,conf] = tldBot(opt);
    %profile off;
    %profile viewer;

    % Save results ------------------------------------------------------------
    %dlmwrite([opt.output '/tld.txt'],[bb; conf]');
    %disp('Results saved to ./_output.');
end