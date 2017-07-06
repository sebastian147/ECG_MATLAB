function varargout = untitled(varargin)
% UNTITLED MATLAB code for untitled.fig
%      UNTITLED, by itself, creates a new UNTITLED or raises the existing
%      singleton*.
%
%      H = UNTITLED returns the handle to a new UNTITLED or the handle to
%      the existing singleton*.
%
%      UNTITLED('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNTITLED.M with the given input arguments.
%
%      UNTITLED('Property','Value',...) creates a new UNTITLED or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before untitled_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to untitled_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help untitled

% Last Modified by GUIDE v2.5 28-Jun-2017 02:10:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @untitled_OpeningFcn, ...
                   'gui_OutputFcn',  @untitled_OutputFcn, ...
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


% --- Executes just before untitled is made visible.
function untitled_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to untitled (see VARARGIN)

% Choose default command line output for untitled
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes untitled wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = untitled_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%SUBIR ARCHIVO
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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


[a,b,c,d,e,f,g,h]=textread(info,'%s %s %s %s %s %s %s %s'); %%cargo el archivo en un vector por columnas
fclose(info_point);

Fs=str2double(c(5));
gain=str2double(c(7));
base=str2double(d(7));



%%cargo la senial del archivo
senial = (senial_archivo -base)/gain;
t= (0:length(senial)-1)/Fs;

axes(handles.axes1);
plot(t,senial)  , grid


%%Pongo todo en el eje 0
opol = 6;
m=length(senial_archivo);
[p,s,mu] = polyfit(t,senial_archivo,opol);
f_y = polyval(p,t,[],mu);
y = senial_archivo - f_y;

axes(handles.axes1);
plot(t,y), grid


%%Filtro Fir
global t y2 a;
a=fir1(100,0.1,'stop');
y2=filter(a,1,y);
axes(handles.axes2);
plot(t,y2), grid




%Filtro butter
global b y3;
fNorm = 25 / (Fs/2);               
[b,l] = butter(10, fNorm, 'low');  
y3 = filtfilt(b, l, y);

axes(handles.axes3);
plot(y3), grid


%Deteccion ritmo cardiaco
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
set(handles.text5, 'String', num2str(ritmo));






% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global t y2 a b y3;
figure ('Name','Filtro FIR')
subplot(2,1,1)
plot(t,y2), grid
title('Señal despues de FIR')
subplot(2,1,2)
plot(a), grid
title('Filtro FIR')


figure ('Name','Filtro butter')
subplot(2,1,1)
plot(t,y3), grid
title('Señal despues de butterworth')
subplot(2,1,2)
plot(b), grid
title('Filtro butterworth')




