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

% Last Modified by GUIDE v2.5 20-Nov-2011 00:37:22

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

handles.source_image = 1;
set(handles.radiobutton_source_1, 'Value', get(handles.radiobutton_source_1, 'Max'));
handles.destination_image = 3;
set(handles.radiobutton_destination_3, 'Value', get(handles.radiobutton_destination_3, 'Max'));
set(handles.checkbox_show_color_bars, 'Value', get(handles.checkbox_show_color_bars, 'Max'));
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
    if get(handles.image_selector_1, 'Value') == get(handles.image_selector_1, 'Max')
        canvas = handles.im1;
    elseif get(handles.image_selector_2, 'Value') == get(handles.image_selector_2, 'Max')
        canvas = handles.im2;
    elseif get(handles.image_selector_3, 'Value') == get(handles.image_selector_3, 'Max')
        canvas = handles.im3;
    end
    imsave(canvas);

% --- Executes on selection change in color_index_mode.
function color_index_mode_Callback(hObject, ~, ~)
    contents = cellstr(get(hObject,'String'));
    mode = contents{get(hObject,'Value')};
    colormap(mode);

function set_color_map(handles)
    contents = cellstr(get(handles.color_index_mode,'String'));
    mode = contents{get(handles.color_index_mode,'Value')};
    colormap(mode);
    
% --- Executes on button press in pushbutton_apply_scale.
function pushbutton_apply_scale_Callback(hObject, ~, handles)
    contents = cellstr(get(handles.popupmenu_scale_mode,'String'));
    mode = contents{get(handles.color_index_mode,'Value')};
    if get(handles.radio_button_scale_factor, 'Value') == get(handles.radio_button_scale_factor, 'Max')
        scale = str2double(get(handles.edit_scale_factor,'String'));
        if isnan(scale)
            %sacar un error
            return;
        end
    else
        rows = str2double(get(handles.edit_scale_rows,'String'));
        columns = str2double(get(handles.edit_scale_columns,'String'));
        scale = [rows columns];
        if (isnan(rows)|| isnan(columns))
            %error
            return;
        end
    end
    try
        switch handles.source_image
            case 1
                im = handles.im1_data;
            case 2
                im = handles.im2_data;
            case 3
                im = handles.im3_data;
        end
    catch err
        return;
    end

    im2 = imresize(im, scale, mode);
    f
    update_image_widget(im2, handles.destination_image, handles, hObject);

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
    set(min_max_handle, 'String', sprintf('[%d. %d]', min(im_vector), max(im_vector)));
    axes(canvas_handle);
    cla('reset');
    [image, map] = gray2ind(image, fix(get(handles.slider_color_levels, 'Value')));
    set(handles.text_color_levels, 'String', fix(get(handles.slider_color_levels, 'Value')));
    imshow(image, map);
    set_color_map(handles);
    if (get(handles.checkbox_show_color_bars, 'Value') == get(handles.checkbox_show_color_bars, 'Max'))
        colorbar();
    end

% --- Executes when selected object is changed in uipanel_scale.
function uipanel_scale_SelectionChangeFcn(~, eventdata, handles)
    if strcmp(get(eventdata.NewValue,'String'), 'Factor')
        set(handles.edit_scale_factor, 'Enable', 'on');
        set(handles.edit_scale_rows,'Enable', 'off');
        set(handles.edit_scale_columns, 'Enable', 'off');
    elseif strcmp(get(eventdata.NewValue,'String'), 'Dimensiones')
        set(handles.edit_scale_factor, 'Enable', 'off');
        set(handles.edit_scale_rows,'Enable', 'on');
        set(handles.edit_scale_columns, 'Enable', 'on');
    end


% --- Executes when selected object is changed in uipanel_source_selector.
function uipanel_source_selector_SelectionChangeFcn(hObject, ~, handles)
    if get(handles.radiobutton_source_1, 'Value') == get(handles.radiobutton_source_1, 'Max')
        handles.source_image = 1;
    elseif get(handles.radiobutton_source_2, 'Value') == get(handles.radiobutton_source_2, 'Max')
        handles.source_image = 2;
    elseif get(handles.radiobutton_source_3, 'Value') == get(handles.radiobutton_source_3, 'Max')
        handles.source_image = 3;
    end
    guidata(hObject, handles);


% --- Executes when selected object is changed in uipanel_destination_selector.
function uipanel_destination_selector_SelectionChangeFcn(hObject, ~, handles)
    if get(handles.radiobutton_destination_1, 'Value') == get(handles.radiobutton_destination_1, 'Max')
        handles.destination_image = 1;
    elseif get(handles.radiobutton_destination_2, 'Value') == get(handles.radiobutton_destination_2, 'Max')
        handles.destination_image = 2;
    elseif get(handles.radiobutton_destination_3, 'Value') == get(handles.radiobutton_destination_3, 'Max')
        handles.destination_image = 3;
    end
    guidata(hObject, handles);

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

% --- Executes on slider movement.
function slider_color_levels_Callback(hObject, ~, handles)
    set(handles.text_color_levels, 'String', fix(get(handles.slider_color_levels, 'Value')));
    update_image_widgets(hObject, handles);



% --- Executes during object creation, after setting all properties.
function slider_color_levels_CreateFcn(hObject, ~, ~)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
    set(hObject,'Value', get(hObject, 'Max'));


% --- Executes on button press in checkbox_show_color_bars.
function checkbox_show_color_bars_Callback(hObject, ~, handles)
    update_image_widgets(hObject, handles);


% --- Executes on button press in pushbutton_calculate_mse.
function pushbutton_calculate_mse_Callback(hObject, eventdata, handles)
    try
        if (handles.source_image == 1)
            image1 = handles.im1_data;
        elseif (handles.source_image == 2)
            image1 = handles.im2_data;
        elseif (handles.source_image == 3)
            image1 = handles.im3_data;
        end

        if (handles.destination_image == 1)
            image2 = handles.im1_data;
        elseif (handles.destination_image == 2)
            image2 = handles.im2_data;
        elseif (handles.destination_image == 3)
            image2 = handles.im3_data;
        end

        if(size(image1) == size(image2))
            %set(handles.edit_mse_value, 'String', mse(handles.im1_data, handles.im2_data));
            set(handles.edit_mse_value, 'String', my_mse(handles.im1_data, handles.im2_data));
        else
            msgbox('Las imagenes deben tener las mismas dimensiones', 'Error', 'error', 'modal')
        end
    catch err
        msgbox('Imagenes no validas', 'Error', 'error', 'modal')
    end
        
function value = my_mse(im1, im2)
squared_diff = (int16(im1) - int16(im2)).^2;
err_sum = sum(squared_diff(:));
value = err_sum/length(im1(:));
        
        


% --- Executes on button press in pushbutton_substract.
function pushbutton_substract_Callback(hObject, eventdata, handles)
try
    if (handles.source_image == 1)
        image1 = handles.im1_data;
    elseif (handles.source_image == 2)
        image1 = handles.im2_data;
    elseif (handles.source_image == 3)
        image1 = handles.im3_data;
    end

    if (handles.destination_image == 1)
        image2 = handles.im1_data;
    elseif (handles.destination_image == 2)
        image2 = handles.im2_data;
    elseif (handles.destination_image == 3)
        image2 = handles.im3_data;
    end
    
    image1 = int16(image1);
    image2 = int16(image2);
    substract = image1 - image2;  
    figure, imshow(substract, [min(substract(:)) max(substract(:))]), colorbar();

catch err
    msgbox('Imagenes no validas', 'Error', 'error', 'modal')
end



function pushbutton_filter_Callback(hObject, eventdata, handles)
try
    if (handles.destination_image == 1)
        image = handles.im1_data;
    elseif (handles.destination_image == 2)
        image = handles.im2_data;
    elseif (handles.destination_image == 3)
        image = handles.im3_data;
    end
    
    h = fspecial('average');
    image = imfilter(image, h, 'circular');
    
    update_image_widget(image, handles.destination_image, handles, hObject);
    
catch err
        msgbox('Imagenes no validas', 'Error', 'error', 'modal')
end
