function [] = make_mooring_vel_m( time_A, z_A, U_A, moorname, path2ganges, overwrite_old_velm)
%%  [] = make_mooring_vel_m( time_A, z_A, U_A, moorname, path2ganges, [overwrite_old_velm])
%  
%  This function generates vel_m files for all gusTs and chipods 
%  on mooring in data base with the given ADCP data
%
%  INPUT
%     time_A      :  time vector for ADCP data
%     z_A         :  depth vector (or matrix) for ADCP (meters below surface)
%     U_A         :  complex velocity matrix (real: east, imag: north)
%     moorname    :  mooring name as it appears in data base
%     path2ganges :  path to ganges
%     overwrite_old_velm : shall existing vel_m files be over written? (1: yes, 0:no (default) )
%
%
%   created by: 
%        Johannes Becherer
%        Mon Nov 27 14:31:20 PST 2017


if nargin<6
 overwrite_old_velm = 0;
end

% open omg database
omg_db = sqlite([path2ganges 'ganges/work/database/omg.sqlite'], 'readonly');
   % find all instruments in database that belong to mooring
   sql_string = ['SELECT inst_name, inst_type, mab, depth, lat, lon, deploy, recover, datapath, waterdepth ' ...
                        'FROM instOnPlat WHERE platform_name like "' moorname '" and ' ...
                        '( inst_type like "gust%" or inst_type like "chipod") '];
   data = fetch(omg_db, sql_string);
close(omg_db);

  % which instruments to process
   if isempty(data)
      M= [] ;
      warning('!!! No matching instruments where found in the data base');
      return;
   end
   disp(['the following instruments have been found on the mooring ' moorname]) ;
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


   z = -abs(depth); % make sure the depth is negative

   % check if vel_m already exist

   sdir     = [path2ganges datapath '/input/'];
   fid_velm = [sdir 'vel_m.mat'];
   if exist(fid_velm) & ~overwrite_old_velm
      disp([ fid_velm ' exist already']);
      disp(['the processing will be skiped for this instrument']);
   else
      if exist(sdir)
         disp(['  generating vel_m for ' i_sn] );
         generate_vel_m( time_A, z_A, real(U_A), imag(U_A), z, sdir);
      else
         disp([ sdir 'does not  exist']);
         disp(['the processing will be skiped for this instrument']);
      end
   end

end
