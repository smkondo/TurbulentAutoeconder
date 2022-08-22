%plotfig.m
%this MATLAB script plots the 3D flow structures from a turbulent channel
%flwo at Re_tau = 180

% Author: Shinya Kondo

clc; clear all; close all;

%% parameters
Re_tau = 180;
nx = 101;
nz = 101;
ny = 97;
%% locations
x = readmatrix('Re180x.csv');
y = readmatrix('Re180y.csv');
z = readmatrix('Re180z.csv');


%% download the velocity data (uncomment each file at separate times)
% udata = load('ucorrupt.mat').data;
% udata = load('ureconstruct.mat').data;
udata = load('uoriginal.mat').data;

u = permute(squeeze(udata(:,1,:,:)),[2,1,3]);
v = permute(squeeze(udata(:,2,:,:)),[2,1,3]);
w = permute(squeeze(udata(:,3,:,:)),[2,1,3]);

%%
[X,Z] = meshgrid(x,z);
figure(1)
pcolor(X,Z,squeeze(u(:,10,:))')
xlabel('x^+')
ylabel('z^+')
title('u''^+(x^+,z^+) at y^+=3.85')
daspect([1 1 1])
colorbar
%% compute the Q-value (second invariant of the velocity gradient)
%at each gridpoint, store the second invariant of the velocity gradient
%tensor and the vorticity components
Q = zeros(size(u)); %1/2*(Omij Omij - Sij Sij)
omx = zeros(size(u)); 
omy = zeros(size(u));
omz = zeros(size(u));
% first compute the velocity gradient tensor at each location
% using central finite difference scheme
for i=2:nx-1
    for j=2:ny-1
        for k=2:nz-1 
            dudx = (u(i+1,j,k)-u(i-1,j,k))/(x(i+1)-x(i-1));
            dudy = (u(i,j+1,k)-u(i,j-1,k))/(y(j+1)-y(j-1));
            dudz = (u(i,j,k+1)-u(i,j,k-1))/(z(k+1)-z(k-1));
            dvdx = (v(i+1,j,k)-v(i-1,j,k))/(x(i+1)-x(i-1));
            dvdy = (v(i,j+1,k)-v(i,j-1,k))/(y(j+1)-y(j-1));
            dvdz = (v(i,j,k+1)-v(i,j,k-1))/(z(k+1)-z(k-1));
            dwdx = (w(i+1,j,k)-w(i-1,j,k))/(x(i+1)-x(i-1));
            dwdy = (w(i,j+1,k)-w(i,j-1,k))/(y(j+1)-y(j-1));
            dwdz = (w(i,j,k+1)-w(i,j,k-1))/(z(k+1)-z(k-1));
            vten = [dudx dudy dudz; dvdx dvdy dvdz; dwdx dwdy dwdz];
%             Q(i,j,k) = 1/2*(trace(vten)^2 - 2*(dudy*dvdx+dudz*dwdx+dvdz*dwdy));
%             [e, ~] = eig(vten);
%             e = real(e);
%             Q(i,j,k) = -1*(dudy*dvdx + dudz*dwdx + dvdz*dwdy);
            Q(i,j,k) =1/2*(trace(vten)^2-trace(vten*vten)); %1/2*(tr(A)^2-tr(A^2))
            omx(i,j,k) = dwdy - dvdz;
            omy(i,j,k) = dwdx - dudz;
            omz(i,j,k) = dvdx - dudy;
        end 
    end 
end 

%% Part G

Q=Q/180^2;

% on the yz plane at i=90 (x = 5.592), plot the color contour of Q+
% [Z,Y] = meshgrid(z,y);
Qplot = Q(90,:,:);
Qplot = reshape(Qplot, 97, 101);
Qmax = max(Qplot, [], 'all');

%also superimpose the streamlines onto the plot
vstream = v(90,:,:);
vstream = reshape(vstream, 97, 101);
wstream = w(90,:,:);
wstream = reshape(wstream, 97, 101);
N = 75; 
zstart = max(z)*rand(N,1); 
ystart = max(y)*rand(N,1); 


%% Part H
%plot the isosurfaces of Q with Q+ = max(Qrms(y))
% u_prime = u-repmat(Umean', [101,1,101]);
u_prime = u;
Qvalue = rms(Q, [1 3]);
Qvalue = max(Qvalue);
[X,Y,Z] = meshgrid(x.*Re_tau,y.*Re_tau,z.*Re_tau);
Q = permute(Q, [2 1 3]);
omx = permute(omx, [2 1 3]);
%%
figure(8)
p = patch(isosurface(X,Y,Z,Q,Qvalue));
isonormals(X,Y,Z,Q,p)
isocolors(X,Y,Z,omx,p)
p.FaceColor = 'interp';
p.EdgeColor = 'none';
hold on

c = colorbar;
hL = title(c,'\omega_x^+','FontSize',14);     
caxis([-30 30])
xlabel('x^+','FontSize',14)
ylabel('y^+','FontSize',14)
zlabel('z^+','FontSize',14)

u_prime = permute(u_prime, [2 1 3]);
p2 = patch(isosurface(X,Y,Z,u_prime,-2));
p2.FaceAlpha = 0.2;
p2.EdgeColor = 'none';
hold off

daspect([1 1 1])


%% AFTER 3D isosurface generation, 
%  Try using the following to get a proper camera position and angle. 

% set camera position and view
fig = gcf;
axes1 = get(fig,'CurrentAxes');
set(axes1,'CameraPosition',-1.35*[-12 18 -9]*Re_tau,'CameraUpVector',[0 1 0],'CameraViewAngle',11,'DataAspectRatio',[1 1 1]);    
    
% add light
camlight('headlight')

% set axes ranges    
ylim( [ 0 1].*Re_tau ); xlim( [ 0 2*pi].*Re_tau );  zlim( [ 0 1*pi].*Re_tau);

% enlarge the figure window
set(gcf, 'Position', [100, 100, 1500, 1000]);

% show edges of the bounding box
box on; 
ax = gca;
ax.BoxStyle = 'full';