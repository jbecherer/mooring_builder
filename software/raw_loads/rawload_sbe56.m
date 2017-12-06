function [T] = rawload_sbe56(fname)
%%    [T] = rawload_sbe56(fname)
%     
%     This function reads a raw cvs file from a sbe37 
%     and converts it into a mat structure T
%
%     INPUT
%        fname    :  path to raw csv file
%     OUTPUT
%        T.time   :  time
%        T.T      :  temp
%
%     created by 
%        Johannes Becherer
%
% Sun Jul  9 18:13:16 PDT 2017

% cnv or csv
if fname([-2:0]+end) == 'csv'
   is_csv = 1;
elseif fname([-2:0]+end) == 'cnv'
   is_csv = 2;
else
   is_csv = 0;
   return;
end


% open file
   fid = fopen(fname);



% set read position to beginning of file
   fseek(fid,0,-1);                                 

if is_csv == 1
   % find end of header
   while isempty(strfind(fgetl(fid),'Sample')); end        
   % read all info from file
   A = textscan(fid, '%s%s%s%s', 'Delimiter',',');

   fclose(fid);    % close file

   %_____________________structure data______________________
   T.T     = nan(length(A{1}(:)),1);
   T.time  = nan(length(A{1}(:)),1);
   for i = 1:length(A{1}(:))
      timestr{i} =  [char(strrep(A{2}(i),'"','')) ' ' char(strrep(A{3}(i),'"',''))];
      T.T(i)       = str2num(char(strrep(A{4}(i),'"','')));
   end
   T.time = datenum(timestr);

elseif is_csv == 2 

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

   T.time    = data(1,:) + datenum(2017,01,00);
   T.T       = data(2,:);
end


   
      
