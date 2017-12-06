clear all;
close all;


path2ganges = '/home/johannes/';
addpath(genpath('../software'));
addpath(genpath([path2ganges '/ganges/work/chipod_gust/software/']));


 overwrite_old_velm = 1;

% open omg database
omg_db = sqlite([path2ganges 'ganges/work/database/omg.sqlite'], 'readonly');

%_____________________MS100______________________
   % here in this example the adcp is on lander ms100_a and
   % all instruments on ms100_t get the correponding vel_m
   lander   =  'ms100_a';
   string   =  'ms100_t';
  %lander   =  'oc40n_a';
  %string   =  'oc40n_t';
  %lander   =  'oc40s_a';
  %string   =  'oc40s_t';


    %---------------------find ADCP data----------------------
      sql_string = ['SELECT inst_name,  datapath ' ...
                           'FROM instOnPlat WHERE platform_name like "' lander '" and inst_type like "adcp%"'];
      data = fetch(omg_db, sql_string);
      i_sn     = char(data(1,1));   % what serial number
      path2adcp = char(data(1,2));
      if size(data,1) > 1
         disp(['There are multiple matching ADCP instruments for ' lander]);
         data(:,1)
      else
         load([path2ganges path2adcp]);
         %---------------------generate vel_m----------------------
          make_mooring_vel_m( A.time, A.z, A.U, lander, path2ganges, overwrite_old_velm)
          make_mooring_vel_m( A.time, A.z, A.U, string, path2ganges, overwrite_old_velm)
      end
   



% close db
close(omg_db);
