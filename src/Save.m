function Save(src,event)
global S T indice name DEP 
%%%%% save the theta-s selected data on the sigma-pi diagram
try
if isempty(S)
   warndlg('Select first','Warning');
   return
end
if iscell(S)
    S=cell2mat(S);
    T=cell2mat(T);
    indice=cell2mat(indice); 
end
baseFileName_1 = sprintf('%s_sigma_pi.txt',name);
sigma=sw_dens0(S,T)-1000; %%% compute potential density 
spi=sw_pspi(S,T,DEP(indice),0); %%% compute potential spicity
wm=repmat(name,length(spi),1);
Tab = table(round(spi,15),round(sigma,15),wm, ...
    'VariableNames', { 'PI', 'SIGMA','NAME'} );
selpath = uigetdir;
cd (selpath);
writetable(Tab, baseFileName_1)
dlg = msgbox('File saved');
S=[];T=[];indice=[];name={};
catch exception 
    warndlg('Save file error','Warning');
end

