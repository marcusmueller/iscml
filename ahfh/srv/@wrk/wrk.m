% wrk.m
%
% Implementation of the cluster worker object,
%
% Version 2
% 9/18/2011
% Terry Ferrett

classdef wrk < handle
    
    properties
        hostname    % node which runs worker
        pid         % process id on node
        wrkCnt      % worker count in wc object
        ws          % worker script
	stac        % command string to start worker
        stoc        % command string to stop worker
    end
    
    methods
        function obj = wrk(hostname, wrkCnt, ws, stac)
            obj.hostname = hostname;
             obj.wrkCnt = wrkCnt;
	    obj.ws = ws;
	    obj.stac = stac;
        end
    end
    
end
