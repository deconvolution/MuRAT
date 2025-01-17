function AQc_i                   =...
    Murat_codaMatrix(modvQc,K_grid,r_grid,flag,origin,sections)
% function AQc_i                   =...
%     Murat_codaMatrix(modvQc,origin,sections,flag,K_grid,r_grid)
%
% CREATES the coda attenuation inversion matrix and plots the corresponding
%   kernels
%
% Input parameters:         
%    modvQc:                velocity model for grid
%    K_grid:                kernel from Murat_kernels
%    r_grid:                grid from Murat_kernels
%    flag:                  if turned to 1 creates the figure
%    origin:                origin of the grid
%    sections:              sections of the figure
%
% Output parameters:
%    AQc_i:                 coda inversion matrix

% Nodes of the kernel model space
xK                              =   unique(r_grid(:,1));
yK                              =   unique(r_grid(:,2));
zK                              =   sort(unique(r_grid(:,3)),'descend');

[Xk,Yk,Zk,K]                    =   Murat_fold(xK,yK,zK,K_grid);

% Interpolated axes for inversion model
x                               =   unique(modvQc(:,1));
y                               =   unique(modvQc(:,2));
z                               =   sort(unique(modvQc(:,3)),'descend');

% Interpolation sets everything in the right place
[X,Y,Z,~]                       =   Murat_fold(x,y,z);

% Kernel in inversion grid space
mK                              =   interp3(Xk,Yk,Zk,K,X,Y,Z);

%In case limits outside of the grid interpolate better
if find(isnan(mK))
    mK(isnan(mK))               =   10^-100;
    mK(mK == 0)                 =   10^-100;
    if isempty(find(mK, 1))
        
        mod_K                   =   Murat_unfold(x,y,z);
        mod_K(:,4)              =   0;
        [~,maxK]                =   max(K_grid);
        rmax                    =   r_grid(maxK,:);
        [~,min_K]               =   min(sqrt((mod_K(:,1)-rmax(1)).^2 ...
        + (mod_K(:,2)-rmax(2)).^2 + (mod_K(:,3)-rmax(3)).^2));
        mod_K(min_K,4)          =   1;
        [~,~,~,mK]              =   Murat_fold(x,y,z,mod_K(:,4));

    end
end

% Kernel in its grid space
if flag == 1
    sections1                   =   [sections(2) sections(1) sections(3)];
    Xk1                         =   origin(1) + km2deg(Xk/1000);
    Yk1                         =   origin(2) + km2deg(Yk/1000);
    X1                          =   origin(1) + km2deg(X/1000);
    Y1                          =   origin(2) + km2deg(Y/1000);

    subplot(1,2,1)
    Murat_imageKernels(Xk1,Yk1,Zk,log(K),'default',sections1)
    
    subplot(1,2,2)
    Murat_imageKernels(X1,Y1,Z,log(mK),'default',sections1)
    
end

%pre-define 3D matrix in space
lx                              =   length(x);
ly                              =   length(y);
lz                              =   length(z);
index                           =   0;
AQc_i                           =   zeros(1,(length(modvQc(:,1))));
for i=1:lx
    for j=1:ly
        for k=1:lz
            index               =   index+1;
            AQc_i(index)        =   mK(i,j,k);
        end
    end
end

% Residual from cutting the grid (it is always < 1%).
AQc_i                           =   AQc_i/sum(AQc_i);
end