function [M] = make_mooring(moorName, path2Ganges)
%%  [M] = make_mooring(morName, path2ganges)
%
% This function is meant to generate a collective mooring file
%  containing all instruments of a particular mooring that is listed in
%  the omg-data base
%  
%  INPUT
%     morName     :  mooring dataabase name
%     path2ganges :  local path to ganges not including ganges for instance '/home/user/'
%  OUTPUT
%     M           :  structure containing all instruments's data of the mooring
% 
%
% created by Johannes
% on
% Fri Jul  7 21:38:13 PDT 2017

%%addpath('../raw_laods/')
%addpath('../raw_laods/')
addpath(genpath('../'))


% open omg database
omg_db = sqlite([path2Ganges 'ganges/work/database/omg.sqlite'], 'readonly');

% find all instruments in database that belong to mooring
sql_string = ['SELECT inst_name, inst_type, mab, depth, lat, lon, deploy, recover, datapath, waterdepth, ' ...
                     ' start, stop FROM instOnPlat WHERE platform_name like "' moorName '"']
data = fetch(omg_db, sql_string);
disp(['The following statement is applied to the data base']);
disp(sql_string);
close(omg_db);

  % which instruments to process
   if isempty(data)
      M= [] ;
      warning('!!! No matching instruments where found in the data base');
      return;
   end
   disp('the following instruments have been found on the mooring') ;
   disp( char(data{:,1}));


cnt = 1; % counter for T structure

% loop through all instruments
for i = 1:size(data,1)
   time_lim = [datenum(data(i,7)) datenum(data(i,8))]; % what are the time constrains (deploy and revover)
   i_type   = char(data(i,2));   % what kind of instrument
   i_sn     = char(data(i,1));   % what serial number
   datapath = char(data(i,9));
   depth    = cell2mat(data(i,4));
   mab      = cell2mat(data(i,3));

   % general mooring specifics
   M.name      = moorName;
   M.lat       = cell2mat(data(i,5));
   M.lon       = cell2mat(data(i,6));
   M.deploy    = char(data(i,7));
   M.recover   = char(data(i,8));
   M.w_depth   = cell2mat(data(i,10));

   disp(['Instrument ' i_type ' with the SN ' i_sn]);
   
   % path to relevant data
   fid = [path2Ganges datapath];

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
         cnt = cnt+1;

         % T2
         M.T{cnt}.time    = T.time;
         M.T{cnt}.T       = T.T2;
         M.T{cnt}.SN        = i_sn;
         M.T{cnt}.inst_type = i_type;
         M.depth(cnt)     = depth+.5;
         M.mab(cnt)       = mab-.5;
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
         M.depth(cnt)   = depth;
         M.mab(cnt)     = mab;
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

         if ~isempty(T)
            % cut fields to time lims
            T = time_lim_fields(T, time_lim);

            M.T{cnt}           = T;
            M.T{cnt}.SN        = i_sn;
            M.T{cnt}.inst_type = i_type;
            M.depth(cnt)   = depth;
            M.mab(cnt)     = mab;
            cnt = cnt+1;
         else
            disp(['no data obtained from ' fid ' !!!!!']);
         end
      else
         disp(['!!!!  ' fid ' NOT exist!!!!!!']);
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
         cnt = cnt+1;
      else
         disp(['!!!!  ' fid ' NOT exist!!!!!!'])
      end

   else
      disp(['  No rule to process instrument of type ' i_type])
   end

   
end
