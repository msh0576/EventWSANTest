function [resultz] = ps_aggregation (call_count, Event_count1, Event_count2, Event_count3)

resultz = zeros(call_count, 8);

for i_pa = 1 : call_count
    [result status]= python('tossim-event-client.py',num2str(Event_count1),num2str(Event_count2),num2str(Event_count3))
    
    %[result status]= python('sqd.py','2', '1')
    %[result status]=python('test_tossim.py', num2str(rssi));
    %[result status]=python('example_socket_client.py', num2str(rssi));
    resultz(i_pa, :) = str2num(result);
end