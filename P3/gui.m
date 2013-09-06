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

% Last Modified by GUIDE v2.5 10-Feb-2012 21:30:17

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
        end;
    end
 
% --- Executes on button press in pushbutton_save_image.
function pushbutton_save_image_Callback(~, ~, handles)
    %try
        if get(handles.image_selector_1, 'Value') == get(handles.image_selector_1, 'Max')
            canvas = getframe(handles.im1);
        elseif get(handles.image_selector_2, 'Value') == get(handles.image_selector_2, 'Max')
            canvas = getframe(handles.im2);
        end
        
        [im, map] = frame2im(canvas);
        
        if isempty(map)
            canvas = im; 
        else
            canvas = ind2rgb(im, map);
        end
        [filename, cancelled]=imsave(handles.im1);
        if ~cancelled
            imwrite(canvas, filename);
        end
    %catch error
     %   msgbox('Imagen activa invalida', 'Error', 'error', 'modal');
    %end

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
    
function [filtered_im, ok] = apply_filter(handles)
    try
        ok = 1;
        im = handles.im1_data;
        filtered_im = zeros(size(im));
        contents = cellstr(get(handles.popupmenu_filter_types, 'String'));
        mode = contents{get(handles.popupmenu_filter_types, 'Value')};

        window_size = str2double(get(handles.edit_filter_window_size, 'String'));
        if isnan(window_size)
            msgbox('Tamaño de la ventana incorrecto', 'Error', 'error', 'modal');
            ok = 0;
            return;
        end

        if strcmp(mode,'Gaussiano')
            variance = str2double(get(handles.edit_filter_variance, 'String'));
            if isnan(variance)
                msgbox('Varianza incorrecta', 'Error', 'error', 'modal')
                ok = 0;
                return;
            end
            sigma = sqrt(variance);
            h = fspecial('gaussian', window_size, sigma);
            filtered_im = imfilter(im, h, 'same', 'circular');
        elseif strcmp(mode,'Media')
            h = fspecial('average', window_size);
            filtered_im = imfilter(im, h, 'circular', 'same');
        elseif strcmp(mode,'Mediana')
            filtered_im = colfilt(im, [window_size window_size], 'sliding', @median);
        elseif strcmp(mode,'Maximo')
            filtered_im = colfilt(im, [window_size window_size], 'sliding', @max);
        elseif strcmp(mode,'Minimo')
            filtered_im = colfilt(im, [window_size window_size], 'sliding', @min);
        end
        
    catch error
        msgbox('Imagen Observada invalida', 'Error', 'error', 'modal');
        ok = 0;
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
    

% --- Executes on button press in pushbutton_apply_detector.
function pushbutton_apply_detector_Callback(hObject, ~, handles)
    try
        contents = cellstr(get(handles.popupmenu_detector_selector, 'String'));
        mode = contents{get(handles.popupmenu_detector_selector, 'Value')};
        threshold = str2double(get(handles.edit_gradient_threshold, 'String'));
        if (get(handles.checkbox_noise_reduction, 'Value') == get(handles.checkbox_noise_reduction, 'Max'))
            im = apply_filter(handles);
            im = im2single(im);
        else
            im = im2single(handles.im1_data);
        end
        
        if strfind(mode, 'M') %matlab
            params{1} = im;
            if strfind(mode, 'Roberts')
                params{2} = 'roberts';
            elseif strfind(mode, 'Sobel')
                params{2} = 'sobel';
            elseif strfind(mode, 'Prewitt')
                params{2} = 'prewitt';
            elseif strfind(mode, 'Canny')
                params{2} = 'canny';
            end
            
            if get(handles.checkbox_auto, 'Value') == get(handles.checkbox_auto, 'Min')
                params{3} = threshold;
                set(handles.edit_sigma, 'String', num2str(threshold*0.4));
            end

            if strcmp(params{2}, 'sobel')
                Gx = imfilter(im, fspecial('sobel') /8,'replicate');
                Gy = imfilter(im, fspecial('sobel')'/8,'replicate');
            elseif strcmp(params{2}, 'roberts')
                Gx = imfilter(im,[1 0;  0 -1]/2,'replicate');
                Gy = imfilter(im,[0 1; -1  0]/2,'replicate');
            elseif strcmp(params{2}, 'prewitt')
                Gx = imfilter(im, [-1 -1 -1; 0 0 0; 1 1 1] /6, 'replicate');
                Gy = imfilter(im, [-1 -1 -1; 0 0 0; 1 1 1]'/6, 'replicate');
            end

            [filtered_im threshold] = edge(params{:});
            filtered_im = uint8(filtered_im);
            if length(threshold) == 2
                set(handles.edit_gradient_threshold, 'String', num2str(threshold(2)));
                set(handles.edit_sigma, 'String', num2str(threshold(1)));
            else
                set(handles.edit_gradient_threshold, 'String', num2str(threshold));
            end
        else % caseros
            if strcmp(mode,'Roberts')
                Ix = [1  0; 0 -1]/2;
                Iy = [0 1; -1  0]/2;
            elseif strcmp(mode,'Sobel')
                Ix = [-1  -2 -1; 0 0 0; 1 2 1]/8;
                Iy = Ix';
            elseif strcmp(mode,'Prewitt')
                Ix = [-1  -1 -1; 0 0 0; 1 1 1]/6;
                Iy = Ix';
            end
            
            Gx = imfilter(im, Ix, 'replicate');
            Gy = imfilter(im, Iy, 'replicate');
            
            contents2 = cellstr(get(handles.popupmenu_direction, 'String'));
            mode2 = contents2{get(handles.popupmenu_direction, 'Value')};
            k1 = 1;
            k2 = 1;
            if strcmp(mode2, 'Ambos')
                %nada que hacer
            elseif strcmp(mode2, 'Horizontal')
                k1 = 1;
                k2 = 0;
            elseif strcmp(mode2, 'Vertical')
                k1 = 0;
                k2 = 1;
            end
            
            if get(handles.checkbox_thin_borders, 'Value') == get(handles.checkbox_thin_borders, 'Max')
                Gxy = thin_borders(Gx, Gy);
            else
                Gxy = k1*Gx.^2 + k2*Gy.^2;
            end;
            threshold = threshold.^2;
            filtered_im = uint8(Gxy > threshold);
        end
        
        if get(handles.radiobutton_display_edges, 'Value') == get(handles.radiobutton_display_edges, 'Max')
            %nada que hacer
        elseif get(handles.radiobutton_image_edges, 'Value') == get(handles.radiobutton_image_edges, 'Max')    
            aux = filtered_im;
            filtered_im = handles.im1_data;
            aux = logical(aux);
            out_red = filtered_im;
            out_blue = filtered_im;
            out_green = filtered_im;
            out_red(aux) = 255;
            out_green(aux) = 255;
            out_blue(aux) = 0;
            filtered_im = cat(3, out_red, out_green, out_blue);
        elseif get(handles.radiobutton_gradient_module, 'Value') == get(handles.radiobutton_gradient_module, 'Max')
            filtered_im = sqrt(Gx.^2 + Gy.^2);
        elseif get(handles.radiobutton_gradient_45, 'Value') == get(handles.radiobutton_gradient_45, 'Max')
            filtered_im = Gx;
        elseif get(handles.radiobutton_gradient_135, 'Value') == get(handles.radiobutton_gradient_135, 'Max')
            filtered_im = Gy;
        end   
         
        handles.im2_data = filtered_im;
        update_image_widgets(hObject, handles);
    catch error
        msgbox('Argumentos incorrectos', 'Error', 'error', 'modal');
    end

function imf = thin_borders(gx, gy)
    gxy = gx.^2 + gy.^2;
    dgxy = round((180/pi) * atan(gy./gx));
    d = [0 45 90 135];
    dim = size(dgxy);
    drgxy = zeros(dim);

    for i = 1:dim(1)
        for j = 1:dim(2)
            [~, orden] = sort(abs(dgxy(i, j) - d));
            drgxy(i, j) = d(orden(1));
        end
    end

    imf = double(zeros(dim));
    for i = 1:dim(1)
        for j = 1:dim(2)
            if drgxy(i, j) == 0
                max_g = max([gxy(max([i-1, 1]), j), gxy(i, j), gxy(min([i+1, dim(1)]),j)]);
            elseif drgxy(i, j) == 45
                max_g = max([gxy(max([i-1, 1]), max([j-1, 1])), gxy(i, j), gxy(min([i+1, dim(1)]), min([j+1, dim(2)]))]);
            elseif drgxy(i, j) == 90
                max_g = max([gxy(i, max([j-1, 1])), gxy(i, j), gxy(i, min([j+1, dim(2)]))]);
            elseif drgxy(i, j) == 135
                max_g = max([gxy(min([i+1, dim(1)]), max([j-1, 1])), gxy(i, j), gxy(max([i-1, 1]), min([j+1, dim(2)]))]);
            end
            if (max_g) == gxy(i, j)
                imf(i, j) = gxy(i, j);
            else
                imf(i, j) = 0;
            end
        end
    end
        
function [cx cy] = my_corners(I, umbral, ventana, visualizacion_autovalores, supresion, distancia_supresion)
    I = im2single(I);
    mascara = [-1 0 1];
    Ix = imfilter(I,mascara,'replicate');
    Iy = imfilter(I,mascara','replicate');
    mascarasuma = ones(ventana,ventana);
    Ix2 = Ix.^2;
    Suma_Ix2 = imfilter(Ix2,mascarasuma,'replicate');
    Iy2 = Iy.^2;
    Suma_Iy2 = imfilter(Iy2,mascarasuma,'replicate');
    Ixy = Ix.*Iy;
    Suma_Ixy = imfilter(Ixy,mascarasuma,'replicate');
    dim = size(I);
    autovalores = zeros();
    for i = 1:dim(1)
        for j = 1:dim(2)
            C=([Suma_Ix2(i,j) Suma_Ixy(i,j); Suma_Ixy(i,j) Suma_Iy2(i,j)]);
            d = eig(C); 
            autovalores(i,j) = min(d);
        end;
    end;
    
    if visualizacion_autovalores
            cx = autovalores;
            cy =[];
        return;
    end
    
    Esquinas = autovalores > umbral;
    [r,c] = find(Esquinas);
    
    if supresion == 0
        cx = c;
        cy = r;
        return
    end
    
    autovalores = autovalores(:);
    i = 1 + dim(1)*(r-1)+(c-1);
    autovalores = autovalores(i);
    autovalores = autovalores';
    
    [~, indices] = sort(autovalores, 'descend');
    cx = [];
    cy = [];
    n_elementos = size(indices);
    for i=1:n_elementos(2)
        encontrado = 0;
        for j=1:(i-1)
            if (abs(r(indices(i)) - r(indices(j))) + abs(c(indices(i)) - c(indices(j)))) < distancia_supresion
                encontrado = 1;
            end
        end
        if (~encontrado)
            cx = [cx, c(indices(i))];
            cy = [cy, r(indices(i))];
        end    
    end

% --- Executes on selection change in popupmenu_detector_selector.
function popupmenu_detector_selector_Callback(hObject, ~, handles)
    set(handles.edit_sigma, 'String','');
    contents = cellstr(get(hObject,'String'));
    filter   = contents{get(hObject,'Value')};
    set(handles.radiobutton_gradient_module, 'Visible', 'on');
    set(handles.radiobutton_gradient_135, 'Visible', 'on');
    set(handles.radiobutton_gradient_45, 'Visible', 'on');
    if strfind(filter, 'Canny')
        set(handles.radiobutton_display_edges, 'Value', get(handles.radiobutton_display_edges, 'Max'));
        set(handles.popupmenu_direction, 'Enable', 'off');
        set(handles.radiobutton_gradient_module, 'Visible', 'off');
        set(handles.radiobutton_gradient_135, 'Visible', 'off');
        set(handles.radiobutton_gradient_45, 'Visible', 'off');
    elseif strfind(filter,'Sobel')
        set(handles.popupmenu_direction, 'Enable', 'on');
    elseif strfind(filter, 'Prewitt')
        set(handles.popupmenu_direction, 'Enable', 'on');
    else
        set(handles.popupmenu_direction, 'Enable', 'on');
    end
    
    if strfind(filter, 'M')
        set(handles.popupmenu_direction, 'Enable', 'off');
        set(handles.checkbox_auto, 'Enable', 'on');
        set(handles.checkbox_auto, 'Value', get(handles.checkbox_auto, 'Max'));
        set(handles.checkbox_thin_borders, 'Enable', 'off');
    else
        set(handles.checkbox_auto, 'Value', get(handles.checkbox_auto, 'Min'));
        set(handles.checkbox_auto, 'Enable', 'off');
        set(handles.checkbox_thin_borders, 'Enable', 'on');
    end

% --- Executes on button press in pushbutton_corners.
function pushbutton_corners_Callback(hObject, ~, handles)
    try
        if (get(handles.checkbox_noise_reduction, 'Value') == get(handles.checkbox_noise_reduction, 'Max'))
            im = apply_filter(handles);
        else
            im = handles.im1_data;
        end

        if (get(handles.checkbox_local_max_supression, 'Value') == get(handles.checkbox_local_max_supression, 'Max'))
            supression = 1;
        else
            supression = 0;
        end
        supression_distance = str2double(get(handles.edit_local_max_supression_distance, 'String'));
        supression_distance = max(1, supression_distance);
        set(handles.edit_local_max_supression_distance, 'String', num2str(supression_distance));

        threshold = str2double(get(handles.edit_corners_threshold, 'String'));

        window_size = str2double(get(handles.edit_window_size, 'String'));
        window_size = max(3, window_size);
        if mod(window_size, 2) == 0
            window_size = window_size + 1;
        end
        set(handles.edit_window_size, 'String', num2str(window_size));

        if isfield(handles, 'im1_data')
            if get(handles.radiobutton_corners_view_eigen, 'Value') == get(handles.radiobutton_corners_view_eigen, 'Max')
                [cx, ~] = my_corners(im, threshold, window_size, 1, supression, supression_distance);
                handles.im2_data = cx;
                update_image_widgets(hObject, handles);
            else
                [cx, cy] = my_corners(im, threshold, window_size, 0, supression, supression_distance); 
                if get(handles.radiobutton_corners_view_overlay, 'Value') == get(handles.radiobutton_corners_view_overlay, 'Max')
                    handles.im2_data = im;
                    update_image_widgets(hObject, handles);
                    hold on;
                    plot(cx, cy,'ys');
                else
                    handles.im2_data = zeros(size(im));
                    update_image_widgets(hObject, handles);
                    hold on;
                    plot(cx, cy,'ys');
                end
            end        
        end
    catch error
        msgbox('Argumentos incorrectos', 'Error', 'error', 'modal');
    end

% --- Executes on button press in checkbox_noise_reduction.
function checkbox_noise_reduction_Callback(hObject, ~, handles)
    if get(hObject,'Value') == get(hObject,'Max')
        set(handles.popupmenu_filter_types, 'Enable', 'on');
        set(handles.edit_filter_window_size, 'Enable', 'on');
        set(handles.edit_filter_variance, 'Enable', 'on');
    else
        set(handles.popupmenu_filter_types, 'Enable', 'off');
        set(handles.edit_filter_window_size, 'Enable', 'off');
        set(handles.edit_filter_variance, 'Enable', 'off');
    end

% --- Executes on button press in checkbox_local_max_supression.
function checkbox_local_max_supression_Callback(hObject, ~, handles)
    if get(hObject,'Value') == get(hObject,'Max')
        set(handles.edit_local_max_supression_distance, 'Enable', 'on');
    else
        set(handles.edit_local_max_supression_distance, 'Enable', 'off');
    end
    
    
% --- Executes during object creation, after setting all properties.
function popupmenu_detector_selector_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_gradient_threshold_Callback(~, ~, ~)
% hObject    handle to edit_gradient_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_gradient_threshold as text
%        str2double(get(hObject,'String')) returns contents of edit_gradient_threshold as a double


% --- Executes during object creation, after setting all properties.
function edit_gradient_threshold_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_gradient_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_sigma_Callback(~, ~, ~)
% hObject    handle to edit_sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sigma as text
%        str2double(get(hObject,'String')) returns contents of edit_sigma as a double


% --- Executes during object creation, after setting all properties.
function edit_sigma_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_direction.
function popupmenu_direction_Callback(~, ~, ~)
% hObject    handle to popupmenu_direction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_direction contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_direction


% --- Executes during object creation, after setting all properties.
function popupmenu_direction_CreateFcn(hObject, ~, ~)
% hObject    handle to popupmenu_direction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_auto.
function checkbox_auto_Callback(~, ~, ~)
% hObject    handle to checkbox_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_auto

% --- Executes during object creation, after setting all properties.
function popupmenu_filter_types_CreateFcn(hObject, ~, ~)
% hObject    handle to popupmenu_filter_types (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_filter_window_size_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_filter_window_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_filter_variance_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_filter_variance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_corners_threshold_Callback(~, ~, ~)
% hObject    handle to edit_corners_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_corners_threshold as text
%        str2double(get(hObject,'String')) returns contents of edit_corners_threshold as a double


% --- Executes during object creation, after setting all properties.
function edit_corners_threshold_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_corners_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_window_size_Callback(~, ~, ~)
% hObject    handle to edit_window_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_window_size as text
%        str2double(get(hObject,'String')) returns contents of edit_window_size as a double


% --- Executes during object creation, after setting all properties.
function edit_window_size_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_window_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_local_max_supression_distance_Callback(~, ~, ~)
% hObject    handle to edit_local_max_supression_distance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_local_max_supression_distance as text
%        str2double(get(hObject,'String')) returns contents of edit_local_max_supression_distance as a double


% --- Executes during object creation, after setting all properties.
function edit_local_max_supression_distance_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_local_max_supression_distance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_thin_borders.
function checkbox_thin_borders_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_thin_borders (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_thin_borders
