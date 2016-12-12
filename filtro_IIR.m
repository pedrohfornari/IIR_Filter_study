function [thd_out, N, filter_ok] = filtro_IIR(aproximacao, bits) 
% Especifica��es
ft = 8000;
spec_Ap = 1;
spec_As = 35;
spec_Ws1 = 0.25*1000*2*pi;
spec_Wp1 = 0.60*1000*2*pi;
spec_Wp2 = 1.60*1000*2*pi;
spec_Ws2 = 2.40*1000*2*pi;

% Vari�veis para calcular o filtro, Nfft � o numero de pontos do c�lculo 
% da transformada de Fourrier, pontos_teste s�o o n�mero de sen�ides utilizadas
% no teste do filtro quantizado, quanto maior o n�mero de pontos, mais
% confi�vel � o resultado, por�m maior � o tempo para a implementa��o do
% filtro.
Nfft = 20000;
pontos_teste = 40;
% bits = 12;
% aproximacao = 3; % 0 == Butter
%                  % 1 == Chebyshev 1
%                  % 2 == Chebyshev 2
%                  % 3 == Eliptica
% filter_ok � uma vari�vel para o controle da implementa��o do filtro,
% Indica se o filtro est� pronto (filter_ok = 1) ou n�o (filter_ok = 0) 
% e se esse ultrapassou o n�mero m�ximo de itera��es (filter_ok = 2)
filter_ok =0;             

%% A pr�-distor��o � feita chamando a fun��o pre_distorcao
[Ws1_distorcido, Wp1_distorcido, Wp2_distorcido, Ws2_distorcido]...
    = pre_distorcao(spec_Ws1, spec_Wp1, spec_Wp2, spec_Ws2, ft);
% Fim pre distorcao

%% Como existe a necessidade de fazer simetria geom�trica das frequ�ncias
% do passa faixas, optou-se por recalcular a frequencia da primeira banda
% de rejei��o "Ws1". Aqui tamb�m � feita a aloca��o das especifica��es nas
% vari�veis para uso futuro.
As = spec_As;
Ap = spec_Ap;
wp1 = Wp1_distorcido;
wp2 = Wp2_distorcido;
ws2 = Ws2_distorcido;

ws1_corrigido = Wp1_distorcido*Wp2_distorcido/Ws2_distorcido;
w0 = sqrt(ws1_corrigido*Ws2_distorcido);
Bw = (Wp2_distorcido-Wp1_distorcido);

%% Transformando especifica��es em um passa baixas normalizado, para uso no
% c�lculo da ordem.
wp_pb = 1; % Frequ�ncia da banda passante
ws_pb = (w0^2-ws1_corrigido^2)/(Bw*ws1_corrigido);% Frequ�ncia da banda de rejei��o
% fim

% inc_order guarda o n�mero de itera��es feita para otimiza��o, ou seja,
% quantas vezes a ordem foi incrementada no 'while' para que o filtro final
% obede�a as especifica��es.
inc_order =0;


% O la�o while realiza o calculo dos coeficientes, e testa o filtro,
% conforme ser� explicado ao longo do c�digo. O la�o roda enquanto o filtro
% n�o estiver pronto (filter_ok ==0). Se filter_ok ==1, o filtro est� pronto
% e respeita as especifica��es. Se filter_ok ==2, o n�mero m�ximo de
% incrementos na ordem foi atingido (5), e o filtro � considerado sem solu��o.
while filter_ok==0
%% A otimizacao da ordem � feita com a fun��o que CalculaOrdem. Os melhores
% valores para a ordem s�o retornados.
[Ws, Wc, Ap, As, N] =...
         CalculaOrdem(spec_Ap, spec_As, wp_pb, ws_pb, 0, aproximacao, 0.001,inc_order);
% Fim

% Como o filtro implementado pelas fun��es � muito pr�ximo do limite
% superior da especifica��o, foi implementado um deslocamento. Este
% deslocamento atenua a resposta do filtro de modo que a metade da resposta
% ideal na banda passante fique na metade das especifica��es da banda
% passante (ver gr�ficos para visualiza��o do efeito do deslocamento). 
deslocamento = (1+10^(-spec_Ap/20))/(1+10^(-Ap/20));

%fprintf(['\nN = ',num2str(N)]);

% Mostra-se o n�mero de acr�scimos que foram feitos � ordem m�nima do
% filtro ideal.
fprintf(['\nN�mero de acr�scimos � ordem m�nima = ',num2str(inc_order),'\n\n']);

%% Os coeficientes com os novos valores da ordem s�o calculados de acordo 
%com a aproxima��o.
if aproximacao == 0 % Butter
    [C,D] = butter(N,Wc,'s');
elseif aproximacao == 1 % Chebyshev 1
    [C,D] = cheby1(N,Ap,Wc,'s');
elseif aproximacao == 2 % Chebyshev 2
    [C,D] = cheby2(N,As,Ws,'s');
elseif aproximacao == 3 % Eliptica
    [C,D] = ellip(N,Ap,As,Ws,'s');
end%if
% Fim

%% Calculam-se os coeficientes do bandpass analogico pre distorcido
[bt,at] = lp2bp(C,D,w0,Bw);

%% � feito o bandpass digital
[B,A] = bilinear(bt,at,ft);

[hd,wd]=freqz(B,A,2048);


%% Fatoracao e escalonamento em funcoes biquadraticas com uso da fun��o tf2sos.
% Por op��o de projeto, escolheu-se ordenar para que a primeira linha de
% sos contenha os polos mais distantes do c�culo unit�rio, e j� foi feito
% escalonamento.
[sos,g] = tf2sos(B,A,'up','two');
g = g*deslocamento; % A atenua��o � aplicada
% Fim da fatoracao e do escalonamento em funcoes biquadraticas
%% Teste da resposta ao impulso das biquadradas feito por meio de uma fun��o
% muito parecida com a filtragem_quantizada.m, s� que nesse caso n�o
% quantizamos nada, avaliando a resposta ao impulso do filtro quando
% implementado na forma de v�rios filtros de segunda ordem na forma
% direta II
impulso = ([1, zeros(1,1e4)]);

entrada = impulso*g;
estados = zeros(1,2);
saida_biquadradas=zeros(length(entrada),size(sos,1));
for j = 1:size(sos,1)
    for i = 1:length(entrada)
        temp = entrada(i)-estados(1)*sos(j,5)-estados(2)*sos(j,6);
        saida_biquadradas(i,j) = (temp)*sos(j,1)+estados(1)*sos(j,2)+...
            estados(2)*sos(j,3);
        estados(2) = estados(1);
        estados(1) = temp;
    end%for
    entrada = saida_biquadradas(:,j);
end%for

%% Teste da resposta ao impulso das biquadradas com coef quant, aplicamos o
% mesmo teste anterior para o filtro com os coeficientes quantizados,
% sem quantizar a entrada e os pontos de armazenamento em mem�ria.
% Avaliamos assim os efeitos que a quantiza��o dos coeficientes gera no
% filtro, por�m o teste ainda n�o � aplic�vel em dsp`s, ser� feito depois
% utilizando diversas senoides na entrada.

saturacao = ceil(10*max(max(abs(sos))))/10;
sos_quant = quantizador(sos,bits,saturacao);
g_quant = quantizador(g,bits,saturacao);
resposta_coef_quant_impulso = impulso*g_quant;
estados2 = zeros(1,2);

saida_biquadradas2=zeros(length(entrada),size(sos_quant,1));
for j = 1:size(sos_quant,1)
    for i = 1:length(resposta_coef_quant_impulso)
        temp = resposta_coef_quant_impulso(i)-estados2(1)*sos_quant(j,5)-estados2(2)*sos_quant(j,6);
        saida_biquadradas2(i,j) = (temp)*sos_quant(j,1)+estados2(1)*sos_quant(j,2)+...
            estados2(2)*sos_quant(j,3);
        estados2(2) = estados2(1);
        estados2(1) = temp;
    end
    resposta_coef_quant_impulso = saida_biquadradas2(:,j);
end

%% Teste das senoides � feito por meio da fun��o filtragem_quantizada, aplicando
% diversas senoides no filtro e avaliando a resposta. As sen�ides tem
% frequ�ncias ao longo dos pontos de frequ�ncia mais importantes do filtro,
% como a banda passante e o in�cio das bandas de rejei��o. Caso o filtro
% esteja correto, esse teste retornar� filter_ok=1, de forma que esse
% filtro possa ser implementado em um dispositivo f�sico.
[max_Ap, max_As, min_Ap, senoide, filter_ok, max_ponto] =...
    teste_filtro(bits, spec_Ap, spec_As, Nfft,...
    pontos_teste, spec_Ws1/8000, spec_Wp1/8000, spec_Wp2/8000,...
    spec_Ws2/8000, sos, g);

%% Caso o filtro n�o respeite as especifica��es a ordem dever� ser incrementada
% para isso utilizamos a vari�vel inc_order, como explicado anteriormente.
% Caso esse incremento ultrapasse o valor 5, ou seja, o filtro precise de
% uma ordem maior que a ordem estimada inicial + 5 finalizamos os testes e
% dizemos que o filtro n�o � implement�vel nessas especifica��es.
inc_order = inc_order+1;
if inc_order == 5;
    filter_ok=2;
end
end
%% Aqui � feito o c�lculo da distor��o harmonica do filtro. retornamos ainda 
% algumas vari�veis para debug, por�m o valor importante � thd_out, que
% significa a maior distor��o harm�nica encontrada pelo filtro.
[thd_out, pontos_w, percent_thd] =...
    filter_thd(senoide, sos, g, bits, pontos_teste, spec_Wp1/8000, spec_Wp2/8000, ft);
output = 20*log10(max_ponto);

%% Chamamos a fun��o para plotar os gr�ficos que auxiliam na avalia��o do
% filtro, como grafico de fase e ganho de das etapas antes e depois da
% quantiza��o do filtro e da separa��o em biquadradas.
ok = filter_plot(spec_Ws1,spec_Wp1,spec_Wp2,spec_Ws2,Nfft, entrada,...
    resposta_coef_quant_impulso, wd, hd, aproximacao, bits, N, pontos_teste, output,thd_out);

%% calculo das folgas
disp(0-max_Ap);
disp(1+min_Ap);
disp(35-max_As);
%fazemos um display do resultado final do filtro
lable2 ={'\nConclu�do\n\n\n','\nN�mero de itera��es m�ximo atingido\n\n\n'};
fprintf(lable2{filter_ok});