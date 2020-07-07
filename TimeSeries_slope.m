[a,R]=geotiffread('E:\QHTimeSeries\QH_L5_2010_NDVImax_fvc.tif');%�ȵ���ĳ��ͼ���ͶӰ��Ϣ��Ϊ����ͼ�������׼ȷ
info=geotiffinfo('E:\QHTimeSeries\QH_L5_2010_NDVImax_fvc.tif');
[m,n]=size(a);
years=10; %��ʾ�ж��������Ҫ���ع�
data=zeros(m*n,years);
k=1;
for year=2010:2019 %��ʼ���
    file=['E:\QHTimeSeries\QH_L5_',int2str(year),'_NDVImax_fvc.tif'];%ע���Լ���������ʽ������ʹ�õ���������prec2000.tif������������޸�
    bz=importdata(file);
    bz=reshape(bz,m*n,1);
    data(:,k)=bz;
    k=k+1;
end
    xielv=zeros(m,n);p=zeros(m,n);R2=zeros(m,n);
for i=1:length(data)
    bz=data(i,:);
    if max(bz)>0 %ע�����ǽ����ж���Чֵ��Χ�������Ч��Χ��-1��1����ĳ�max(bz)>-1����
        bz=bz';
        X=[ones(size(bz)) bz];
        X(:,2)=[1:years]';
        [b,bint,r,rint,stats] = regress(bz,X);
        pz=stats(3);
        p(i)=pz;
        pz=stats(1);
        R2(i)=pz;
        xielv(i)=b(2);
    end
end
name1='E:\QHTimeSeries\QHһԪ���Իع�10-19����ֵ.tif';
name2='E:\QHTimeSeries\QHһԪ���Իع�10-19_Pֵ.tif';
name3='E:\QHTimeSeries\QHһԪ���Իع�10-19_R��.tif';
geotiffwrite(name1,xielv,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite(name2,p,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite(name3,R2,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
%һ����˵��ֻ��ͨ�������Լ��������ֵ���ǿɿ���
xielv(p>0.05)=NaN;
name1='E:\QHTimeSeries\ͨ��������0.05�����QHһԪ���Իع�10-19����ֵ.tif';
geotiffwrite(name1,xielv,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);