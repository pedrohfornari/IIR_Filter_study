function [new_spec_Ws1, new_spec_Wp1, new_spec_Wp2, new_spec_Ws2]...
    = pre_distorcao(spec_Ws1, spec_Wp1, spec_Wp2, spec_Ws2, ft)
%% Função que calcula as frequências distorcidas segundo a equação XXX do
%  livro YYY
%  As entradas são:
%   spec_Ws1 -> Especificação da frequência final da banda de rejeição inferior
%   spec_Wp1 -> Especificação da frequência inicial da banda passante
%   spec_Wp2 -> Especificação da frequência final da banda passante
%   spec_Ws2 -> Especificação da frequencia inicial da banda de rejeição superior
%   ft -> Frequência de amostragem do filtro
%  As saidas são as frequências com a distorção já aplicada, seguindo a
%  mesma ordem da entrada:
%   spec_Ws1 -> Especificação distorcida da frequência digital final da banda de rejeição inferior
%   spec_Wp1 -> Especificação distorcida da frequência digital inicial da banda passante
%   spec_Wp2 -> Especificação distorcida da frequência digital final da banda passante
%   spec_Ws2 -> Especificação distorcida da frequencia digital inicial da banda de rejeição superior
%
%% Calcula as frequências digitais do filtro dividindo as especificações 
%   de frequencia pela frequência de amostragem
spec_ws1 = spec_Ws1/ft;
spec_wp1 = spec_Wp1/ft;
spec_wp2 = spec_Wp2/ft;
spec_ws2 = spec_Ws2/ft;

%% Aplica a pré-distorção nas frequências
new_spec_Ws1 = 2*ft*tan(spec_ws1/2);
new_spec_Wp1 = 2*ft*tan(spec_wp1/2);
new_spec_Wp2 = 2*ft*tan(spec_wp2/2);
new_spec_Ws2 = 2*ft*tan(spec_ws2/2);

end %Function