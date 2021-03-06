% CWC   Create Cluster Worker Controller Object
%
%
%   The calling syntax is:
%     cwc_obj = cwc(srv_root, proj_root, cf)
%
%   Inputs:
%      srv_root = Cluster worker controller root directory.
%      proj_root = Project root directory.     
%      cf = Configuration file specifying
%             - List of cluster nodes and maximum workers per node.
%             - Input and output paths for worker data.
%
%   Outputs:
%      cwc_obj = Cluster Worker Controller Object
%
%   Example:
%      [cwc_obj] = cwc( srv_root, ahfh_root, 'eight_core.cfg' );
%
%          where srv_root is a workspace variable containing the
%            path to the cluster worker controller scripts,
%            and proj_root is the path to the ahfh project
% cwc.m
%
% Implementation of the cluster worker controller.
%
% Version 2
% 10/6/2011
% Terry Ferrett

classdef cwc < wc
    
    % Cluster state.
    properties
        wrkCnt
        nodes
        %maxWorkers
        workers
        workerScript
    end
    
    % Cluster controller paths.
    properties
        bashScriptPath
        cfp
        cmlRoot
	srv_root
	proj_root	
        workerPath
        
        svPath
        svFile
    end
    
    % Worker paths.
    properties
        inPath
        outPath
    end
    
    
    methods
        function obj = cwc(srv_root, proj_root, cfpIn)
            % 1. Read configuration file name.
            obj.cfp = strcat(proj_root, '/cfg/', cfpIn);
	    
            
            % 2. Read worker input path from configuration file.
            heading = '[Paths]';
            key = 'InputPath';
            out = util.fp(obj.cfp, heading, key);
            obj.inPath = out{1}{1};
            
                        
            
            % 5. cluster server root path and path to BASH scripts.
            obj.srv_root = srv_root;
            obj.bashScriptPath = srv_root;
	    obj.proj_root = proj_root;
	    obj.cmlRoot = proj_root;            

            % 6. State file and path.
            svPath = [proj_root '/state'];
            obj.svPath = svPath;
            obj.svFile = 'cwc_state.mat';
            
            
            % 7.Change the home directory to /rhome - the
            %   mount point for home directories on the cluster nodes.
            [ignore pathTemp] = strtok(proj_root, '/');
            obj.workerPath = ['/rhome' pathTemp '/wrk'];
            
            % 8. Initialize the worker ID counter to 0.
            obj.wrkCnt = 0;
            
            % 9. Initialize the worker array.
            obj.workers = wrk.empty(1,0);
            
            
            % Read the worker configuration from the configuration file.
            heading = '[Workers]';
            key = 'worker';
            out = util.fp(obj.cfp, heading, key);
            n = length(out);
            % create a worker object for every worker specified in the config file.
            
            for k = 1:n,
                cw(obj,out{k});
            end
            
            % Form a list of active nodes from the worker objects.
            l = 1;
            obj.nodes{1} = '';
            for k = 1:n,
                curwrk = out{k};
                
                % if the node already exists in the list, don't add it.
                add = 1;
                for m = 1:length(obj.nodes),
                    if strcmp( obj.nodes(m), curwrk{2} ),
                        add = 0;
                    end
                end
                
                if add == 1,
                    obj.nodes{l} = curwrk{2};
                    l = l + 1;
                end
            end
            
            
        end
    end
    
    
    
    methods
        % create worker objects from configuration file data
        cw(obj, cfd)
        % Start single worker.
        staw(obj, worker)
        % Start workers on entire cluster.
        cSta(obj, varargin)
        
        % Stop single worker.
        stow(obj, worker)
        % Stop workers on entire cluster.
        cSto(obj, varargin)
        % delete worker object
        dw(obj, worker)
        % return the number of workers running worker script 'ws'
        [NumberWorkers nodes] = cstat(obj, ws)
        % Unconditionally stop all workers running under this username.
        slay(obj)
        % Save the cluster state.
        svSt(obj)
    end
end

