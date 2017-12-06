function [] = add_instrument_pathes2database(path2ganges, experiment, platform, instType, inst_sn )
%%     [] = add_instrument_pathes2database(path2ganges, [experiment], [platform], [instType], [inst_sn])
%
%  This functions automatically tries to find datapathes and adds them to the omg database
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
      command = [' find ' path2ganges inpath '  -type d -name ' inst_name];
  else 
      command = [' find ' path2ganges inpath '  -type f -name "*' inst_name '*.[d, c,a,r][s,a,n][v,t,k]"'];
  end
  [~, output] = system(command);

  % set new path in data base
  if ~isempty(output)
    new_path = [output(strfind(output, inpath):end-1) ];


    disp('current path:')
    disp(['  '  inpath])
    disp('found path:')
    disp(['  '  new_path])

    if ~strcmp( inpath, new_path) % if the found path is diffrent from the database path
       question = input('  shall I update the path in the database ? y/n ', 's');
       if question == 'y'
         exec(omg_db, ['update instruments set datapath = "' new_path '" where id = ' num2str(inst_id)]);
       end
    end

  else
    disp('there was no matching path found')
  end


end

% close database
close(omg_db);

