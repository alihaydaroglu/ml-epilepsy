
function plot_mea(data1, data2, rewd_all, sample_rate, channels)
%     for i = 16:26
%         plotnum = 0;
%         
%         switch(i)
%             case 21 %12
%                 plotnum = 4;
%             case 19 %13
%                 plotnum = 7;
%             case 16 %14
%                 plotnum = 10;
%             case 24 %21
%                 plotnum = 2;
%             case 22 %22
%                 plotnum = 5;
%             case 20 %23
%                 plotnum = 8;
%             case 17 %24
%                 plotnum = 11;
%             case 26 %31
%                 plotnum = 3;
%             case 25 %32
%                 plotnum = 6;
%             case 23 %33
%                 plotnum = 9;
%             case 18 %34
%                 plotnum = 12;
%         end
%         
%         subplot(4,3,plotnum)
        if nargin < 5
            channels = [39 40 41 42 22];
        end
        for n = 1:length(channels)
            subplot(length(channels), 1, n)
            i = channels(n);
            %subplot(8,8,i)
            yyaxis left
            t = linspace(0, (1/sample_rate) * length(data1(i,:)), length(data1(i,:)));
            hold on 
            plot(t, data1(i, :), 'b')
            plot(t, data2(i,:), '-g')
            axis([0, (1/sample_rate) * length(data2(i,:)), -0.5e03, 0.5e03])   
%         
            %yyaxis right
            t_short = linspace(0, 500 * (1/sample_rate) * length(rewd_all(i,:)), length(rewd_all(i,:))); % 500 is reward resolution
            plot(t_short, rewd_all(i,:), 'r')
            hold off
        end
end

%% Electrode mappings
% E#: electrode number on MEA
% M#: channel # in Matlab
% E12 : M21
% E13 : M19
% E14 : M16
% E21 : M24
% E22 : M22
% E23 : M20
% E24 : M17
% E31 : M26
% E32 : M25
% E33 : M23
% E34 : M18

% E44 : M27
% E54 : M34

