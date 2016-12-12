function [max_Ap, max_As, min_Ap, senoide, filter_ok, max_ponto] = ...
    teste_filtro(Nbits, spec_Ap, spec_As, Nfft, pontos_teste, ...
    ws1, wp1, wp2, ws2, sos, g)
%% Funcao testa o filtro quantizado, calculando a saida do filtro para
% algumas senoides em determinadas frequencias a fim de estimar a reposta
% do filtro atraves do ganho em cada frequencia.
%
% Os parametros de entrada são:
%
% Nbits -> número de bits para quantização
% spec_Ap -> máximo ripple na banda passante segundo especificações em dB
% spec_As -> mínima rejeição em banda de rejeição em dB
% Nfft -> número de pontos para a transformada de fourrier
% pontos_teste -> número de senóides que serão testadas para verificar o filtro
% ws1 -> frequencia de corte inferior
% wp1 -> limite inferior de banda passante 
% wp2 -> limite superior de banda passante
% ws2 -> frequencia de corte superior
% sos -> matriz de coeficientes do filtro separado e escalonado em
% biquadradas de segunda ordem
% g -> ganho do filtro
%
% As saídas da função são:
%
% max_Ap -> máximo valor da saída do filtro na banda passante, para debug
% max_As -> máximo valor da saída do filtro na banda rejeição, para debug
% min_Ap -> minimo valor da saída do filtro na banda passante, para debug
% senoide -> senoides utilizadas no teste, para debug
% filter_ok -> conclusão do teste: 0 = não passou no teste
%                                  1 = passou no teste
% max_pontos -> matriz de todos os pontos máximos, para debug.

%% A variavel 'n' calcula as senoides no tempo.
n = (0:1000);

%% A variavel 'w' controla as frequencias de cada senoide. Os pontos sao
%%igualmente espacados.
w = linspace(0.05,pi-0.05,pontos_teste);

%% A matriz senoide é previamente alocada para velocidade do programa.
senoide = zeros(pontos_teste, length(n));

%% 'i' calcula a frequencia de cada senoide.
for i = 1:pontos_teste
    % 'j' obtem n valores de cada senoide no tempo.
    for j = 1:length(n)
        senoide(i, j) = (1*sin(w(i)*j));
    end

    %% Os valores de cada senoide no tempo sao quantizados em Nbits.
    % O valor maximo de cada na saida senoide representa a primeira
    % harmonica. Esse valor eh obtido passando as senoides quantizadas 
    % pelo filtro implementado utilizando a forma direta II quantizando cada
    % etapa necessária, depois feita a DFT com Nfft pontos.
    % Depois eh tirado o modulo e por fim pego o valor maximo.
    % Ao se dividir esse valor maximo pelo valor maximo em modulo da
    % DFT com Nfft pontos da senoide de entrada obtem-se o ganho
    % (resposta em frequencia) do filtro para a frequencia de cada senoide.
    % Os pontos maximos sao colocados em 'max_ponto':
    max_ponto(i) = max(abs(fft(filtragem_quantizada(senoide(i,:),sos...
        ,g,Nbits),Nfft))/max(abs(fft(senoide(i,400:end),Nfft))));
end

    %% 'max_passante' recebe 'max_ponto' para poder ser feita analise do
    % ripple em banda passante.
    banda_passante = max_ponto;

    %% 'max_rejeicao' recebe 'max_ponto' para poder ser feita analise do
    % ripple em banda de rejeicao.
    banda_rejeicao= max_ponto;
    %% Os pontos que nao sao importantes para o calculo do ripple na
    % banda passante sao descartados. Isso equivale a descartar os
    % pontos que estão com frequencia w > wp.
for i = 1:pontos_teste
    if w(i)>wp2||w(i)<wp1
        % O descarte equivale a igualar-se a 1 pois depois todos os
        % valores de 'max_passante' sao subtraidos de 1, resultando
        % apenas no ripple nos pontos que importam, e nos pontos
        % descartados o valor fica igual a 0. O ripple eh analisado
        % pelo valor maximo do modulo de (max_passante-1), logo, os
        % valores que ficam igual a 0 na subtracao nao interferem na
        % conta.
        banda_passante(i) = 1;
    end

    % Os pontos que nao sao importantes para o calculo do ripple na
    % banda de rejeicao sao descartados. Isso equivale a descartar os
    % pontos que estão com frequencia w < ws.
    if w(i)<ws2&&w(i)>ws1
        % O descarte equivale a igualar-se a 0 pois o ripple eh
        % analisado pelo valor maximo do modulo de (max_rejeicao), logo
        % os valores que ficam igual a 0 nao interferem na conta.
        banda_rejeicao(i) = 0;
    end
end

    %% Calcula-se os máximos valores de banda passante e rejeição e o mínimo
    %  valor da banda passante, para verificar com as especificações
    max_Ap = 20*log10(max(abs(banda_passante)));
    min_Ap = 20*log10(min(abs(banda_passante)));
    max_As = 20*log10(max(abs(banda_rejeicao)));
    
    %% Atrubui-se que o filtro está correto e logo em seguida testa a 
    %  afirmação. Caso esteja errado, filter_ok recebe 0 outra vez
    filter_ok = 1;

if((max_Ap>0)||(min_Ap< -spec_Ap)||(max_As > -spec_As))
        filter_ok = 0;
end
end %Function