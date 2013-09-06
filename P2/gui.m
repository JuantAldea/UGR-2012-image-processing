function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 28-Dec-2011 19:12:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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

% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton_load_image.
function pushbutton_load_image_Callback(hObject, ~, handles)
    [im_path, cancelled] = imgetfile();
    if ~cancelled
        im = imread(im_path);
        if length(size(im)) > 2
            im = rgb2gray(im);
        end
        if get(handles.image_selector_1, 'Value') == get(handles.image_selector_1, 'Max')
            update_image_widget(im, 1, handles, hObject);
        elseif get(handles.image_selector_2, 'Value') == get(handles.image_selector_2, 'Max')
            update_image_widget(im, 2, handles, hObject);
        elseif get(handles.image_selector_3, 'Value') == get(handles.image_selector_3, 'Max')
            update_image_widget(im, 3, handles, hObject);
            
        end       
    end
 
% --- Executes on button press in pushbutton_save_image.
function pushbutton_save_image_Callback(~, ~, handles)
    try
        if get(handles.image_selector_1, 'Value') == get(handles.image_selector_1, 'Max')
            canvas = handles.im1;
        elseif get(handles.image_selector_2, 'Value') == get(handles.image_selector_2, 'Max')
            canvas = handles.im2;
        elseif get(handles.image_selector_3, 'Value') == get(handles.image_selector_3, 'Max')
            canvas = handles.im3;
        end
        imsave(canvas);
    catch error
        msgbox('Imagen activa invalida', 'Error', 'error', 'modal');
    end

function update_image_widget(image, index, handles, hObject)
    switch index
        case 1
            canvas_handle = handles.im1;
            size_text_handle = handles.im1_size_text;
            min_max_handle = handles.im1_min_max;
            handles.im1_data = image;
        case 2
            canvas_handle = handles.im2;
            size_text_handle = handles.im2_size_text;
            min_max_handle = handles.im2_min_max;
            handles.im2_data = image;
        case 3
            canvas_handle = handles.im3;
            size_text_handle = handles.im3_size_text;
            min_max_handle = handles.im3_min_max;
            handles.im3_data = image;
    end
    guidata(hObject, handles);
    im_vector = image(:);
    dimensions = size(image);
    set(size_text_handle, 'String', sprintf('%d x %d', dimensions(1), dimensions(2)));
    set(min_max_handle, 'String', sprintf('[%d, %d]', min(im_vector), max(im_vector)));
    axes(canvas_handle);
    cla('reset');
    imshow(image, [min(image(:)) max(image(:))]);

function update_image_widgets(hObject, handles)
    if isfield(handles, 'im1_data')
        update_image_widget(handles.im1_data, 1, handles, hObject);
    end
    if isfield(handles, 'im2_data')
        update_image_widget(handles.im2_data, 2, handles, hObject);
    end
    if isfield(handles, 'im3_data')
        update_image_widget(handles.im3_data, 3, handles, hObject);
    end
    
function [normal db] = my_snr(im1, im2)
    im1 = double(im1);
    im2 = double(im2);
    average = mean(im1(:));
    squared_im_minus_mean = (im1 - average).^2;
    squared_error = (im1 - im2).^2;
    sum_squared_error = sum(squared_error(:));
    sum_squared_im_minus_mean = sum(squared_im_minus_mean(:));
    normal = sum_squared_im_minus_mean / sum_squared_error;
    db = 10 * log(normal)/log(10);

function value = my_mse(im1, im2)
    squared_diff = (double(im1) - double(im2)).^2;
    err_sum = sum(squared_diff(:));
    value = err_sum/(length(im1(:)));

function value = my_isnr(im1, im2, im3)
    im1 = double(im1);
    im2 = double(im2);
    im3 = double(im3);
    squared_error = (im1 - im2).^2;
    squared_filtered_error = (im1 - im3).^2;
    squared_error_sum = sum(squared_error(:));
    squared_filtered_error_sum = sum(squared_filtered_error(:));
    value = squared_error_sum/squared_filtered_error_sum;
    value = 10*log(value)/log(10);
        
function I = salt_pepper(im, p, q)
    mascara = rand(size(im));
    I = im;
    I(mascara <= p) = 255;
    I(mascara > p & mascara <= p + q) = 0;
    %I(mascara >= p+q); %no hace nada

function I = uniform(im, a, b)
    mascara = a + (b - a) * rand(size(im));
    I = im + mascara;
    I = max(0, min(I, 255));

function I = gauss_aditive(im, media, s)
    I = im + media + sqrt(s) * randn(size(im));
    I = max(0, min(I, 255));

function I = gauss_multiplicative(im, alfa)
    I = im + sqrt(alfa * im) .* randn(size(im));
    I = max(0, min(I, 255));

% --- Executes on button press in pushbutton_apply_noise.
function pushbutton_apply_noise_Callback(hObject, ~, handles)
    try
        a = str2double(get(handles.edit_noise_param_a, 'String'));
        b = str2double(get(handles.edit_noise_param_b, 'String'));
        im_double = double(handles.im1_data);
        noisy_im = zeros(size(im_double));

        if get(handles.radiobutton_uniform_aditive, 'Value') == get(handles.radiobutton_uniform_aditive, 'Max')
            noisy_im = uniform(im_double, a, b);
        elseif get(handles.radiobutton_gaussian_aditive, 'Value') == get(handles.radiobutton_gaussian_aditive, 'Max')
            noisy_im = gauss_aditive(im_double, a, b);
        elseif get(handles.radiobutton_gaussian_multiplicative, 'Value') == get(handles.radiobutton_gaussian_multiplicative, 'Max')
            if (a <= 0)
                msgbox('Alfa > 0', 'Error', 'error', 'modal')
            else
                noisy_im = gauss_multiplicative(im_double, a);
            end
        elseif get(handles.radiobutton_salt_pepper, 'Value') == get(handles.radiobutton_salt_pepper, 'Max')
            if ( a + b > 1 || a < 0 || b < 0)
                msgbox('Probabilidades incorrectas', 'Error', 'error', 'modal')
            else
                noisy_im = salt_pepper(im_double, a, b);
            end
        end
        handles.im2_data = uint8(noisy_im);
        update_image_widgets(hObject, handles);
        %Actualizar el MSE
        set(handles.edit_mse_value, 'String', my_mse(handles.im1_data, handles.im2_data));
        [normal_snr db_snr] = my_snr(handles.im1_data, handles.im2_data);
        set(handles.edit_snr_value, 'String', normal_snr);
        set(handles.edit_snr_db_value, 'String', db_snr);
    catch error
        msgbox('Imagen Original invalida', 'Error', 'error', 'modal');
    end

% --- Executes when selected object is changed in uipanel_noise_type.
function uipanel_noise_type_SelectionChangeFcn(~, ~, handles)
    set(handles.text_noise_param_b, 'Visible', 'on');
    set(handles.edit_noise_param_b, 'Visible', 'on');
if get(handles.radiobutton_uniform_aditive, 'Value') == get(handles.radiobutton_uniform_aditive, 'Max')
    set(handles.text_noise_param_a, 'String', 'a');
    set(handles.text_noise_param_b, 'String', 'b');
    set(handles.edit_noise_param_a, 'String', '-5');
    set(handles.edit_noise_param_b, 'String', '5');
elseif get(handles.radiobutton_gaussian_aditive, 'Value') == get(handles.radiobutton_gaussian_aditive, 'Max')
    set(handles.text_noise_param_a, 'String', 'Media');
    set(handles.text_noise_param_b, 'String', 'Varianza');
    set(handles.edit_noise_param_a, 'String', '0.0');
    set(handles.edit_noise_param_b, 'String', '1.0');
elseif get(handles.radiobutton_gaussian_multiplicative, 'Value') == get(handles.radiobutton_gaussian_multiplicative, 'Max')
    set(handles.text_noise_param_a, 'String', 'Alfa');
    set(handles.text_noise_param_b, 'Visible', 'off');
    set(handles.edit_noise_param_b, 'Visible', 'off');
    set(handles.edit_noise_param_a, 'String', '0.1');
elseif get(handles.radiobutton_salt_pepper, 'Value') == get(handles.radiobutton_salt_pepper, 'Max')
    set(handles.text_noise_param_a, 'String', 'P(S)');
    set(handles.text_noise_param_b, 'String', 'P(P)');
    set(handles.edit_noise_param_a, 'String', '0.05');
    set(handles.edit_noise_param_b, 'String', '0.05');
    
end

% --- Executes on button press in pushbutton_reset_rng.
function pushbutton_reset_rng_Callback(~, ~, handles)
    seed = str2double(get(handles.edit_rng_seed, 'String'));
    if (isnan(seed))
        msgbox('Semilla incorrecta', 'Error', 'error', 'modal')
    else
        rng(seed);
    end
    
% --- Executes on button press in pushbutton_apply_filter.
function pushbutton_apply_filter_Callback(hObject, ~, handles)
    try
        im = handles.im2_data;
        filtered_im = zeros(size(im));
        contents = cellstr(get(handles.popupmenu_filter_types, 'String'));
        mode = contents{get(handles.popupmenu_filter_types, 'Value')};

        window_size = str2double(get(handles.edit_filter_window_size, 'String'));
        if isnan(window_size)
            msgbox('Tamaño de la ventana incorrecto', 'Error', 'error', 'modal');
            return;
        end

        if strcmp(mode,'Gaussiano')
            variance = str2double(get(handles.edit_filter_variance, 'String'));
            if isnan(variance)
                msgbox('Varianza incorrecta', 'Error', 'error', 'modal')
                return;
            end
            sigma = sqrt(variance);
            h = fspecial('gaussian', window_size, sigma);
            filtered_im = imfilter(im, h, 'same', 'circular');
        elseif strcmp(mode,'Media')
            h = fspecial('average', window_size);
            filtered_im = imfilter(im, h, 'circular', 'same');
        elseif strcmp(mode,'Mediana')
            %foo = @(x) median(x(:));
            %filtered_im = nlfilter(im, [window_size window_size], foo);
            %filtered_im = medfilt2(im, [window_size, window_size]);
            filtered_im = colfilt(im, [window_size window_size], 'sliding', @median);
        elseif strcmp(mode,'Maximo')
            %foo = @(x) max(x(:));
            %filtered_im = nlfilter(im, [window_size window_size], foo);
            filtered_im = colfilt(im, [window_size window_size], 'sliding', @max);
        elseif strcmp(mode,'Minimo')
            %foo = @(x) min(x(:));
            %filtered_im = nlfilter(im, [window_size window_size], foo);
            filtered_im = colfilt(im, [window_size window_size], 'sliding', @min);
        end

        handles.im3_data = filtered_im;
        set(handles.edit_isnr_db_value, 'String', my_isnr(handles.im1_data, handles.im2_data, handles.im3_data));
        update_image_widgets(hObject, handles);
    catch error
        msgbox('Imagen Observada invalida', 'Error', 'error', 'modal');
    end;

% --- Executes on selection change in popupmenu_filter_types.
function popupmenu_filter_types_Callback(hObject, ~, handles)
    contents = cellstr(get(hObject,'String'));
    filter   = contents{get(hObject,'Value')};
    if strcmp(filter, 'Gaussiano')
        set(handles.edit_filter_window_size, 'String', '13');
        set(handles.edit_filter_variance, 'String', '0.5');
        set(handles.text_filter_variance, 'Visible', 'on');
        set(handles.edit_filter_variance, 'Visible', 'on');
    else
        set(handles.edit_filter_window_size, 'String', '3');
        set(handles.text_filter_variance, 'Visible', 'off');
        set(handles.edit_filter_variance, 'Visible', 'off');
    end
    
% --- Executes on button press in pushbutton_difference.
function pushbutton_difference_Callback(hObject, ~, handles)
    try
        image1 = int16(handles.im1_data);
        image2 = int16(handles.im2_data);
        handles.im3_data = image1 - image2; 
        update_image_widgets(hObject, handles);
    catch error;
        msgbox('Imagenes no validas', 'Error', 'error', 'modal');
        return;
    end
    
    
% --- Executes during object creation, after setting all properties.
function edit_noise_param_b_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_noise_param_b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_noise_param_a_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_noise_param_a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_snr_db_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_snr_db_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit_snr_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_snr_db_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_rng_seed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rng_seed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popupmenu_filter_types_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_filter_types (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_filter_window_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_filter_window_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_filter_variance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_filter_variance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_isnr_db_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_isnr_db_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
