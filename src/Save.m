function Save(src,event)
global S T indice name DEP LON LAT 
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
%%%%%%%%%
SAL=gsw_SA_from_SP(S,DEP(indice),mean(LON),mean(LAT));
TMP=gsw_CT_from_t(SAL,T,DEP(indice));
%%%%%%%%%
sigma=gsw_sigma0(SAL,TMP); %%% potential density
spi=gsw_pspi(SAL,TMP,0);%%% potential spicity
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

