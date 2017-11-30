function [] = generate_all_praw(path2ganges, experiment, platform, chipod_or_gust, inst_sn, do_redo, do_parallel )
%%     [] = generate_all_praw(path2ganges, [experiment], [platform], [chipod_or_gust], [inst_sn], [do_redo], [do_parallel])
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
%     do_parallel    :  shall the processing be done in parallel (default 1 yes)
%
%
%   created by: 
%        Johannes Becherer
%        Tue Nov 21 13:18:21 PST 2017

%_____________________set default inputs______________________
if nargin < 7
   do_parallel = 1;
end

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
sql_string = ['SELECT inst_name, inst_id,  datapath, inst_type , start, stop ' ...
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
   basedir   = char(data{i,3});
   inst_type = char(data{i,4});

   start     = char(data{i,5});
   stop      = char(data{i,6});
      try 
         timelims(1) = datenum(start);
      catch
         timelims(1) = datenum(1900,0,0,0,0,0);
      end
      try 
         timelims(2) = datenum(stop);
      catch
         timelims(2) = datenum(2100,0,0,0,0,0);
      end



   basedir
   if basedir(end) ~= '/'
      basedir = [basedir '/'];
   end
   disp(['processing instrument ' inst_name]);

   %first check if temp.file exists
   exist_praw = exist([ path2ganges basedir '/proc/Praw.mat']);

   if ~exist_praw | do_redo
      try
         generate_praw( [path2ganges basedir], do_parallel,  timelims) 
        % db comment 
         database_comment = [datestr(now, 'yyyy-mm-dd HH:MM') ' :  Praw.mat processed'];
         add_comment2instrument( database_comment , path2ganges, experiment, platform, inst_type, inst_name, 0 );
      catch ME
         disp(ME)
         warning( [ 'I could not process ' inst_name ' in ' basedir] );
      end

   end

end

%_____________________close data base______________________
close(omg_db);
