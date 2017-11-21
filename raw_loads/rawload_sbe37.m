function [T] = rawload_sbe37(fname)
%%    [T] = rawload_sbe37(fname)
%     
%     This function reads a raw cvs file from a sbe37 
%     and converts it into a mat structure T
%
%     INPUT
%        fname    :  path to raw cvs file
%     OUTPUT
%        T.time   :  time
%        T.T      :  temp
%        T.C      :  conductivity
%        T.depth  :  depth
%        T.S      :  salinity
%        T.dens   :  density
%
%     created by 
%        Johannes Becherer
%
% Sun Jul  9 18:13:16 PDT 2017


% path to the sea water tool box
addpath(genpath('~/mixingsoftware/seawater/'));

% open file
   fid = fopen(fname);

% set read position to beginning of file
   fseek(fid,0,-1);                                 

% go through lines until '*END*'
   while strcmp(fgetl(fid),'*END*') == 0; end        


   n=1;                            
   while 1
      tline = fgetl(fid);                 % read in line
      if ~ischar(tline), break, end       % if eof, break and finish
         data(:,n) = sscanf(tline,'%f');     % put numbers in a matrix (in columns)
         n=n+1;
   end

   fclose(fid);    % close file
      
%_____________________structure data______________________

   T.time    = data(5,:) + datenum(2017,01,00);

   T.T       = data(3,:);
   T.C       = data(1,:);
   T.depth   = data(2,:);
   T.S       = sw_salt(abs(T.C)./sw_c3515*10, T.T, T.depth); 
   T.dens    = sw_dens(T.S, T.T, T.depth); 

