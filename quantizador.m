function [saida_quantizador]=quantizador(entrada_quantizador,bits,saturacao)

% Fun��o implementa um quantizador de n bits com satura��o em (saturacao-delta) e
% (-saturacao), onde delta eh o passo do quantizador.
%
% As entradas sao:
%
% > entrada_quantizador = sinal a ser quantizado
% > bits = numero de bits do quantizador, ou ainda (1+bits de mantissa)
% > saturacao = valor m�ximo do quantizador
% A sa�da � a entrada devidamente quantizada com o numero de bits dado
bits_de_mantissa = bits-1;

%% Calculo do passo do quantizador
passo_quantizador = saturacao*power(2,-bits_de_mantissa); 

%% Calculo da sa�da fazendo (passo do quantizador)*(n�vel de quantiza��o da
% entrada)
saida_quantizador = passo_quantizador*round(entrada_quantizador/passo_quantizador); 

%% Satura��o negativa 
saida_quantizador(saida_quantizador < -saturacao) = -saturacao;

%% Satura��o positiva
saida_quantizador(saida_quantizador > saturacao-passo_quantizador) = ((saturacao)-passo_quantizador);
end %Function