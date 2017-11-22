%% this files shows examples on how to use the different routines of this package

path2ganges = '/home/johannes/';

addpath(genpath('./sw_tbx/'));
addpath(genpath('./database/'));
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
moorName = 'oc25sb-t'
[M] = make_mooring(moorName, path2ganges)
[fig] = plot_T_chain(M); 

%_____________________add datapaths to database______________________
% add_instrument_pathes2database(path2ganges, [experiment], [platform], [instType], [inst_sn])
