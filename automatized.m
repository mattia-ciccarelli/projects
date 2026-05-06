% =========================================================================
% MEGA-SCRIPT AUTOMATIZZATO: BIFORCAZIONE MATCONT + TKE (PARALLELIZZATO)
% =========================================================================
clear all
close all
clc
restoredefaultpath
% Sostituisci la parte del "matlab.desktop.editor" con questa:
cd(fileparts(mfilename('fullpath')));
addpath(genpath('.'))
addpath(genpath('./results'))

% 1. AVVIO DEL PARPOOL (Una sola volta, fuori dal ciclo)
poolobj = gcp('nocreate');
if isempty(poolobj)
    parpool; 
end

% 2. DEFINIZIONE DELLE CARTELLE DA ANALIZZARE
% Inserisci qui i nomi esatti delle cartelle di input generate da Julia.
% Si presume che si trovino tutte dentro la cartella './results/'
cartelle_input = {'Re5000_Ordine3', 'Re5200_Ordine3', 'Re4800_Ordine3'}; 

% =========================================================================
% 3. INIZIO CICLO AUTOMATIZZATO SUI VARI CASI
% =========================================================================
for c = 1:length(cartelle_input)
    cartella_corrente = cartelle_input{c};
    fprintf('\n======================================================\n');
    fprintf('ELABORAZIONE IN CORSO CARTELLA: %s\n', cartella_corrente);
    fprintf('======================================================\n');
    
    %----------------------------------------
    % user input (Percorsi Aggiornati Dinamicamente)
    %----------------------------------------
    order_trunc=[3]; 
    LU = 1;
    omega0=7.384/LU;
    coeffnorm=100;  
    hopf_reference = 4339.31;
    equilib = true;  
    X0 = [0.01; 0.01; 0.01; 0.01]; 
    nodes=[21524];  
    FRCplot=1;
    
    % ---- PERCORSI DINAMICI ----
    out_name = strcat('../DPIM_NS 2/results/', cartella_corrente, '/Uchannel1');
    nameode = 'Uchannel_auto';
    f2use = @Uchannel_auto;
    namefile = strcat('../DPIM_NS 2/results/', cartella_corrente, '/param.mat'); 
    
    nu0=coeffnorm*LU/5000;
    nu=nu0+0.0001;
    par_nu=nu;   
    
    load(namefile);
    nred=size(Avector,2)-1;
    
    %----------------------------------------
    % creates ode function
    %----------------------------------------
    tol = 1e-100;
    equations = assembly_function_frc(Avector,fdyn,order_trunc);
    for i = 1:size(Avector,2)
      equations{i} = strcat(equations{i},';');
    end
    
    % Crea la cartella 'models' in automatico se non esiste già
    if ~exist('./models/', 'dir')
        mkdir('./models/');
    end
    
    fid = fopen(strcat('./models/',nameode,'.m'),'wt');
    intro1="function out = ";
    fprintf(fid, intro1);
    fprintf(fid, nameode);
    intro2 = ['\n out{1} = @init;\n out{2} = @fun_eval; \n out{3} = [];\n out{4} = [];\n out{5} = [];\n out{6} = [];\n out{7} = [];\n out{8} = [];\n out{9} = [];\n out{10}= @userf1;\nend\n\nfunction dydt = fun_eval(t,x,z', num2str(nred+1), ')'];
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
    init 
    addpath(genpath('./models'))
    
    %----------------------------------------
    % orbit initialization
    %----------------------------------------
    active_pars=[1]; 
    ncol=4;  
    ntst=40; 
    tolerance=1e-4;
    
    if ~equilib
        period=2*pi/omega0;
        tfin=20*period; 
        dt=period/200;
        hls=feval(f2use);
        options=odeset('RelTol',1e-9);
        par_nu=nu;
        [t,y]=ode15s(hls{2},0:dt:tfin,X0,options,par_nu);
        figure(10)   
        plot(t,y(:,1)) 
        
        x1=y(end,:);   
        period=2*pi/omega0;
        [t,y]=ode113(hls{2},linspace(0,period,320),x1,options,par_nu);  
        plot(t,y(:,1)) 
         
        [vx0,vv0]=initOrbLC(f2use,t,y,[par_nu],active_pars,ntst,ncol,tolerance);
        plot(vx0(1:4:end-2))
        opt=contset; 
        opt=contset(opt,'MaxNumPoints',800); 
        opt=contset(opt,'InitStepsize',4e-4); 
        opt=contset(opt,'MaxStepsize',4e-3); 
        opt=contset(opt,'MinStepsize',1e-15); 
        opt=contset(opt,'Backward',1); 
        opt=contset(opt,'Singularities',1);
        [xlcc,vlcc,slcc,hlcc,flcc]=cont(@limitcycle,vx0,vv0,opt); 
        plotcycle(xlcc,vlcc,slcc,[size(xlcc,1) 1 2]);
    else
        [vx0, vv0] = init_EP_EP(f2use, zeros(nred,1), [par_nu], active_pars);
        plot(vx0(1:4:end-2))
        opt=contset; 
        opt=contset(opt,'MaxNumPoints',8000); 
        opt=contset(opt,'InitStepsize',4e-6); 
        opt=contset(opt,'MaxStepsize',4e-5); 
        opt=contset(opt,'MinStepsize',1e-15); 
        opt=contset(opt,'Backward',1); 
        opt=contset(opt,'Singularities',1);
        [xlcc,vlcc,slcc,hlcc,flcc]=cont(@equilibrium,vx0,vv0,opt);
        xlcc_cut = xlcc(:,1:slcc(2).index);
        save(strcat(out_name,'_eq'),'xlcc','xlcc_cut','ncol','ntst')
        cont_par = xlcc(nred+1,:);
        xlcc(nred+1,:) = coeffnorm*LU./(nu0+xlcc(nred+1,:));
        fprintf("Hopf point found at: %f\n", xlcc(nred+1,slcc(2).index))
        fprintf("Hopf point (ref.): %f\n", hopf_reference)
        fprintf("Relative error: %.2f%%\n", (xlcc(nred+1,slcc(2).index)/hopf_reference-1)*100)
        figure(102);
        cpl(xlcc, vlcc, slcc, [nred+1 1]);
        xlabel('$Re$', 'Interpreter', 'latex');
        ylabel('$u_y$', 'Interpreter', 'latex');
        xlcc(nred+1,:) = cont_par;
        
        [vx0, vv0] = init_H_LC(f2use, xlcc(1:nred,slcc(2).index), xlcc(end,slcc(2).index), active_pars, 1e-9, ntst, ncol);
        opt=contset(opt,'MaxNumPoints',800); 
        opt=contset(opt,'InitStepsize',4e-7); 
        opt=contset(opt,'MaxStepsize',9e-3); 
        opt=contset(opt,'Backward',1); 
        opt=contset(opt,'Singularities',1);
        [xlcc,vlcc,slcc,hlcc,flcc]=cont(@limitcycle,vx0,vv0,opt);
    end
    save(out_name,'xlcc','ncol','ntst')
    
    %----------------------------------------
    %  FRC plot
    %----------------------------------------
    nnu=size(xlcc,2);
    nvar=length(X0);
    FRC=zeros(nvar,nnu);
    omega=zeros(1,nnu);
    nu=zeros(1,nnu);
    for i=1:nnu
      for ivar=1:nvar  
        vx=xlcc(ivar:nvar:end-2,i);
        omega(i)=2*pi/xlcc(end-1,i); 
        nu(i)=xlcc(end,i); 
        FRC(ivar,i)=max(vx);
      end
    end
    Re = coeffnorm*LU./(nu0+nu);
    figure(12)
    nplotvar=4;
    colormap("turbo")
    for plotvar=1:nplotvar
        subplot(1,nplotvar,plotvar)
        scatter3(Re,FRC(plotvar,:),omega,20,omega,'filled')
        xlabel("Re")
        ylabel(strcat('a_',num2str(plotvar)))
        zlabel("\omega")
        view(2)
    end
    
    % --- SALVATAGGIO FIGURA MATCONT 12 (Formato .fig) ---
    saveas(figure(12), strcat('../DPIM_NS 2/results/', cartella_corrente, '/Figure_12_FRC_3D.fig'));
    
    %----------------------------------------
    %  FRC for mid point
    %----------------------------------------
    if FRCplot==0
        disp("Physical FRC desactivated. To activate set FRCplot=1 and set correct node")   
    else    
      nred=size(Avector,2)-1;
      po_all = xlcc; 
      npo = size(po_all,2); 
      lpo = size(po_all,1);  
      lpo = ((lpo-2)/(nred)); 
          
      nnodes = length(nodes);
      frf = -Inf*ones(npo,nnodes+1);  
      frfm = Inf*ones(npo,nnodes+1);  
      vars = zeros(nred+1,1); 
      harm = [0.0,0.0]; 
        
      [term2use]=terms2use_check(Avector,nred,order_trunc);
      for i = 1:npo
        nu = po_all(end,i);
        vars(nred+1) = nu;
        for j = 1:lpo 
          for k = 1:nred 
            vars(k) = po_all(k+(j-1)*(nred),i);
          end
          zprod_all=prod((vars)'.^Avector,2);
          disp_val=sum(permute(mappings_r(:,nodes,:),[1,3,2]).*(zprod_all.*term2use),1);
          normdisp = disp_val(2);
          if (normdisp>frf(i,2))
            frf(i,2)=disp_val(2); 
            frf(i,1)=coeffnorm*LU/(nu0+nu);
          end
          if (normdisp<frfm(i,2))
            frfm(i,2)=disp_val(2); 
            frfm(i,1)=coeffnorm*LU/(nu0+nu);
          end
        end
      end
      
      figure(100)
      plot(frf(1:end-1,1),frf(1:end-1,2),'--k')
      xlim([4000,5000]);
      
      figure(101)
      plot(frfm(1:end-1,1),frfm(1:end-1,2),'--k')
      xlim([4000,5000]);
      
      figure(102)
      hold on
      plot(frfm(1:end-1,1),(frf(1:end-1,2)-frfm(1:end-1,2))/2,'-b')
      xlim([4000,5000]);
      
      % --- SALVATAGGIO FIGURE MATCONT 100, 101, 102 (Formato .fig) ---
      saveas(figure(100), strcat('../DPIM_NS 2/results/', cartella_corrente, '/Figure_100_FRC_Upper.fig'));
      saveas(figure(101), strcat('../DPIM_NS 2/results/', cartella_corrente, '/Figure_101_FRC_Lower.fig'));
      saveas(figure(102), strcat('../DPIM_NS 2/results/', cartella_corrente, '/Figure_102_FRC_Amplitude.fig'));
    end

    % =========================================================================
    % PARTE 2: CALCOLO ANALITICO DELLA TKE (PARALLELIZZATO)
    % =========================================================================
    
    % --- MESSAGGIO DI AVVISO PER L'UTENTE ---
    fprintf('\n---> TKE calculation...\n');
    
    
    addpath(genpath('../../MatCont7p6')) 
    
    % ---- CARICAMENTO DINAMICO DEI DATI ----
    load(namefile, 'mappings_r', 'Avector','M');
    load(out_name, 'xlcc', 'ncol', 'ntst'); 
    
    LU = 1;
    coeffnorm = 100;
    nu0 = coeffnorm * LU / 5000; 
    order_trunc = [3]; 
    [nPages, nNodes, nComponents] = size(mappings_r);
    nred = size(Avector, 2) - 1; 
    
    condition1 = sum(Avector(:, 1:nred+1), 2) <= order_trunc(1);
    term2use = condition1;
    
    po_all = xlcc;   
    npo = size(po_all, 2); 
    lpo = size(po_all, 1);
    lpo = (lpo - 2) / nred; 
    
    Re_list = zeros(1, npo);
    TKE_mean = zeros(1, npo);
    M_scalar = M(1:nNodes, 1:nNodes);
    
    parfor i = 1:npo
        nu = po_all(end, i);
        Re_list(i) = coeffnorm * LU / (nu0 + nu);
        
        vars = zeros(nred+1, 1);
        vars(nred+1) = nu;
        
        U_fluct_time = zeros(lpo, nNodes, nComponents);
        
        for j = 1:lpo
            for k = 1:nred
                vars(k) = po_all(k + (j-1)*nred, i); 
            end
            zprod_all = prod((vars)'.^Avector, 2);
            zprod_all_3D = reshape(zprod_all .* term2use, [nPages, 1, 1]);
            U_fluct_time(j, :, :) = sum(mappings_r .* zprod_all_3D, 1);
        end
        
        U_mean = squeeze(mean(U_fluct_time, 1));  
        TKE_time = zeros(1, lpo);
        
        for j = 1:lpo
            u_turb = squeeze(U_fluct_time(j, :, :)) - U_mean;
            u_comp = u_turb(:, 1); 
            v_comp = u_turb(:, 2); 
            TKE_time(j) = 0.5 * (u_comp' * M_scalar * u_comp + v_comp' * M_scalar * v_comp); 
        end
        
        TKE_mean(i) = mean(TKE_time);
    end
    
    % --- PLOT TKE E SALVATAGGIO (Formato .fig) ---
    fig_tke = figure('Name', 'Bifurcation Diagram - TKE', 'Color', 'w');
    plot(Re_list, TKE_mean, '-b', 'LineWidth', 2);
    grid on;
    xlabel('$Re$', 'Interpreter', 'latex', 'FontSize', 14);
    ylabel('$\langle TKE \rangle$', 'Interpreter', 'latex', 'FontSize', 14);
    title(sprintf('Turbulent Kinetic Energy (ROM Order %d)', order_trunc(1)), 'FontSize', 12);
    xlim([4000,6000]);
    
    saveas(fig_tke, strcat('../DPIM_NS 2/results/', cartella_corrente, '/Figure_TKE_Diagram.fig'));
    
    % CHIUSURA DELLE FIGURE PER LIBERARE MEMORIA
    close all; 
    fprintf('---> Dati e grafici (.fig) salvati con successo per %s\n', cartella_corrente);
    
end % Fine del ciclo sulle cartelle

disp('TUTTE LE CARTELLE SONO STATE PROCESSATE CON SUCCESSO!');

%----------------------------------------------
% FUNZIONI LOCALI (Devono stare in fondo allo script)
%----------------------------------------------
function [equations]=assembly_function_frc(Avector,fdyn,order_trunc)
ndofs=size(Avector,2);
nterms=size(Avector,1);
equations = cell(ndofs,1);
dofspowercombo = cell(nterms,1);
for i = 1:nterms
  manyterms=0;
  if sum(Avector(i,1:ndofs-1))<=order_trunc(1) 
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
    condition1=sum(Avector(:,1:nred+1),2)<=order_trunc(1);  
    term2use=condition1; 
end