%����ԭʼ��fMRI���ݵ��ص�
load fmri_averige.mat
c=fmri_test;
d=fmri_train;
a=std(fmri_test); %�鿴��ͬ����֮��ķ���
figure(1)
hold on
plot(a);%���ַ���֮��ͬ����֮��ķ������������һ����Χ��
title('the std of different voxels of testing set with orignal ')
%% ����testing set
%������һ��������ٲ鿴��׼��
max_t=max(c);
min_t=min(c);
s=(c-min_t)./(max_t-min_t);  %scale to (0-1)
% figure(1)
% hold on
% plot(s);
s_s=std(s);
figure(2)
hold on
plot(s_s);%���ַ���֮��ͬ����֮��ķ������������һ����Χ��
title('the std of different voxels of testing set with (0-1) scale')
%% ����training set
max_t=max(d);
min_t=min(d);
s=(d-min_t)./(max_t-min_t);  %scale to (0-1)
% figure(1)
% hold on
% plot(s);
s_s=std(s);
figure(3)
hold on
plot(s_s);%ѵ�����ķ���Ҳͬ��������һ����Χ��
title('the std of different voxels of training set with (0-1) scale')
%% ʹ�ü�����Ȼ�õ����Լ����ر�׼��ķֲ�

N=length(s_s);
u=sum(s_s)/N;
sigma=sum((s_s-u).^2)./(N-1);
x = -1:0.1:1;
y = gaussmf(x,[u sigma]);
figure(4)
hold on
plot(x,y)
xlabel(['mean=',num2str(u),'var=',num2str(sigma)])
title('the distribution of std of training set voxels')
%���Կ���ÿ�����صı�׼��ʮ�ֵĽӽ���


