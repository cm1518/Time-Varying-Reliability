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