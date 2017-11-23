function [] = plot_temp_for_gust_and_chipods(path2ganges, experiment, platform, instType, inst_sn )
%%     [] = plot_temp_for_gust_and_chipods(path2ganges, [experiment], [platform], [instType], [inst_sn])
%     
%     This function makes temperarture overview plits for all gusTs and chipods selected
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

addpath(genpath([path2ganges '/ganges/work/chipod_gust/software/']));


%_____________________Ask the data base______________________
% open omg database
omg_db = sqlite([path2ganges 'ganges/work/database/omg.sqlite']);

% find all instruments in database that belong to mooring
sql_string = ['SELECT inst_name, inst_id,  datapath, inst_type, start, stop ' ...
                     'FROM instOnPlat where experiment like "' experiment '" and ' ...
                     'platform_name like "' platform  '" and inst_type like "' instType '" and '...
                     'inst_name like "' inst_sn '"'];
   disp('The following SQL statement is applied to the omg_database:');
   disp(['  ' sql_string]);
data = fetch(omg_db, sql_string );

% close databas
close(omg_db);

%_____________________show all instruments that are going to be ______________________
disp('all these instruments are going to be handled:');
disp(char(data{:,1}));



      
%_______________loop through all instruments_______________________
for i = 1:size(data,1)
   inst_name = char(data{i,1});
   inst_id   = data{i,2};
   basedir   = char(data{i,3});
   inst_type = char(data{i,4});
   start     = char(data{i,5});
   stop      = char(data{i,6});

   disp(['processing instrument ' inst_name]);


   % find data on ganges
  if ~isempty( strfind(inst_type, 'GusT') ) | ~isempty(strfind(inst_type, 'hipod'))
   % if gust of chipod
      temp_fid = [path2ganges basedir '/proc/temp.mat'];
      if exist(temp_fid)
         
         load(temp_fid);

         % set time_limits
         tl = T.time([1 end]);

         [fig ] = plot_basic_temp(T, inst_name, 1 , tl, 'off');
         print(fig , [ path2ganges basedir '/pics/temp_whole.png'],'-dpng','-r200')

         Ndays =  floor(diff(tl));
         if  Ndays > 2  % if long time series split up in individual days

            for day = 1:(Ndays-1) 

               if day == 1 
                  tl_zoom = [0 1.2]  +tl(1);
               elseif day < (Ndays-1)
                  tl_zoom = [-.2 1.2]  +tl(1) + day;
               else % last day
                  tl_zoom = [tl(1)+day tl(2)];
               end

               clf;
          

               [fig ] = plot_basic_temp(T, inst_name, 1 , tl_zoom, 'off');
               print(fig , [ path2ganges basedir '/pics/temp_' datestr( floor(mean(tl_zoom)), 'yyyymmdd' ) '.png'],'-dpng','-r200')

            end

         end
         


      else
         disp( ['I could not find ' temp_fid ] );
      end
  else 
      disp([ inst_name ' is not handled: routine only works for chipods and gusTs'])
  end

end

