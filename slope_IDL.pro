;IDL程序
PRO tendency
  ;设置编译环境
  COMPILE_OPT IDL2
  ;设置参数，后台调用ENVI函数环境
  ENVI,/RESTORE_BASE_SAVE_FILES,/NO_STATUS_WINDOW
  ENVI_BATCH_INIT, log_file='batch.txt'
 
  ;=================================================================================
  in_name='E:\year\' 
  out_slp='E:\year\slp.tif' 
  out_R='E:\year\R.tif' 
  ;=================================================================================
  filenames=FILE_SEARCH(in_name,'*.tif')
  
  name=filenames[0]
  ;打开一个图像，获取行列数，投影信息
  ENVI_OPEN_FILE,name,r_fid=fid,/no_realize;directory and file name, to be modified
  IF (fid EQ -1) THEN BEGIN
    info=DIALOG_MESSAGE('未找到数据，请确认路径或文件名格式是否正确！')
    RETURN
  ENDIF
  ENVI_FILE_QUERY, fid, ns=ns, nl=nl, nb=nb, dims=dims
  map_info=ENVI_GET_MAP_INFO(fid=fid)
  ;获取文件个数
  n = N_ELEMENTS(filenames)
  ;根据文件名，获得因子的时间序列
  t=FLTARR(n)
  FOR i=0,n-1 DO BEGIN
    time = STRMID(filenames[i],STRPOS(filenames[i],'2'),4)
    t[i] = FLOAT(time)
  ENDFOR
  ;创建三维数组保存数据
  data=FLTARR(ns,nl,n)
  FOR i=0,n-1 DO BEGIN
    ENVI_OPEN_FILE,filenames[i],r_fid=fid,/no_realize;directory and file name, to be modified
    IF (fid EQ -1) THEN BEGIN
      info=DIALOG_MESSAGE('未找到数据，请确认路径或文件名格式是否正确！')
      RETURN
    ENDIF
    data[*,*,i]=ENVI_GET_DATA(fid=fid,dims=dims,pos=0)
  ENDFOR
  ;逐像元拟合
  slp=FLTARR(ns,nl) ;创建数组保存斜率计算结果
  r=FLTARR(ns,nl) ;创建数组保存相关系数计算结果
  FOR i=0,ns-1 DO BEGIN
    FOR j=0,nl-1 DO BEGIN
      
      lin=linfit(t,data[i,j,*])
      slp[i,j]=lin[1]

     
      r[i,j]=correlate(t,data[i,j,*])

    ENDFOR
  ENDFOR
  
  ENVI_WRITE_ENVI_FILE,slp,out_dt=4,map_info=map_info,ns=ns,nl=nl,nb=nb,out_name=out_slp
  ENVI_WRITE_ENVI_FILE,r,out_dt=4,map_info=map_info,ns=ns,nl=nl,nb=nb,out_name=out_R
END
