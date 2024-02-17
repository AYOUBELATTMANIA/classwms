function Select(src,event)
global  S T indice name
%%%% select data representing the water mass name by using the 
%%%% Graphical data selection tool developed by the John D'Errico (2023). 
%%%% https://www.mathworks.com/matlabcentral/fileexchange/13857-graphical-data-selection-tool
if isempty(name)
   warndlg('Choose name first','Warning');
   return
end
try
zoom off; pan off;
[p,S_tmp,T_tmp] = selectdata('selectionmode','Brush','action',...
        'delete','BrushSize',0.04,'BrushShape','circle'); 
S=[S; S_tmp];
T=[T; T_tmp];
indice=[indice; p];
catch exception 
    warndlg('Select error','Warning');
end

