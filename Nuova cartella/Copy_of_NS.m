
clear all
clc
restoredefaultpath
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));
addpath(genpath('.'))

addpath(genpath('./results'))
%----------------------------------------
% user input
%----------------------------------------

order_trunc=[3]; % order

LU=1;
omega0=7.384/LU;
coeffnorm=100;
hopf_reference = 49.03266832152;
equilib = false;

X0=[0.01;0.01]; % initial condition for time integration
% X0 = [0.01; 0.01; 0.01; 0.01];

nodes=[2055];  % a node at end of cantilever
% nodes=[1696];
FRCplot=1;

out_name='./results/Uchannel1';
nameode='Uchannel_auto';  % name of ode function
f2use=@Uchannel_auto;   % ode file to use in ./models
namefile='../DPIM_NS 2/output/param_4500.mat'; 
nu0=coeffnorm*LU/4500;

nu=-0.0001;

load(namefile);

%----------------------------------------
% creates ode function
%----------------------------------------

tol = 1e-100;
equations = assembly_function_frc(Avector,fdyn,order_trunc);
for i = 1:size(Avector,2)
  equations{i} = strcat(equations{i},';');
end

fid = fopen(strcat('./models/',nameode,'.m'),'wt');
intro1="function out = ";
fprintf(fid, intro1);
fprintf(fid, nameode);
%fprintf(fid,"\n");
intro2="\n out{1} = @init;\n out{2} = @fun_eval; \n out{3} = [];\n out{4} = [];\n out{5} = [];\n out{6} = [];\n out{7} = [];\n out{8} = [];\n out{9} = [];\n out{10}= @userf1;\nend\n\nfunction dydt = fun_eval(t,x,z3)";
fprintf(fid, intro2);
fprintf(fid, "\n");
for i = 1:size(Avector,2)-1
  dofname=strcat('z',num2str(i),'=x(',num2str(i),');\n');
  fprintf(fid, dofname);
end
fprintf(fid,"dydt=[");
for i = 1:size(Avector,2)-1
  fprintf(fid, strcat(equations{i},'\n'));
end
fprintf(fid,"];\n");
final="end\n\nfunction [tspan,y0,options] = init \n handles = feval(duff_cubic); \n y0=[0,0,0,0]; \n options = odeset('Jacobian',handles(3),'JacobianP',handles(4),'Hessians',[],'HessiansP',[]); \n tspan = [0 10]; \nend\n";
fprintf(fid, final);
fclose(fid);

%----------------------------------------
% matcont setup
%----------------------------------------

addpath(genpath('./Matcont_files')) 
init % matcont init
addpath(genpath('./models'))

%----------------------------------------
% orbit initialization
%----------------------------------------

active_pars=[1]; % sets active parameter ofr continuation: w
ncol=4;  % number of collocation points
ntst=40; % number of discretization segments
tolerance=1e-4;

if ~equilib

%----------------------------------------
% initial time integration: needs to find an estimate for starting cycle
%----------------------------------------

period=2*pi/omega0;
tfin=20*period; % final time where steady steady can be expected
dt=period/200;

% long time integration
hls=feval(f2use);
options=odeset('RelTol',1e-9);
z3=nu;
[t,y]=ode15s(hls{2},0:dt:tfin,X0,options,z3);
figure(10)
plot(t,y(:,1)) % activate to plot

%%
% additional integration over a single period
x1=y(end,:);   % uses end of previous as initial cond
period=2*pi/omega0;
[t,y]=ode113(hls{2},linspace(0,period,320),x1,options,z3);  % one period
plot(t,y(:,1)) % activate to plot
 
%----------------------------------------
% continuation
%----------------------------------------

[vx0,vv0]=initOrbLC(f2use,t,y,[z3],active_pars,ntst,ncol,tolerance);
plot(vx0(1:4:end-2))
opt=contset; % options init
opt=contset(opt,'MaxNumPoints',800); % how many points in FRF
opt=contset(opt,'InitStepsize',4e-4); % initial dimension of continuation arch
opt=contset(opt,'MaxStepsize',4e-3); % max dimension of continuation arch
opt=contset(opt,'MinStepsize',1e-15); % min dimension of continuation arch
%%%%%%%%%%%%%
%%%%%%%%%%%%% IMPORTANT!!!
%%%%%%%%%%%%%
opt=contset(opt,'Backward',1); % if 1 reverses initial tangent: proceed by trial and error
%%%%%%%%%%%%%
%%%%%%%%%%%%%
opt=contset(opt,'Singularities',1);
[xlcc,vlcc,slcc,hlcc,flcc]=cont(@limitcycle,vx0,vv0,opt); % launches continuation
plotcycle(xlcc,vlcc,slcc,[size(xlcc,1) 1 2]);

else

%----------------------------------------
% continuation to find Hopf point
%----------------------------------------
[vx0, vv0] = init_EP_EP(f2use, [0.0,0.0]', [z3], active_pars);
plot(vx0(1:4:end-2))
opt=contset; % options init
opt=contset(opt,'MaxNumPoints',8000); % how many points in FRF
opt=contset(opt,'InitStepsize',4e-6); % initial dimension of continuation arch
opt=contset(opt,'MaxStepsize',4e-5); % max dimension of continuation arch
opt=contset(opt,'MinStepsize',1e-15); % min dimension of continuation arch
%%%%%%%%%%%%%
%%%%%%%%%%%%% IMPORTANT!!!
%%%%%%%%%%%%%
opt=contset(opt,'Backward',0); % if 1 reverses initial tangent: proceed by trial and error
%%%%%%%%%%%%%
%%%%%%%%%%%%%
opt=contset(opt,'Singularities',1);
[xlcc,vlcc,slcc,hlcc,flcc]=cont(@equilibrium,vx0,vv0,opt);
xlcc_cut = xlcc(:,1:slcc(2).index);
save(strcat(out_name,'_eq'),'xlcc','xlcc_cut','ncol','ntst')
cont_par = xlcc(3,:);
xlcc(3,:) = coeffnorm*LU./(nu0+xlcc(3,:));
fprintf("Hopf point found at: %f\n", xlcc(3,slcc(2).index))
fprintf("Hopf point (ref.): %f\n", hopf_reference)
fprintf("Relative error: %.2f%%\n", (xlcc(3,slcc(2).index)/hopf_reference-1)*100)
figure(102);
cpl(xlcc, vlcc, slcc, [3 1]);
xlabel('$Re$', 'Interpreter', 'latex');
ylabel('$u_y$', 'Interpreter', 'latex');
xlcc(3,:) = cont_par;

%----------------------------------------
% continuing periodic orbits
%----------------------------------------
[vx0, vv0] = init_H_LC(f2use, xlcc(1:2,slcc(2).index), xlcc(end,slcc(2).index), active_pars, 1e-9, ntst, ncol);

opt=contset(opt,'MaxNumPoints',700); % how many points in FRF
opt=contset(opt,'InitStepsize',4e-7); % initial dimension of continuation arch
opt=contset(opt,'MaxStepsize',9e-2); % max dimension of continuation arch
opt=contset(opt,'Backward',1); 
opt=contset(opt,'Singularities',1);
[xlcc,vlcc,slcc,hlcc,flcc]=cont(@limitcycle,vx0,vv0,opt);

end
save(out_name,'xlcc','ncol','ntst')
%%
%----------------------------------------
%  FRC plot
%----------------------------------------

% x is a matrix in which each column corresponds to a computed orbit. 
% length(X0) is the number of integrated variable (last ones being nonautonomous) 
% e.g. xlcc(1:length(X0):end-2 gives the history over period of first variable
% last element of each column contains the value of the active parameter
% last but one?? dont know guess number of iter in continuation

nnu=size(xlcc,2);
nvar=length(X0);
FRC=zeros(nvar,nnu);
omega=zeros(1,nnu);
nu=zeros(1,nnu);
for i=1:nnu
  for ivar=1:nvar  
    vx=xlcc(ivar:nvar:end-2,i);
    omega(i)=2*pi/xlcc(end-1,i); % but last is freq
    nu(i)=xlcc(end,i); % last is continuation param
    FRC(ivar,i)=max(vx);
  end
end
Re = coeffnorm*LU./(nu0+nu);

figure(12)
nplotvar=2;
colormap("turbo")
for plotvar=1:nplotvar
subplot(1,nplotvar,plotvar)
scatter3(Re,FRC(plotvar,:),omega,20,omega,'filled')
%scatter3(nu,FRC(plotvar,:),omega,20,omega,'filled')
xlabel("Re")
ylabel(strcat('a_',num2str(plotvar)))
zlabel("\omega")
view(2)
%colorbar
end

%----------------------------------------
%  FRC for mid point
%----------------------------------------

if FRCplot==0

 disp(" ")   
 disp("Physical FRC desactivated. To activate set FRCplot=1 and set correct node")   
 
else    

  nred=size(Avector,2)-1;
  po_all = xlcc; % matcont orbits
  npo = size(po_all,2); % number of matcont orbits
  lpo = size(po_all,1);  % number of points per period
  lpo = ((lpo-2)/(nred)); % number of corrected points per period
      
  nnodes = length(nodes);
  frf = -Inf*ones(npo,nnodes+1);  
  frfm = Inf*ones(npo,nnodes+1);  
  vars = zeros(nred+1,1); 
  harm = [0.0,0.0]; 
    
  [term2use]=terms2use_check(Avector,nred,order_trunc);
  for i = 1:npo
    nu = po_all(end,i);
    vars(nred+1) = nu;
    for j = 1:lpo %loop  pt periodo
      for k = 1:nred %loop dof
        vars(k) = po_all(k+(j-1)*(nred),i);
      end
      % evaluate all the alpha vectors  products all at once
      zprod_all=prod((vars)'.^Avector,2);
      % and also all the displacements, the one to exclude are multiplied by zero
      disp=sum(permute(mappings_r(:,nodes,:),[1,3,2]).*(zprod_all.*term2use),1);
      normdisp = disp(2);
      if (normdisp>frf(i,2))
        frf(i,2)=disp(2); 
        frf(i,1)=coeffnorm*LU/(nu0+nu);%nu;
      end
      if (normdisp<frfm(i,2))
        frfm(i,2)=disp(2); 
        frfm(i,1)=coeffnorm*LU/(nu0+nu);%nu;
      end
    end
  end
  
  figure(100)
%  plot(frf(1:end-1,1),frf(1:end-1,2),'color','r','linewidth',1)
  plot(frf(1:end-1,1),frf(1:end-1,2),'--k')
  %xlim(omega0*[0.5,2])
  
  figure(101)
  plot(frfm(1:end-1,1),frfm(1:end-1,2),'--k')
  %xlim(omega0*[0.5,2])
  
  figure(102)
  hold on
  plot(frfm(1:end-1,1),(frf(1:end-1,2)-frfm(1:end-1,2))/2,'-b')
  %xlim(omega0*[0.5,2])
  xlim([45,60]);
  ylim([0,0.4]);

%   myom=frf(1:end-1,1);
%   mymax=frf(1:end-1,2);
%   myampl=(frf(1:end-1,2)-frfm(1:end-1,2))/2;
%   save('FRCphy.mat','myom','mymax','myampl')

end
%%

% fom = loadFOM('C:\Users\Alessio\Documents\MATLAB\redbKIT-2.2\Problems\FEM_CFD_Dfg2D\Results\snapshots_old');
% %figure(102);
% hold on
% scatter(fom(:,1),fom(:,2), 'k*', 'DisplayName', 'FOM');

% fom = loadFOM('C:\Users\Alessio\Documents\MATLAB\redbKIT-2.2\Problems\FEM_CFD_Dfg2D\Results\snapshots');
% %figure(102);
% hold on
% scatter(fom(:,1),fom(:,2), 'k*', 'DisplayName', 'FOM');
%%


%----------------------------------------------
% create ode matlab function 
%----------------------------------------------
function [equations]=assembly_function_frc(Avector,fdyn,order_trunc)

ndofs=size(Avector,2);
nterms=size(Avector,1);
equations = cell(ndofs,1);
dofspowercombo = cell(nterms,1);

for i = 1:nterms
  manyterms=0;
  if sum(Avector(i,1:ndofs-1))<=order_trunc(1) % check autonomous order
      for j = 1:ndofs
        if (Avector(i,j)~=0)
          if manyterms==0
            if (Avector(i,j)==1)
              dofspower{i} = strcat('z',num2str(j));
              manyterms=1;
            else
              dofspower{i} = strcat('z',num2str(j) ,'^',num2str(Avector(i,j)));
              manyterms=1;
            end
          else
           if (Avector(i,j)==1)
             dofspower{i} = strcat(dofspower{i},'*z',num2str(j));
           else
             dofspower{i} = strcat(dofspower{i},'*z',num2str(j) ,'^',num2str(Avector(i,j)));
           end
          end
        end
      end
  else
    dofspower{i}='skip';
  end
end

for i = 1:size(fdyn,2)
  equations{i}='';
  for j = 1:nterms
    if strcmp(dofspower{j},'skip')==0
      if abs(fdyn(j,i))>0
        if fdyn(j,i)>0
          equations{i}=strcat(equations{i},'+',num2str(fdyn(j,i),'%16.15e'),'*', dofspower{j});
        else
          equations{i}=strcat(equations{i},num2str(fdyn(j,i),'%16.15e'),'*', dofspower{j});
        end
      end
    end
 end
end

end

function [term2use]=terms2use_check(Avector,nred,order_trunc)

    condition1=sum(Avector(:,1:nred+1),2)<=order_trunc(1);  % check autonomous order
%     condition2=sum(Avector(:,nred-1:nred),2)>0; %% if i have NA part
%     condition3=sum(Avector(:,1:nred),2)<=order_trunc(3);% and its combinined sum is less than the desired value
%     condition4=sum(Avector(:,nred-1:nred),2)<=order_trunc(2);% and its combinined sum is less than the
%     condition5=sum(Avector(:,nred-1:nred),2)==0;%% or i do not have NA part
    
    term2use=condition1; %& ((condition2 & condition3 & condition4) | condition5); % gives 1 if the term is needed
    

end
