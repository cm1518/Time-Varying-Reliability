clear 
close all
clc

T=250;
sigma_m = 0.2290; % stdev of MP shock of the SW-DGP


states=randn(T-4,1);
states(5:140,1)=states(5:140,1)+5;
states(150:230,1)=states(150:230,1)+5;


P = NaN(2);
mc = dtmc(P,'StateNames',["Expansion" "Recession"]);
mdl = arima(0,0,0);
Mdl = msVAR(mc,[mdl; mdl]);

P0 = 0.5*ones(2);
mc0 = dtmc(P0,'StateNames',Mdl.StateNames);
mdl01 = arima('Constant',5,'Variance',1);
mdl02 = arima('Constant',0,'Variance',1);
Mdl0 = msVAR(mc0,[mdl01; mdl02]);

EstMdl = estimate(Mdl,Mdl0,states);

summarize(EstMdl)

%Y = simulate(EstMdl,270); 



% Define a 2x2 Markov transition matrix  
P = EstMdl.Switch.P;  
  
% Initial state (1 or 2)  
initialState = randi(2);  
  
% Number of steps to simulate  
numSteps = T;  
  
% Simulate the Markov chain  
simulatedStates = simulateMarkovChain(P, initialState, numSteps)';  
  
% Display the simulated states  
plot(simulatedStates);  





function states = simulateMarkovChain(transitionMatrix, initialState, numSteps)  
    % Function to simulate states given a 2x2 Markov transition matrix  
    %   
    % Inputs:  
    %   transitionMatrix - 2x2 matrix representing the Markov transition probabilities  
    %   initialState - Initial state (1 or 2)  
    %   numSteps - Number of steps to simulate  
    %  
    % Output:  
    %   states - Array of simulated states  
  
    % Validate inputs  
    if size(transitionMatrix, 1) ~= 2 || size(transitionMatrix, 2) ~= 2  
        error('Transition matrix must be 2x2.');  
    end  
    if initialState ~= 1 && initialState ~= 2  
        error('Initial state must be 1 or 2.');  
    end  
    if numSteps <= 0  
        error('Number of steps must be a positive integer.');  
    end  
  
    % Initialize the states array  
    states = zeros(1, numSteps);  
    states(1) = initialState;  
  
    % Simulate the Markov chain  
    for t = 2:numSteps  
        currentState = states(t-1);  
        if currentState == 1  
            states(t) = find(rand <= cumsum(transitionMatrix(1, :)), 1);  
        else  
            states(t) = find(rand <= cumsum(transitionMatrix(2, :)), 1);  
        end  
    end  
end  