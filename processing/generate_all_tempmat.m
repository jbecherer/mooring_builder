function [] = generate_all_tempmat(path2ganges, experiment, platform, chipod_or_gust, inst_sn, do_redo )
%%     [] = add_instrument_pathes2database(path2ganges, [experiment], [platform], [chipod_or_gust], [inst_sn], [do_redo])
%
%  This functions automatically tries to find datapathes and adds them to the omg database
%
%  INPUT
%     path2ganges    :  local path to ganges on computer (default '/data/' corresonding to matlab server)
%     experiment     :  string to identify the experiemnt (default '%' which means all experiments) 
%     platform       :  string to identify the platforms (default '%' which means all platforms) 
%     chipod_or_gust :  which type of instrument (1:chipod, 2:gust, 0:both (default) ) 
%     inst_sn        :  string to identify the serial number of instrument (default '%' which means all sns) 
%     do_redo        :  shall the processing be done although a temp.mat file exist already? (default 0 no)
%
%
%   created by: 
%        Johannes Becherer
%        Tue Nov 21 13:18:21 PST 2017

%_____________________set default inputs______________________
if nargin < 6
   do_redo = 0;
end

if nargin < 5
   inst_sn = '%';
   disp( '---select all serial numbers---');
end

if nargin < 4
   chipod_or_gust = 0;
   disp( '---select all instruments types---');
end
  switch chipod_or_gust % chipods or gusTs?
   case 0
      instType = 'gust%" or inst_type like "chipod%';
   case 1
      instType = 'chipod%';
   case 2
      instType = 'gust%';
  end

if nargin < 3
   platform = '%';
   disp( '---select all platforms---');
end

if nargin < 2
   experiment = '%';
   disp( '---select all experiments---');
end

if nargin < 1
   path2ganges = '/data/';
   disp( '!!!Where is ganges on your computer???');
end

% add chipod processing
addpath(genpath([path2ganges '/ganges/work/chipod_gust/software/']));



%_____________________Ask the data base______________________
% open omg database
omg_db = sqlite([path2ganges 'ganges/work/database/omg.sqlite']);

% find all instruments in database that belong to mooring
sql_string = ['SELECT inst_name, inst_id,  datapath, inst_type ' ...
                     'FROM instOnPlat where experiment like "' experiment '" and ' ...
                     'platform_name like "' platform  '" and (inst_type like "' instType '") and '...
                     'inst_name like "' inst_sn '"'];
   disp('The following SQL statement is applied to the omg_database:');
   disp(['  ' sql_string]);
data = fetch(omg_db, sql_string );

%_____________________show all instruments that are going to be ______________________
disp('all these instruments are going to be handled:');
disp(char(data{:,1}));


%_____________________do_processing______________________

%_______________loop through all instruments_______________________
for i = 1:size(data,1)
   inst_name = char(data{i,1});
   inst_id   = data{i,2};
   basedir    = char(data{i,3});
   inst_type = char(data{i,4});

   basedir
   if basedir(end) ~= '/'
      basedir = [basedir '/'];
   end
   disp(['processing instrument ' inst_name]);

   %first check if temp.file exists
   exist_temp = exist([ path2ganges basedir '/proc/temp.mat']);

   if ~exist_temp | do_redo
      try
         generate_temp( [path2ganges basedir],  1)
      catch ME
         warning( [ 'I could not process ' inst_name ' in ' basedir] );
      end

   end

end

%_____________________close data base______________________
close(omg_db);
