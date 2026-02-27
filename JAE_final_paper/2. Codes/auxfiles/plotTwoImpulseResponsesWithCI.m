function plotTwoImpulseResponsesWithCI(IR1, lowerCI1, upperCI1, IR2, lowerCI2, upperCI2, time, legendLabels, additionalIRF)
    % Function to plot two impulse responses with confidence bands and an optional additional IRF
    % 
    % Inputs:
    % IR1          - First impulse response (vector)
    % lowerCI1     - Lower bound of the confidence interval for the first impulse response (vector)
    % upperCI1     - Upper bound of the confidence interval for the first impulse response (vector)
    % IR2          - Second impulse response (vector)
    % lowerCI2     - Lower bound of the confidence interval for the second impulse response (vector)
    % upperCI2     - Upper bound of the confidence interval for the second impulse response (vector)
    % time         - Time vector (vector)
    % legendLabels - (Optional) Cell array containing legend labels for the impulse responses
    % additionalIRF - (Optional) Additional impulse response function to be plotted with asterisks (vector)
    %
    % Example usage:
    % plotTwoImpulseResponsesWithCI(IR1, lowerCI1, upperCI1, IR2, lowerCI2, upperCI2, time, {'IR1', 'IR2', 'Additional IRF'}, additionalIRF)

    % This function will create a plot with the impulse responses and their confidence bands semi-transparent, 
    % ensuring that neither of them completely covers the other. The FaceAlpha property controls the transparency
    % of the filled areas, and the Color property with an alpha value controls the transparency of the lines.

    % Check if the inputs are of the same length
    if length(IR1) ~= length(lowerCI1) || length(IR1) ~= length(upperCI1) || length(IR1) ~= length(time) || ...
       length(IR2) ~= length(lowerCI2) || length(IR2) ~= length(upperCI2) || length(IR2) ~= length(time)
        error('All input vectors must be of the same length');
    end

    % Check if the inputs are vectors
    if ~isvector(IR1) || ~isvector(lowerCI1) || ~isvector(upperCI1) || ~isvector(IR2) || ~isvector(lowerCI2) || ~isvector(upperCI2) || ~isvector(time)
        error('All inputs must be vectors');
    end

    % Check if additionalIRF is provided and is a vector of the same length as time
    if nargin == 9 && ~isempty(additionalIRF)
        if ~isvector(additionalIRF) || length(additionalIRF) ~= length(time)
            error('additionalIRF must be a vector of the same length as time');
        end
    end

    % Plot the impulse responses
    hold on;
    
    % Plot the confidence bands for the second impulse response in blue with transparency
    fill([time; flipud(time)], [upperCI2; flipud(lowerCI2)], [0.6 0.8 1], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
    
    % Plot the second impulse response line in blue with transparency
    h2 = plot(time, IR2, 'Color', [0 0 1 0.7], 'LineWidth', 1.5);
    
    % Plot the confidence bands for the first impulse response in grey with transparency
    fill([time; flipud(time)], [upperCI1; flipud(lowerCI1)], [0.8 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
    
    % Plot the first impulse response line in black with transparency
    h1 = plot(time, IR1, 'Color', [0 0 0 0.7], 'LineWidth', 1.5);
    
    % Plot the additional impulse response function with asterisks if provided
    if nargin == 9 && ~isempty(additionalIRF)
        h3 = plot(time, additionalIRF, 'g*', 'LineWidth', 1);
    end
    
    % Add labels and title
    xlabel('Horizon');
    ylabel('Impulse Response');
    
    % Add grid
    grid on;
    
    % Add legend if legendLabels is provided
    if nargin >= 8 && ~isempty(legendLabels)
        if ~iscell(legendLabels) || length(legendLabels) < 2 || (nargin == 9 && length(legendLabels) ~= 3)
            error('legendLabels must be a cell array with 2 or 3 elements');
        end
        if nargin == 9 && ~isempty(additionalIRF)
            legend([h1, h2, h3], legendLabels{1}, legendLabels{2}, legendLabels{3});
        else
            legend([h1, h2], legendLabels{1}, legendLabels{2});
        end
    end
    
    % Hold off to stop adding to the current plot
    hold off;

    axis tight;
end