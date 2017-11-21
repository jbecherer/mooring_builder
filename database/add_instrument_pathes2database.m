
%path2ganges = '/home/johannes/'
path2ganges = '/Users/mixing/'

experiment = 'is17';


%_____________________Ask the data base______________________
% open omg database
omg_db = sqlite([path2ganges 'ganges/work/database/omg.sqlite']);

% find all instruments in database that belong to mooring
data = fetch(omg_db, ['SELECT inst_name, inst_id,  datapath, inst_type ' ...
                     'FROM instOnPlat where experiment like "' experiment '"']);
      
% loop through all instruments
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
      command = [' find ' path2ganges inpath '  -type f -name "*' inst_name '*.[c,a,r][s,a,n][v,t,k]"'];
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


close(omg_db);
