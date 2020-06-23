function [traj] = createTrajectory(obj)
%
%DEFINETRAJECTORY Creates a paramterised symbolic trajectory definition.
%   Detailed explanation goes here

%% read required properties
sTrajType = obj.input.sTrajType; % trajectory type
timeA = obj.input.timeA; % start time
timeB = obj.input.timeB; % end time
posA = obj.input.posA; % start position
posB = obj.input.posB; % end position
DOF = obj.input.DOF; % degree of freedom
nPieces = obj.input.nPieces; % #intervals
trapRatio = obj.input.trapRatio; % ratio t_acc/t_tot (trap)
trajFun = obj.input.trajFun; % custom symbolic trajectory function
trajFunBreaks = obj.input.trajFunBreaks;

%% define position function
syms t % time variable

% define position function and derivatives
switch sTrajType
    case {'poly5','poly','cheb','cheb2'}
        % define symbolic variables
        syms p0
        symVar=sym('p', [1 5+DOF]);
        symVar=[p0 symVar];
        % create position fucntion
        switch sTrajType
            case 'poly5'
                pol=t.^(0:5).';
                q=symVar*pol;
            case 'poly'
                pol=t.^(0:5+DOF).';
                q=symVar*pol;
            case 'cheb'
                pol=chebyshevT(0:5+DOF,t).';
                q=symVar*pol;
            case 'cheb2'
                pol=chebyshevU(0:5+DOF,t).';
                q=symVar*pol;
        end
        % calculate derivatives
        qd1 = diff(q,t);
        qd2 = diff(qd1,t);       
    case 'spline'
        % define symbolic variables
        p0i= sym('p%d0',[1 nPieces]).';
        symVar = sym('p%d%d',[nPieces 3]);
        symVar = [p0i symVar];
        % create position function
        pol=t.^(0:3).';
        q=symVar*pol;  
        qd1=diff(q);
        qd2=diff(qd1);
    case 'trap'
        symVar = [];
        % create velocity function
        dt = timeB-timeA;
        qd1_max = (posB-posA)/((trapRatio*dt)+(dt-2*trapRatio*dt));
        qd1 = sym.empty(3,0);
        qd1(1,:) = qd1_max/(trapRatio*dt)*(t-timeA);
        qd1(2,:) = qd1_max;
        qd1(3,:) = -qd1_max/(trapRatio*dt)*(t-timeB);
        % calculate derivative
        qd2 = diff(qd1,t);
        % solve system
        syms C1 C2 C3
        q = int(qd1,t);
        eq = sym.empty(3,0);
        eq(1) = subs(q(1),t,timeA)+C1 == posA;
        eq(2) = subs(q(2),t,dt/2+timeA)+C2 == ...
            abs(posB-posA)/2+min(posB,posA);
        eq(3) = subs(q(3),t,timeB)+C3 == posB;
        sol = solve(eq,[C1 C2 C3]);
        q = sym.empty(3,0);
        q(1,:) = q(1)+sol.C1;
        q(2,:) = q(2)+sol.C2;
        q(3,:) = q(3)+sol.C3;
        
    case 'custom'
        q=trajFun;
        qd1=diff(q);
        qd2=diff(qd1);
        
end

%% define breakpoints
switch sTrajType
    case 'trap'
        breaks = [timeA,timeA+trapRatio*dt,...
            timeB-trapRatio*dt,timeB];
    case 'spline'
        breaks = linspace(timeA,timeB,nPieces+1);
    case 'custom'
        breaks = trajFunBreaks;
    otherwise
        breaks = [timeA,timeB];
end

%% define constrained and design variables
switch sTrajType
    case {'poly5','poly','cheb','cheb2'}
        constrVar = symVar(1:6).';
        designVar = symVar(7:end).'; % higher degree coeff.
    case 'spline'
        constrVar=symVar(1:end).';
        designVar=sym('q', [1 nPieces]);
        designVar=designVar(2:nPieces-2).';
    otherwise
        constrVar =[];
        designVar =[];
end

%% define trajectory constraint equations
% start and end constraint equations
switch sTrajType
    case {'poly','poly5','cheb','cheb2','spline'}
        constrEq_bnd = sym.empty(6,0);
        constrEq_bnd(1,1) = subs(q(1),t,timeA)==posA;
        constrEq_bnd(2,1) = subs(qd1(1),t,timeA)==0;
        constrEq_bnd(3,1) = subs(qd2(1),t,timeA)==0;
        constrEq_bnd(4,1) = subs(q(end),t,timeB)==posB;
        constrEq_bnd(5,1) = subs(qd1(end),t,timeB)==0;
        constrEq_bnd(6,1) = subs(qd2(end),t,timeB)==0;
    otherwise
        constrEq_bnd =[];
end

% breakpoint constraint equations
switch sTrajType
    case 'spline'
        constrEq_br=sym(zeros(3*nPieces-3,1));
        for i=1:nPieces-1
            constrEq_br(3*i-2,1)=subs(q(i),t,breaks(i+1))==...
                subs(q(i+1),t,breaks(i+1));
            constrEq_br(3*i-1,1)=subs(qd1(i),t,breaks(i+1))==...
                subs(qd1(i+1),t,breaks(i+1));
            constrEq_br(3*i,1)=subs(qd2(i),t,breaks(i+1))==...
                subs(qd2(i+1),t,breaks(i+1));
        end
    otherwise
        constrEq_br=[];
end

% optimisation variables equations (necessary?)
switch sTrajType
    case 'spline'
        constrEq_var=sym(zeros(nPieces-3,1));
        for i=1:nPieces-3
            constrEq_var(i,1)=subs(q(i+2),t,breaks(i+2))==...
                designVar(i);
        end
    otherwise
        constrEq_var=[];
end

% combine constraint equations
constrEq=[constrEq_bnd; constrEq_br; constrEq_var];

%% solve constraint equations and substitute solution
% solve equations (eq) by solving constrained variables (constVar)
% as a function of the design variables (designVar)
switch sTrajType
    case {'poly5','poly','cheb','cheb2','spline'}
        fprintf('Solving constraint equations... \n');
        tic
        sol = solve(constrEq,constrVar);
        tsol=toc;
        fprintf(['Solution for constraint equations '...
            'found in %f s. \n\n'],tsol);
        constrVar_sol=struct2array(sol).';
        
        % replace constrained variables (constrVar) with equations obtained
        % from the solution (constrVar_sol)
        q = subs(q,constrVar,constrVar_sol);
        qd1 = subs(qd1,constrVar,constrVar_sol);
        qd2 = subs(qd2,constrVar,constrVar_sol);
    otherwise
%         constrVar_sol =[];
%         tsol = [];
end

% write output
traj.q=q;
traj.qd1=qd1;
traj.qd2=qd2;
traj.breaks=breaks;
traj.designVar=designVar;

% traj.var.symVar=symVar;
% traj.var.constrVar=constrVar;
% traj.var.constrVar_sol=constrVar_sol;
% traj.var.constrEq=constrEq;
% 
% traj.tsol=tsol;

obj.traj = traj;
end

