% Generate neuron data by calling external program
% will use preserved data automatically

% if you want to calculate
%netstr = 'net_2_2';
%scee = 0.02;     % cortical strength
%pr = 1;          % poisson input rate
%ps = 0.012;      % poisson input strength
%simu_time = 1e5;
%stv = 0.5;
%dt = 1/128;
% and use RC filter
% call this function like:
%  [X, ISI, ras] = gendata_neu('net_2_2', 0.02, 1, 0.012, 1e5, 0.5, '-dt 0.0078125 --RC-filter');
% If you want a new experiment, run
%  change '-dt 0.0078125 --RC-filter' to 'new -dt 0.0078125 --RC-filter'

% note: the parameter extpara may have security hole -- to excute arbitrary shell command

function [X, ISI, ras] = gendata_neu(netstr, scee, pr, ps, simu_time, stv, extpara, data_dir_prefix)
if (exist('stv', 'var')==0)
    stv = 0.5;
end
new_run    = false;
use_exp_IF = false;
use_common_poisson = false;
return_X_name = false;
pI = -1;
mode_rm_only = false;
mode_read_only = false;
mode_run_in_background = false;
if (exist('extpara','var')==0)
    extpara = '';
else
    if (length(extpara)>=2) && (1==strcmpi(extpara(1:2), 'rm'))
        mode_rm_only = true;         % remove the output files then exit
    end
    if (length(extpara)>=4) && (1==strcmpi(extpara(1:4), 'read'))
        mode_read_only = true;
    end
    if (length(extpara)>=3) && (1==strcmpi(extpara(1:3),'new'))
        new_run = true;
        extpara = extpara(4:end);
    end
    if (length(extpara)>=5) && (1==strcmpi(extpara(1:5),'ExpIF'))
        use_exp_IF = true;
        extpara = extpara(6:end);
    end
    if (length(extpara)>=2) && (1==strcmpi(extpara(1:2),'co'))
        use_common_poisson = true;
        extpara = extpara(3:end);
    end
    if (length(extpara)>=5) && (1==strcmpi(extpara(1:5),'nameX'))
        return_X_name = true;
        extpara = extpara(6:end);
    end
    fp = strfind(extpara,'-n ');  % number of neurons
    if (length(fp)>0)
        fp = fp(end);  % use last occurrence
        np = strfind(extpara(fp+3:end), ' ');
        np = [np, length(extpara(fp+3:end))+1];
        np([diff(np),2]<=1) = [];                % delete continus white spaces
        pE = str2num(extpara(fp+3:fp+1+np(1)));
        if (length(np)>1)
            pI = str2num(extpara(fp+2+np(1):fp+1+np(2)));
        else
            pI = 0;
        end
    else
        pE = -1;
        pI = -1;
    end
    s_tmp = strtrim(extpara);
    if ~isempty(s_tmp) && strcmp(s_tmp(end), '&') == 1
        mode_run_in_background = true;
    end
end

if filesep == '\'
    fs = '\';          % in M$ windows
else
    fs = '/';
end
pathdir = fileparts(mfilename('fullpath'));
if isempty(netstr)
    matname = '-';
    neu_network = [1];
else
    matname = [pathdir, fs, 'network', fs, netstr, '.txt'];
    neu_network = load('-ascii', matname);
end
p = size(neu_network, 1);
if length(scee)==1 && pI==-1
    file_inf_st = sprintf('%s_sc=%g_pr=%g_ps=%g_t=%.2e_stv=%g',...
                      netstr, scee, pr, ps, simu_time, stv);
else
    % the order of scee is: E2E, E2I, I2E, I2I
    scee = [scee, zeros(1,4-length(scee))];   % extend to full form
    st_scee = strrep(mat2str(scee),' ',',');
    st_p = strrep(mat2str([pE,pI]),' ',',');
    file_inf_st = sprintf('%s_p%s_sc=%s_pr=%g_ps=%g_t=%.2e_stv=%g',...
                      netstr, st_p, st_scee, pr, ps, simu_time, stv);
    if (pI+pE ~= p)
        error('number of neurons does not match the network!');
    end
end
if ~exist('data_dir_prefix', 'var')
    data_dir_prefix = ['data', fs];
end
file_prefix = data_dir_prefix;  % give user the full power to set directory
if use_exp_IF
    file_prefix = [file_prefix, 'EIF_'];
end
output_name     = [file_prefix, 'volt_',file_inf_st,'.dat'];
output_ISI_name = [file_prefix, 'ISI_', file_inf_st,'.txt'];
output_RAS_name = [file_prefix, 'RAS_', file_inf_st,'.txt'];

if mode_rm_only
    system(['rm -f ', output_name]);
    system(['rm -f ', output_ISI_name]);
    system(['rm -f ', output_RAS_name]);
    X = [];
    ISI = [];
    ras = [];
    return
end

if new_run
    system(['rm -f ', output_ISI_name]);
    system(['rm -f ', output_RAS_name]);
end

if (exist(output_RAS_name, 'file') == 0 || new_run) && ~mode_read_only
%    static_param = 'raster_tuning -ng -v --bin-save';     % if you are using M$ Windows
    if use_exp_IF
        static_param = ['"',pathdir, fs, 'raster_tuning_expIF" -ng -v --bin-save -inf -'];
    else
        if use_common_poisson
            static_param = ['"',pathdir, fs, 'raster_tuning_co" -ng -v --bin-save -inf -'];
        else
            static_param = ['"',pathdir, fs, 'raster_tuning" -ng -v --bin-save -inf -'];
        end
    end
    if length(scee)==1 && pI==-1
        cmdst = sprintf('%s -n %d -t %.16e -mat "%s" -pr %.16e -ps %.16e -scee %.16e --save-interval %.16e -o "%s" --save-spike-interval "%s" --save-spike "%s"', ...
                static_param, p, simu_time, matname, pr, ps, scee, stv, output_name, output_ISI_name, output_RAS_name);
    else
        cmdst = sprintf('%s -n %d %d -t %.16e -mat "%s" -pr %.16e -ps %.16e -scee %.16e -scei %.16e -scie %.16e -scii %.16e --save-interval %.16e -o "%s" --save-spike-interval "%s" --save-spike "%s"', ...
                static_param, pE, pI, simu_time, matname, pr, ps, scee(1), scee(2), scee(3), scee(4), stv, output_name, output_ISI_name, output_RAS_name);
    end
%disp([cmdst, ' ', extpara]);  fflush(stdout);   % for debug
    rt = system([cmdst, ' ', extpara]);
else
    rt = 0;
end

if mode_run_in_background
    X=[];
    ISI=rt;
    RAS=[];
    return
end

if mode_read_only
    % fixme: is there a way to test whether the files are using by other program in Matlab? lsof is not portable to M$
    % whether the file is exist and filled?
    f_info = stat(output_RAS_name);
    if ~isempty(f_info) && (time() - f_info.mtime > 1.0)
        rt = 0;
    else
        X=[];
        ISI=[];
        ras=[];
        return
    end
end

if rt==0
    if (nargout>0)
        if return_X_name
            X = output_name;
        else
            fid = fopen(output_name, 'r');
            X = fread(fid, [p, Inf], 'double');
            fclose(fid);
        end
    end
    if (nargout>1)
        ISI = load('-ascii', output_ISI_name);
    end
    if (nargout>2)
        ras = load('-ascii', output_RAS_name);
    end
else
    X=[];
    ISI=[];
    ras=[];
    error('Fail to generate data!');
end

end
% vim: set ts=4 sw=4 ss=4
