function [saida_filtro] = filtragem_quantizada(entrada,sos,g,bits)
%% Essa função calcula a saida do filtro, já aplicando a quantização
%   Suas entradas são:
%    entrada -> sinal de entrada do filtro
%    sos -> matriz com os coeficientes do filtro separados em biquadradas e já escalonados
%    g -> ganho do filtro
%    bits -> precisão do filtro, dada pelo numero de bits da pracisão da memória do filtro
%   a saida, dada por saida_filtro, é apenas a simulação da saída do filtro
%   real, já quantizado, após passar pelas operações necessárias.
%
%% Calculamos o valor máximo do filtro para evitar saturação e overflow na 
 % quantização, que tem valor de saturação variável. 
saturacao = ceil(10*max(max(abs(sos))))/10;

%% Quantização dos coeficientes do filtro, do ganho e da entrada
sos = quantizador(sos,bits,saturacao);
g = quantizador(g,bits,saturacao);
entrada = quantizador(entrada,bits,saturacao)*g;

%% Estados utilizados para implementação dos filtros na forma Direta II 
estados = zeros(1,2);
saida_biquadradas=zeros(length(entrada),size(sos,1));

%% Para cada estrutura de segunda ordem é feito o cálculo da saída, cada
%saída é colocada na entrada da próxima estrutura devido a recursividade do
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
    % Quantizamos os pontos necessários
    saida_biquadradas(:,j) = quantizador(saida_biquadradas(:,j),bits,saturacao);
    entrada = saida_biquadradas(:,j);
end

%% Quantizamos a saída e jogamos fora 400 amostraas, correspondentes a resposta
%%transitória do filtro.
saida_filtro = quantizador(entrada(400:end),bits,saturacao);

end %Function