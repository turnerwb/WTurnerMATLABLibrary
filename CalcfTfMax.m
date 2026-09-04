function [fT, fMax] = CalcfTfMax(SP)

%EDIT ME: upper and lower bounds to the ~ linear regions of the h21 curve
    lm_uppercutoff = 40e9;
    lm_lowercutoff = 5e8;
%End EDIT ME
    f = SP.Frequencies;
    h = hparameters(SP);
    h_mtx = h.Parameters; %Need matrix form
    %UNCOMMENT NEXT LINE FOR h21 Plot (in dB)
    figure(1)
   plot(log10(f),squeeze(20*log10(abs(h_mtx(2,1,:)))))
    f_lm = f((f>=lm_lowercutoff & f<=lm_uppercutoff));
    h21_lm = h_mtx(2,1,f>=lm_lowercutoff & f<=lm_uppercutoff);
    fixedslope = fittype('-20*x+b');
    fixedslopemdl = fit(log10(f_lm),20*log10(squeeze(abs(h21_lm))),fixedslope,'StartPoint',-20*log10(f(1))+abs(squeeze(h_mtx(2,1,1))))
    fixedslopefit = -20*log10(f) + fixedslopemdl.b;
    LTZero_fixedslope = fixedslopefit<=0;
    fT = 10^(-1*fixedslopemdl.b/-20);
    hold('on')
    plot(log10(f), fixedslopefit)
    yline(0,'k','LineWidth',2)
    hold('off')
    ylim([-20 40])
    xlabel('log_{10}(f)')
    ylabel('|h_{21}|(dB)')
    set(gca,'FontSize',20)

    Z= zparameters(SP);
    Z11 = squeeze(Z.Parameters(1,1,:));
    Z12 = squeeze(Z.Parameters(1,2,:));
    Z21 = squeeze(Z.Parameters(2,1,:));
    Z22 = squeeze(Z.Parameters(2,2,:));
    U = 10*log10((abs(Z12-Z21).^2) ./ (4*(real(Z11).*real(Z22) - real(Z12).*real(Z21))));
    U_lm = U((f>=lm_lowercutoff & f<=lm_uppercutoff));
    U_Fit = fit(log10(f_lm),real(U_lm),fixedslope,'StartPoint',-20*log10(f(1))+abs((U(1))));
    fMax = 10^(-1*U_Fit.b/-20);
    % figure(2)
    % plot(log10(f),real(U))
    % hold('on')
    % plot(U_Fit)
    % yline(0,'k','LineWidth',2)
    % hold('off')
    % ylim([-20 40])
    % xlabel('log_{10}(f)')
    % ylabel('U')
    % set(gca,'FontSize',20)
end