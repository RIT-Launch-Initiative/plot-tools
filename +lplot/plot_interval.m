% Plot one or two variables between given event labels
% [pl, pr, xl] = plot_interval(table, first, second,  ... 
%                   start_ev = "EVENT", end_ev = "EVENT" [, labels = ["EVENT1", "EVENT2", ...]])
% INPUTS
%   table:      Table imported from OpenRocket
%   first:      variable to plot on the left axis
%   second:     (optional) variable to plot on the right axis
%   start_ev:   (optional) starting event label (must occur exactly once in the table)
%               default "LAUNCH"
%   end_ev:     (optional) ending event label (must occur exactly once in the table)
%               default "SIMULATION_END"
%   labels:    (optional) additonal markers between the start and end to include
%               The start and end markers are always present
%               Markers beyond the bounds start/end_ev are ignored
% OUTPUTS
%   pl: left plot Line object (to further customize properties e.g. color, marker)
%   pr: (set only if <second> is provided) right plot Line object
%   xl: marker line object
% 
% Example: plot_interval(omen, "Altitude", ...
%               start_ev = "LAUNCH", end_ev = "GROUND_HIT", labels = ["BURNOUT", "DROGUE", "MAIN"]);
% Example: plot_interval(omen, "Angle of attack", "Stability margin", ...
%               start_ev = "LAUNCHROD", end_ev = "APOGEE", labels = "BURNOUT");
% 

function [pl, pr, xl] = plot_interval(table, first, second, interval, markers)
    arguments
        table timetable;
        first (1,1) string;
        second (1,1) string = "";
        interval.start_ev (1,1) string = "LAUNCH";
        interval.end_ev (1,1) string = "SIMULATION_END";
        markers.labels (1, :) string = [];
    end

    import lplot.*;

    %% Restrict table to selection
    plot_range = timerange(eventfilter(interval.start_ev), ...
        eventfilter(interval.end_ev), "closed");

    if second == ""
        table = table(plot_range, first);
    else
        table = table(plot_range, [first, second]);
        yyaxis left;
    end
    
    %% Plot
    % plot left axis
    pl = plot(table, first);
    ylabels(first, table.Properties.VariableUnits{1});

    % plot right axis if present
    if second ~= ""
        yyaxis right;

        pr = plot(table, second);
        ylabels(second, table.Properties.VariableUnits{2});

        yyaxis left;
    end

    xlabel("Time");

    %% Get markers that are selected and in the time range
    % get time-based range instead of event-based range 
    % can't subscript into eventtable using eventfilters for some reason
    plot_time_range = timerange(table.Time(1), table.Time(end), "closed");
    ev_in_range = table.Properties.Events(plot_time_range, :);
    selected_ev = ismember(ev_in_range.EventLabels, ...
        [markers.labels, interval.start_ev, interval.end_ev]);

    % TODO the selected_ev line currently adds the start and end to the labels
    % to look for, so the start and end are always marked no matter what. Would
    % it be better to default markers.labels to start and end but allow a total
    % override?

    % plot markers
    xl = xline(ev_in_range.Time(selected_ev), "-k", ...
        ev_in_range.EventLabels(selected_ev), ...
        Interpreter = "none", HandleVisibility = "off");
    xl(end).LabelHorizontalAlignment = "left";
end

