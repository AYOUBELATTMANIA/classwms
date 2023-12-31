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

% Last Modified by GUIDE v2.5 22-Aug-2023 09:19:03

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
axesm('mercator','MapLatLimit',[-90 90],'MapLonLimit',[-180 180],...
'Frame','on','Grid','on','MeridianLabel','off','ParallelLabel','off')
axis off; 
geoshow('landareas.shp','FaceColor',[ 0.5 0.3 0.1 ])
daspect auto


% --------------------------------------------------------------------
function openfile_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to openfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%% import the data ascii file that the user want to classify
directory=sprintf('C:\\classwms\\data');
cd (directory) 
global dep tmp sal lon lat
try
FileName= 'data_to_classify.txt';
file= uiimport(FileName,'rt');
lon=file.longitude;  lat=file.latitude;
dep=file.depth;  tmp=file.temperature;
sal=file.salinity;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axes(handles.axes6)
geoshow(lat, lon, 'DisplayType', 'Point','Color', 'black',...
 'linewidth',1,'marker','o','markeredgecolor','r',...
 'markerfacecolor','r','MarkerSize',2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Plot vertical profils of temperature and salinity
figure('Name','Tempearture and Salinity profiles')
subplot 121
plot(tmp,dep,'.r','linewidth',10);
set(gca,'Ydir','reverse') 
ylabel('Depth [m]',...
 'Interpreter','Latex');
xlabel ('Temperature [$$^{\circ} C$$]','interpreter','latex')
set(gca,'Color',[0.8 0.8 0.8])
grid on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot 122
plot(sal,dep,'.g','linewidth',10);
set(gca,'Ydir','reverse') 
ylabel('Depth [m]',...
 'Interpreter','Latex');
xlabel ('Salinity [psu]','interpreter','latex')
set(gca,'Color',[0.8 0.8 0.8])
grid on
%%%%%%%% plot the theta-s diagram
figure('Name','Tempearture and Salinity diagram')
theta_sdiag(tmp,sal,'color',dep,'caxis',[min(dep) max(dep)],...
    'trange',[min(tmp)-0.1 max(tmp)+0.1],'srange',[min(sal)-0.1 max(sal)+0.1]);
set(gca,'Color',[0.8 0.8 0.8])
xlabel ('Salinity [psu]','interpreter','latex')
ylabel ('Temperature [$$^{\circ} C$$]','interpreter','latex')
%%%%%%%%%% plot the sigma-pi diagram
figure('Name','Sigma Pi diagram');
sigma=sw_dens0(sal,tmp)-1000; %%% potential density
spi=sw_pspi(sal,tmp,dep,0);%%% potential spicity
hc=scatter(spi,sigma,16,dep,'o','fill');
set(hc,'markeredgecolor','none');
cmap=jet(10); colormap(cmap); h=colorbar; title(h,'Depth [m]','interpreter','latex')
set(gca,'Color',[0.8 0.8 0.8]); grid on
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
global sal tmp K data G dep
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
            T_n=(tmp-min(tmp))./(max(tmp)-min(tmp)); %% data temperature normalisation
            S_n=(sal-min(sal))./(max(sal)-min(sal)); %% data salinity normalisation
            data=[S_n T_n];
            [G C sumD D]=kmeans(data,K);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% plot clustering results using random centroid
            figure('Name','Clustering analysis results')
            gscatter (sal,tmp,G)
            set(gca,'Color',[0.8 0.8 0.8])
            xlabel ('Salinity [psu]','interpreter','latex')
            ylabel ('Temperature [$$^{\circ} C$$]','interpreter','latex')
            grid on
      case 'User centroid'
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
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              %%% plot clustering results using user centroid
            figure('Name','Clustering analysis results')
            gscatter (sal,tmp,G)
            set(gca,'Color',[0.8 0.8 0.8])
            hold on; plot(POS(:,1),POS(:,2),'or','DisplayName','initial centroids');
            xlabel ('Salinity [psu]','interpreter','latex')
            ylabel ('Temperature [$$^{\circ} C$$]','interpreter','latex')
            grid on
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
axes(handles.axes6)
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
axesm('mercator','MapLatLimit',[lat_min lat_max],'MapLonLimit',[lon_min lon_max],...
'Frame','on','Grid','on','MeridianLabel','off','ParallelLabel','off')
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
daspect auto
catch exception 
    f = warndlg('limits error','Warning');
end


% --- Executes on button press in restore.
function restore_Callback(hObject, eventdata, handles)
% hObject    handle to restore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%% restore the basemap to the global initial view
axes(handles.axes6)
axesm('mercator','MapLatLimit',[-90 90],'MapLonLimit',[-180 180],...
'Frame','on','Grid','on','MeridianLabel','off','ParallelLabel','off')
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
global S T indice name SAL TMP DEP LON LAT
S=[]; T=[]; indice=[]; name={}; 
try
directory=sprintf('C:\\classwms\\data');
cd (directory) 
FileName= 'database_not_labeled.txt';
file= uiimport(FileName,'rt');
LON=file.longitude;  LAT=file.latitude;
DEP=file.depth;  TMP=file.temperature; SAL=file.salinity;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axes(handles.axes6)
geoshow(LAT, LON, 'DisplayType', 'Point','Color', 'black',...
 'linewidth',1,'marker','o','markeredgecolor','b',...
 'markerfacecolor','b','MarkerSize',1);
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
set(gca,'Color',[0.8 0.8 0.8])
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
global tmp sal  dep
try
%%%%% import the labeled database file 
directory=sprintf('C:\\classwms\\data');
cd (directory) 
FileName='database_labeled.txt';
A=readtable(FileName); A=table2cell(A);
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
sigma=sw_dens0(sal,tmp)-1000; 
spi=sw_pspi(sal,tmp,dep,0);
x= [spi sigma];
%%% classify training data using trained classifier
predictedWMS = resubPredict(mdl);
figure ('name','Confusion matrix chart')
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
set(gca,'Color',[0.8 0.8 0.8])
grid on
catch exception 
    f = warndlg('KNN error','Warning');
    return
end
