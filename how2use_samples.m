%% this files shows examples on how to use the different routines of this package

path2ganges = '/home/johannes/';

addpath(genpath('./database/'));
addpath(genpath('./raw_loads/'));
addpath(genpath('./supply/'));
addpath(genpath([path2ganges 'ganges/work/chipod_gust/software/']));


%_____________________database selects______________________
experiment = 'is17';
platform   = 'ms100%';
instType   = 'gust%';
inst_sn    = '%';

%_____________________add datapaths to database______________________
% add_instrument_pathes2database(path2ganges, [experiment], [platform], [instType], [inst_sn])
