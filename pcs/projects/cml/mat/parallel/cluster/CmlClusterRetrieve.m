% CmlClusterRetrieve.m
% Retrieve CML scenarios completed by PCS.
%
% Inputs
%  No arguments      Retrieve all completed jobs
%
%  scenario          CML scenario name
%  records            record list
%
%
%  Running on the cluster retrieves completed jobs, converts them to
%   CML output files, and places the output files in CML's output
%   directory.
%
%  Running locally connects to the cluster, performs the steps described
%  above, and copies the CML output directory on the
%  cluster to the output directory for the CML output directory stored locally.
%
%     Last updated on 2/11/2013
%
%     Copyright (C) 2012, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.

function CmlClusterRetrieve( )

location = CmlJobSubMRunLocation();

switch location,
    
    % retrieve jobs while running on cluster.
    case 'clusterlocal'
        
        % read location of user's project root.
        [project_root] = ReadProjectRoot();
        
        % retrieve state of jobs which are still running.
        running_queue = [project_root '/JobRunning'];
        listing = GetDirectoryListing( running_queue );
        ConsumeRunningQueue( running_queue, listing );
        
        
        %  remove internal data files of jobs
        %  under the following conditions
        %  1. job file in JobOut
        %  2. job file NOT in JobRunning/JobIn
        % construct paths to all queues
        input_queue = [project_root '/JobIn'];
        running_queue = [project_root '/JobRunning'];
        output_queue = [project_root '/JobOut'];
        int_data_dir = [project_root '/Data' '/Jm'];
        
        % get listing of jobs in jobout
        listing = GetDirectoryListing( output_queue );
        DeleteIntDat( listing,...
            input_queue,...
            running_queue,...
            int_data_dir );
        
        
        % consume jobs which have finished.
        output_queue = [project_root '/JobOut'];% whenever a retrieve is performed
        listing = GetDirectoryListing( output_queue );
        ConsumeOutputQueue( output_queue, listing );
        
        
        
        % retrieve jobs from cluster by executing CmlClusterRetrieve remotely.
        % copy CML's output directory from remote copy of CML to local.
    case 'local'
        cml_home = CmlLoadCmlHome('local');
        
        % read linux account info used on cluster.
        [user remote_cmlroot remote_projroot] =  CmlReadAccountInfo();
        
        % report the jobs which are in the running and output queues.
        ReportRemoteJobStatus(user, remote_projroot);
        
        % copy remote CML output folder to local
        RetrieveRemoteJobs(user, remote_cmlroot);
end

end


% delete internal data files which are no longer needed
function DeleteIntDat( listing,...
    input_queue,...
    running_queue,...
    int_data_dir )

% iterate over jobs in jobout
N = size( listing );
for k = 1:N,
    % get job filename
    job_name = listing(k).name;
    
    [int_df_name] = GetIntDatName( job_name, int_data_dir );
    
    % check if data file exists
    int_df_ex = exist( int_df_name, 'file');
    
    if int_df_ex,
        
        [job_in_dnex job_running_dnex ] = ...
            ChkJInJRun( input_queue, running_queue, job_name);        
        
        % if file does not exist in job in and
        % does not exist in job running
        if job_in_dnex & job_running_dnex
            % delete data file
            delete( int_df_name );
        end
        
    end
end
end


% check if job files exist in jobin and jobrunning
%  for file in jobout
function [job_in_dnex job_running_dnex ] = ...
    ChkJInJRun( input_queue, running_queue, job_name)

% construct path to job running and job out file
job_in_file = [ input_queue filesep job_name ];
job_running_file = [ running_queue filesep job_name ];

% check if files exist
job_in_dnex = ~exist( job_in_file, 'file' );
job_running_dnex = ~exist( job_running_file, 'file' );
end


% Get internal data file name
function [int_df_name] = GetIntDatName( job_name, int_data_dir )

% tokenize job filename
[scenario_name record] = ReadScenarioNameAndRecord( job_name );

% construct path to data file
int_df_name = ...
    [ int_data_dir filesep scenario_name '_' int2str(record) '_' 'Data.mat'];
end


% print status of user's cluster jobs
function ReportRemoteJobStatus( user, remote_projroot )

fprintf('Running Jobs:\n');
PrintMatFilesInProjDir(user, remote_projroot, 'JobRunning');

fprintf('\n');

fprintf('Completed Jobs:\n');
PrintMatFilesInProjDir(user, remote_projroot, 'JobOut');

fprintf('\n');
end


% print a list of .mat files in a remote project directory
function PrintMatFilesInProjDir(user, remote_projroot, remote_projdir)
c1 = ['ssh' ' ' user '@wcrlcluster.csee.wvu.edu '];

% get listing of mat files in user's cluster JobRunning/
c2 = ['ls ' remote_projroot '/' remote_projdir '/' ' | grep -i .mat'];
cmd = [c1 c2];
[dc running_jobs] = system(cmd);
fprintf(running_jobs);
end


% retrieve CML output files for completed cluster jobs
function RetrieveRemoteJobs( user, remote_cmlroot )
ExecRemoteCmlClusterRetrieve(user, remote_cmlroot);
RetrieveRemoteOutput(user, remote_cmlroot);
end


% execute CmlClusterRetrieve remotely
function ExecRemoteCmlClusterRetrieve(user, remote_cmlroot)
c1 = ['ssh' ' ' user '@wcrlcluster.csee.wvu.edu '];
c2 = ['matlab -r' ' '];
c3 = ['"cd\(\'''];
c4 = [remote_cmlroot];
c5 = ['\''\)'];
c6 = ['\;CmlStartup\;'];
c7 = ['CmlClusterRetrieve'];
c8 = ['\;'];
c9 = ['exit" > /dev/null'];

cmd = [c1 c2 c3 c4 c5 c6 c7 c8 c9];
system(cmd);
end


% copy remote CML output directory to local
function RetrieveRemoteOutput(user, remote_cmlroot)

cml_home = CmlLoadCmlHome('local');
% copy remote output to local output
fprintf('Consuming remote CML output.\n');
cmd1 = ['scp -r ' user '@wcrlcluster.csee.wvu.edu:'];
cmd2 = [remote_cmlroot '/output/*' ' ' ];
cmd3 = [ cml_home '/output > /dev/null'];
cmd = [cmd1 cmd2 cmd3];

system(cmd);
end


% copy intermediate results from JobRunning to CML output
function ConsumeRunningQueue( running_queue, listing )
N = size( listing );
for k = 1:N,
    [scenario_name record] = ReadScenarioNameAndRecord( listing(k).name );
    full_path_to_output_file = [ running_queue '/' listing(k).name ];
    CopyJobOutToCmlOut( full_path_to_output_file, scenario_name, record);
end
end


% convert job running file file to cml output file, copy to cml out, and leave
% running file in place
function  CopyJobOutToCmlOut( full_path_to_job_output_file, scenario_name, record )

load( full_path_to_job_output_file );
save_param = JobParam;
save_state = JobState;

save_param = SetSimLocationLocal( save_param );

eval( scenario_name );


sim_param(record).filename
save( [cml_home sim_param(record).filename], 'save_param', 'save_state');

end

%     This library is free software;
%     you can redistribute it and/or modify it under the terms of
%     the GNU Lesser General Public License as published by the
%     Free Software Foundation; either version 2.1 of the License,
%     or (at your option) any later version.
%
%     This library is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%     Lesser General Public License for more details.
%
%     You should have received a copy of the GNU Lesser General Public
%     License along with this library; if not, write to the Free Software
%     Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
