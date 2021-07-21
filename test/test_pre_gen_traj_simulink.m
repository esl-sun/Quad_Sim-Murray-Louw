for k = 1:length(out.ref.time)
    disp(out.ref.time(k))
    plot(out.ref.signals.values(2,:,k))
    ylim([-1 11])
    pause
end





