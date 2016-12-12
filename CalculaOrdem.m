function [new_ws_pb, new_wc, new_Ap, new_As, order] =...
         CalculaOrdem(Ap, As, wp_pb, ws_pb, wc, aproximacao, passo,inc_order)
%% Essa fun��o calcula a ordem e otimiza as especifica��es do filtro para
% que a ordem utilizada seja melhor aproveitada e que o filtro respeite
% melhor as especifica��es ap�s os efeitos n�o lineares da quantiza��o.
% Para isso � calculada uma ordem inicial, conforme as aproxima��es de
% ordem das fun��es do matlab, para cada tipo de filtro. Ap�s isso � feita
% uma restri��o das especifica��es, at� que a ordem aumente. Quando isso
% ocorre voltamos imediatamente a ultima especifica��o, mantendo a menor
% ordem poss�vel com a maior restri��o poss�vel, de forma a otimizar o
% filtro para ser mais robusto as n�o linearidades causadas pela
% quantiza��o.
%
% As entradas s�o:
%
% Ap -> Ripple m�ximo na banda passante
% As -> M�nima atenua��o para a banda de rejei��o
% wp_pb -> Frequencia limite da banda passante do filtro passa baixas
% ws_pb -> Frequencia inicial da banda de rejei��o do filtro passa baixas
% wc -> Frequ�ncia de corte do filtro passa baixas
% aproxima��o -> m�todo para determina��o dos coeficientes do filtro
% passo -> Utilizado para alterar os valores de Ap e As na otimiza��o,
% quanto melhor for esse valor, melhor ser� a otimiza��o
% inc_order -> Utilizado quando o filtro n�o respeita as especifica��es e
% precisa ser otimizado, contador para o numero de vezes que a ordem do
% filtro foi incrementada
%
% As sa�das s�o:
% 
% new_ws_pb -> nova frequencia inicial da banda rejeicao do filtro passa baixa
% new_wc -> nova frequencia de corte do filtro passa baixas
% new_Ap -> Nova especifica��o de ripple m�ximo na banda passante
% new_As -> Nova especifica��o de atenua��o m�nima na banda de rejei��o
% order -> Ordem estimada para o filtro
%
     
%% Inicializa Valores
new_ws_pb = ws_pb;
new_wc = wc;
new_Ap = Ap;
new_As = As;     
%% Calculamos a ordem pela primeira vez dependendo da aproxima��o utilizada
if aproximacao == 0 % Butter
    [order, new_wc] = buttord(wp_pb,ws_pb,new_Ap, new_As,'s');
elseif aproximacao == 1 % Chebyshev 1
    [order, new_wc] = cheb1ord(wp_pb,ws_pb,new_Ap, new_As,'s');
elseif aproximacao == 2 % Chebyshev 2
    [order, new_ws_pb] = cheb2ord(wp_pb,ws_pb,new_Ap, new_As,'s');
elseif aproximacao == 3 % Eliptica
    [order, new_ws_pb] = ellipord(wp_pb,ws_pb,new_Ap, new_As,'s');
end%%if
%% Atribuimos valores para otimiza��o de ordem
order_aux = order; % Ordem auxiliar usada no while para identificar quando
                   % a ordem com uma especifica��o melhor passa da order
order = order+inc_order; %Utilizada para melhorar filtro que n�o respeitou 
                         %especifica��es. � incrementada com o n�mero de
                         %itera��es do la�o do programa principal.

%fprintf(['\norder = ',num2str(order)]);

%% loop de otimiza��o que restringe especifica��es at� limite de ordem
% A vari�vel order_aux contem o valor da ordem calculada a cada itera��o,
% por�m sabemos que esse valor n�o � necessariamente um inteiro, apesar de
% order e order aux o serem. Ent�o restringimos as especifica��es at� que
% order aux ultrapasse o valor de order, assim aproveitamos ao m�ximo a
% ordem utilizada, melhorando o filtro para que ele seja mais robusto aos
% efeitos da quantiza��o.
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

%% Quando a ordem ultrapassa a ordem m�nima inteira retornamos a ultima especifica��o
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