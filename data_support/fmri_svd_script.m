%��ÿ��������SVD�ֽ�
load fmri_non%ÿ������������
% load fmri %ÿ������������
%ÿ4��һ��trial���������зֳ�60*4*876
s=["train","test"];
%����ƴ����һ�����ԣ�

fmri=zeros(1200,876);
k=5;  %k-fold
% s=["test"];
tmc=4;
%% read fmri 
for i=1:length(s)
a=eval(['fmri_',char(s(i))]);    %��ס
[t v]=size(a);
if i==1
    fmri(1:t,:)=a;
else
    fmri(end-t+1:end,:)=a;
end
end
% fmri
[t v]=size(fmri);   %duration time / voxel
a=reshape(fmri,[tmc,t/tmc,v]);  %timecourse  trial voxel
%% shape operate

% a=reshape(a,[tmc,t/tmc,v]);
a=permute(a,[3 2 1]);
% b=reshape(a(:,:,1),[t/trial,v]);
%�ȳ���һ��ÿ��ʹ�þ�ֵ���ķ�������ÿ��trial��һ�ξ�ֵ����
% m=mean(a);
%% svd decompose
fmri_svd=zeros(v,t/tmc);
for p=1:v   %do svd decompose per voxel 
    m=reshape(a(p,:,:),t/tmc,tmc); %trail timecourse 
    [U,S,V] = svd(m);
    stimu=U(:,1);%����SVD���Զ���������ֵ����һ�б�������ֵ�����źš�
    if p==166||p==446||p==607||p==608 %% the index of 4 different source boundary 
    figure(p)
    hold on
    stem(U(1:60,1))
    end
    fmri_svd(p,:)=stimu';
end
fmri_svd=reshape(fmri_svd,[v,t/tmc])';  
%% save fmri svd data
[t v]=size(fmri_svd);
l=t-t/k;
for i=1:length(s)
 if i==1
 eval([['fmri_',char(s(i))],'=','fmri_svd(1:l,:)',';']);
 else
 eval([['fmri_',char(s(i))],'=','fmri_svd(l+1:end,:)',';']);
 end
end
save fmri_svd_non_long fmri_test fmri_train
% save fmri_svd_long fmri_test fmri_train %ƴ����һ����������ź�
% 