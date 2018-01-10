function plotPerformance(t, norm1, norm2, norm3, norm4)

%subplot(size, size, index);
figure
plot(t, norm1, 'b', t, norm2, 'g', t, norm3, 'r', t, norm4, 'y');
legend('1', '2', '3', '4');