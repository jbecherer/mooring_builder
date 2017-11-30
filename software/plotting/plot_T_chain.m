function [fig] = plot_T_chain(M, vis, tl)
%%   [fig] = plot_T_chain(M, vis, tl)
%
%     This function generates a figure containing
%     all temperature sensors in a given mooring
%
%     INPUT
%        M        :  mooring structure (output of make_mooring)
%        vis      :  shall the figure be visible ('on'/ 'off' default 'on')
%        tl       :  time limits
%     OUTPUT
%        fig      :  figure handel
%
%     created by 
%        Johannes Becherer
%
% Tue Jul 11 11:45:44 PDT 2017

if nargin < 2
   vis = 'on';
end
if nargin < 3
   if M.recover ~= '2100-01-01 00:00'
     xl = [datenum(M.deploy) datenum(M.recover)];
   else
      xl = [0 3]+ datenum(M.deploy); 
   end
else
    xl = tl;
end

%_____________________plot______________________
fig = figure('Color',[1 1 1],'visible',vis,'Paperunits','centimeters',...
               'Papersize',[40 20],'PaperPosition',[-6 0 40 20]);

         col = get(groot,'DefaultAxesColorOrder'); 
          [ax, ~] = create_axes(fig, 1, 1, 0);

            
          a = 1;
          


          % number of instruments
          N = length(M.T);


         col1 = jet(N); % color scheme
   
         % plot all instruments
            for i = 1:N
                   pi = i;  plot(ax(a), M.T{i}.time, M.T{i}.T, 'color', [col1(i,:) .5], 'Linewidth', 1);

                   %ff  = (nanmean(diff(M.T{i}.time)*3600*24))/1200; % filter to 60 min intervals
                    %ff  = (nanmean(diff(xl)*3600*24))/1200; % filter to 200 step per intervals
                     ff  = nanmean(diff(M.T{i}.time))./diff(xl)*200; % filter to 200 step per intervals
                     if ff>1
                        ff=1;
                     end
                     
                   pi = i;  plot(ax(a), M.T{i}.time, qbutter(M.T{i}.T, ff), 'color', col1(i,:)*.7, 'Linewidth', 2);
                   if M.T{i}.SN(1) == 'G'  % if gusT
                       plot(ax(a), M.T{i}.time, qbutter(M.T{i}.T, ff), '--','color', [0 0 0], 'Linewidth', 2);
                   end

                   L{i} = [M.T{i}.SN ' (' M.T{i}.inst_type ')'];
            end

             xlim(ax(a), xl);
             t = text_corner(ax(a), ['T [^{\circ}C]'], 1);
            
             datetick(ax(a), 'x', 'dd-mmm-yyyy HH:MM:SS',  'keeplimits');
             
            abc='abcdefghijklmnopqrst';
            for i = 1:(size(ax,1)*size(ax,2))
               text_corner(ax(i), abc(i), 7);
            end

            %_____________________mooring diagram______________________
            squeeze_axes(ax , .85, 1);
            lp =get(ax(1), 'Position'); 
            axs = axes('Position', [lp(1)+lp(3)+.01 lp(2), .1 , lp(4)]);
            mooring_sketch(axs, M.w_depth, M.mab-M.w_depth, L, col1.*.7, 10)

