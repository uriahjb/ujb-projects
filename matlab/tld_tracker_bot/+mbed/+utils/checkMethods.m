% Do a very simple check of the methods for all the classes
function checkMethods()

import mbed.*

%% verify that the pins and leds have been specified correctly
pins = {'p5'    'p6'    'p7'    'p8'    'p9'    'p10'    'p11'    'p12'    'p13'    ...
    'p14'    'p15'    'p16'    'p17'    'p18'    'p19'    'p20' ...
    'p21'    'p22'    'p23'    'p24'    'p25'    'p26'    'p27'    'p28'    'p29'    'p30'};
for i=1:numel(pins)
   p = mbed.(pins{i}) ;
   assert( strcmp(p.name,pins{i}) && (p.no == str2double(pins{i}(2:end))) );
   fprintf('Verified %s\n', p.name);
end

leds = { 'LED1', 'LED2', 'LED3', 'LED4'};
for i=1:numel(leds)
   p = mbed.(leds{i}) ;
   assert( strcmp(p.name,leds{i}) && (p.no == str2double(leds{i}(4:end))) );
   fprintf('Verified %s\n', p.name);
end

%% Verify the methods for the analog and digital i/o
m = TestRPC();

fprintf('\n--- AnalogIn ---\n');
ai = AnalogIn(m, p15);
read(ai);
read_u16(ai);

fprintf('\n--- AnalogOut ---\n');
ao = AnalogOut(m, p18);
read(ao);
write(ao, 15.2);
write_u16(ao,44);

fprintf('\n--- DigitalIn ---\n');
di = DigitalIn(m, p14);
read(ai);
options = {'PullUp', 'PullDown', 'PullNone', 'OpenDrain'};
for i=1:numel(options)
   mode(di, options{i});
end

fprintf('\n--- DigitalOut ---\n');
do = DigitalOut(m, p16);
read(do);
write(do,1);
write(do,0);

fprintf('\n--- PwmOut ---\n');
pwm = PwmOut(m, p21);
period(pwm, 48.7);
period_ms(pwm, 22);
period_us(pwm, 1000);
pulsewidth(pwm, 92.3);
pulsewidth_ms(pwm, 22);
pulsewidth_us(pwm, 1000);
read(pwm);
write(pwm,17.3);

% LEDs
fprintf('\n--- DigitalOut with LEDs ---\n');
led = DigitalOut(m, LED1);
write(led,1);
write(led,0);

%% verify Serial class
fprintf('\n--- Serial ---\n');
ser = Serial(m, p9, p10);
ser.baud(9600);
ser.getc();
ser.putc('c');
ser.readable();
ser.writeable();
ser.puts('abcd')
ser.gets();

%%
delete(m);

