% gw.m
%
% generic worker function
%
% reads struct containing
%  entry function
%  path to code
%  struct containing parameters
%
% executes entry function and saves results
%
% Version 1
% 12/26/2011
% Terry Ferrett

function gw(wid, iq, rq, oq, lp, LOG_PERIOD, NUM_LOGS)

LOG_PERIOD = str2double(LOG_PERIOD);
NUM_LOGS = str2double(NUM_LOGS);


default_path = path; % the default path will be restored after executing
                     %  the entry function

% global task controller directories
%iq = gq.iq;     %input
%rq = gq.rq;    % running
%oq = gq.oq;  %output
%ld = gq.ld;    %log dir



%%% log the worker start time %%%
[cur_time] = gettime(); % current time
ls = ['Worker' ' ' int2str(wid) ' ' 'started at' ' '  cur_time];
fprintf(ls); fprintf('\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


tic;   % start logging timer
nlog = 0; % intialize log count


%%% main worker loop
while(1)
    

    next_input = read_input_queue(iq); % read a random input file from the input queue
    if( ~isempty(next_input) )
    
      
        try
        next_running = feed_running_queue(next_input, iq, rq, wid); % move the input file to the running queue
        TaskParam = read_input_file(rq, next_running); % read the input struct from the running queue
        
        
        % break the input struct into local variables
        InputParam = TaskParam.InputParam;     % simulation parameters
        FunctionPath = TaskParam.FunctionPath; % path to simulation code
        FunctionName = TaskParam.FunctionName; % entry routine into simulation code
        
        addpath(FunctionPath);   % add simulation code path to working paths
        
        
        %%% log function start time %       
        [cur_time] = gettime(); % current time
        username = strtok(next_running, '_');  % username
        task_name = get_task_name(next_input);
        ls = ['Executing task' ' ' task_name ' ' 'from user' ' ' username  ' ' 'at'  ' ' cur_time];
        fprintf(ls);
        fprintf('\n');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        % run the function with its input parameters        
        FunctionName = str2func(FunctionName);
        TaskState = feval(FunctionName, InputParam);
        
        
        %%% log function end time %
        [cur_time] = gettime(); % current time
        ls = ['Task' ' ' task_name ' ' 'from user'  ' ' username ' ' 'complete' ' ' 'at'  ' ' cur_time];
        fprintf(ls);
        fprintf('\n');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        
        consume_running_queue(next_running, rq); % delete file from running queue
        write_output(TaskParam, TaskState, next_input, oq); % write to output queue
        
        
        path(default_path); % restore the default path
       
        
        catch exception
            % an error occurred in file loading or function execution.
            % perform cleanup by resetting the default path
            path(default_path); 
        task_name = get_task_name(next_input);
        username = strtok(next_running, '_');  % username
        [cur_time] = gettime(); % current time
            
        ls = ['Task' ' ' task_name ' ' 'from user' ' ' username  ' ' 'at'  ' ' cur_time];
ls = [ls 'failed to execute.'];
        fprintf(ls);
        fprintf('\n');
        fprintf(exception.message);
        
        end
    end
    
    
    pause(5); % wait 5 seconds before making another pass




    t = toc;
if(t > LOG_PERIOD) % rotate log file
    [cur_time] = gettime(); % current time
    rotate_log(lp,nlog, cur_time);        % rotate the log file
    nlog = mod(nlog+1, NUM_LOGS);
tic;
end
    
end
end





function next_input = read_input_queue(iq)

srch = strcat(iq, '/*.mat');      % form full directory string

fl = dir( srch );    % get list of .mat files in input queue directory

nf = length(fl);  % how many input files does this user have?

fn = ceil(rand*nf); % pick file randomly
if fn ~= 0,
    next_input = fl(fn).name;
else
    next_input = '';
end

end





function next_running = feed_running_queue(next_input, iq,  rq, wid)

% move the file to the running queue and tag with the worker id
[beg en] = strtok(next_input,'_');
next_running = [beg '_' int2str(wid) en];


cs = ['mv' ' ' iq '/' next_input ' ' rq '/' next_running ];



system(cs);

end





function TaskParam = read_input_file(rq, next_running)

lf = [rq '/' next_running];

    load(lf);

end






function consume_running_queue(next_running, rq)

cs = ['rm' ' ' rq '/' next_running];
system(cs);

end



function write_output(TaskParam, TaskState, next_input, oq)

op = [oq '/' next_input];

save(op, 'TaskParam', 'TaskState');

end



function [cur_time] = gettime();
timevec = fix(clock);  % time
year = int2str(timevec(1)); month = int2str(timevec(2)); day = int2str(timevec(3));
hour = int2str(timevec(4)); min = int2str(timevec(5)); sec = int2str(timevec(6));

cur_time = [year '-' month '-' day ' ' hour ':' min ':' sec];
end






function  task_name = get_task_name(next_input)


[beg task_name] = strtok(next_input, '_');

task_name = task_name(2:end-4);

end





function rotate_log(lp, nlog, cur_time)


% insert message at end of existing log file regarding rotation
cs = ['echo' ' ' '''Log file rotated at ' cur_time ''' ' '>>' ' ' lp];
system(cs);


% copy the existing log file to file number nlog
fnind = strfind(lp, '/');  %tokenize the full path to the log file
fnind = fnind(end);

lfp = lp(1:fnind-1);
lfn = lp(fnind+1:end);

af = [lfp '/archive' '/' lfn '.' int2str(nlog)];
cs = ['cp' ' ' lp ' ' af];
system(cs);
%%%%%%%%%%%%%%%%



%lfn = [lp '.' int2str(nlog)];
%cs = ['cp' ' ' lp ' ' lfn];
%system(cs);


% null existing log file
cs = ['cat /dev/null' ' ' '>' ' ' lp];
system(cs);


% prepend first ten lines of previous log file to new
cs = ['tail ' af ' >> ' lp];


% insert message about new log file creation with timestamp
cs = ['echo' ' ' '''Log file rotated at ' cur_time ''' ' '>>' ' ' lp];
system(cs);



end
