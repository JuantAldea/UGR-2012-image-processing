I = im2double(imread('blox.gif'));
mascara = [-1 0 1];
Ix = imfilter(I,mascara,'replicate'); %Gradiente horizontal
Iy = imfilter(I,mascara','replicate'); %Gradiente vertical

%Cálculo de los elementos que compondrán la matriz C
Vecindario = 3;
mascarasuma = ones(Vecindario,Vecindario);
Ix2 = Ix.^2;
Suma_Ix2 = imfilter(Ix2,mascarasuma,'replicate');
Iy2 = Iy.^2;
Suma_Iy2 = imfilter(Iy2,mascarasuma,'replicate');
Ixy = Ix.*Iy;
Suma_Ixy = imfilter(Ixy,mascarasuma,'replicate');
%Observa que de esta forma hemos creado tres matrices que contienen, en la
%posición (i,j), la sumatoria correspondiente al vecindario del píxel (i,j).
%Hemos aprovechado la eficiencia de la función imfilter.
display(size(I));
dim = size(I);
autovalores = zeros();
for i = 1:dim(1)
    for j = 1:dim(2)
        %Construimos la matriz C
        C=([Suma_Ix2(i,j) Suma_Ixy(i,j);Suma_Ixy(i,j) Suma_Iy2(i,j)]);
        d = eig(C); %Obtenemos los dos autovalores de C
        autovalores(i,j) = min(d); %Guardamos el menor autovalor
    end;
end;

%imshow(Autovalores, [], 'InitialMagnification', 100), colorbar,...
%title('Imagen de Autovalores');

Umbral = 0.03; %Debemos probar diferentes valores del umbral
Esquinas = autovalores > Umbral;
%Obtenemos las posiciones de los elementos que superan el umbral
[r,c] = find(Esquinas);
autovalores = autovalores(:);
i = 1 + dim(1)*(r-1)+(c-1);

autovalores = autovalores(i);

lista = [r, c autovalores]';
autovalores = autovalores';
[lista_ordenada, indices] = sort(autovalores, 'descend');
esquinas_reales_c = [];
esquinas_reales_r = [];
n_elementos = size(indices);
for i=1:n_elementos(2)
    row = lista(1, indices(i));
    col = lista(2, indices(i));
    display ([row, col]);
    encontrado = 0;
    for j=1:(i-1)
        row_busqueda = lista(1, indices(j));
        col_busqueda = lista(2, indices(j));
        if (abs(row - row_busqueda) + abs(col - col_busqueda)) < 5
            encontrado = 1;
        end
    end
    if (~encontrado)
        esquinas_reales_c = [esquinas_reales_c, col];
        esquinas_reales_r = [esquinas_reales_r, row];
    end    
end
%Mostramos la imagen y pintamos las esquinas detectadas
figure, imshow(I, []), colormap(gray(256)), hold on; %Mostramos la imagen
%plot(c, r,'ys'), title('Esquinas detectadas'); %Marcamos las esquinas
rectangle('Position', [10, 10, 100, 100]);
plot(esquinas_reales_c, esquinas_reales_r,'ys'), title('Esquinas detectadas'); %Marcamos las esquinas
