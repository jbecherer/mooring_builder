%% this files shows examples on how to use the different routines of this package

path2ganges = '/home/johannes/';

addpath(genpath('./sw_tbx/'));
addpath(genpath('./database/'));
addpath(genpath('./processing/'));
addpath(genpath('./plotting/'));
addpath(genpath('./mooring/'));
addpath(genpath('./raw_loads/'));
addpath(genpath('./supply/'));
addpath(genpath([path2ganges 'ganges/work/chipod_gust/software/']));


%_____________________database selects______________________
experiment = 'is17';
platform   = 'ms100%';
instType   = 'gust%';
inst_sn    = '%';


%_____________________combine all ctd data from a mooring in a structure______________________
%moorName = 'oc25sb-t'
%[M] = make_mooring(moorName, path2ganges)
%[fig] = plot_T_chain(M); 

%_____________________add datapaths to database______________________
%  platform = '%';
%  insttype = '%';
%add_instrument_pathes2database(path2ganges, [experiment], [platform], [instType], [inst_sn])

%_____________________add _comments to instruments in database______________________
%  inst_sn = 'G064';
%  comment = 'test';
%  clear_old_comment = 0;
%  add_comment2instrument( comment , path2ganges, experiment, platform, instType, inst_sn, clear_old_comment )

%_____________________add start and stop date to database to database______________________
   %inst_sn = 'G041';
  %platform   = '%';
  %instType   = '%';
  %add_auto_startstop2instruments(path2ganges, [experiment], [platform], [instType], [inst_sn])

%_____________________temp.mat processing______________________
%chipod_or_gust = 0;
%do_redo = 0;
%inst_sn = '1123'
%generate_all_tempmat(path2ganges, experiment, platform, chipod_or_gust , inst_sn, do_redo)

%_____________________make bsic temp_plots______________________
%inst_sn = 'G041';
%plot_temp_for_gust_and_chipods(path2ganges, experiment, platform, instType, inst_sn )

%_____________________calibrate all pitot tubes______________________
chipod_or_gust = 0;
do_redo        = 0;
do_parallel    = 1;
calibrate_all_pitots(path2ganges, experiment, platform, chipod_or_gust, inst_sn, do_redo )
