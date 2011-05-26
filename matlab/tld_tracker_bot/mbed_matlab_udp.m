% Initializing UDP connection, mbed is 192.168.0.11, we are 192.168.0.1
u = udp('192.168.0.11', 3444, 'localport', 3444);
% Writing data
fwrite(u, 'hello, its me Uriah!');
% Reading data
fscanf(u, '%c');

