function [thd_out, N, filter_ok] = filtro_IIR(aproximacao, bits) 
% Especificações
ft = 8000;
spec_Ap = 1;
spec_As = 35;
spec_Ws1 = 0.25*1000*2*pi;
spec_Wp1 = 0.60*1000*2*pi;
spec_Wp2 = 1.60*1000*2*pi;
spec_Ws2 = 2.40*1000*2*pi;

% Variáveis para calcular o filtro, Nfft é o numero de pontos do cálculo 
% da transformada de Fourrier, pontos_teste são o número de senóides utilizadas
% no teste do filtro quantizado, quanto maior o número de pontos, mais
% confiável é o resultado, porém maior é o tempo para a implementação do
% filtro.
Nfft = 20000;
pontos_teste = 40;
% bits = 12;
% aproximacao = 3; % 0 == Butter
%                  % 1 == Chebyshev 1
%                  % 2 == Chebyshev 2
%                  % 3 == Eliptica
% filter_ok é uma variável para o controle da implementação do filtro,
% Indica se o filtro está pronto (filter_ok = 1) ou não (filter_ok = 0) 
% e se esse ultrapassou o número máximo de iterações (filter_ok = 2)
filter_ok =0;             

%% A pré-distorção é feita chamando a função pre_distorcao
[Ws1_distorcido, Wp1_distorcido, Wp2_distorcido, Ws2_distorcido]...
    = pre_distorcao(spec_Ws1, spec_Wp1, spec_Wp2, spec_Ws2, ft);
% Fim pre distorcao

%% Como existe a necessidade de fazer simetria geométrica das frequências
% do passa faixas, optou-se por recalcular a frequencia da primeira banda
% de rejeição "Ws1". Aqui também é feita a alocação das especificações nas
% variáveis para uso futuro.
As = spec_As;
Ap = spec_Ap;
wp1 = Wp1_distorcido;
wp2 = Wp2_distorcido;
ws2 = Ws2_distorcido;

ws1_corrigido = Wp1_distorcido*Wp2_distorcido/Ws2_distorcido;
w0 = sqrt(ws1_corrigido*Ws2_distorcido);
Bw = (Wp2_distorcido-Wp1_distorcido);

%% Transformando especificações em um passa baixas normalizado, para uso no
% cálculo da ordem.
wp_pb = 1; % Frequência da banda passante
ws_pb = (w0^2-ws1_corrigido^2)/(Bw*ws1_corrigido);% Frequência da banda de rejeição
% fim

% inc_order guarda o número de iterações feita para otimização, ou seja,
% quantas vezes a ordem foi incrementada no 'while' para que o filtro final
% obedeça as especificações.
inc_order =0;


% O laço while realiza o calculo dos coeficientes, e testa o filtro,
% conforme será explicado ao longo do código. O laço roda enquanto o filtro
% não estiver pronto (filter_ok ==0). Se filter_ok ==1, o filtro está pronto
% e respeita as especificações. Se filter_ok ==2, o número máximo de
% incrementos na ordem foi atingido (5), e o filtro é considerado sem solução.
while filter_ok==0
%% A otimizacao da ordem é feita com a função que CalculaOrdem. Os melhores
% valores para a ordem são retornados.
[Ws, Wc, Ap, As, N] =...
         CalculaOrdem(spec_Ap, spec_As, wp_pb, ws_pb, 0, aproximacao, 0.001,inc_order);
% Fim

% Como o filtro implementado pelas funções é muito próximo do limite
% superior da especificação, foi implementado um deslocamento. Este
% deslocamento atenua a resposta do filtro de modo que a metade da resposta
% ideal na banda passante fique na metade das especificações da banda
% passante (ver gráficos para visualização do efeito do deslocamento). 
deslocamento = (1+10^(-spec_Ap/20))/(1+10^(-Ap/20));

%fprintf(['\nN = ',num2str(N)]);

% Mostra-se o número de acréscimos que foram feitos à ordem mínima do
% filtro ideal.
fprintf(['\nNúmero de acréscimos à ordem mínima = ',num2str(inc_order),'\n\n']);

%% Os coeficientes com os novos valores da ordem são calculados de acordo 
%com a aproximação.
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

%% É feito o bandpass digital
[B,A] = bilinear(bt,at,ft);

[hd,wd]=freqz(B,A,2048);


%% Fatoracao e escalonamento em funcoes biquadraticas com uso da função tf2sos.
% Por opção de projeto, escolheu-se ordenar para que a primeira linha de
% sos contenha os polos mais distantes do cículo unitário, e já foi feito
% escalonamento.
[sos,g] = tf2sos(B,A,'up','two');
g = g*deslocamento; % A atenuação é aplicada
% Fim da fatoracao e do escalonamento em funcoes biquadraticas
%% Teste da resposta ao impulso das biquadradas feito por meio de uma função
% muito parecida com a filtragem_quantizada.m, só que nesse caso não
% quantizamos nada, avaliando a resposta ao impulso do filtro quando
% implementado na forma de vários filtros de segunda ordem na forma
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
% sem quantizar a entrada e os pontos de armazenamento em memória.
% Avaliamos assim os efeitos que a quantização dos coeficientes gera no
% filtro, porém o teste ainda não é aplicável em dsp`s, será feito depois
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

%% Teste das senoides é feito por meio da função filtragem_quantizada, aplicando
% diversas senoides no filtro e avaliando a resposta. As senóides tem
% frequências ao longo dos pontos de frequência mais importantes do filtro,
% como a banda passante e o início das bandas de rejeição. Caso o filtro
% esteja correto, esse teste retornará filter_ok=1, de forma que esse
% filtro possa ser implementado em um dispositivo físico.
[max_Ap, max_As, min_Ap, senoide, filter_ok, max_ponto] =...
    teste_filtro(bits, spec_Ap, spec_As, Nfft,...
    pontos_teste, spec_Ws1/8000, spec_Wp1/8000, spec_Wp2/8000,...
    spec_Ws2/8000, sos, g);

%% Caso o filtro não respeite as especificações a ordem deverá ser incrementada
% para isso utilizamos a variável inc_order, como explicado anteriormente.
% Caso esse incremento ultrapasse o valor 5, ou seja, o filtro precise de
% uma ordem maior que a ordem estimada inicial + 5 finalizamos os testes e
% dizemos que o filtro não é implementável nessas especificações.
inc_order = inc_order+1;
if inc_order == 5;
    filter_ok=2;
end
end
%% Aqui é feito o cálculo da distorção harmonica do filtro. retornamos ainda 
% algumas variáveis para debug, porém o valor importante é thd_out, que
% significa a maior distorção harmônica encontrada pelo filtro.
[thd_out, pontos_w, percent_thd] =...
    filter_thd(senoide, sos, g, bits, pontos_teste, spec_Wp1/8000, spec_Wp2/8000, ft);
output = 20*log10(max_ponto);

%% Chamamos a função para plotar os gráficos que auxiliam na avaliação do
% filtro, como grafico de fase e ganho de das etapas antes e depois da
% quantização do filtro e da separação em biquadradas.
ok = filter_plot(spec_Ws1,spec_Wp1,spec_Wp2,spec_Ws2,Nfft, entrada,...
    resposta_coef_quant_impulso, wd, hd, aproximacao, bits, N, pontos_teste, output,thd_out);

%% calculo das folgas
disp(0-max_Ap);
disp(1+min_Ap);
disp(35-max_As);
%fazemos um display do resultado final do filtro
lable2 ={'\nConcluído\n\n\n','\nNúmero de iterações máximo atingido\n\n\n'};
fprintf(lable2{filter_ok});