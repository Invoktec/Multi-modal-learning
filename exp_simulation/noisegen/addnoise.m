function [noisy, noise] = addnoise(signal, noise, snr)
% signal����ʾ����ͼ��noise��������snr��ָ���� SNR ֵ��

% ��������ȼ��㺯��
SNR = @(signal, noisy) 20*log10(norm(signal)/norm(signal-noisy));

S = length(signal); N = length(noise);
assert(N >= S);

R = randi(1+N-S);
noise = noise(R:R+S-1);

noise = noise / norm(noise) * norm(signal) * 10^(0.05*snr);

noisy = noise + signal;

assert(abs(SNR(signal, noisy)) < 1e10*eps);
