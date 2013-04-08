function [sim_param_out, sim_state] = SingleRead( sim_param_in )
% CodedRead reads a single coded simulation from a file.
%
% The calling syntax is:
%     [sim_param, sim_state] = SingleRead( sim_param )
%
%     Required inputs/outputs:
%     sim_param = A structure containing simulation parameters.
%
%     Required output
%     sim_state = A structure containing the simulation state.
%
%     Note: See readme.txt for a description of the structure formats.
%
%     Copyright (C) 2005-2007, Matthew C. Valenti
%
%     Last updated on Oct. 12, 2007
%
%     Function SingleRead is part of the Iterative Solutions Coded Modulation
%     Library (ISCML).
%
%     The Iterative Solutions Coded Modulation Library is free software;
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


epsilon = 1e-5; % the minimum SNR spacing

[spc spu sim_state_prototype] = DefineStructures;
sim_param_out = struct;
sim_state = struct;

[spcf spuf sim_state_fieldnames] = get_field_names( spc, spu, sim_state_prototype );

number_new_SNR_points = get_number_input_snr_points(sim_param_in);
if number_new_SNR_points == 0
    clear number_new_SNR_points
end

check_for_consistent_snr_trial_vector_lengths(sim_param_in);

sim_param_out = update_changeable_parameters( sim_param_in, spcf, spc, sim_param_out );

cml_home = CmlLoadCmlHome( 'local' );  % verify logic 12/14/2012

sim_param_out.filename = modify_filename_relative_absolute(sim_param_in.filename, cml_home);

fid = fopen( [cml_home sim_param_out.filename], 'r');


if ( (fid > 0)&( sim_param_out.reset < 1 ) )
    load_struct.fid = fid;
    load_struct.sim_param_out = sim_param_out;
    load_struct.cml_home = cml_home;
    load_struct.spuf = spuf;
    load_struct.spu = spu;
    load_struct.sim_param_in = sim_param_in;
    [ save_param save_state sim_param_out ] = load_previous_simulation_state( load_struct );
else
    setup_struct.spuf = spuf;
    setup_struct.spu = spu;
    setup_struct.sim_param_in = sim_param_in;
    setup_struct.sim_param_out = sim_param_out;
    sim_param_out = setup_unchangeable_sim_param( setup_struct );
end


sim_state = sim_state_prototype;
switch sim_param_in.sim_type,
    case 'capacity',
        sim_state = init_capacity( sim_param_out, number_new_SNR_points);
    case 'exit',
        sim_state = init_exit(sim_param_in, sim_param_out, number_new_SNR_points);
    case 'uncoded',
        sim_state = init_uncoded(sim_param_in, sim_param_out, number_new_SNR_points, sim_state);
    case 'coded',
        sim_state = init_coded( sim_param_out, number_new_SNR_points, sim_state );
    case 'bloutage',
        sim_state = init_bloutage( sim_param_out, number_new_SNR_pints, sim_state );
    case 'outage',
        sim_state = init_outage( number_new_SNR_points, sim_state );
    case 'throughput',
        if ( (fid > 0)&( sim_param_out.reset < 1 ) )
            sim_param_out.SNR = save_param.SNR;
        end
        
    case 'bwcapacity',
        if ( (fid > 0)&( sim_param_out.reset < 1 ) )
            sim_param_out.h = save_param.h;
        end
    case 'minSNRvsB',
        if ( (fid > 0)&( sim_param_out.reset < 1 ) )
            sim_param_out.h = save_param.h;
            sim_param_out.bwconstraint = save_param.bwconstraint;
        end
        
    otherwise,
        error( 'simulation type not supported\n' );
end

% restore the saved sim_state
if ( (fid > 0)&( sim_param_out.reset < 1 ) )
    
    restore_struct.sim_param_in = sim_param_in;
    restore_struct.sim_param_out = sim_param_out;
    restore_struct.save_param = save_param;
    restore_struct.sim_state_fieldnames = sim_state_fieldnames;
    restore_struct.save_state = save_state;
    restore_struct.sim_state = sim_state;
    if exist('number_new_SNR_points', 'var')
        restore_struct.number_new_SNR_points = number_new_SNR_points;
    end
    restore_struct.epsilon = epsilon;
    sim_state = restore_saved_state( restore_struct );
    
    
    
end

if (fid>0)
    fclose( fid );
end

return;
end



function [spcf spuc ssf] = get_field_names( spc, spu, sim_state_prototype )
spcf = fieldnames( spc );
spuc = fieldnames( spu );
ssf = fieldnames( sim_state_prototype );
end



function number_new_SNR_points = get_number_input_snr_points(sim_param_in)
if isfield( sim_param_in, 'SNR' )
    number_new_SNR_points = length( sim_param_in.SNR );
else
    number_new_SNR_points = 0;
end
end



function check_for_consistent_snr_trial_vector_lengths(sim_param_in)
if isfield( sim_param_in, 'max_trials' )
    if ( length( sim_param_in.max_trials ) ~= length( sim_param_in.SNR ) )
        error( 'number of trials must match number of SNR points' );
    end
end
end



function sim_param_out = update_changeable_parameters( sim_param_in, spcf, spc, sim_param_out )
% set the changeable parameters to the value in sim_param_in
for i=1:length( spcf )
    if isfield( sim_param_in, spcf{i} )
        fieldvalue = getfield( sim_param_in, spcf{i} );
        sim_param_out = setfield( sim_param_out, spcf{i},  fieldvalue );
    else
        % if not defined, then set to default
        fieldvalue = getfield( spc, spcf{i} ) ;
        sim_param_out = setfield( sim_param_out, spcf{i}, fieldvalue );
    end
end
end



function filenameOut = modify_filename_relative_absolute(filenameIn, cml_home )
% determine if sim_param_in.filename is relative or absolute
if ( length( filenameIn ) >= length( cml_home ) )
    temp_string = filenameIn(1:length(cml_home));
    if strcmp( temp_string, cml_home )
        % this is an absolute path. strip out cml home
        filenameOut = filenameIn( length(cml_home)+1: length( filenameIn ) );
    else
        filenameOut = filenameIn;
    end
else
    filenameOut = filenameIn;
end
end



function [ save_param save_state sim_param_out ] = load_previous_simulation_state( load_struct )

fid = load_struct.fid;
sim_param_out = load_struct.sim_param_out;
cml_home = load_struct.cml_home;
spuf = load_struct.spuf;
spu = load_struct.spu;
sim_param_in = load_struct.sim_param_in;


% load the saved file
load( [cml_home sim_param_out.filename], '-mat' );

check_struct.spuf = spuf;
check_struct.spu = spu;
check_struct.save_param = save_param;
check_struct.sim_param_in = sim_param_in;
check_struct.sim_param_out = sim_param_out;

sim_param_out = check_unchangeable_fieldnames( check_struct );

end



function sim_param_out = check_unchangeable_fieldnames( check_struct )

spuf = check_struct.spuf;
spu = check_struct.spu;
save_param = check_struct.save_param;
sim_param_in = check_struct.sim_param_in;
sim_param_out = check_struct.sim_param_out;

for i=1:length( spuf )
    
    if strcmp( spuf{i}, 'exit_param') & strcmp(save_param.sim_type, 'exit'),
        % handle exit_param as a special case
        % assume all params defined
        % error if params do not match
        if isfield( save_param, 'exit_param' )
            if isfield( sim_param_in, 'exit_param')
                if save_param.exit_param.rate ~= sim_param_in.exit_param.rate,
                    error('saved exit_param.rate does not match scenario file');
                end
                if ~isequal(save_param.exit_param.requested_IA, sim_param_in.exit_param.requested_IA),
                    error('saved exit_param.requested_IA does not match scenario file');
                end
                switch save_param.exit_param.exit_phase,
                    case 'detector',
                    case 'decoder',
                        if save_param.exit_param.dv ~= sim_param_in.exit_param.dv,
                            error('saved exit_param.dv does not match scenario file');
                        end
                        if save_param.exit_param.dc ~= sim_param_in.exit_param.dc,
                            error('saved exit_param.dc does not match scenario file');
                        end
                        if ~strcmp(save_param.exit_param.exit_type, sim_param_in.exit_param.exit_type),
                            error('saved exit_param.exit_type does not match scenario file');
                        end
                end
                sim_param_out = setfield( sim_param_out, spuf{i}, getfield( save_param, spuf{i} ) );
            else
                error
            end
        end
        
        
        
    elseif strcmp( spuf{i}, 'twrc_param') & isfield(save_param, 'twrc_param' ),
        sim_param_out = setfield( sim_param_out, spuf{i}, getfield( save_param, spuf{i} ) );
    elseif strcmp( spuf{i}, 'ldpc_param') & isfield(save_param, 'ldpc_param' ),
        sim_param_out = setfield( sim_param_out, spuf{i}, getfield( save_param, spuf{i} ) );
    else
        if isfield( save_param, spuf{i} )
            if isfield( sim_param_in, spuf{i} )
                match = test_if_stored_value_matches_scenario_file( save_param, spuf, sim_param_in, i);
                set_default_if_no_match( match, sim_param_in, save_param, spuf, spu, i );
            else
                % fprintf( ['Warning: field ' spuf{i} ' not defined in the scenario file, using stored value\n' ] );
            end
            % set the value to the saved value
            sim_param_out = setfield( sim_param_out, spuf{i}, getfield( save_param, spuf{i} ) );
        else
            % Set to default value when a new value is defined
            sim_param_out = setfield( sim_param_out, spuf{i}, getfield( spu, spuf{i} ) );
        end
        
    end
    
end

end



function match = test_if_stored_value_matches_scenario_file( save_param, spuf, sim_param_in, i)

cur_svp_field = getfield( save_param, spuf{i} );
n_svp = length(cur_svp_field);

cur_simp_field = getfield( sim_param_in, spuf{i} );
n_simp = length(cur_simp_field);

test_length = abs( n_svp - n_simp );

match = 1;
if test_length == 0,
    match = sum( abs( cur_svp_field ) - abs( cur_simp_field ) );
end

end



function set_default_if_no_match( match, sim_param_in, save_param, spuf, spu, i )
if match
    if ~length( getfield( sim_param_in, spuf{i} ) )
        %fprintf( ['Warning: Field "' spuf{i} '" undefined in the scenario file, using default value\n' ] );
        save_param = setfield( save_param, spuf{i}, getfield( spu, spuf{i} ) );
    elseif ~length( getfield( save_param, spuf{i} ) )
        %fprintf( ['Warning: stored value of field ' spuf{i} ' is set to [], using default value\n' ] );
        save_param = setfield( save_param, spuf{i}, getfield( spu, spuf{i} ) );
    else
        fprintf( ['Warning: field ' spuf{i} ' does not match stored value, using stored value\n' ] );
    end
end
end



function sim_param_out = setup_unchangeable_sim_param( setup_struct )

spuf = setup_struct.spuf;
spu = setup_struct.spu;
sim_param_in = setup_struct.sim_param_in;
sim_param_out = setup_struct.sim_param_out;

for i=1:length( spuf )
    % fprintf( ['\nValidating ' spuf{i} '\n' ] );
    % initialize to default value (Corrected on 9-8-07)
    sim_param_out = setfield( sim_param_out, spuf{i}, getfield( spu, spuf{i} ) );
    
    if isfield( sim_param_in, spuf{i} )
        if ( length( getfield( sim_param_in, spuf{i} ) ) )
            % value is in the scenario file, so use it
            sim_param_out = setfield( sim_param_out, spuf{i}, getfield( sim_param_in, spuf{i} ) );
        end
    end
end
end



function sim_state = init_capacity( sim_param_out, number_new_SNR_points)
% capacity simulation
sim_state.trials = zeros( sim_param_out.max_iterations, number_new_SNR_points );
sim_state.capacity_sum = zeros( 1, number_new_SNR_points );
sim_state.capacity_avg = sim_state.trials;
end



function sim_state = init_exit(sim_param_in, sim_param_out, number_new_SNR_points)

switch sim_param_in.exit_param.exit_type,
    case 'ldpc',
        
        error_check_ldpc_exit( sim_param_in );
        
        switch sim_param_in.exit_param.exit_phase,
            case {'decoder'},
                sim_state = init_exit_state_metrics( sim_param_in, number_new_SNR_points );
                [ sim_param_det sim_state_det ] = CmlPlot( sim_param_in.exit_param.det_scenario,...
                    sim_param_in.exit_param.det_record );
                
                sim_state.exit_state.IA_det_sum = sim_state_det.exit_state.IA_det_sum;
                sim_state.exit_state.IE_det_sum = sim_state_det.exit_state.IE_det_sum;
                sim_state.exit_state.I_A_det = sim_state_det.exit_state.I_A_det;
                sim_state.exit_state.I_E_det = sim_state_det.exit_state.I_E_det;
                sim_state.trials = sim_state_det.trials;
                sim_state.exit_state.dec_complete = 0;
                
            case {'detector'},
                sim_state = init_exit_state_metrics( sim_param_in, number_new_SNR_points );
        end
    case 'turboproc',
        error('Turbo EXIT is still in the oven.');
end
end



function error_check_ldpc_exit( sim_param_in )

if ~isfield(sim_param_in, 'exit_param')
    error('Parameters for exit analysis not specified.  Please define sim_param.exit_param');
end

ep = sim_param_in.exit_param;  % shorter name for exit_param

if ~isfield(ep, 'exit_type');
    error('Exit type not specified in scenario file. Please define sim_param.exit_param.exit_type.');
end

if ~isfield(ep, 'rate')
    error('Rate not specified in scenario file. Please define sim_param.exit_param.rate.');
end

if ~isfield(ep, 'exit_phase')
    error('EXIT analysis phase not defined. Please define sim_param.exit_param.exit_phase {detector, decoder}.');
end

switch ep.exit_phase,
    case {'detector'}
        
    case {'decoder'}
        if ~isfield(ep, 'dv')
            error('Variable node degree not specified in scenario file. Please define sim_param.exit_param.dv.');
        end
        
        if ~isfield(ep, 'dv_dist')
            error('Variable node degrees not specified in scenario file. Please define sim_param.exit_param.dv_dist.');
        end
        
        if ~isfield(ep, 'dc')
            error('Check node degree not specified in scenario file. Please define sim_param.exit_param.dc.');
        end
        
        if ~isfield(ep, 'requested_IA')
            error('Apriori mutual information not specified in scenario file. Please define sim_param.exit_param.requested_IA.');
        end
        
        if length(ep.dv) ~= length(ep.dv_dist),
            error('Number of specified variable node degrees and number of specified degree distributions must match. length(dv) ~= length(dv_dist).');
        end
        
        check_valid_dv_dist(sim_param_in);
        
        if ~isfield(ep, 'det_scenario')
            error('Detector scenario not specified. Please define sim_param.exit_param.det_scenario');
        end
        
        if ~isfield(ep, 'det_record')
            error('Detector record not specified.  Please define sim_param.exit_param.det_record');
        end
        
        check_for_completed_det_record( ep.det_scenario, ep.det_record );
        
        
    otherwise,
        error('exit_phase must be one of { ''detector'', ''decoder'' }');
        
end
end



function check_valid_dv_dist(sim_param_in)
%given
n = sim_param_in.framesize;
k= n*sim_param_in.exit_param.rate;
dc  = sim_param_in.exit_param.dc;
dv = sim_param_in.exit_param.dv;
dv_dist = sim_param_in.exit_param.dv_dist;

dv_dist_sum = sum(dv_dist);
if abs(1 - dv_dist_sum) > 10^(-3),
    error('vnd degree distribution, sim_param_in.exit_param.dv_dist, must sum to 1.');
end

% compute number of vnd edges
%vnd_edges = sum( n * dv_dist .* dv );
%cnd_edges = (n-k) * dc;

%if vnd_edges ~= cnd_edges,
%    error( 'vnd_dist not consistent with specified codeword length and check node degree.');
%end

end



function sim_state = init_uncoded(sim_param_in, sim_param_out, number_new_SNR_points, sim_state)
% uncoded modulation
sim_state.trials = zeros( sim_param_out.max_iterations, number_new_SNR_points );
sim_state.frame_errors = zeros( 1, number_new_SNR_points );
sim_state.symbol_errors = zeros( 1, number_new_SNR_points );
sim_state.bit_errors = zeros( 1, number_new_SNR_points );
sim_state.BER = sim_state.trials;
sim_state.SER = sim_state.trials;

sim_state.timing_data.trial_samples = 0;
sim_state.timing_data.time_samples = 0;
sim_state.timing_data.elapsed_time = 0;

end



function sim_state = init_coded( sim_param_out, number_new_SNR_points, sim_state )
sim_state.trials = zeros( sim_param_out.max_iterations, number_new_SNR_points );
sim_state.frame_errors = zeros( sim_param_out.max_iterations, number_new_SNR_points );
sim_state.bit_errors = zeros( sim_param_out.max_iterations, number_new_SNR_points );
sim_state.BER = sim_state.trials;
sim_state.FER = sim_state.trials;

sim_state.timing_data.trial_samples = 0;
sim_state.timing_data.time_samples = 0;
sim_state.timing_data.elapsed_time = 0;

end



function sim_state = init_bloutage( sim_param_out, number_new_SNR_pints, sim_state )
% coded modulation
sim_state.trials = zeros( sim_param_out.max_iterations, number_new_SNR_points );
sim_state.frame_errors = zeros( sim_param_out.max_iterations, number_new_SNR_points );
sim_state.FER = sim_state.trials;
end



function sim_state = init_outage( number_new_SNR_points, sim_state )
% outage probability in block fading
sim_state.trials = zeros( 1, number_new_SNR_points );
sim_state.frame_errors = zeros( 1, number_new_SNR_points );
sim_state.FER = sim_state.trials;
end



function sim_state = restore_saved_state( restore_struct )

sim_param_in = restore_struct.sim_param_in;
sim_param_out = restore_struct.sim_param_out;
save_param = restore_struct.save_param;
sim_state_fieldnames = restore_struct.sim_state_fieldnames;
sim_state = restore_struct.sim_state;
save_state = restore_struct.save_state;
if isfield(restore_struct, 'number_new_SNR_points')
    number_new_SNR_points = restore_struct.number_new_SNR_points;
end
epsilon = restore_struct.epsilon;

% determine if the SNR has changed
SNR_has_changed = 0;
if ~exist( 'number_new_SNR_points' )
    SNR_has_changed = 0;
elseif ( length( save_param.SNR ) ~= number_new_SNR_points )
    SNR_has_changed = 1; % a different number of SNR points
elseif max( save_param.SNR ~= sim_param_in.SNR )
    SNR_has_changed = 1; % different SNR points (but same number)
end

% will need to add or delete SNR points to the state
if SNR_has_changed
    fprintf( 'Warning: SNR vector does not matched saved vector\n' );
end

% restore saved state, one structure element at a time
for i=1:length( sim_state_fieldnames )
    
    % process fixed length fields - fields which do not change as function
    %  of number of SNR points
    [action msg] = process_fl_fields(sim_state_fieldnames{i},...
        SNR_has_changed,...
        sim_param_in.sim_type);
    switch action
        case 'endsim'
            error(msg);
        case 'finishiteration'
    end
    
    
    if isfield( save_state, sim_state_fieldnames{i} )
        saved_vector = getfield( save_state, sim_state_fieldnames{i} );
        
        if isstruct(saved_vector)   % assume structures are restored
            sim_state = setfield( sim_state, sim_state_fieldnames{i}, saved_vector );
        else                        % expand or contract double vectors
            
            
            if ( SNR_has_changed & ~isempty( saved_vector ) )
                % fix 6-11-06
                row_count = size( saved_vector, 1 );
                new_vector = zeros( row_count, number_new_SNR_points );
                
                % this logic needs to be verified 8-10-06
                for j=1:number_new_SNR_points
                    index = find( (save_param.SNR  <= sim_param_in.SNR(j) + epsilon)&(save_param.SNR >= sim_param_in.SNR(j)-epsilon) );
                    if (length( index ) > 1)
                        error( 'Duplicate SNR points in saved sim' );
                    elseif (length(index) == 1)
                        new_vector(:,j) = saved_vector(:,index);
                    end
                end
                sim_state = setfield( sim_state, sim_state_fieldnames{i}, new_vector);
            else
                sim_state = setfield( sim_state, sim_state_fieldnames{i}, saved_vector );
            end
            
            
        end
    end
end

% alphabetize fields
sim_param_out = orderfields( sim_param_out );
sim_state = orderfields( sim_state );
end



function sim_state = init_exit_state_metrics( sim_param_in, number_new_SNR_points )
N = length(sim_param_in.exit_param.requested_IA);
sim_state.trials = zeros( 1, number_new_SNR_points );
sim_state.exit_state.IA_det_sum = zeros( N, number_new_SNR_points );
sim_state.exit_state.IE_det_sum = zeros( N, number_new_SNR_points );
sim_state.exit_state.I_A_det = zeros( N, number_new_SNR_points );
sim_state.exit_state.I_E_det = zeros( N, number_new_SNR_points );
sim_state.exit_state.IE_vnd = zeros( N, number_new_SNR_points );
sim_state.exit_state.IE_cnd = zeros( N, number_new_SNR_points );
sim_state.exit_state.IA_cnd = zeros( N, number_new_SNR_points );
end



function check_for_completed_det_record (scenario, record )
[sim_param sim_state] = CmlPlot(scenario, record);

if sim_state.exit_state.det_complete ~= 1,
    error('Please specify a completed detector scenario and record.');
end
end



function [action msg] = process_fl_fields(field, SNR_has_changed, sim_type)
%%%%
% The fields denoted as fixed length either do not change as a function of
% SNR, or changing length as a function of SNR is not yet supported.
% Take appropriate action based on conditions.
%  Terry 1/2013
%%%%

switch field
    
    case 'timing_data'
        action = 'finishiteration';
        msg = '';
        
    case 'exit_state'
        if SNR_has_changed & strcmp(sim_type, 'exit'),
            action = 'endsim';
            msg = 'changing SNR vector for exit analysis not currently supported.';
        else
            action = 'finishiteration';
            msg = '';
        end
        
    otherwise
        action = 'finishiteration';
        msg = '';
end

end