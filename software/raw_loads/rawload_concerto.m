function [T] = rawload_concerto(fid)
%%  [T] = rawload_concerto(fid)
%
%  This function reads in the raw files (sqlite, rsk)
%  from CONCERTOs and returns a  mat  structure 
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


% open data base file
db1 = sqlite(fid);

% get data block
chan = fetch(db1,'select * from channels');
data = fetch(db1,'select * from data');

% convert unix time from t logger into matlab time
timetmp = datenum(1970,1,1,0,0,double(cell2mat(data(:,1))/1000));
[T.time, ii]  = sort(timetmp); % the data require chronological sorting

% load all the fields
for i = 2:size(data,2)
   tmp    = double(cell2mat(data(:,i)));
   switch chan{i-1,2}(1:4) % decide which field it is
   case 'cond'
      T.C      = tmp(ii);
      T.units.C = [(chan{i-1,3}) ' : ' (chan{i-1,4})];
   case 'temp'
      T.T      = tmp(ii);
      T.units.T = [(chan{i-1,3}) ' : ' (chan{i-1,4})];
   case 'pres'
      T.P      = tmp(ii);
      T.units.P = [(chan{i-1,3}) ' : ' (chan{i-1,4})];
   case 'dpth'
      T.depth  = tmp(ii);
      T.units.depth = [(chan{i-1,3}) ' : ' (chan{i-1,4})];
   case 'sal_'
      T.S      = tmp(ii);
      T.units.S = [(chan{i-1,3}) ' : ' (chan{i-1,4})];
   end

end

if ~isfield('T', 'depth')
   T.depth = T.P-10;
end

if ~isfield('T', 'S')
   addpath(genpath('~/mixingsoftware/seawater/'));
   T.S       = sw_salt(abs(T.C)./sw_c3515, T.T, T.depth); 
   T.dens    = sw_dens(T.S, T.T, T.depth); 
end


% get_instrument specifics
inst = fetch(db1, 'SELECT serialID, model FROM instruments');

T.sn = inst(1,1);
T.model = inst(1,2);
