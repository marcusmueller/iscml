% util.m
%
% Utility class for CML.
%
% Functionality
%  1. General-purpose file parser, fp()
%
% Version 1, 02/27/2011, Terry Ferrett
% Version 2, 08/01/2012, Mohammad Fanaei
%
%     Copyright (C) 2012, Terry Ferrett and Matthew C. Valenti
%     For full copyright information see the bottom of this file.



classdef util < handle
    
    methods(Static)
        % fp() - File Parser
        function out = fp(filename, heading, key)
            %Method Steps
            %1. Open file.
            %2. Seek to 'heading'.
            %3. for all fields denoted by 'key,
            %      Read value into 'out' array.
            
            fid = fopen(filename);
            
            str_in = fgetl(fid);
            empty_file = isnumeric(str_in);
            
            % Scan for heading.
            while(empty_file == false)
                switch str_in
                    case heading
                        break;
                    otherwise
                        str_in = fgetl(fid);
                        empty_file = isnumeric(str_in);
                end
            end
            
            str_in = fgetl(fid);
            empty_file = isnumeric(str_in);
            
            
            % Scan for key values.
            k = 1;
            while(empty_file == false)
                if( ~isempty(str_in) && str_in(1) ~= '%' )
                    [l_key l_val] = strtok(str_in, '=');
                    % Remove whitespace
                    l_key = strtok(l_key);
                    
                    % Remove equal sign
                    l_val = l_val(2:end);
                    
                   
                    switch l_key
                        case key
                            temp_cell = textscan(l_val, '%s');
                            out{k} = temp_cell{1};
                            k = k+1;
                        otherwise
                            if( length(l_key ) ~= 0 )
                                if( l_key(1) == '[' )
                                    break;
                                end
                            end
                    end
                end
                str_in = fgetl(fid);
                empty_file = isnumeric(str_in);
                
            end
            fclose(fid);
            % If no matching keys were found, assign out to null.
            out_flag = strcmp('out',who('out'));
            if  isempty(out_flag),
                out = {};
            end
        end
        
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
