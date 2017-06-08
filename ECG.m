clear all;
close all;
clc;

%%cargo el archivo
[archivo, ruta] = uigetfile('*.mat', 'Open file .mat');
if isequal(archivo, 0) || isequal(ruta, 0)   
    disp('Entrada de archivo cancelada.');  
   ECG_Data = [];  
else
load ([ruta archivo]);
senial_archivo=val;
end


m=size(senial_archivo);
if(m(1) ~= 1)%problema de archivos con mas columnas

    senial_archivo(2:m(1),:)=[];
end

%%leo el archivo .info genericamente
archivo(end-2)='i';
archivo(end-1)='n';
archivo(end)='f';
archivo(end+1)='o';
info=strcat(ruta,archivo);
info_point =fopen(info,'r');
frecuencia="Sampling frequency:";
frecuencian=strlength(frecuencia);

[a,b,c,d,e,f,g,h]=textread(info,'%s %s %s %s %s %s %s %s'); %%cargo el archivo en un vector por columnas
fclose(info_point);

Fs=str2double(c(5));
gain=str2double(c(7));
base=str2double(d(7));



%%cargo la senial del archivo
senial = (senial_archivo -base)/gain;
t= (0:length(senial)-1)/Fs;
figure(1)
subplot(2,1,1)
plot(t,senial)  , grid


%%pongo todo en el eje 0
opol = 6;
m=length(senial_archivo);
[p,s,mu] = polyfit(t,senial_archivo,opol);
f_y = polyval(p,t,[],mu);
y = senial_archivo - f_y;
subplot(2,1,2)
plot(t,y), grid


%%elimnio el ruido de la senial 50 hz y 60 hz
a=fir1(100,0.1,'stop');

y2=filter(a,1,y);
figure (2)
subplot(2,1,1)
plot(t,y2), grid
subplot(2,1,2)
plot(a), grid

%%calculo el ritmo cardiaco


%no se que hace este filtro
h=fir1(1000,1/(360/2),'high');%nysquit frecuenci(revisar
y3=filter(h,1,y2);
figure (3)
subplot(2,1,1)
plot(t,y3), grid
subplot(2,1,2)
plot(h), grid


%deteccion
maximo=abs(max(y2));
maximo=maximo/2;
flag=0;
j=1;
for i=1:length(y2)
    if(y2(i)>maximo)%si supera un valor generico de los picos mayores
       if(y2(i)<y2(i-1))
        if(flag==0)
            tiempo(j)=i;
            flag=1;
            j=j+1;
        end
       end
    end
    if(y2(i)<0)
        flag=0;
    end

end
promedio=0;
s=1;
for i=1:length(tiempo)-1
    promedio(s)=tiempo(i+1)-tiempo(i);
    s=s+1;
end
ritmo=sum(promedio)/(length(promedio)*60*0.1)   %hago el promedio, lo divido por el intervalo de tiempo y 60 para pasar a pulsaciones por minuto
