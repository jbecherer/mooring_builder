function [T] = rawload_solo(fid)
%%  [T] = rawload_solo(fid)
%
%  This function reads in the raw files (sqlite, rsk)
%  from SoloTs and returns a  mat struction structure 
%
%  INPUT
%     fid      :  path to raw-file
%
%  OUTPUT
%     T.time   :  matlab time
%     T.T      :  temperature
%
%
%  !!!! NOTE this function requirres MATLAB2016a or newer!!!!
%
%   created by: 
%        Johannes Becherer
%        Sat Jul  8 00:13:24 GMT 2017


if nargin<1
    [raw_name,rawdir]=uigetfile('*.*','Load Binary File');
    fid=[rawdir raw_name];
    if raw_name==0
        error('File not found')
        return
    end
end

% rsk or dat
if fid([-2:0]+end) == 'rsk'
   is_rsk = 1;
elseif fid([-2:0]+end) == 'dat'
   is_rsk = 2;
else
   is_rsk = 0;
   return;
end

if is_rsk == 1 

   % open data base file
   db1 = sqlite(fid);

   % get data block
   try 
      data = fetch(db1,'select * from data');
   catch ME
      close(db1);
      T = [];
      return;
   end



   % convert unix time from t logger into matlab time
   timetmp = datenum(1970,1,1,0,0,double(cell2mat(data(:,1))/1000));
   [T.time, ii]  = sort(timetmp); % the data require chronological sorting

   % temperature
   ttmp    = double(cell2mat(data(:,2)));
   T.T     = ttmp(ii);

   % get_instrument specifics
   inst = fetch(db1, 'SELECT serialID, model FROM instruments');

   T.sn = inst(1,1);
   T.model = inst(1,2);

   close(db1);

elseif is_rsk == 2 
   fid = fopen(fid);
   % set read position to beginning of file
      fseek(fid,0,-1);                                 

   T.model = fgetl(fid);
   while isempty(strfind(fgetl(fid), 'Logger time')); end
   
      S  =  fgetl(fid);
      start_time = datenum(S(15:end),'yy/mm/dd HH:MM:SS');
      S  =  fgetl(fid);
      S  =  fgetl(fid);

      dt = (str2double(S([-1:0]+end)))/3600/24; % time step

   while isempty(strfind(fgetl(fid), 'Temp')); end 

   n=1;                            
   while 1
      tline = fgetl(fid);                 % read in line
      if ~ischar(tline), break, end       % if eof, break and finish
         data(n) = sscanf(tline,'%f');     % put numbers in a matrix (in columns)
         n=n+1;
   end

   fclose(fid);    % close file
      
   %_____________________structure data______________________

   T.T       = data;
   T.time    = [0:(length(T.T)-1)]*dt + start_time ;

end

