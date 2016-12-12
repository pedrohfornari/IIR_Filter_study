%Essa funcao faz o calculo do thd maximo da saida do filtro
%Para isso ele calcula a saida para as senoides aplicadas na
%banda passante e calcula o thd maximo
%Como a funcao thd do matlab fornece o resultado em dBc
%o resultado de cada calculo eh normalizado para um resultado em
%porcentagem, que fica melhor para analisar os resultados.
%
%As entradas são:
%
%senoides_inp -> senoides de entrada
%filter_coef_final -> coeficientes do filtro final
%Nbits -> numero de bits relativos a precisao do filtro
%pontos_de_teste -> numero de senoides utilizadas para o teste do filtro
%nao linear
%wp -> frequencia normalizada limite da banda de passagem
%Fa -> Frequencia de amostragem do filtro
%
%As saídas são:
%
%thd_out -> thd máximo em porcentagem
%pontos_w -> senóides que foram utilizadas no teste de thd, para debug
%percent_thd -> matriz com todos os thds calculados, para fim de debug
function [thd_out, pontos_w, percent_thd] = filter_thd(senoides_inp, sos, g, Nbits, pontos_de_teste, wp1, wp2, Fa)

%Inicia variaveis para selecionar apenas senoides com frequencia referentes
%a banda de passagem do filtro
w = linspace(0.05, pi-0.05, pontos_de_teste);

pontos_w = 0;

% Pontos inválidos são quantos pontos estão antes da banda passante (para
% se descartar no cálculo do THD).
pontos_invalidos = 1;
%Fim

%Calculo do numero de senoides na banda de passagem
for i = 1:pontos_de_teste
    if(w(i)<wp1)
        pontos_invalidos = pontos_invalidos+1;
        
    elseif((w(i)>=wp1)&&(w(i)<=wp2))
        pontos_w = pontos_w+1;
    end
end
%Fim

percent_thd = zeros(pontos_w,1);%inicializa vetor

%Para cada senoide da banda de passagem eh calculado o thd da saida do
%filtro, calculado pela função filtragem_quantizada. Após isso eh feita uma
%normalizacao do resultado para porcentagem
for i = pontos_invalidos+1:pontos_w+pontos_invalidos
    percent_thd(i-pontos_invalidos) = 100*(10^(thd(filtragem_quantizada(senoides_inp(i,:),sos,g,Nbits), Fa,10)/20));
end
%Fim
%Encontra o valor maximo do thd
thd_out = max(percent_thd);
%Fim