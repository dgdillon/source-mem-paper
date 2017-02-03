% Author: Dan Dillon
% This script generates ERP figures for the SOURCE paper.

% Figure 1: (a) Question Hit minus Number Hit MUT (across groups) with
% waveforms extracted from representative significant electrodes, and (b)
% same thing but with Side Hit minus Number Hit. Point: there is no
% difference b/w groups but Q-N pulls on left parietal and frontal, S-N
% pulls on midline posterior.

% Figure 2: For words from the animacy task, Question Hit minus Side Hit 
% (or maybe vice versa) MUT (across groups) with waveforms from 
% representative significant electrodes. Again, smart to first make
% separate graphs in each group and document the tests run to establish no
% differences before collapsing across.

% Figure 3: For words from the mobility task, Question Hit minus Side Hit
% separately by group, then the b/w group test with waveforms from
% significant electrodes.

%% This section runs MUTs on Question - Number Hits and Side - Number Hits, separately in HC and MDD
% Needs updating, this was done before I created functions and stored them
% in the Code dir (results are fine, just that this code is messier than
% necessary).

path2results = '/Users/danieldillon/Work/Expts/SOURCE/Analysis/ERPs/'

% First load a random dataset (SM011) into eeglab to get channel locations
EEG = pop_loadset('filename',...
    '/Users/danieldillon/Work/Expts/SOURCE/Data/SM011/Analysis/ERPs_-200_to_2000/SM011_mgd_events_chan_aref_filt_itp_ar1_ICA_ar2_elist_bins_be_ar4.set')

% Figure out which chans are neighbors, max distance of 4 cm b/w neigbors
chan_hood = spatial_neighbors(EEG.chanlocs,4)

% Set up bins and time windows, iterate over them and output results
% In HC_GND and MDD_GND, bin 168 = SHit - NHit and bin 170 = QHit - NHit
bins = [168; 170];
tws = [400 800; 800 1400; 1400 2000];
groups = {'HC','MDD'};

for i=1:length(groups);
    curr_path = sprintf('%s%s%s',path2results,groups{i},'/');
    cd(curr_path);
    gnd_fname = sprintf('%s%s',groups{i},'_GND.GND');
    gnd_fname = sprintf('%s%s',curr_path,gnd_fname)
    
    load(gnd_fname,'-mat')
    for j=1:length(bins);
        for k=1:length(tws);
            dname = sprintf('%s%s%i%s%i%s%i%s',curr_path,'MUT_bin',bins(j),'_',tws(k,1),'-',tws(k,2),'_cluster_stdout.txt');
            fname = sprintf('%s%s%i%s%i%s%i%s',curr_path,'MUT_bin',bins(j),'_',tws(k,1),'-',tws(k,2),'_cluster.txt');
            img_name = sprintf('%s%s%i%s%i%s%i%s',curr_path,'MUT_bin',bins(j),'_',tws(k,1),'-',tws(k,2),'_cluster_topo');

            diary(dname);
            GND=clustGND(GND,bins(j),'time_wind',[tws(k,1) tws(k,2)],'chan_hood',...
                chan_hood,'exclude_chans',{'E128', 'E127', 'E17', 'E126', 'E125'},...
                'thresh_p',.05,'mean_wind','yes','output_file',fname,'save_GND','yes')
            save(gnd_fname,'GND','-v7.3') % Otherwise the GND won't save (!!!)
            last_test = length(GND.t_tests)
            sig_topo(GND,last_test,'units','t','title_on',1)
%             saveas(gcf,img_name,'epsc');
            print(img_name,'-dpdf');
            diary off;
        end
    end
    clear('GND')
end

%% This section runs b/w group tests on Side-Number Hits (bin 168 in HC and MDD GND)
% and Question-Number Hits (bin 170 in HC and MDD GND).
code_dir = '/Users/danieldillon/Work/Expts/Code';
cd(code_dir);
MUT_analyses_bwgs('SOURCE','/Users/danieldillon/Work/Expts/SOURCE/Analysis/ERPs/',...
4,'yes',{'E128', 'E127', 'E17', 'E126', 'E125'},'HC','MDD',[168 170],[400 800; 800 1400; 1400 2000])

%% This section runs MUTs on Question - Number Hits and Side - Number Hits, across HC and MDD
% Toggle the initial yes/no to make the GRP file combining HC and MDD.
% Because bins 168 and 170 were the first two bins added to the combined
% GRP data file, they are bins 1 and 2.
code_dir = '/Users/danieldillon/Work/Expts/Code';
cd(code_dir);
MUT_analyses_across_grps('yes','/Users/danieldillon/Work/Expts/SOURCE/Analysis/ERPs/',...
4,{'E128', 'E127', 'E17', 'E126', 'E125'},'HC','MDD',[168 170],[1 2],[400 800; 800 1400; 1400 2000])

%% This section runs MUTs on Question - Side LNL Hits (bin 181) for HC and MDD considered separately
% Both groups show big negativity over midline sites, with a leftward tilt
% in the MDD group. Narrowly missing significance in controls, lots of
% significant effects in MDD. Not expecting to see group diffs because the
% effects are in similar places and in the same direction.
code_dir = '/Users/danieldillon/Work/Expts/Code';
cd(code_dir);
MUT_analyses_wig('/Users/danieldillon/Work/Expts/SOURCE/Analysis/ERPs/',...
    4,{'E128', 'E127', 'E17', 'E126', 'E125'},{'HC','MDD'},[181],[400 800; 800 1400; 1400 2000])

%% This section runs MUTs on HC vs. MDD for Question - Side LNL Hits (bin 181).
% As expected, no group differences.
code_dir = '/Users/danieldillon/Work/Expts/Code';
cd(code_dir);
MUT_analyses_bwgs('SOURCE','/Users/danieldillon/Work/Expts/SOURCE/Analysis/ERPs/',...
4,'no','no',{'E128', 'E127', 'E17', 'E126', 'E125'},'HC','MDD',[181],[400 800; 800 1400; 1400 2000])

%% This section runs MUTs on HC plus MDD for Question - Side LNL Hits
% 181 is the bin in the HC and MDD GND files, and the across groups
% comparison is the 3rd bin to add to the HC_plus_MDD.GND file.
% Very strong effects throughout, negative difference maximal over central
% sites with a drift towards left frontal.
code_dir = '/Users/danieldillon/Work/Expts/Code';
cd(code_dir);
MUT_analyses_across_grps('no','/Users/danieldillon/Work/Expts/SOURCE/Analysis/ERPs/',...
4,{'E128', 'E127', 'E17', 'E126', 'E125'},'HC','MDD',[181],[3],[400 800; 800 1400; 1400 2000])

%% This section runs MUTs on Question - Side MI Hits (bin 180) for HC and MDD considered separately
% No sig effects in HC, robust left parietal diffs in all windows for MDD
code_dir = '/Users/danieldillon/Work/Expts/Code';
cd(code_dir);
MUT_analyses_wig('/Users/danieldillon/Work/Expts/SOURCE/Analysis/ERPs/',...
    4,{'E128', 'E127', 'E17', 'E126', 'E125'},{'HC','MDD'},[180],[400 800; 800 1400; 1400 2000])

%% This section runs MUTs on HC vs. MDD for Question - Side MI Hits (bin 180).
% Reliable group differences (MDD > HC) over left parietal in first two
% time windows. Plot this next with the groups reversed (MDD_vs_HC) so the
% differences show up positive and then you can move on to plotting waves.
code_dir = '/Users/danieldillon/Work/Expts/Code';
cd(code_dir);
MUT_analyses_bwgs('SOURCE','/Users/danieldillon/Work/Expts/SOURCE/Analysis/ERPs/',...
4,'no','no',{'E128', 'E127', 'E17', 'E126', 'E125'},'HC','MDD',[180],[400 800; 800 1400; 1400 2000])

%% This section runs MUTs on MDD vs. HC for Question - Side MI Hits (bin 180).
% Same as cell above but group order is reversed so differences show up
% positive.
code_dir = '/Users/danieldillon/Work/Expts/Code';
cd(code_dir);
MUT_analyses_bwgs('SOURCE','/Users/danieldillon/Work/Expts/SOURCE/Analysis/ERPs/',...
4,'no','no',{'E128', 'E127', 'E17', 'E126', 'E125'},'MDD','HC',[180],[400 800; 800 1400; 1400 2000])
%% MUTs on MDD vs. HC for Question - Side MI Hits (bin 180), with 2cm spacing between channels.
% No results are significant, but paper from Song et al. (2015) (Don
% Tucker's group, in J Neuro Methods) suggests why: mean distance b/w
% channels on the 128 channel cap is 2.7 cm. Let's try 3 cm next as that
% should yield significant results again if this is correct.
code_dir = '/Users/danieldillon/Work/Expts/Code';
cd(code_dir);
MUT_analyses_bwgs('SOURCE','/Users/danieldillon/Work/Expts/SOURCE/Analysis/ERPs/',...
2,'no','no',{'E128', 'E127', 'E17', 'E126', 'E125'},'MDD','HC',[180],[400 800; 800 1400; 1400 2000])

%% MUTs on MDD vs. HC for Question - Side MI Hits (bin 180), with 3cm spacing between channels.
% Significant results from 800-1400 but not 400-800, which is suboptimal
% b/c the differences b/w 400-800 are big.
code_dir = '/Users/danieldillon/Work/Expts/Code';
cd(code_dir);
MUT_analyses_bwgs('SOURCE','/Users/danieldillon/Work/Expts/SOURCE/Analysis/ERPs/',...
3,'no','no',{'E128', 'E127', 'E17', 'E126', 'E125'},'MDD','HC',[180],[400 800; 800 1400; 1400 2000])
%% MUTs on MDD vs. HC for Question - Side MI Hits (bin 180), with 5cm spacing between channels.
% Last one, just to show that 5 cm is too big. To my surprise, this gives
% significant results from 400-800 but not 800-1400, reverse of what we got
% with 3 cm. Looks like we inadvertently hit the sweet spot on the first
% try with 4 cm--sticking with that.
code_dir = '/Users/danieldillon/Work/Expts/Code';
cd(code_dir);
MUT_analyses_bwgs('SOURCE','/Users/danieldillon/Work/Expts/SOURCE/Analysis/ERPs/',...
5,'no','no',{'E128', 'E127', 'E17', 'E126', 'E125'},'MDD','HC',[180],[400 800; 800 1400; 1400 2000])