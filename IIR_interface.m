function varargout = IIR_interface(varargin)
% IIR_INTERFACE MATLAB code for IIR_interface.fig
%      IIR_INTERFACE, by itself, creates a new IIR_INTERFACE or raises the existing
%      singleton*.
%
%      H = IIR_INTERFACE returns the handle to a new IIR_INTERFACE or the handle to
%      the existing singleton*.
%
%      IIR_INTERFACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IIR_INTERFACE.M with the given input arguments.
%
%      IIR_INTERFACE('Property','Value',...) creates a new IIR_INTERFACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before IIR_interface_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to IIR_interface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help IIR_interface

% Last Modified by GUIDE v2.5 01-Jul-2016 15:54:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @IIR_interface_OpeningFcn, ...
                   'gui_OutputFcn',  @IIR_interface_OutputFcn, ...
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


% --- Executes just before IIR_interface is made visible.
function IIR_interface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IIR_interface (see VARARGIN)

% Choose default command line output for IIR_interface
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

initialize_gui(hObject, handles, false);
% UIWAIT makes IIR_interface wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = IIR_interface_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in bits.
function bits_Callback(hObject, eventdata, handles)
% hObject    handle to bits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns bits contents as cell array
%        contents{get(hObject,'Value')} returns selected item from bits


% --- Executes during object creation, after setting all properties.
function bits_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in aproximacao.
function aproximacao_Callback(hObject, eventdata, handles)
% hObject    handle to aproximacao (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns aproximacao contents as cell array
%        contents{get(hObject,'Value')} returns selected item from aproximacao


% --- Executes during object creation, after setting all properties.
function aproximacao_CreateFcn(hObject, eventdata, handles)
% hObject    handle to aproximacao (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function thd_Callback(hObject, eventdata, handles)
% hObject    handle to thd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thd as text
%        str2double(get(hObject,'String')) returns contents of thd as a double


% --- Executes during object creation, after setting all properties.
function thd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function order_Callback(hObject, eventdata, handles)
% hObject    handle to order (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of order as text
%        str2double(get(hObject,'String')) returns contents of order as a double


% --- Executes during object creation, after setting all properties.
function order_CreateFcn(hObject, eventdata, handles)
% hObject    handle to order (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function implementado_Callback(hObject, eventdata, handles)
% hObject    handle to implementado (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of implementado as text
%        str2double(get(hObject,'String')) returns contents of implementado as a double


% --- Executes during object creation, after setting all properties.
function implementado_CreateFcn(hObject, eventdata, handles)
% hObject    handle to implementado (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
initialize_gui(gcbf, handles, true);

% --- Executes on button press in projetar.
function projetar_Callback(hObject, eventdata, handles)
% hObject    handle to projetar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

aprox = get(handles.aproximacao, 'Value')-2;
switch(get(handles.bits, 'Value'));
    case(2) 
        Nbits = 12;
    case(3)
        Nbits = 16;
end

write_projetando(handles);

[handles.metricdata.thd, handles.metricdata.order, handles.metricdata.implementado]...
    = filtro_IIR(aprox, Nbits); 
set(handles.thd, 'String', handles.metricdata.thd);
if(handles.metricdata.implementado == 1)
set(handles.implementado,  'String', 'Implementado com sucesso');
elseif(handles.metricdata.implementado == 2)
set(handles.implementado,  'String', 'Limite de iterações atingido');
end
set(handles.order, 'String', handles.metricdata.order);
function initialize_gui(fig_handle, handles, isreset)
% If the metricdata field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.
if isfield(handles, 'metricdata') && ~isreset
    return;
end

handles.metricdata.thd = 0;
handles.metricdata.implementado  = 0;
handles.metricdata.order = 0;

set(handles.thd, 'String', handles.metricdata.thd);
set(handles.implementado,  'String', 'Agurardando Usuário');
set(handles.order, 'String', handles.metricdata.order);

% Update handles structure
guidata(handles.figure1, handles);


function write_projetando(handles)
    set(handles.implementado,  'String', 'Projetando...');
    pause(1);
