function [M] = get_instruments(cond, table, path2ganges)
%% [S] = get_instruments(cond, [table], [path2ganges])
%
%  This function generates a structure S that contains all the
%  instruments from the database that full fill the sql-cond cond
%
%  INPUT
%     cond        :  string containing condition (i.e. 'platform_name = "ch17_s2"')
%     table       :  specify talbe or view the condition should be applied on (default instOnPlat)
%     path2ganges :  path where ganges is mounted on the machine 
%                        (default '/data/' works only on matlab-server)
%  
%  OUTPUT
%     S        :  structure containing all data and meta data of the instrument selction
%
%  created by
%     Johannes Becherer
%
% Thu Jul 13 14:01:35 PDT 2017


if nargin < 2
   table = 'instOnPlat';
end
if nargin < 3
   path2ganges = '/data/';
end

% open omg database
db1 = sqlite([path2ganges 'ganges/work/database/omg.sqlite'], 'readonly');

cond
% SQL select statement
selState = ['SELECT inst_name, inst_type, mab, depth, lat, lon, deploy, recover, datapath, waterdepth, platform_name ' ...
                     'FROM ' table ' WHERE ' cond]
% Run statement on data base 
data = fetch(db1, selState);

% some output
disp('The following SQL statement will run on the data base:');
disp(selState);
disp('');
disp('The querry includes the follwing instruments');
data(:,1:2)

%________________read in the relevant data______________________

cnt = 1; % counter for T structure

% loop through all instruments
for i = 1:size(data,1)
   time_lim = [datenum(data(i,7)) datenum(data(i,8))]; % what are the time constrains (deploy and revover)
   i_type   = char(data(i,2));   % what kind of instrument
   i_sn     = char(data(i,1));   % what serial number
   datapath = char(data(i,9));
   depth    = cell2mat(data(i,4));
   mab      = cell2mat(data(i,3));

   % general specifics
   platformname    = char(data(i,11));
   lat             = cell2mat(data(i,5));
   lon             = cell2mat(data(i,6));
   deploy          = char(data(i,7));
   recover         = char(data(i,8));
   w_depth         = cell2mat(data(i,10));

   disp(['Instrument ' i_type ' with the SN ' i_sn]);
   
   % path to relevant data
   fid = [path2ganges datapath];

    %--------------------chipod----------------------
   if ~isempty( strfind(i_type,'chi')) |  ~isempty( strfind(i_type,'Chi'))  
   
      disp(['  ' i_sn ' is processed as chipod'])
      
      % path to temp file
      fid = [fid '/proc/temp.mat'];

      % check if data file exist
      if exist(fid) == 2;
         disp(['   loading ' fid ])

         % load data
         load(fid);
         T.depth_p = T.depth; % resave pressure depth

         % cut fields to time lims
         T = time_lim_fields(T, time_lim);

         % T1 
         M.T{cnt}         = T;
         M.T{cnt}.T       = M.T{cnt}.T1;
         M.T{cnt}.SN        = i_sn;
         M.T{cnt}.inst_type = i_type;
            rmfield(M.T{cnt}, 'T1');
            rmfield(M.T{cnt}, 'T2');
         M.depth(cnt)   = depth-.5;
         M.mab(cnt)     = mab+.5;
         M.lat(cnt)           = lat;
         M.lon(cnt)           = lon;
         M.w_depth(cnt)       = w_depth;
         M.platform_name{cnt} = platformname;
         M.deploy{cnt}        = deploy;
         M.recover{cnt}       = recover;
         cnt = cnt+1;

         % T2
         M.T{cnt}.time    = T.time;
         M.T{cnt}.T       = T.T2;

         M.T{cnt}.SN        = i_sn;
         M.T{cnt}.inst_type = i_type;
         M.depth(cnt)     = depth+.5;
         M.mab(cnt)       = mab-.5;
           
         M.lat(cnt)           = lat;
         M.lon(cnt)           = lon;
         M.w_depth(cnt)       = w_depth;
         M.platform_name{cnt} = platformname;
         M.deploy{cnt}        = deploy;
         M.recover{cnt}       = recover;
         cnt = cnt+1;

      else
         disp(['!!!!  ' fid ' NOT exist!!!!!!'])
         disp(['   1st you have to preprocess temp for ' i_sn])
         disp(['   or ' datapath ' is the wrong directory'])
      end

   %---------------------GusT----------------------
     elseif    ~isempty( strfind(i_type,'Gus')) |  ~isempty( strfind(i_type,'gus'))
   
      disp(['  ' i_sn ' is processed as GusT'])
      
      % path to temp file
      fid = [fid '/proc/temp.mat'];

      % check if data file exist
      if exist(fid) == 2;
         disp(['   loading ' fid ])

         % load data
         load(fid);
         T.depth_p = T.depth; % resave pressure depth

         % cut fields to time lims
         T = time_lim_fields(T, time_lim);

         M.T{cnt}           = T;
         M.T{cnt}.SN        = i_sn;
         M.T{cnt}.inst_type = i_type;
         M.depth(cnt)      = depth;
         M.mab(cnt)        = mab;
         M.lat(cnt)           = lat;
         M.lon(cnt)           = lon;
         M.w_depth(cnt)       = w_depth;
         M.platform_name{cnt} = platformname;
         M.deploy{cnt}        = deploy;
         M.recover{cnt}       = recover;
         cnt = cnt+1;

      else
         disp(['!!!!  ' fid ' NOT exist!!!!!!'])
         disp(['   1st you have to preprocess temp for ' i_sn])
         disp(['   or ' datapath ' is the wrong directory'])
      end

   %---------------------SoloT----------------------
   elseif ~isempty( strfind(i_type,'solo')) |  ~isempty( strfind(i_type,'Solo'))
      disp(['  ' i_sn ' is processed as SoloT'])

      % check if data file exist
      if exist(fid) == 2;
         disp(['   loading ' fid ])

         % load data
         T = rawload_solo(fid);

         % cut fields to time lims
         T = time_lim_fields(T, time_lim);

         M.T{cnt}           = T;
         M.T{cnt}.SN        = i_sn;
         M.T{cnt}.inst_type = i_type;
         M.depth(cnt)   = depth;
         M.mab(cnt)     = mab;
         M.lat(cnt)           = lat;
         M.lon(cnt)           = lon;
         M.w_depth(cnt)       = w_depth;
         M.platform_name{cnt} = platformname;
         M.deploy{cnt}        = deploy;
         M.recover{cnt}       = recover;
         cnt = cnt+1;
      else
         disp(['!!!!  ' fid ' NOT exist!!!!!!'])
      end

   %---------------------Concerto (RBR)--------------------
   elseif ~isempty( strfind(i_type,'CONCERTO')) |  ~isempty( strfind(i_type,'RBR CTD'))
      disp(['  ' i_sn ' is processed as RBRConcerto'])

      % check if data file exist
      if exist(fid) == 2;
         disp(['   loading ' fid ])

         % load data
         T = rawload_concerto(fid);
         T.depth_p = T.depth; % resave pressure depth

         % cut fields to time lims
         T = time_lim_fields(T, time_lim);

         M.T{cnt}           = T;
         M.T{cnt}.SN        = i_sn;
         M.T{cnt}.inst_type = i_type;
         M.depth(cnt)   = depth;
         M.mab(cnt)     = mab;
         M.lat(cnt)           = lat;
         M.lon(cnt)           = lon;
         M.w_depth(cnt)       = w_depth;
         M.platform_name{cnt} = platformname;
         M.deploy{cnt}        = deploy;
         M.recover{cnt}       = recover;
         cnt = cnt+1;
      else
         disp(['!!!!  ' fid ' NOT exist!!!!!!'])
      end


   %---------------------SBE37----------------------
   elseif ~isempty( strfind(i_type,'SBE37')) |  ~isempty( strfind(i_type,'sbe37'))
      disp(['  ' i_sn ' is processed as SBE37'])

      % check if data file exist
      if exist(fid) == 2;
         disp(['   loading ' fid ])

         % load data
         T = rawload_sbe37(fid);
         T.depth_p = T.depth; % resave pressure depth

         % cut fields to time lims
         T = time_lim_fields(T, time_lim);

         M.T{cnt}           = T;
         M.T{cnt}.SN        = i_sn;
         M.T{cnt}.inst_type = i_type;
         M.depth(cnt)   = depth;
         M.mab(cnt)     = mab;
         M.lat(cnt)           = lat;
         M.lon(cnt)           = lon;
         M.w_depth(cnt)       = w_depth;
         M.platform_name{cnt} = platformname;
         M.deploy{cnt}        = deploy;
         M.recover{cnt}       = recover;
         cnt = cnt+1;
      else
         disp(['!!!!  ' fid ' NOT exist!!!!!!'])
      end

   %---------------------SBE56----------------------
   elseif ~isempty( strfind(i_type,'SBE56')) |  ~isempty( strfind(i_type,'sbe56'))
      disp(['  ' i_sn ' is processed as SBE56'])

      % check if data file exist
      if exist(fid) == 2;
         disp(['   loading ' fid ])

         % load data
         T = rawload_sbe56(fid);

         % cut fields to time lims
         T = time_lim_fields(T, time_lim);

         M.T{cnt}           = T;
         M.T{cnt}.SN        = i_sn;
         M.T{cnt}.inst_type = i_type;
         M.depth(cnt)   = depth;
         M.mab(cnt)     = mab;
         M.lat(cnt)           = lat;
         M.lon(cnt)           = lon;
         M.w_depth(cnt)       = w_depth;
         M.platform_name{cnt} = platformname;
         M.deploy{cnt}        = deploy;
         M.recover{cnt}       = recover;
         cnt = cnt+1;
      else
         disp(['!!!!  ' fid ' NOT exist!!!!!!'])
      end

   else
      disp(['  No rule to process instrument of type ' i_type])
   end

   
end

close(db1);
