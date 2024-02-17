
function [hc]=theta_sdiag(theta,s,varargin)
% make the t-s plot given temperature and salinity data with ability to show a third field (e.g., density, depth) in color
% need sw_dens.m from the seawater package 
% usage:
%         hc=theta_sdiag(theta,s,varargin)
%             varargin:
%               ['color',value] : if value=1, the density will be shown in color; 
%                                        otherwise value should be some filed (e.g., depth) with same size as theta/s
%         ['trange',Trange] : the range of temperature shown on the plot (ylim)
%         ['srange',Srange] : the range of salinity shown on the plot (xlim)
%  ['markersize',size-of-marker] : as it tells, the marker size, check scatter for its definition
%     ['caxis',color-range] : the range of the third field shown in color
% e.g.,
%       hc=theta_sdiag(t,s,'color',dep,'caxis',[10 500],'trange',[-2 10],'srange',[31.5 34.8]);

% history:
%
% April 2009: original code by Vihang bhatt
%                    http://www.mathworks.com/matlabcentral/fileexchange/23796-t-s-diagram/content/theta_sdiag.m
% March 2014: enable to show a thrid field in color and more other options by xianmin (xianmin@ualberta.ca)
%                    https://scriptdemo.blogspot.com/2014/03/matlab-make-t-s-diagram-with-third.html


%%%%

if nargin<2
   help theta_sdiag
   return
end

isColor=0;
markerS=16;
if nargin>3
    while(size(varargin,2)>0)
        switch lower(varargin{1})
            case {'iscolor','color'}
                if numel(varargin{2})~=1
                    colorVar=varargin{2};
                    isColor=2;
                else
                    isColor=varargin{2};
                    if isColor==2
                        error('isColor should not equal 2 if no variable specified for the scatter color')
                    end
                end
                varargin(1:2)=[];
            case {'dt','deltat'}
                deltaT=varargin{2};varargin(1:2)=[];
            case {'ds','deltas'}
                deltaS=varargin{2};varargin(1:2)=[];
            case {'tmin','mint'}
                thetamin=varargin{2};varargin(1:2)=[];
            case {'tmax','maxt'}
                thetamax=varargin{2};varargin(1:2)=[];
            case {'trange','tlimit','ylim','tlim'}
                tRange=varargin{2}; thetamax=tRange(2); thetamin=tRange(1); varargin(1:2)=[]; clear tRange
            case {'smin','mins'}
                smin=varargin{2};varargin(1:2)=[];
            case {'smax','maxs'}
                smax=varargin{2};varargin(1:2)=[];
            case {'srange','slimit','xlim','slim'}
                sRange=varargin{2}; smax=sRange(2); smin=sRange(1); varargin(1:2)=[]; clear sRange
            case {'markersize'}
                markerS=varargin{2};varargin(1:2)=[];
            case {'caxis','mycaxis'}
                myCAXIS=varargin{2};varargin(1:2)=[];
            otherwise
        end
    end

end

theta=theta(:);
s=s(:);
if ~exist('smin','var'), smin=min(s)-0.01.*min(s); end
if ~exist('smax','var'), smax=max(s)+0.01.*max(s); end
if ~exist('thetamin','var'), thetamin=min(theta)-0.1*max(theta); end
if ~exist('thetamax','var'), thetamax=max(theta)+0.1*max(theta); end
if ~exist('deltaS','var'), deltaS=0.05; end
if ~exist('deltaT','var'), deltaT=0.25; end

xdim=round((smax-smin)/deltaS+1);
ydim=round((thetamax-thetamin)/deltaT+1);
dens=zeros(ydim,xdim);
thetai=((1:ydim)-1)*deltaT+thetamin;
si=((1:xdim)-1)*deltaS+smin;

for j=1:ydim
    for i=1:xdim
        dens(j,i)=sw_dens(si(i),thetai(j),0);
    end
end

dens=dens-1000;
[c,h]=contour(si,thetai,dens,'k');
clabel(c,h,'LabelSpacing',1000);
% xlabel('Salinity [psu]','FontWeight','bold','FontSize',10,'fontname','Nimbus Sans L')
% ylabel('Potentiel temperature [°C]','FontWeight','bold','FontSize',10,'fontname','Nimbus Sans L')
% set(gca,'fontname','Nimbus Sans L')
% 
%% plotting scatter plot of theta and s;
hold on;

if isColor==1
   mydens=sw_dens(s,theta,0)-1000;
   hc=scatter(s,theta,markerS,mydens,'o','fill');
   set(hc,'markeredgecolor','none');
elseif isColor==2 % use the depth as color
   if ~exist('myCAXIS','var')
       myCAXIS=[nanmin(colorVar(:)) nanmax(colorVar(:))];
   end
   caxis(myCAXIS);
   hc=scatter(s,theta,markerS,colorVar(:),'o','fill');
   set(hc,'markeredgecolor','none');
   cmap=jet(10); colormap(cmap); 
   h=colorbar;
   title(h,'Depth [m]','interpreter','latex')

end

if nargout==0
   clear hc
end