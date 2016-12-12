function [saida_filtro] = filtragem_quantizada(entrada,sos,g,bits)
%% Essa fun��o calcula a saida do filtro, j� aplicando a quantiza��o
%   Suas entradas s�o:
%    entrada -> sinal de entrada do filtro
%    sos -> matriz com os coeficientes do filtro separados em biquadradas e j� escalonados
%    g -> ganho do filtro
%    bits -> precis�o do filtro, dada pelo numero de bits da pracis�o da mem�ria do filtro
%   a saida, dada por saida_filtro, � apenas a simula��o da sa�da do filtro
%   real, j� quantizado, ap�s passar pelas opera��es necess�rias.
%
%% Calculamos o valor m�ximo do filtro para evitar satura��o e overflow na 
 % quantiza��o, que tem valor de satura��o vari�vel. 
saturacao = ceil(10*max(max(abs(sos))))/10;

%% Quantiza��o dos coeficientes do filtro, do ganho e da entrada
sos = quantizador(sos,bits,saturacao);
g = quantizador(g,bits,saturacao);
entrada = quantizador(entrada,bits,saturacao)*g;

%% Estados utilizados para implementa��o dos filtros na forma Direta II 
estados = zeros(1,2);
saida_biquadradas=zeros(length(entrada),size(sos,1));

%% Para cada estrutura de segunda ordem � feito o c�lculo da sa�da, cada
%sa�da � colocada na entrada da pr�xima estrutura devido a recursividade do
%filtro IIR obedecendo o diagrama de blocos apresentado nos slides do
%professor.
for j = 1:size(sos,1)
    for i = 1:length(entrada)
        temp = entrada(i)-estados(1)*sos(j,5)-estados(2)*sos(j,6);
        temp = quantizador(temp,bits,saturacao);
        saida_biquadradas(i,j) = (temp)*sos(j,1)+estados(1)*sos(j,2)+...
            estados(2)*sos(j,3);
        estados(2) = estados(1);
        estados(1) = temp;
    end
    % Quantizamos os pontos necess�rios
    saida_biquadradas(:,j) = quantizador(saida_biquadradas(:,j),bits,saturacao);
    entrada = saida_biquadradas(:,j);
end

%% Quantizamos a sa�da e jogamos fora 400 amostraas, correspondentes a resposta
%%transit�ria do filtro.
saida_filtro = quantizador(entrada(400:end),bits,saturacao);

end %Function