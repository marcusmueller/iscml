The purpose of this tutorial is to acquaint a new user with the fundamentals of CML using simulation of BPSK error-rate in AWGN as an example.


**Contents**



# Assumptions #

In this tutorial, it is assumed that the user has

  * An installation of MATLAB >= 7.6 (R2008a)

  * Downloaded and installed CML from the [CML Project Page](Cml.md)

  * Uncompressed CML to the directory **`<CMLROOT>`**.


# Simulating BPSK Error Rate in AWGN #

## Starting CML ##

  * Start MATLAB and cd to **`<CMLROOT>`**

  * Execute function 'CmlStartup' to set paths to CML functions and classes
    * ` >> CmlStartup`
> ![https://iscml.googlecode.com/svn/trunk/pcs/projects/cml/doc/web/cml_startup.jpg](https://iscml.googlecode.com/svn/trunk/pcs/projects/cml/doc/web/cml_startup.jpg)



## Simulation Specification ##
  * CML simulations are specified by _records_ stored in _scenario files_.

  * A record contains a complete set of parameters to specify a simulation, such as modulation, channel type, and channel code.

  * In this example, we will illustrate usage of a record specifying error-rate simulation of BPSK in AWGN.
    * **Scenario file location:** **`<CMLROOT>`**/scenarios/UncodedScenarios.m
    * **Record:** 1

  * To view this scenario file in MATLAB,
    * ` >> edit UncodedScenarios.m `

### UncodedScenarios.m ###
```
record = 1;
sim_param(record).sim_type = 'uncoded';    % This is an uncoded error-rate simulation.
sim_param(record).modulation = 'BPSK';     % Modulation type is BPSK
sim_param(record).mod_order = 2;           % Modulation order is 2
sim_param(record).channel = 'AWGN';        % Channel type is AWGN
sim_param(record).minBER = 1e-6;           % We want to simulate down to an error-rate of 1e-6
sim_param(record).SNR_type = 'Eb/No in dB' % The SNR range is specified in energy-per-bit
sim_param(record).SNR = [0:0.5:11];        % Desired SNR range in dB
sim_param(record).framesize = 100000;      % Each frame contains 100,000 symbols

% Maximum trials to execute per SNR point
sim_param(record).max_trials = 100000*ones( size(sim_param(record).SNR) );
% Maximum frame errors to gather at each SNR point
sim_param(record).max_frame_errors = 60*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 10;
sim_param(record).comment = 'Uncoded BPSK in AWGN';   % 
sim_param(record).linetype = 'g:';
sim_param(record).legend = sim_param(record).comment;
sim_param(record).filename = strcat( data_directory, 'BPSKAWGN.mat');
sim_param(record).reset = 0;
```

  * Several example scenario files may be found in **`<CMLROOT>`**/scenarios.

  * User-created scenario files are stored in **`<CMLROOT>`**/localscenarios.
    * The recommended procedure for creating a new scenario file is to copy an existing scenario from **`<CMLROOT>`**/scenarios to **`<CMLROOT>`**/localscenarios and modifying the contents of the copy.

## Executing the Simulation ##

  * To execute simulation of the record,
    * ` >> CmlSimulate('UncodedScenarios', 1) `

  * The simulation will execute, stopping at the SNR point satisfying the minimum error-rate criteria.

  * Simulation time will range from 1-5 minutes depending on the speed of the executing computer.


![https://iscml.googlecode.com/svn/trunk/pcs/projects/cml/doc/web/cml_simulate.jpg](https://iscml.googlecode.com/svn/trunk/pcs/projects/cml/doc/web/cml_simulate.jpg)


## Plotting Results ##
  * Once the simulation is complete, error-rate results may be plotted using
    * ` >> CmlPlot('UncodedScenarios', 1) `

  * Two BPSK error-rate plots will be generated
    1. Bit-error rate (BER) vs SNR
    1. Symbol-error rate (SER) vs SNR
  * which are identical under binary modulation.

![https://iscml.googlecode.com/svn/trunk/pcs/projects/cml/doc/web/cml_plot.jpg](https://iscml.googlecode.com/svn/trunk/pcs/projects/cml/doc/web/cml_plot.jpg)



## Summary of Steps ##
  * Download and install CML from the [CML Project Page](Cml.md).


  * Start MATLAB and initialize CML.
    * `>> cd` **`<CMLROOT>`**
    * `>> CmlStartup`

  * Execute simulation of BPSK in AWGN.
    * ` >> CmlSimulate('UncodedScenarios', 1)`

  * Plot results.
    * ` >> CmlPlot('UncodedScenarios',1)`