% Author: Dan Dillon
% This script generates ERP figures for the SOURCE paper.

%% Start eeglab from the correct directory
code_dir = '/Users/danieldillon/Work/Expts/Code'
cd(code_dir)
eeglab

%% Run this section to generate (a) waveforms for Question, Side, and Number Hits across HC and MDD.
% Channels are F3 (24), F4 (124), P1 (60), P2 (85), and Oz (75).
% Save as /Users/danieldillon/Work/Expts/SOURCE/Analysis/ERPs/MDD_plus_HC/AllSubs_QSNHits_waves.pdf
out_folder = '/Users/danieldillon/Work/Expts/SOURCE/Analysis/ERPs/HC_plus_MDD/'

ERP = pop_loaderp( 'filename', 'All_GrandAvg.erp', 'filepath', '/Users/danieldillon/Work/Expts/SOURCE/Analysis/ERPs/MDD_plus_HC/' );

ERP = pop_ploterps( ERP,  51:2:55, [ 24 124 60 85 75] , 'AutoYlim', 'on', 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 3 2],...
 'ChLabel', 'on', 'FontSizeChan',  10, 'FontSizeLeg',  12, 'FontSizeTicks',  10, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' , 'b-' },...
 'LineWidth',  1, 'Maximize', 'on', 'Position', [ 103.667 29.6667 106.833 31.9167], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0,...
 'xscale', [ -200.0 1999.0   -100 0:400:1600 ], 'YDir', 'normal' );

% Save PDF
ERP = pop_exporterplabfigure(ERP, 'Filepath', out_folder, 'Format', 'pdf', 'Resolution',300, 'SaveMode', 'auto', 'Tag', {'ERP_figure'});
old_fname = ERP.erpname
oldPDF = sprintf('%s/ %s .pdf', out_folder, old_fname);
newPDF = sprintf('%s/%s.pdf', out_folder, 'AllSubs_QSNHits_waves');
movefile(oldPDF,newPDF,'f'); % Hack but PDF exports with irritating spaces around the erpname and I haven't figured out a better way to remove them.

%% This section runs MUTs on Question - Number Hits and Side - Number Hits, separately in HC and MDD
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

%% This section runs b/w group tests on Question-Number Hits and Side-Number Hits
% Obviously it is not ready.

%% This section runs MUTs on Question - Number Hits and Side - Number Hits, across HC and MDD
% May need a tweak, crashed when I tried to run it.

out_folder = '/Users/danieldillon/Work/Expts/SOURCE/Analysis/ERPs/HC_plus_MDD/'
cd(out_folder)
load('HC_plus_MDD.GRP','-mat')

% Average the bins across the two groups
% In HC_GND and MDD_GND, bin 168 = SHit - NHit and bin 170 = QHit - NHit
bins = [168 170]

for i=1:length(bins)
    GRP=bin_opGRP(GRP,'(A+B)/n','controls',bins(i),'MDD',bins(i))
end

% Compute one-sample t-tests using MUT

% First load a dataset into eeglab to get the channel locations (use SM011)
EEG = pop_loadset('filename',...
    '/Users/danieldillon/Work/Expts/SOURCE/Data/SM011/Analysis/ERPs_-200_to_2000/SM011_mgd_events_chan_aref_filt_itp_ar1_ICA_ar2_elist_bins_be_ar4.set')

% Figure out which chans are neighbors, max distance of 4 cm b/w neigbors
chan_hood = spatial_neighbors(EEG.chanlocs,4)

% Set up bins and time windows, iterate over them and output results
bins = [1 2]; % Bin 1 = SHit - NHit, Bin 2 = QHit - NHit
tws = [400 800; 800 1400; 1400 2000];

cd(out_folder);
grp_fname = sprintf('%s%s',out_folder,'HC_plus_MDD.GND');

for i=1:length(bins);
    for j=1:length(tws);
        dname = sprintf('%s%s%i%s%i%s%i%s',out_folder,'MUT_bin',bins(i),'_',tws(j,1),'-',tws(j,2),'HC-plus-MDD_cluster_stdout.txt');
        fname = sprintf('%s%s%i%s%i%s%i%s',out_folder,'MUT_bin',bins(i),'_',tws(j,1),'-',tws(j,2),'HC-plus-MDD_cluster.txt');
        img_name = sprintf('%s%s%i%s%i%s%i%s',out_folder,'MUT_bin',bins(i),'_',tws(j,1),'-',tws(j,2),'HC-plus-MDD_cluster_topo');

        diary(dname);
        GRP=clustGRP(GRP,bins(i),'time_wind',[tws(j,1) tws(j,2)],'chan_hood',...
            chan_hood,'exclude_chans',{'E128', 'E127', 'E17', 'E126', 'E125'},...
            'thresh_p',.05,'mean_wind','yes','output_file',fname,'save_GRP','yes')
        save(grp_fname,'GRP','-v7.3')
        last_test = length(GRP.t_tests)
        sig_topo(GRP,last_test,'units','t','title_on',1)
%             saveas(gcf,img_name,'epsc');
        print(img_name,'-dpdf');
        diary off;
    end
end