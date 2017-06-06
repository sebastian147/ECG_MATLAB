clc;


%%cargo el archivo
[filename, pathname] = uigetfile('*.mat', 'Open file .mat');
if isequal(filename, 0) || isequal(pathname, 0)   
    disp('Entrada de archivo cancelada.');  
   ECG_Data = [];  
else
load (filename);
end;

ECGsignal = (val -1024)/200;
Fs=360;
t= (0:length(ECGsignal)-1)/Fs;
subplot(2,1,1)
plot(t,ECGsignal)  , grid


%%pongo todo en el eje x
opol = 6;
[p,s,mu] = polyfit(t,val,opol);
f_y = polyval(p,t,[],mu);
dt_ecgnl = val - f_y;
subplot(2,1,2)
plot(t,dt_ecgnl), grid


%%elimino ruido
