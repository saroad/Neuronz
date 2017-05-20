function plotPerformance(t, normC, normVplus, normVminus, normX)

%subplot(size, size, index);
figure
plot(t, normC, 'b', t, normVplus, 'g', t, normVminus, 'r', t, normX, 'y');
legend('ComplexCells', 'LGN On', 'LGN Off', 'Layer 6');