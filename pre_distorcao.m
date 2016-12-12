function [new_spec_Ws1, new_spec_Wp1, new_spec_Wp2, new_spec_Ws2]...
    = pre_distorcao(spec_Ws1, spec_Wp1, spec_Wp2, spec_Ws2, ft)
%% Fun��o que calcula as frequ�ncias distorcidas segundo a equa��o XXX do
%  livro YYY
%  As entradas s�o:
%   spec_Ws1 -> Especifica��o da frequ�ncia final da banda de rejei��o inferior
%   spec_Wp1 -> Especifica��o da frequ�ncia inicial da banda passante
%   spec_Wp2 -> Especifica��o da frequ�ncia final da banda passante
%   spec_Ws2 -> Especifica��o da frequencia inicial da banda de rejei��o superior
%   ft -> Frequ�ncia de amostragem do filtro
%  As saidas s�o as frequ�ncias com a distor��o j� aplicada, seguindo a
%  mesma ordem da entrada:
%   spec_Ws1 -> Especifica��o distorcida da frequ�ncia digital final da banda de rejei��o inferior
%   spec_Wp1 -> Especifica��o distorcida da frequ�ncia digital inicial da banda passante
%   spec_Wp2 -> Especifica��o distorcida da frequ�ncia digital final da banda passante
%   spec_Ws2 -> Especifica��o distorcida da frequencia digital inicial da banda de rejei��o superior
%
%% Calcula as frequ�ncias digitais do filtro dividindo as especifica��es 
%   de frequencia pela frequ�ncia de amostragem
spec_ws1 = spec_Ws1/ft;
spec_wp1 = spec_Wp1/ft;
spec_wp2 = spec_Wp2/ft;
spec_ws2 = spec_Ws2/ft;

%% Aplica a pr�-distor��o nas frequ�ncias
new_spec_Ws1 = 2*ft*tan(spec_ws1/2);
new_spec_Wp1 = 2*ft*tan(spec_wp1/2);
new_spec_Wp2 = 2*ft*tan(spec_wp2/2);
new_spec_Ws2 = 2*ft*tan(spec_ws2/2);

end %Function