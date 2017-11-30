function [] = add_comment2instrument( comment , path2ganges, experiment, platform, instType, inst_sn, clear_old_comment )
%%     [] = add_comment2instrument( comment, path2ganges, [experiment], [platform], [instType], [inst_sn], [clear_old_comment])
%
%  This functions automatically tries to find datapathes and adds them to the omg database
%
%  INPUT
%		comment				:	new comment (string)
%     path2ganges			:  local path to ganges on computer (default '/data/' corresonding to matlab server)
%     experiment			:  string to identify the experiemnt (default '%' which means all experiments) 
%     platform				:  string to identify the platforms (default '%' which means all platforms) 
%     instType				:  string to identify the type of instrument (default '%' which means all types) 
%     inst_sn				:  string to identify the serial number of instrument (default '%' which means all sns) 
%     clear_old_comment :	should the old comment be deleted 1 or appended to the new comment 1 (default) 
%
%
%   created by: 
%        Johannes Becherer
%        Tue Nov 21 13:18:21 PST 2017

%_____________________set default inputs______________________
if nargin < 7
   clear_old_comment = 0;
   disp( '---old comments will be appended---');
end

if nargin < 6
   inst_sn = '%';
   disp( '---select all serial numbers---');
end

if nargin < 5
   instType = '%';
   disp( '---select all instruments types---');
end

if nargin < 4
   platform = '%';
   disp( '---select all platforms---');
end

if nargin < 3
   experiment = '%';
   disp( '---select all experiments---');
end

if nargin < 2
   path2ganges = '/data/';
   disp( '!!!Where is ganges on your computer???');
end



%_____________________Ask the data base______________________
% open omg database
omg_db = sqlite([path2ganges 'ganges/work/database/omg.sqlite']);

% find all instruments in database that belong to mooring
sql_string = ['SELECT inst_name, inst_id,  comment ' ...
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
   inst_name 	= char(data{i,1});
   inst_id   	= data{i,2};
	old_comment = char(data{i,3});

   disp(['___________' inst_name '_________________']);


    disp('old comment:')
    disp(['  '  old_comment])
    disp('new_comment:')
    disp(['  '  comment])
	 if ~clear_old_comment
    	disp(['  '  old_comment])
      
	   exec(omg_db, ['update instruments set comment = ("' comment '" || char(13) || comment)  where id = ' num2str(inst_id)]);
	 else
	   exec(omg_db, ['update instruments set comment = "' comment '"  where id = ' num2str(inst_id)]);
	 end



end

% close database
close(omg_db);
