% main.m
%
% main task controller loop
%
% Version 4
% 5/2014
% Terry Ferrett
%
% outline
% 1. scan user input directories for input files
% 2. decide which user to service
% 3. launch tasks for the user with the least active tasks
%
%     Copyright (C) 2012, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.
%
%  POTENTIAL CAVEAT
%   Added '&' to end of all system() commands in an attempt to
%       prevent hanging.
%  Keep an eye on this one, for example, spawing zombies or leaking memory.
%   Added pause at end of every system command for flow control.
% next attempt - copy operation needs more delay than move
% future impl
%  only use moves
%  group permissions


function main(obj, ss)

%%% main-specific initialization
nu = length(obj.users);      % number of users

% task controller running states
IS_START = strcmp(ss, 'start');
IS_RESUME = strcmp(ss, 'resume');
IS_SHUTDOWN = strcmp(ss, 'shutdown');

% timers
timer_users = tic;       % user list update timer
timer_heartbeat = tic;   % heartbeat timer
heartbeat_oneshot=1;     % touch the heartbeat file


% primary execution loop
while(1)
    
    % perform these actions while task controller is running
    %  or resuming
    if IS_START || IS_RESUME
        
        % scan user input directories for new .mat inputs
        [au fl] = scan_user_inputs(obj);
        
        % decide which user to service
        [users_srt fl_srt] = schedule(obj, au, fl);
        
        % move input files to cluster input queue
        place_user_input_in_queue(obj, users_srt, fl_srt);
        
        % scan the global running queue and countactive workers for each user
        calculate_active_workers(obj);
        
    end
    
    
    % scan global output queue and place completed tasks in user output
    %  directory
    if IS_START || IS_RESUME || IS_SHUTDOWN
        consume_output(obj);
    end
    
    % Pause for tsp seconds before making anothe pass
    pause(obj.tsp);
    
    % get files in global queues
    pgoq = obj.gq.oq{1};
    srch = strcat(pgoq, '/*.mat');      % form full dir string
    fl = dir( srch );    % get list of .mat files in output queue
    nfoq = length(fl);
    
    pgrq = obj.gq.rq{1};
    srch = strcat(pgrq, '/*.mat');      % form full dir string
    fl = dir( srch );    % get list of .mat files in running queue
    nfrq = length(fl);
    
    Q_EMPTY = (nfoq == 0)&&(nfrq == 0);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % if no files are left in the output queue and the tc is in shutdown mode,
    %  break out of main control loop
    if IS_SHUTDOWN && Q_EMPTY
        break;
    end
    
    
    % check for new users every 2 minutes
    if toc(timer_users) > 120,
        obj.init_users();
        timer_users = tic;
    end
    
    
    % touch heartbeat file to indicate that TC has not crashed
    c1 = heartbeat_oneshot;
    c2 = toc(timer_heartbeat) > obj.hb_period;
    if c1 | c2,
        heartbeat(obj);
        timer_heartbeat = tic;
        heartbeat_oneshot = 0;
    end
    
end

end


% touch heartbeat file indicate that TC has not crashed
function heartbeat(obj)

% path to heartbeat file
hb_file = [ obj.hb_path filesep 'tc_' obj.gq_name ];

% touch implemented as file opening and closing
fid = fopen(hb_file, 'w+'); fclose(fid);

end


% scan all user task input directories for task files
function [au fl] = scan_user_inputs(obj)

nu = length(obj.users);           % number of users in system

na = 0;                           % users having input files

au ={};                           % active user list

fl = {};                          % file list

fprintf('1 ');

% iterate over all users
for k = 1:nu,
    
    % full search string for input files
    srch = strcat(obj.users{k}.iq, '/*.mat');
    
    % list of task files for this user
    sfl{k} = dir( srch{1} );
    
    if length( sfl{k} ) > 0,
        
        na = na + 1;
        
        au{na} = obj.users{k};
        
        % number of files in user input directory
        nf(na) = length(sfl{k});
        
        % file list for this user
        fl{na} = sfl{k};
        
    end
    
    
end
fprintf('2 ');
end


% sort the users by number of active workers possessed by each
function [users_srt fl_srt] = schedule(obj, au, fl)

ntu = length(obj.users);    % total number of users

nau = length(au);           % number of users having input files (active users)

nw = [];                    % number of workers occupied by active users

users_srt = {};             % users sorted by number of active users

fl_srt = {};                % sorted list

fprintf('3 ');

for k =1:nau,
    
    for l = 1:ntu,
        
        USER_MATCH = strcmp(au{k}.username, obj.users{l}.username);
        LOCATION_MATCH = strcmp(au{k}.user_location, obj.users{l}.user_location);
        
        if USER_MATCH & LOCATION_MATCH,
            
            nw(k) = obj.users{k}.aw;      % number of workers for this user
            
        end
        
    end
    
end
fprintf('4 ');

if ~isempty(nw)
    
    [l P] = sort(nw);
    
    users_srt = au{P};
    
    fl_srt = fl(P);
end

fprintf('5 ');

end


% moving user input into input queue en mass
function place_user_input_in_queue(obj, users_srt, fl_srt)

PCSUSER = 'pcs';

fprintf('6 ');

if ~isempty(users_srt)
    
    
    % mfiq - Max Files Input Queue - maximum number of files available
    %        in input queue.
    avw = obj.mfiq - obj.aw;
    %avw = obj.nw - obj.aw;   % available number of workers
    
    nf = length( fl_srt{1} );
    cnt = 0;
    fprintf('7 ');
    while avw > 0 & nf > 0,   % add files to queue until the queue is full or no more files exist
        
        avw = avw - 1;
        nf = nf - 1;
        cnt = cnt + 1;
        
        
        puif = strcat(users_srt.iq, '/', fl_srt{1}(cnt).name);  % path to input file
        purf = strcat(users_srt.rq, '/', fl_srt{1}(cnt).name);  % path to running file
        
        pgiq = obj.gq.iq;    % path to global input queue
        purq = users_srt.rq; % path to user running queue
        
        
        % append username to file
        fn = fl_srt{1}(cnt).name;
        afn = [users_srt.username '_' users_srt.user_location '_' fn];
        
        
        % copy user input file into user running queue
        %        cmd_str = ['sudo cp' ' ' puif{1} ' ' purq{1} '/' fn ' ' '&'];
        cmd_str = ['sudo cp' ' ' puif{1} ' ' purf{1} ' ' '&'];
        fprintf('%s\n', cmd_str);
        [st res] = system(cmd_str);
        fprintf('\n');
        pause(0.05);
        
        
        % change user running queue file ownership from root to user
        cmd_str = ['sudo chown' ' ' users_srt.username ':' users_srt.username ' ' purf{1} ' ' '&'];
        fprintf('%s\n', cmd_str);
        [st res] = system(cmd_str);
        fprintf('\n');
        pause(0.05);
        
        % change user input file ownership to pcs user
        cmd_str = ['sudo chown' ' ' PCSUSER ':' PCSUSER ' ' puif{1} ' ' '&'];
        fprintf('%s\n', cmd_str);
        [st res] = system(cmd_str);   % change ownership back to user
        fprintf('\n');
        pause(0.05);
        
        
        % move user file into input queue
        cmd_str = ['sudo mv -f' ' ' puif{1} ' ' pgiq{1} '/' afn ' ' '&'];
        fprintf('%s\n', cmd_str);
        [st res] = system(cmd_str);
        fprintf('\n');
        pause(0.05);
        
        fprintf('avw %d\n', avw);
        fprintf('nf %d\n', nf);
        
    end
    
    obj.aw = obj.aw + cnt;
    
end

end



function update_user_active_status(obj, users_srt, fl_srt) % move input file to user's active directory


if ~isempty(users_srt)
    
    puiq = users_srt.iq{1};
    
    purq =  users_srt.rq{1};
    
    nf = length( fl_srt{1} );
    
    for k = 1:nf,
        
        af = strcat(fl_srt{1}(k).name);
        
        cmd_str = ['sudo mv -f' ' ' puiq '/' af ' ' purq '/' af ' ' '&'];
        
        [st res] = system(cmd_str);
        fprintf('\n');
        pause(0.05);
        
    end
    
end

end


function calculate_active_workers(obj) % scan the global running queue and count the active workers for each user

%%% 3/13/2013 - changing implementation to only count files in input queue
%%% variable names should eventually be changed to be more meaningful,
%%% for example, "obj.aw" denoting number of active workers should be
%%%% changed to something like "obj.nfiq" denoting number of files in iq

%%%%%%%% get list of files in running and input queues %%%
%%% read the files in the global running queue%%%
%srch = strcat(obj.gq.rq{1}, '/*.mat');
%rqf = dir( srch );

%%% read the files in the global input queue
srch = strcat(obj.gq.iq{1}, '/*.mat');
iqf = dir( srch );

%%% concatenate the two file lists
%bqf = struct_cat(rqf,iqf);  % file list concatenated from both queues
bqf = iqf;

%%% calculate the resulting length
nf = length(bqf);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%% read files in global running queue %%%
%srch = strcat(obj.gq.rq{1}, '/*.mat');
%nf = length(fl);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


fprintf('8 ');
nu = length(obj.users);                % loop over all users

for k = 1:nu,
    
    nw = 0;                            % set the number of workers to 0
    
    %name = obj.users{k}.username;      % shorter notation for this user
    name = [obj.users{k}.username '_' obj.users{k}.user_location];      % shorter notation for this user, include location
    
    
    
    for m = 1:nf,                      % loop over all files and determine the user
        
        isuser = findstr(bqf(m).name, name);  % find the username embedded in the filename and compare
        
        if isempty(isuser),
        elseif isuser == 1,            % pattern matches. add user.
            nw = nw + 1;
        end
        
    end
    
    obj.users{k}.aw = nw;  % update active user count
    
end
fprintf('9 ');


nw = 0;         % add up all active workers for all users
for k = 1:nu,
    nw = nw + obj.users{k}.aw;
end


obj.aw = nw;    %  update the global count of active users
% this is the number of files in the input queue
end



function consume_output(obj)

[fl nf] = get_files_in_output_queue(obj);

fprintf('10 ');
for k = 1:nf,       % loop over all files in output queue
    
    [username location] = get_username_location_from_file( fl(k).name );
    fprintf('11 ');
    [does_user_exist user_ind] = compare_to_active_users( obj, username, location, obj.users );
    fprintf('12 ');
    switch does_user_exist,
        case 'yes',
            consume_output_file(obj, fl(k).name, user_ind);
            fprintf('13 ');
        case 'no'
            delete_output_file( obj, fl(k).name );
            fprintf('14 ');
    end
    
end

end


% Get username and location from task filename.
function [username location] = get_username_location_from_file( name );

[username suffix] = strtok(name, '_');

[location suffix] = strtok(suffix, '_');

end


% Does the user named in the filename exist?
function [does_user_exist user_ind] = compare_to_active_users( obj, username, location, users )
nu = get_number_users( obj.users );

does_user_exist = 'no';
user_ind = -1;

for k = 1:nu,
    cur_user = users{k}.username;
    cur_location = users{k}.user_location;
    
    user_match = strcmp( cur_user, username );
    loc_match = strcmp( cur_location, location );
    
    if user_match&loc_match,
        does_user_exist = 'yes';
        user_ind = k;
    end
    
end

end


function consume_output_file(obj, output_task_filename, user_ind)

fprintf('15 ');
[ownership_name ownership_group] = get_file_ownership( obj.users{user_ind}.username, obj.users{user_ind}.user_location );

[on] = remove_username_loc_from_filename( output_task_filename );

[ puoq ] = get_path_user_output_queue( obj.users{user_ind}.oq{1});

[ pgoq ] = get_path_global_output_queue( obj.gq.oq{1} );

cmd_str = ['sudo chown' ' ' ownership_name ':' ownership_group ' ' pgoq '/' output_task_filename ' ' '&'];
fprintf('%s\n', cmd_str);
[st res] = system(cmd_str);   % change ownership back to user
fprintf('\n');
%        fprintf('%d\n', st);
%        fprintf('%s\n', res);
pause(0.05);


cmd_str = ['sudo mv -f' ' ' pgoq '/'  output_task_filename ' ' puoq '/' on ' ' '&'];
fprintf('%s\n', cmd_str);
[st res] = system(cmd_str); % move file to user output queue
fprintf('\n');
pause(0.05);

[ purq ] = get_path_user_running_queue( obj.users{user_ind}.rq{1} );

clear_from_user_running_queue( on, purq );
fprintf('16 ');

end



% move completed tasks in global output queue to user output queue
function consume_output_file_new(obj, output_task_filename, user_ind)

fprintf('15 ');

[ownership_name ownership_group] = get_file_ownership( obj.users{user_ind}.username, obj.users{user_ind}.user_location );

[on] = remove_username_loc_from_filename( output_task_filename );

[ puoq ] = get_path_user_output_queue( obj.users{user_ind}.oq{1});

[ pgoq ] = get_path_global_output_queue( obj.gq.oq{1} );


% don't change ownership implementation
cmd_str = ['sudo chown' ' ' ownership_name ':' ownership_group ' ' pgoq '/' output_task_filename ' ' '&'];
[st res] = system(cmd_str);   % change ownership back to user
fprintf('\n');
pause(0.05);

% change move implementation

fprintf('chown 2 ');
cmd_str = ['sudo mv -f' ' ' pgoq '/'  output_task_filename ' ' puoq '/' on ' ' '&'];
fprintf('%s\n', cmd_str);
[st res] = system(cmd_str); % move file to user output queue
fprintf('\n');
pause(0.05);

fprintf('mv 2 ');
[ purq ] = get_path_user_running_queue( obj.users{user_ind}.rq{1} );

clear_from_user_running_queue( on, purq );
fprintf('16 ');

end




function delete_output_file( obj, output_task_filename )

[ pgoq ] = get_path_global_output_queue( obj.gq.oq{1} );

cmd_str = ['sudo rm' ' ' pgoq '/'  output_task_filename ' ' '&'];
[st res] = system(cmd_str); % delete file from output queue
fprintf('\n');
pause(0.05);

end




function [fl nf] = get_files_in_output_queue(obj)
%%% get files in output queue %%%
pgoq = obj.gq.oq{1};
srch = strcat(pgoq, '/*.mat');      % form full dir string
fl = dir( srch );    % get list of .mat files in output queue
nf = length(fl);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


function nu = get_number_users( users )
nu = length(users);
end


%%% this code is deprecated, only one location exists. web users directory is gone
function [ownership_name ownership_group] = get_file_ownership( username, user_location )
if( strcmp( user_location, 'web') )
    ownership_name = 'tomcat55';
    ownership_group = 'tomcatusers';
elseif( strcmp( user_location, 'local') )
    ownership_name = username;           % shorten the name
    ownership_group = username;
end
end


function [on] = remove_username_loc_from_filename( name )
[username suffix] = strtok(name, '_');
[location suffix] = strtok(suffix, '_');

on = suffix(2:end);
end


function puoq = get_path_user_output_queue( oq )
puoq = oq;
end


function purq = get_path_user_running_queue( oq )
purq = oq;
end

function [ pgoq ] = get_path_global_output_queue( oq )
pgoq = oq;
end


function clear_from_user_running_queue( on, purq )

if findstr( on, 'failed')
    prefix = on(1:end-11);
    suffix = '.mat';
    on = [prefix suffix];
end
cmd_str = ['sudo rm' ' ' purq '/'  on ' ' '&'];
fprintf('%s\n', cmd_str);
[st res] = system(cmd_str); % remove file from user running queue
fprintf('\n');
pause(0.05);

end





% concatenate two structs having identical fields
function bqf = struct_cat(rqf,iqf)

% get the length of both structs
l1 = length(rqf);
l2 = length(iqf);

% concatenate the structs
bqf = rqf;

for k = 1:l2,
    bqf(l1+k) = iqf(k);
end



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