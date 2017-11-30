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


% open file
   fid = fopen(fname);

% set read position to beginning of file
   fseek(fid,0,-1);                                 

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
