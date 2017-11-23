function [] = add_auto_startstop2instruments(path2ganges, experiment, platform, instType, inst_sn )
%%     [] = add_auto_startstop2instruments(path2ganges, [experiment], [platform], [instType], [inst_sn])
%
%  This functions automatically tries to automatically find the start and stop
%  time of gusT and chipods depending on the pressure record in the temp.mat
%  file and adds them to the omg database
%
%  INPUT
%     path2ganges    :  local path to ganges on computer (default '/data/' corresonding to matlab server)
%     experiment     :  string to identify the experiemnt (default '%' which means all experiments) 
%     platform       :  string to identify the platforms (default '%' which means all platforms) 
%     instType       :  string to identify the type of instrument (default '%' which means all types) 
%     inst_sn        :  string to identify the serial number of instrument (default '%' which means all sns) 
%
%
%   created by: 
%        Johannes Becherer
%        Tue Nov 21 13:18:21 PST 2017

%_____________________set default inputs______________________
if nargin < 5
   inst_sn = '%';
   disp( '---select all serial numbers---');
end

if nargin < 4
   instType = '%';
   disp( '---select all instruments types---');
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



%_____________________Ask the data base______________________
% open omg database
omg_db = sqlite([path2ganges 'ganges/work/database/omg.sqlite']);

% find all instruments in database that belong to mooring
sql_string = ['SELECT inst_name, inst_id,  datapath, inst_type ' ...
                     'FROM instOnPlat where experiment like "' experiment '" and ' ...
                     'platform_name like "' platform  '" and inst_type like "' instType '" and '...
                     'inst_name like "' inst_sn '"'];
   disp('The following SQL statement is applied to the omg_database:');
   disp(['  ' sql_string]);
data = fetch(omg_db, sql_string );

%_____________________show all instruments that are going to be ______________________
disp('all these instruments are going to be handled:');
disp(char(data{:,1}));



      
%_______________loop through all instruments_______________________
for i = 1:size(data,1)
   inst_name = char(data{i,1});
   inst_id   = data{i,2};
   inpath    = char(data{i,3});
   inst_type = char(data{i,4});

   disp(['processing instrument ' inst_name]);


   % find data on ganges
  if ~isempty( strfind(inst_type, 'GusT') ) | ~isempty(strfind(inst_type, 'hipod'))
   % if gust of chipod
      temp_fid = [path2ganges inpath '/proc/temp.mat'];
      if exist(temp_fid)
         
         load(temp_fid);

         % find times under water
         ii_good = find( T.P > ( nanmedian(T.P)- nanstd(T.P) )  );
         start = datestr( T.time(ii_good(1)), 'yyyy-mm-dd HH:MM' )
         stop  = datestr( T.time(ii_good(end)), 'yyyy-mm-dd HH:MM' )

         % write to database
         sql_string = ['update instruments set start = "' start '", stop = "' stop '" where id = ' num2str(inst_id)];
         disp(sql_string)
         exec(omg_db, sql_string);

      else
         disp( ['I could not find ' temp_fid ] );
      end
  else 
      disp([ inst_name ' is not handled: routine only works for chipods and gusTs'])
  end

end

% close database
close(omg_db);
