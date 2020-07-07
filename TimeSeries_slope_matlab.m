[a,R]=geotiffread('E:\TimeSeries\time2010.tif');%先导入某个图像的投影信息，为后续图像输出做准确
info=geotiffinfo('E:\TimeSeries\time2010.tif');
[m,n]=size(a);
years=10; %表示有多少年份需要做回归
data=zeros(m*n,years);
k=1;
for year=2010:2019 %起始年份
    file=['E:\TimeSeries\time',int2str(year),'.tif'];%注意自己的名字形式，这里使用的名字是time2010.tif，根据这个可修改
    bz=importdata(file);
    bz=reshape(bz,m*n,1);
    data(:,k)=bz;
    k=k+1;
end
    xielv=zeros(m,n);p=zeros(m,n);R2=zeros(m,n);
for i=1:length(data)
    bz=data(i,:);
    if max(bz)>0 %注意这是进行判断有效值范围，如果有效范围是-1到1，则改成max(bz)>-1即可
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
name1='E:\TimeSeries\一元线性回归10-19趋势值.tif';
name2='E:\TimeSeries\一元线性回归10-19_P值.tif';
name3='E:\TimeSeries\一元线性回归10-19_R方.tif';
geotiffwrite(name1,xielv,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite(name2,p,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite(name3,R2,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
%一般来说，只有通过显著性检验的趋势值才是可靠的
xielv(p>0.05)=NaN;
name1='E:\QHTimeSeries\通过显著性0.05检验的QH一元线性回归10-19趋势值.tif';
geotiffwrite(name1,xielv,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
