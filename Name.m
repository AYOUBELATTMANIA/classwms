function Name(src,event)
global  S T indice name
%%%% defining the water mass name during labeling process
try
prompt = {'Enter the water mass name'};
dlgtitle = 'Name';
answer = inputdlg(prompt,dlgtitle,[1 50]);
if isempty(answer)
   return
end
name=char(answer(1));
catch exception 
    warndlg('Name error','Warning');
end

