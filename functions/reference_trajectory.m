function reference_trajectory(block)
% Outputs matrix reference signal for MPC block
% Uses pre generated S trajectory instead of step refences

	setup(block);
  
%endfunction

function setup(block)
  
    block.NumDialogPrms  = 4;

    %% Register number of input and output ports
    block.NumInputPorts  = 1; % pos_sp
    block.NumOutputPorts = 1; % ref

    %% Setup functional port properties to dynamically
    %% inherited.
    block.SetPreCompInpPortInfoToDynamic;
    block.SetPreCompOutPortInfoToDynamic;

    %% Extract Dialog params
    pre_generated_traj  = block.DialogPrm(1).Data;
    PH                  = block.DialogPrm(2).Data;
    num_refs            = block.DialogPrm(3).Data;
    Ts_mpc              = block.DialogPrm(4).Data;
    
    %% Port dimentions
    block.InputPort(1).Dimensions        = 1;
    block.InputPort(1).DirectFeedthrough = true;

    block.OutputPort(1).Dimensions       = [num_refs, PH];

    %% Set block sample time to same as MPC
    block.SampleTimes = [Ts_mpc 0];

    %% Set the block simStateCompliance to default (i.e., same as a built-in block)
    block.SimStateCompliance = 'DefaultSimState';

    %% Register methods
    block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
    block.RegBlockMethod('InitializeConditions',    @InitConditions);  
    block.RegBlockMethod('Outputs',                 @Output);  
    block.RegBlockMethod('Update',                  @Update);  
    
    %% Check for errors
    if PH < length(pre_generated_traj)
        error('[reference_trajectory.m] Trajectory longer than prediction not supported. Increase PredictionHorizon or decrease Jerk time')
    end
%endfunction

function DoPostPropSetup(block)

    %% Extract Dialog params
    pre_generated_traj  = block.DialogPrm(1).Data;
    PH                  = block.DialogPrm(2).Data;
    num_refs            = block.DialogPrm(3).Data;

    %% Setup Dwork
    block.NumDworks = 2;
    
    block.Dwork(1).Name = 'prev_pos_sp'; % Previous setpoint
    block.Dwork(1).Dimensions      = 1;
    block.Dwork(1).DatatypeID      = 0;
    block.Dwork(1).Complexity      = 'Real';
    block.Dwork(1).UsedAsDiscState = true;

    block.Dwork(2).Name = 'prev_traj'; % Previous trajectory
    block.Dwork(2).Dimensions      = PH; % Must be column vector
    block.Dwork(2).DatatypeID      = 0;
    block.Dwork(2).Complexity      = 'Real';
    block.Dwork(2).UsedAsDiscState = true;

%endfunction

function InitConditions(block)
    %% Extract Dialog params
    pre_generated_traj  = block.DialogPrm(1).Data;
    PH                  = block.DialogPrm(2).Data;
    num_refs            = block.DialogPrm(3).Data;
    
    %% Initialize Dwork
    block.Dwork(1).Data = NaN;
    block.Dwork(2).Data = NaN+ones(PH,1);    
  
%endfunction

function Output(block)
    %% Extract Dialog params
    pre_generated_traj  = block.DialogPrm(1).Data;
    PH                  = block.DialogPrm(2).Data;
    num_refs            = block.DialogPrm(3).Data;
    
    %% Get Dwork memory
    prev_pos_sp = block.Dwork(1).Data;
    prev_traj = block.Dwork(2).Data;
    
    %% Input
    pos_sp = block.InputPort(1).Data;
    
    %% Set actual initial condition if NaN
    if isnan(prev_pos_sp) % Means that it is still initial values
        prev_pos_sp = pos_sp;
        prev_traj = pos_sp*ones(PH,1);
    end
    
    %% Calculations
    P = pos_sp - prev_pos_sp; % Step distance to travel

    if abs(P) > 1e-2 % Step occured if threshold breached    
        % Pre generated trajectory for a single step size only
        pos_traj = prev_pos_sp + pre_generated_traj; % previous position + step trajectory sp. Remove first entry because setpoint starts from future time step

    else % Complete current trajectory
        pos_traj = [prev_traj(2:PH)', prev_traj(PH)']; % delete timestep that passed. (prev_traj is column vecotr)
    end

    % Add zeros for references/setpoints of other states and fill rows of MPC
    % matrix signal
    % ref(:,1) = [dtheta_sp(k+1), pos_sp(k+1), vel_sp(k+1), theta_sp(k+1), delay states...]
    ref = zeros(num_refs, PH); % Matrix signal always same size
    ref(2,:) = pos_traj; % Assign pos row to traj

    %% Output
    block.OutputPort(1).Data = ref;
    
    %% Save memory
    block.Dwork(1).Data = pos_sp; % prev_pos_sp
    block.Dwork(2).Data = pos_traj; % prev_traj
  
%endfunction

function Update(block)

  
%endfunction

