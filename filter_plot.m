function ok = filter_plot(spec_Ws1,spec_Wp1,spec_Wp2,spec_Ws2,Nfft,...
    entrada, resposta_quantizada_impulso, wd, hd, aproximacao, bits,...
    N, pontos_teste, output, thd_out)
% Esta função traça os gráficos dos resultados obtidos, para visualização.


%% Função que desenha o gabarito digital
% Quantidades de pontos no plot do gabarito
pontos_gabarito_digital = linspace(0,pi,Nfft/2);
% Linha para limite superior na banda passante e superior na banda de
% rejeição
xd1_1 = 0;
xd1_1(pontos_gabarito_digital<spec_Wp1/8000|pontos_gabarito_digital>spec_Wp2/8000) = -35;

% Linha para traçar o pontilhado para melhor visualização da frequência da
% banda passante
xd1_2 = 0;
xd1_2(pontos_gabarito_digital<spec_Wp1/8000|pontos_gabarito_digital>spec_Wp2/8000) = -100;

% Linha para limite inferior na banda passante
xd2 = -1*ones(1,length(xd1_1));
xd2(pontos_gabarito_digital<spec_Ws1/8000|pontos_gabarito_digital>spec_Ws2/8000) = -100;
% Fim gabarito digital
%% Lable do plot
lable = {'Butterworth', 'Chebyshev 1', 'Chebyshev 2', 'Eliptica'};
% Fim label

%% Passa a resposta em frequência ideal para dB
hddB = 20*log10(abs(hd));
% Fim

%% Plots
% Magnitude e fase do Bandpass digital.
figure;
plot(pontos_gabarito_digital/(2*pi),xd1_1,'r',pontos_gabarito_digital/(2*pi),xd1_2,'r:',pontos_gabarito_digital/(2*pi),xd2,'r');
axis([0,0.5,-45,1]);
hold on
[AX,H1,H2]=plotyy(wd/(2*pi),hddB,wd/(2*pi),angle(hd));
set(AX,{'ycolor'},{'k';'g'});
set(H1,{'color'},{'k'});
set(H2,{'color'},{'g'});
hold off;
axis([0,0.5,-45,1]);
title(['Bandpass digital: Magnitude & Fase ', lable{aproximacao+1}]);
%Fim Bandpass digital

% Bandpass digital para comparação entre: 
%    Bandpass Ideal;
%    Biquadradas em Cascata Ideal (com correção no ganho);
%    Biquadradas em Cascata Quantizadas (com correção no ganho);
figure
h = fft(entrada,Nfft);
h2 = fft(resposta_quantizada_impulso,Nfft);
plot(pontos_gabarito_digital/(2*pi),xd1_1,'r',pontos_gabarito_digital/(2*pi),xd1_2,'r:',pontos_gabarito_digital/(2*pi),xd2,'r');
axis([0,0.5,-45,1]);
hold on;
plot_quant=plot(pontos_gabarito_digital/(2*pi),20*log10(abs(h2(1:length(h2)/2))),'k');
plot_ideal=plot(wd/(2*pi),hddB,'g--');
plot_casca=plot(pontos_gabarito_digital/(2*pi),20*log10(abs(h(1:length(h)/2))),'b-.');
hold off;
title(['Bandpass digital com coeficientes quantizados ',...
    lable{aproximacao+1},', ', num2str(bits),' bits, ordem ',num2str(N)]);
legend([plot_ideal,plot_casca,plot_quant],'Ideal.', sprintf('%s\n%s',...
    'Biquadradas em cascata ideal','com correção de ganho.'),sprintf('%s\n%s',...
    'Biquadradas em cascata quantizado','com correção de ganho.'));
% Fim do Bandpass digital para comparação

% Pontos das senoides
figure
eixo_teste_senoides = linspace(0.05,pi-0.05,pontos_teste)/(2*pi);
plot(eixo_teste_senoides,output,'bo');
hold on
plot(pontos_gabarito_digital/(2*pi),xd1_1,'r',pontos_gabarito_digital/(2*pi),xd1_2,'r:',pontos_gabarito_digital/(2*pi),xd2,'r');
hold off
axis([0,0.5,-45,1]);
title(['Bandpass digital com coeficientes quantizados ',...
    lable{aproximacao+1},', ',num2str(bits),' bits, ordem ',num2str(N),...
    ', THD = ', num2str(thd_out),'%']);
% Fim dos pontos das senoides

% Flag que indica que terminou
ok = 1;
% Fim
end