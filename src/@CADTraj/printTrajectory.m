function [print] = printTrajectory(obj)
%
%DEFINETRAJECTORY Creates a paramterised symbolic trajectory definition.
%   Detailed explanation goes here

%% read required properties
q = obj.traj.q; % symbolic trajectory function
designVar = obj.traj.designVar; % design variables
breaks = obj.traj.breaks; % breakpoints

sTrajType = obj.input.sTrajType; % trajectory type
timeA = obj.input.timeA; % start time
timeB = obj.input.timeB; % end time
posA = obj.input.posA; % start position
posB = obj.input.posB; % end position
DOF = obj.input.DOF; % degree of freedom
nPieces = obj.input.nPieces; % #intervals
digits = obj.input.digits; % #significant digits

%% replace time variable to NX format
syms t time
q = subs(q,t,time);

%% create text file
fileID = fopen('Trajectory.txt','w','native','UTF-8');
fprintf(fileID,'Date and Time: %s\n',datetime('now'));
fprintf(fileID,'%s\r\n','');

%% print variables
fprintf(fileID,'Variables: \n');
switch sTrajType
    case 'custom'
        var = symvar(q);
        for i = 1:size(var,2)
            fprintf(fileID,'%s\n',var(i));
        end
    otherwise
        fprintf(fileID,'time\t\t= time\n');
        if isa(timeA,'sym'), fprintf(fileID,'start time\t= %s\n',timeA); end
        if isa(timeB,'sym'), fprintf(fileID,'end time\t= %s\n',timeB); end
        if isa(posA,'sym'), fprintf(fileID,'start position\t= %s\n',posA); end
        if isa(posB,'sym'), fprintf(fileID,'end position \t= %s\n',posB); end
        for i=1:DOF
            fprintf(fileID,'variable %d\t= %s\n',i,char(designVar(i)));
        end        
end
fprintf(fileID,'%s\r\n','');

%% print trajectory
fprintf(fileID,'Trajectory function: \n');
if ~isempty(digits)
    q = vpa(q,digits);
    breaks = vpa(breaks,digits);
end
sBreaks = string.empty(0,nPieces+1);
for i=1:nPieces+1
    if isa(breaks(i),'sym')
        sBreaks(i) = char(vpa(breaks(i),digits));
    else
        sBreaks(i) = num2str(breaks(i));
    end
end

if nPieces == 1
    fprintf(fileID,'%s\n',q);
else
    fprintf(fileID,'(STEP(time,%s,1,%s,0)*(%s))+',sBreaks(2),sBreaks(2),char(vpa(q(1),digits)));
    for i=2:nPieces
        fprintf(fileID,'((STEP(time,%s,0,%s,1)-STEP(time,%s,0,%s,1))*(%s))+',sBreaks(i),sBreaks(i),sBreaks(i+1),sBreaks(i+1),char(vpa(q(i),digits)));
    end
    fprintf(fileID,'%s\r\n','0'); % add zero to last summation
end
fclose(fileID);
print.q = q;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% assign validated input to property
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

obj.print = print;

end

