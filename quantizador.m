function [saida_quantizador]=quantizador(entrada_quantizador,bits,saturacao)

% Função implementa um quantizador de n bits com saturação em (saturacao-delta) e
% (-saturacao), onde delta eh o passo do quantizador.
%
% As entradas sao:
%
% > entrada_quantizador = sinal a ser quantizado
% > bits = numero de bits do quantizador, ou ainda (1+bits de mantissa)
% > saturacao = valor máximo do quantizador
% A saída é a entrada devidamente quantizada com o numero de bits dado
bits_de_mantissa = bits-1;

%% Calculo do passo do quantizador
passo_quantizador = saturacao*power(2,-bits_de_mantissa); 

%% Calculo da saída fazendo (passo do quantizador)*(nível de quantização da
% entrada)
saida_quantizador = passo_quantizador*round(entrada_quantizador/passo_quantizador); 

%% Saturação negativa 
saida_quantizador(saida_quantizador < -saturacao) = -saturacao;

%% Saturação positiva
saida_quantizador(saida_quantizador > saturacao-passo_quantizador) = ((saturacao)-passo_quantizador);
end %Function