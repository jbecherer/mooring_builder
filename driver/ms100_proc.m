%% process all things on all instruments 

%path2ganges = '/home/johannes/';
path2ganges = '/Users/mixing/';


%_____________________what should be done?______________________
do_redo      = 0;
do_parallel  = 1;
do_temp      = 0;
do_temp_plot = 0;
do_praw      = 1;
do_cal_pitot = 1;
do_peps      = 1;


%____________________which instruments?______________________
chipod_or_gust   = 0;         %  0 both
experiment       = 'is17';
platform         = '%';
instType         = '%';
inst_sn          = '%';


%_____________________set pathes______________________
addpath(genpath('../software/'));
addpath(genpath([path2ganges 'ganges/work/chipod_gust/software/']));




%_____________________generate temp.mat______________________
if do_temp
   generate_all_tempmat(path2ganges, experiment, platform, chipod_or_gust , inst_sn, do_redo, do_parallel);
end

%_____________________make basic temp_plots______________________
if do_temp_plot
   plot_temp_for_gust_and_chipods(path2ganges, experiment, platform, instType, inst_sn );
end

%_____________________Praw ______________________
if do_praw
   generate_all_praw(path2ganges, experiment, platform, chipod_or_gust , inst_sn, do_redo, do_parallel);
end

%_____________________calibrate Pitot______________________
if do_cal_pitot
  calibrate_all_pitots(path2ganges, experiment, platform, chipod_or_gust, inst_sn, do_redo )
end

%_____________________pitot epsilon ______________________
if do_peps
   generate_all_peps(path2ganges, experiment, platform, chipod_or_gust , inst_sn, do_redo, do_parallel);
end
