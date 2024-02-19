function varargout = classwms(varargin)
% CLASSWMS MATLAB code for classwms.fig
%      CLASSWMS, by itself, creates a new CLASSWMS or raises the existing
%      singleton*.
%
%      H = CLASSWMS returns the handle to a new CLASSWMS or the handle to
%      the existing singleton*.
%
%      CLASSWMS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CLASSWMS.M with the given input arguments.
%
%      CLASSWMS('Property','Value',...) creates a new CLASSWMS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before classwms_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to classwms_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help classwms

% Last Modified by GUIDE v2.5 18-Feb-2024 14:03:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @classwms_OpeningFcn, ...
                   'gui_OutputFcn',  @classwms_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before classwms is made visible.
function classwms_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to classwms (see VARARGIN)
% Choose default command line output for classwms
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = classwms_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function axes6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes6
%%%% Plot global map on the main window of the tool just after runing the
%%%% main code
%%% add gsw toolbox path
selpath = uigetdir('','Add GSW toolbox path');
addpath(genpath(selpath))
msg=sprintf('%s direcoty has been added successfully', selpath);
%%%
axesm('mercator','MapLatLimit',[-90 90],'MapLonLimit',[-180 180],...
'Frame','on','Grid','on','MeridianLabel','on','ParallelLabel','on',...
'MLabelLocation',[-180:40:180],'PLabelLocation',[-90:20:90])
axis off; 
geoshow('landareas.shp','FaceColor',[ 0.5 0.3 0.1 ])
daspect auto
dlg = msgbox(msg);




% --------------------------------------------------------------------
function openfile_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to openfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%% import the data ascii file that the user want to classify 
global dep tmp sal lon lat
try
[stmfile, stmpath]=uigetfile('data_to_classify.txt');
file= uiimport(fullfile(stmpath, stmfile),'rt');
lon=file.longitude;  lat=file.latitude;
dep=file.depth;  tmp=file.temperature;
sal=file.salinity;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cla(handles.axes6)
axes(handles.axes6)
axesm('mercator','MapLatLimit',[nanmin(lat)-1 nanmax(lat)+1],...
    'MapLonLimit',[nanmin(lon)-2 nanmax(lon)+2],...
'Frame','on','Grid','on','MeridianLabel','on','ParallelLabel','on',...
'MLineLocation',linspace(nanmin(lon)-2,nanmax(lon)+2,4),'MLabelLocation',...
linspace(nanmin(lon)-2,nanmax(lon)+2,4),'MLabelRound',-2, ...
'PLineLocation',linspace(nanmin(lat)-1,nanmax(lat)+1,4),'PLabelLocation'...
,linspace(nanmin(lat)-1,nanmax(lat)+1,4),'PLabelRound',-2);
axis off; 
geoshow('landareas.shp','FaceColor',[ 0.5 0.3 0.1 ])
geoshow(lat, lon, 'DisplayType', 'Point','Color', 'black',...
 'linewidth',1,'marker','o','markeredgecolor','r',...
 'markerfacecolor','r','MarkerSize',2);
% daspect auto
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Plot vertical profils of temperature and salinity
figure('Name','Tempearture and Salinity profiles')
subplot 121
plot(tmp,dep,'.r','linewidth',10);
set(gca,'Ydir','reverse') 
ylabel('Depth [m]',...
 'Interpreter','Latex');
xlabel ('Temperature [$$^{\circ} C$$]','interpreter','latex')
set(gcf,'Color','w')
grid on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot 122
plot(sal,dep,'.g','linewidth',10);
set(gca,'Ydir','reverse') 
ylabel('Depth [m]',...
 'Interpreter','Latex');
xlabel ('Salinity [psu]','interpreter','latex')
set(gcf,'Color','w')
grid on
%%%%%%%% plot the theta-s diagram
figure('Name','Tempearture and Salinity diagram')
SAL=gsw_SA_from_SP(sal,dep,nanmean(lon),nanmean(lat));
TMP=gsw_CT_from_t(SAL,tmp,dep);
gsw_SA_CT_plot(SAL,TMP)
set(gcf,'Color','w')
xlabel ('Absolute Salinity [g/kg]','interpreter','latex')
ylabel ('Conservative Temperature [$$^{\circ} C$$]','interpreter','latex')
title('');
%%%%%%%%%% plot the sigma-pi diagram
figure('Name','Sigma Pi diagram');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sigma=gsw_sigma0(SAL,TMP); %%% potential density
spi=gsw_pspi(SAL,TMP,0);%%% potential spicity
hc=scatter(spi,sigma,16,dep,'o','fill');
set(hc,'markeredgecolor','none');
cmap=jet(10); colormap(cmap); h=colorbar; title(h,'Depth [m]','interpreter','latex')
set(gcf,'Color','w'); 
grid on
xlabel('Potential spicity [$$ kg/m^{3} $$]','interpreter','latex');
ylabel('Potential density [$$ kg/m^{3} $$]','interpreter','latex');
set(gca,'Ydir','reverse'); 
catch exception 
    f = warndlg('file error','Warning');
    return
end



% % --------------------------------------------------------------------
function Clustering_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Clustering (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%% apply k-means clustering on data
global sal tmp K data G 
try
if isempty(tmp)
  f = warndlg('Please try to import file first','Warning'); 
return
end
prompt = {'Enter the number of cluster'};
dlgtitle = 'K';
answer = inputdlg(prompt,dlgtitle,[1 50]);
if isempty(answer)
   return
end
K=str2double(answer{1});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ButtonName = questdlg( ...
'Choose the method for initial cluster centroid positions','Selection', ...
 'Random centroid','User centroid','Random centroid');
    switch ButtonName
      case 'Random centroid'
          try
            T_n=(tmp-min(tmp))./(max(tmp)-min(tmp)); %% data temperature normalisation
            S_n=(sal-min(sal))./(max(sal)-min(sal)); %% data salinity normalisation
            data=[S_n T_n];
            [G C sumD D]=kmeans(data,K);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% plot clustering results using random centroid
            figure('Name','Clustering analysis results')
            gscatter (sal,tmp,G)
            xlabel ('Salinity [psu]','interpreter','latex')
            ylabel ('Temperature [$$^{\circ} C$$]','interpreter','latex')
            set(gcf,'Color','w')
            grid on
          catch exception 
              f = warndlg('can not perform kmeans classification','Warning');
              return
          end
      case 'User centroid'
         try
          pos=[];POS=[];
          for i=1:K
              txt1=sprintf('Enter the salinity centroid Number %d',i);
              txt2=sprintf('Enter the temperature centroid Number %d',i);
              prompt = {txt1,txt2};
              dlgtitle = 'Centroids';
              answer = inputdlg(prompt,dlgtitle,[1 50]);
              if isempty(answer)
                 return
              end
              sal_c=str2double(answer(1,:)); tmp_c=str2double(answer(2,:));
              %%% temperature and salinity centroids normalisation 
              %%% for each water mass
              T_cn=(tmp_c-min(tmp))./(max(tmp)-min(tmp)); 
              S_cn=(sal_c-min(sal))./(max(sal)-min(sal)); 
              pos_tmp=[S_cn T_cn]; pos=[pos ; pos_tmp];
              pos_tmp=[sal_c tmp_c]; POS=[POS; pos_tmp];
          end
           T_n=(tmp-min(tmp))./(max(tmp)-min(tmp)); %% data temperature normalisation
           S_n=(sal-min(sal))./(max(sal)-min(sal));  %% data salinity normalisation
           data=[S_n T_n];  [G C sumD D]=kmeans(data,K,'Start',pos);
         catch exception 
            f = warndlg('can not perform kmeans classification','Warning');
            return
         end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              %%% plot clustering results using user centroid
            figure('Name','Clustering analysis results')
            gscatter (sal,tmp,G)
            hold on; plot(POS(:,1),POS(:,2),'or','DisplayName','initial centroids');
            xlabel ('Salinity [psu]','interpreter','latex')
            ylabel ('Temperature [$$^{\circ} C$$]','interpreter','latex')
            grid on;  set(gcf,'Color','w');
    end
catch exception
    f = warndlg('can not perform kmeans classification','Warning');
    return
end

% --------------------------------------------------------------------
function silhouette_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to silhouette (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%%%% Silhouette plot after applying k-means
global data G K
if isempty(G)
  f = warndlg('No clusters are found. Please try to perform clustering analysis first','Warning'); 
  return
end
s=silhouette(data,G);N=length(data);
figure('Name','Silhouette values'); yyaxis right; grid on; hold on; moy=mean(s);
a=plot(moy.*ones(1,2),1:2,'r','linewidth',2); ax = gca; 
ax.YAxis(1).Color = 'k'; ax.YAxis(2).Color = 'k'; ax.YTick=[];
yyaxis left; [~,ord] = sortrows([G s],[1 -2]);
indices = accumarray(G(ord), 1:N, [K 1], @(x){sort(x)});
ytick = cellfun(@(ind) (min(ind)+max(ind))/2, indices);
ytickLabels = num2str((1:K)','%d'); h = barh(1:N, s(ord),'hist'); colors = lines(K);
set(h, 'EdgeColor',[0.55 0.55 0.55], 'CData',G(ord),'FaceColor',[0.55 0.55 0.55]);
set(gca, 'CLim',[1 K], 'CLimMode','manual')
set(gca, 'YDir','reverse', 'YTick',ytick, 'YTickLabel',ytickLabels)
xlabel('Silhouette Value','interpreter','latex'), ylabel('Cluster','interpreter','latex')
title(sprintf('average value : %.2f', moy), 'color' ,'red')
set(gcf,'color','w')



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in validate.
function validate_Callback(hObject, eventdata, handles)
% hObject    handle to validate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%% Modifiy the basemap limits on the main window by specifying the
%%%%% maximum and minimum values of longitude and latitude in decimal
%%%%% degrees

global lon_max lon_min lat_max lat_min lon lat LON LAT
try
lat_max=get(handles.edit4,'String');
lat_max=str2double(lat_max);
lat_min=get(handles.edit6,'String');
lat_min=str2double(lat_min);
lon_max=get(handles.edit1,'String');
lon_max=str2double(lon_max);
lon_min=get(handles.edit2,'String');
lon_min=str2double(lon_min);
if isnan(lon_min)||isnan(lon_max)||isnan(lat_min)||isnan(lat_max)
  f = warndlg('fill all empty fields','Warning'); 
  return
end
cla(handles.axes6)
axes(handles.axes6)
axesm('mercator','MapLatLimit',[lat_min lat_max],...
    'MapLonLimit',[lon_min lon_max],...
'Frame','on','Grid','on','MeridianLabel','on','ParallelLabel','on',...
'MLineLocation',linspace(lon_min,lon_max,4),'MLabelLocation',...
linspace(lon_min,lon_max,4),'MLabelRound',-2, ...
'PLineLocation',linspace(lat_min,lat_max,4),'PLabelLocation'...
,linspace(lat_min,lat_max,4),'PLabelRound',-2);
axis off; 
geoshow('landareas.shp','FaceColor',[ 0.5 0.3 0.1 ])
if ~isempty(lon)
geoshow(lat, lon, 'DisplayType', 'Point','Color', 'black',...
 'linewidth',1,'marker','o','markeredgecolor','r',...
 'markerfacecolor','r','MarkerSize',2);
end
if ~isempty(LON)
geoshow(LAT,LON, 'DisplayType', 'Point','Color', 'black',...
 'linewidth',1,'marker','o','markeredgecolor','b',...
 'markerfacecolor','b','MarkerSize',1);
end
% daspect auto
catch exception 
    f = warndlg('limits error','Warning');
end


% --- Executes on button press in restore.
function restore_Callback(hObject, eventdata, handles)
% hObject    handle to restore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%% restore the basemap to the global initial view
cla(handles.axes6)
axes(handles.axes6)
axesm('mercator','MapLatLimit',[-90 90],'MapLonLimit',[-180 180],...
'Frame','on','Grid','on','MeridianLabel','on','ParallelLabel','on',...
'MLabelLocation',[-180:40:180],'PLabelLocation',[-90:20:90])
axis off; 
geoshow('landareas.shp','FaceColor',[ 0.5 0.3 0.1 ])
daspect auto
% --- Executes during object creation, after setting all properties.

function restore_CreateFcn(hObject, eventdata, handles)
% hObject    handle to restore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --------------------------------------------------------------------
function Labeling_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Labeling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%% execute the labeling process by importing the database file and 
%%%%%  ploting the geographic postions of the database oceanographic profiles   
global S T indice name SAL TMP DEP LON LAT lon lat
S=[]; T=[]; indice=[]; name={}; 
try
[stmfile, stmpath]=uigetfile('database_not_labeled.txt');
file= uiimport(fullfile(stmpath, stmfile),'rt');
LON=file.longitude;  LAT=file.latitude;
DEP=file.depth;  TMP=file.temperature; SAL=file.salinity;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cla(handles.axes6)
axes(handles.axes6)
axesm('mercator','MapLatLimit',[nanmin(LAT)-1 nanmax(LAT)+1],...
    'MapLonLimit',[nanmin(LON)-2 nanmax(LON)+2],...
'Frame','on','Grid','on','MeridianLabel','on','ParallelLabel','on',...
'MLineLocation',linspace(nanmin(LON)-2,nanmax(LON)+2,4),'MLabelLocation',...
linspace(nanmin(LON)-2,nanmax(LON)+2,4),'MLabelRound',-2, ...
'PLineLocation',linspace(nanmin(LAT)-1,nanmax(LAT)+1,4),'PLabelLocation'...
,linspace(nanmin(LAT)-1,nanmax(LAT)+1,4),'PLabelRound',-2);
axis off; 
geoshow('landareas.shp','FaceColor',[ 0.5 0.3 0.1 ])
geoshow(LAT, LON, 'DisplayType', 'Point','Color', 'black',...
 'linewidth',1,'marker','o','markeredgecolor','b',...
 'markerfacecolor','b','MarkerSize',1);
if exist ('lon','var') 
    geoshow(lat, lon, 'DisplayType', 'Point','Color', 'black',...
     'linewidth',1,'marker','o','markeredgecolor','r',...
     'markerfacecolor','r','MarkerSize',2);
end
catch exception 
    f = warndlg('file error','Warning');
    return
end
try
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% show the figure dedicated to the labeling process with push buttons 
f=figure('Name','Labeling process','position',[488,123,776,638],...
    'Resize','off');
plot(SAL,TMP,'.k','MarkerSize',6); 
xlabel ('Salinity [psu]','interpreter','latex')
ylabel ('Temperature [$$^{\circ} C$$]','interpreter','latex')
set(gca,'Color','w')
%%% push button to choose a name of the water mass reprsenting the data
%%% that will be selected by user
uicontrol('Parent',f,'Position',[413 600 90 30],'String',...
        'Name','FontWeight','bold','BackgroundColor',...
        [0.94 0.94 0.94],'Callback',@Name);
%%% push button to select data
uicontrol('Parent',f,'Position',[213 600 90 30],'String',...
        'Select','FontWeight','bold','BackgroundColor',...
        [0.94 0.94 0.94],'Callback',@Select);
%%% push button to save selected data
uicontrol('Parent',f,'Position',[313 600 90 30],'String',...
        'Save','FontWeight','bold','BackgroundColor',...
        [0.94 0.94 0.94],'Callback',@Save);
%%% push button to cancel the previous operations
 uicontrol('Parent',f,'Position',[513 600 90 30],'String',...
        'Cancel','FontWeight','bold','BackgroundColor',...
        [0.94 0.94 0.94],'Callback',@Cancel);
catch exception 
    f = warndlg('Labeling error','Warning');
    return
end
    
    
% --------------------------------------------------------------------
function KNN_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to KNN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%% apply the whole process of knn classification
global tmp sal  dep  LON LAT
try
%%%%% import the labeled database file
[stmfile, stmpath]=uigetfile('database_labeled.txt');
% file= uiimport(fullfile(stmpath, stmfile),'rt');
% FileName=uigetfile('database_labeled.txt');
fullfile(stmpath, stmfile)
A=readtable(fullfile(stmpath, stmfile)); A=table2cell(A);
spi=A(:,1); rho=A(:,2); WM=A(:,3); 
spi=cell2mat(spi);rho=cell2mat(rho);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
X=[spi rho];
if isempty(tmp)
  f = warndlg('Please try to import file first','Warning'); 
return
end
catch exception 
    f = warndlg('file error','Warning');
    return
end
try
prompt = {'Enter the number of nearest neighbors to find'};
dlgtitle = 'NumNeighbors';
answer = inputdlg(prompt,dlgtitle,[1 50]);
if isempty(answer)
   return
end
K=str2double(answer{1});
dlg = msgbox('This operation may take a few minutes. Please wait');
%%% fit k-nearest neighbor classifier
mdl = fitcknn(X,WM,'NumNeighbors',K); 
%%% compute accuracy
accuracy =1- resubLoss(mdl);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SAL=gsw_SA_from_SP(sal,dep,mean(LON),mean(LAT));
TMP=gsw_CT_from_t(SAL,tmp,dep);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sigma=gsw_sigma0(SAL,TMP); %%% potential density
spi=gsw_pspi(SAL,TMP,0);%%% potential spicity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x= [spi sigma];
%%% classify training data using trained classifier
predictedWMS = resubPredict(mdl);
figure ('name','Confusion matrix chart')
set(gcf,'color','w')
%%%% Create confusion matrix chart for classification problem
cm=confusionchart(WM,predictedWMS);
title=sprintf('total accuracy : %.2f', accuracy*100);
cm.Title=title;
%%% Classify observations using nearest neighbor classification model
wms = predict(mdl,x);
if ishghandle(dlg)
    delete(dlg);
end
%%%% plot knn results
figure('Name','KNN classification results')
gscatter (sal,tmp,wms)
xlabel ('Salinity [psu]','interpreter','latex')
ylabel ('Temperature [$$^{\circ} C$$]','interpreter','latex')
set(gcf,'Color','w')
grid on
catch exception 
    f = warndlg('KNN error','Warning');
    return
end


% --------------------------------------------------------------------
function uipushtool9_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msg=sprintf('Please contact ayoub-bel17@hotmail.com for support.');
msgbox(msg,'HELP');



