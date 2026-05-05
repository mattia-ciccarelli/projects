ndim = 2;

load('C:/Users/Mattia/Desktop/documenti double degree/esami dd/stages/ensta/MatCont7p6/Systems/Uchannel/diagram/H_LC(1).mat')
a1 = max(x(1:ndim:end-2,:));
a2 = max(x(2:ndim:end-2,:));
a3 = x(end,:);

figure(1)
plot(a3, a1, '-b' ,'LineWidth', 2)
hold on

fig= gcf;
axObjs = fig.Children;
dataObjs = axObjs.Children;

x = transpose(dataObjs(1).XData);
y = transpose(dataObjs(1).YData);
name = "C:/Users/Mattia/Desktop/documenti double degree/esami dd/stages/ensta/MatCont7p6/a1.txt";
writematrix([x,y],name,'Delimiter',' ')

figure(2)
plot(a3, a2, '-b' ,'LineWidth', 2)
hold on

fig= gcf;
axObjs = fig.Children;
dataObjs = axObjs.Children;

x = transpose(dataObjs(1).XData);
y = transpose(dataObjs(1).YData);
name = "C:/Users/Mattia/Desktop/documenti double degree/esami dd/stages/ensta/MatCont7p6/a1.txt";
writematrix([x,y],name,'Delimiter',' ')
