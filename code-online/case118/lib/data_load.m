%% �ú���Ӧ������ָ��·����ѵ���Ͳ��Գ���
function DATA = data_load(casename)

m = matfile('fname','Writable',true);
f_this = m.data_source;

try
    load([f_this,'\',casename,'\data.mat']);
catch
    disp('Train Data! Please import the file');
    f_this = uigetdir();
    load([f_this,'\',casename,'\data.mat']);
    m.data_source = f_this;
end
    
end