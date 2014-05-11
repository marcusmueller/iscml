% gen_test_data.m
%
% create an example input structure for the code loaded by the test 

function test_job_manager(nt, user)

InputParam.nnums = 10;                                        % generate 10 uniform random variates
FunctionPath = ['/rhome/pcs/jm/test'];                        % path to entry function
FunctionName = 'test_entryfn';                                               % entry function

TaskParam.InputParam = InputParam; % load input struct
TaskParam.FunctionPath = FunctionPath;
TaskParam.FunctionName = FunctionName;

output_struct = '';

for k = 1:nt,
	  task_filename = ['test_task_' int2str(k) '.mat'];
          tmp_pth = [ './task_tmp/' task_filename ];
          save(tmp_pth, 'TaskParam' );
end

file_op = ['sudo mv ./task_tmp/*.mat /home' '/' user '/' 'tasks/siq/'];
system(file_op);

file_op = ['sudo chown' ' ' user ':' user ' ' '/home' '/' user '/' 'tasks/siq/*'];
system(file_op);
