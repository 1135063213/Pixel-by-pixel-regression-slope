;IDL����
PRO tendency
  ;���ñ��뻷��
  COMPILE_OPT IDL2
  ;���ò�������̨����ENVI��������
  ENVI,/RESTORE_BASE_SAVE_FILES,/NO_STATUS_WINDOW
  ENVI_BATCH_INIT, log_file='batch.txt'
 
  ;=================================================================================
  in_name='E:\year\' 
  out_slp='E:\year\slp.tif' 
  out_R='E:\year\R.tif' 
  ;=================================================================================
  filenames=FILE_SEARCH(in_name,'*.tif')
  
  name=filenames[0]
  ;��һ��ͼ�񣬻�ȡ��������ͶӰ��Ϣ
  ENVI_OPEN_FILE,name,r_fid=fid,/no_realize;directory and file name, to be modified
  IF (fid EQ -1) THEN BEGIN
    info=DIALOG_MESSAGE('δ�ҵ����ݣ���ȷ��·�����ļ�����ʽ�Ƿ���ȷ��')
    RETURN
  ENDIF
  ENVI_FILE_QUERY, fid, ns=ns, nl=nl, nb=nb, dims=dims
  map_info=ENVI_GET_MAP_INFO(fid=fid)
  ;��ȡ�ļ�����
  n = N_ELEMENTS(filenames)
  ;�����ļ�����������ӵ�ʱ������
  t=FLTARR(n)
  FOR i=0,n-1 DO BEGIN
    time = STRMID(filenames[i],STRPOS(filenames[i],'2'),4)
    t[i] = FLOAT(time)
  ENDFOR
  ;������ά���鱣������
  data=FLTARR(ns,nl,n)
  FOR i=0,n-1 DO BEGIN
    ENVI_OPEN_FILE,filenames[i],r_fid=fid,/no_realize;directory and file name, to be modified
    IF (fid EQ -1) THEN BEGIN
      info=DIALOG_MESSAGE('δ�ҵ����ݣ���ȷ��·�����ļ�����ʽ�Ƿ���ȷ��')
      RETURN
    ENDIF
    data[*,*,i]=ENVI_GET_DATA(fid=fid,dims=dims,pos=0)
  ENDFOR
  ;����Ԫ���
  slp=FLTARR(ns,nl) ;�������鱣��б�ʼ�����
  r=FLTARR(ns,nl) ;�������鱣�����ϵ��������
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