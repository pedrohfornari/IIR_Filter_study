function [max_Ap, max_As, min_Ap, senoide, filter_ok, max_ponto] = ...
    teste_filtro(Nbits, spec_Ap, spec_As, Nfft, pontos_teste, ...
    ws1, wp1, wp2, ws2, sos, g)
%% Function that tests the quantized filter by calculating its output for a
% few sine waves to estimate its frequency response from the gain on each
% sine wave frequency.
% Funcao testa o filtro quantizado, calculando a saida do filtro para
% algumas senoides em determinadas frequencias a fim de estimar a reposta
% do filtro atraves do ganho em cada frequencia.
%
% Inputs are:
% Os parametros de entrada s�o:
%
% Nbits -> Number of bits for quantization / n�mero de bits para quantiza��o
% spec_Ap -> passband max ripple / m�ximo ripple na banda passante segundo especifica��es em dB
% spec_As -> rejection band minimal atenuation / m�nima rejei��o em banda de rejei��o em dB
% Nfft -> FFT number of points / n�mero de pontos para a transformada de fourrier
% pontos_teste -> number of sine waves tested / n�mero de sen�ides que ser�o testadas para verificar o filtro
% ws1 -> inferior cut off frequency / frequencia de corte inferior
% wp1 -> inferior limit in the passband / limite inferior de banda passante 
% wp2 -> superior limit at passband / limite superior de banda passante
% ws2 -> superior cut off frequency / frequencia de corte superior
% sos -> matrix of coeficients of the filter divided and stepped on second order filters / 
%        matriz de coeficientes do filtro separado e escalonado em biquadradas de segunda ordem
% g -> filter gain / ganho do filtro
%
% Outputs are:
% As sa�das da fun��o s�o:
%
% max_Ap -> maximum filter output at passband 
%           m�ximo valor da sa�da do filtro na banda passante, para debug
% max_As -> maximum filter output at rejection band
%           m�ximo valor da sa�da do filtro na banda rejei��o, para debug
% min_Ap -> minimum filter output at passband
%           minimo valor da sa�da do filtro na banda passante, para debug
% senoide -> sine waves used / senoides utilizadas no teste, para debug
% filter_ok -> test conclusion: 0 = did not pass
%                               1 = did pass
%              conclus�o do teste: 0 = n�o passou no teste
%                                  1 = passou no teste
% max_pontos -> matrix with maximum points
%               matriz de todos os pontos m�ximos, para debug.

%% 'n' computes the sine waves 
% A variavel 'n' calcula as senoides no tempo.
n = (0:1000);

%% 'w' controls the sine waves frequencies
% A variavel 'w' controla as frequencias de cada senoide. Os pontos sao
%%igualmente espacados.
w = linspace(0.05,pi-0.05,pontos_teste);

%% The sine waves matrix is pre alocated
%  A matriz senoide � previamente alocada para velocidade do programa.
senoide = zeros(pontos_teste, length(n));

%% 'i' calculates the frequency of each sine wave
%  'i' calcula a frequencia de cada senoide.
for i = 1:pontos_teste
    % 'j' obtain n values of each sine on the time domain.
    % 'j' obtem n valores de cada senoide no tempo.
    for j = 1:length(n)
        senoide(i, j) = (1*sin(w(i)*j));
    end

    %% The values of each sine wave are quantized by Nbits. The maximum value
    % of each output represents the first harmonic. This value is obtained
    % by filtering the sines. After that we take the absolute value and
    % then get the maximum value. Dividing it by the maximum absolute DFT
    % original sine wave we obtain the gain and with it the filter
    % frequency response could be tested.
    %  Os valores de cada senoide no tempo sao quantizados em Nbits.
    % O valor maximo de cada na saida senoide representa a primeira
    % harmonica. Esse valor eh obtido passando as senoides quantizadas 
    % pelo filtro implementado utilizando a forma direta II quantizando cada
    % etapa necess�ria, depois feita a DFT com Nfft pontos.
    % Depois eh tirado o modulo e por fim pego o valor maximo.
    % Ao se dividir esse valor maximo pelo valor maximo em modulo da
    % DFT com Nfft pontos da senoide de entrada obtem-se o ganho
    % (resposta em frequencia) do filtro para a frequencia de cada senoide.
    % Os pontos maximos sao colocados em 'max_ponto':
    max_ponto(i) = max(abs(fft(filtragem_quantizada(senoide(i,:),sos...
        ,g,Nbits),Nfft))/max(abs(fft(senoide(i,400:end),Nfft))));
end

    %% the maximum values are passed and diveded betweent two variables, 
    %  max_passante and max rejection, so both are tested within the
    %  respective limits
    %  'max_passante' recebe 'max_ponto' para poder ser feita analise do
    % ripple em banda passante.
    banda_passante = max_ponto;

    %% 'max_rejeicao' recebe 'max_ponto' para poder ser feita analise do
    % ripple em banda de rejeicao.
    banda_rejeicao= max_ponto;
    %%Points that are not usefull are discarted on each test, passband and
    %%rejection band, so it is possible to test only meaning values, to
    %%discard the nonused points we set them to 1 (passband) or 0(rejection
    %%band).
    %% Os pontos que nao sao importantes para o calculo do ripple na
    % banda passante sao descartados. Isso equivale a descartar os
    % pontos que est�o com frequencia w > wp.
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
    % pontos que est�o com frequencia w < ws.
    if w(i)<ws2&&w(i)>ws1
        % O descarte equivale a igualar-se a 0 pois o ripple eh
        % analisado pelo valor maximo do modulo de (max_rejeicao), logo
        % os valores que ficam igual a 0 nao interferem na conta.
        banda_rejeicao(i) = 0;
    end
end

    %% Maximum values are calculated on passband and rejection band
    %  Calcula-se os m�ximos valores de banda passante e rejei��o e o m�nimo
    %  valor da banda passante, para verificar com as especifica��es
    max_Ap = 20*log10(max(abs(banda_passante)));
    min_Ap = 20*log10(min(abs(banda_passante)));
    max_As = 20*log10(max(abs(banda_rejeicao)));
    
    %% The filter is set to correct but if it does not pass the test it is
    %  returned to not ready and then the project restart calculating the
    %  filter coeficients with a greater order.
    %  Atrubui-se que o filtro est� correto e logo em seguida testa a 
    %  afirma��o. Caso esteja errado, filter_ok recebe 0 outra vez
    filter_ok = 1;

if((max_Ap>0)||(min_Ap< -spec_Ap)||(max_As > -spec_As))
        filter_ok = 0;
end
end %Function