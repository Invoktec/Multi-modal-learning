%decrease the time dimension of fmri 
load fmri;
%ÿ4��һ��trial���������зֳ�60*4*876
s=["train","test"];
tmc=4;
for i=1:length(s)
a=eval(['fmri_',char(s(i))]);    %��ס
[t v]=size(a);

a=reshape(a,[tmc,t/tmc,v]);
a=permute(a,[1 3 2]);
% b=reshape(a(:,:,1),[t/trial,v]);
%�ȳ���һ��ÿ��ʹ�þ�ֵ���ķ�������ÿ��trial��һ�ξ�ֵ����
m=mean(a);
m=reshape(m,[v,t/tmc])';     % m���Ǿ�ֵ�������õ�fMRI 
eval([['fmri_',char(s(i))],'=','m',';']);
end
save fmri_averige fmri_test fmri_train