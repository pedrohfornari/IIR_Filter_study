function [new_ws_pb, new_wc, new_Ap, new_As, order] =...
         CalculaOrdem(Ap, As, wp_pb, ws_pb, wc, aproximacao, passo,inc_order)
%% Essa função calcula a ordem e otimiza as especificações do filtro para
% que a ordem utilizada seja melhor aproveitada e que o filtro respeite
% melhor as especificações após os efeitos não lineares da quantização.
% Para isso é calculada uma ordem inicial, conforme as aproximações de
% ordem das funções do matlab, para cada tipo de filtro. Após isso é feita
% uma restrição das especificações, até que a ordem aumente. Quando isso
% ocorre voltamos imediatamente a ultima especificação, mantendo a menor
% ordem possível com a maior restrição possível, de forma a otimizar o
% filtro para ser mais robusto as não linearidades causadas pela
% quantização.
%
% As entradas são:
%
% Ap -> Ripple máximo na banda passante
% As -> Mínima atenuação para a banda de rejeição
% wp_pb -> Frequencia limite da banda passante do filtro passa baixas
% ws_pb -> Frequencia inicial da banda de rejeição do filtro passa baixas
% wc -> Frequência de corte do filtro passa baixas
% aproximação -> método para determinação dos coeficientes do filtro
% passo -> Utilizado para alterar os valores de Ap e As na otimização,
% quanto melhor for esse valor, melhor será a otimização
% inc_order -> Utilizado quando o filtro não respeita as especificações e
% precisa ser otimizado, contador para o numero de vezes que a ordem do
% filtro foi incrementada
%
% As saídas são:
% 
% new_ws_pb -> nova frequencia inicial da banda rejeicao do filtro passa baixa
% new_wc -> nova frequencia de corte do filtro passa baixas
% new_Ap -> Nova especificação de ripple máximo na banda passante
% new_As -> Nova especificação de atenuação mínima na banda de rejeição
% order -> Ordem estimada para o filtro
%
     
%% Inicializa Valores
new_ws_pb = ws_pb;
new_wc = wc;
new_Ap = Ap;
new_As = As;     
%% Calculamos a ordem pela primeira vez dependendo da aproximação utilizada
if aproximacao == 0 % Butter
    [order, new_wc] = buttord(wp_pb,ws_pb,new_Ap, new_As,'s');
elseif aproximacao == 1 % Chebyshev 1
    [order, new_wc] = cheb1ord(wp_pb,ws_pb,new_Ap, new_As,'s');
elseif aproximacao == 2 % Chebyshev 2
    [order, new_ws_pb] = cheb2ord(wp_pb,ws_pb,new_Ap, new_As,'s');
elseif aproximacao == 3 % Eliptica
    [order, new_ws_pb] = ellipord(wp_pb,ws_pb,new_Ap, new_As,'s');
end%%if
%% Atribuimos valores para otimização de ordem
order_aux = order; % Ordem auxiliar usada no while para identificar quando
                   % a ordem com uma especificação melhor passa da order
order = order+inc_order; %Utilizada para melhorar filtro que não respeitou 
                         %especificações. É incrementada com o número de
                         %iterações do laço do programa principal.

%fprintf(['\norder = ',num2str(order)]);

%% loop de otimização que restringe especificações até limite de ordem
% A variável order_aux contem o valor da ordem calculada a cada iteração,
% porém sabemos que esse valor não é necessariamente um inteiro, apesar de
% order e order aux o serem. Então restringimos as especificações até que
% order aux ultrapasse o valor de order, assim aproveitamos ao máximo a
% ordem utilizada, melhorando o filtro para que ele seja mais robusto aos
% efeitos da quantização.
while (order_aux<=order)
    new_Ap = new_Ap-passo;
    new_Ap(new_Ap<=0) = passo/100;
    new_As = new_As+1.5*passo;
   
   if aproximacao == 0 % Butter
    [order_aux, new_wc] = buttord(wp_pb,ws_pb,new_Ap, new_As,'s');
   elseif aproximacao == 1 % Chebyshev 1
    [order_aux, new_wc] = cheb1ord(wp_pb,ws_pb,new_Ap, new_As,'s');
   elseif aproximacao == 2 % Chebyshev 2
    [order_aux, new_ws_pb] = cheb2ord(wp_pb,ws_pb,new_Ap, new_As,'s');
   elseif aproximacao == 3 % Eliptica
    [order_aux, new_ws_pb] = ellipord(wp_pb,ws_pb,new_Ap, new_As,'s');
   end%%if
end%%while

% fprintf(['\norder_aux = ',num2str(order_aux)]);

%% Quando a ordem ultrapassa a ordem mínima inteira retornamos a ultima especificação
    new_Ap = new_Ap+passo;
    new_As = new_As-1.5*passo;
   
   if aproximacao == 0 % Butter
    [order, new_wc] = buttord(wp_pb,ws_pb,new_Ap, new_As,'s');
   elseif aproximacao == 1 % Chebyshev 1
    [order, new_wc] = cheb1ord(wp_pb,ws_pb,new_Ap, new_As,'s');
   elseif aproximacao == 2 % Chebyshev 2
    [order, new_ws_pb] = cheb2ord(wp_pb,ws_pb,new_Ap, new_As,'s');
   elseif aproximacao == 3 % Eliptica
    [order, new_ws_pb] = ellipord(wp_pb,ws_pb,new_Ap, new_As,'s');
   end%%if
   
end%%Function