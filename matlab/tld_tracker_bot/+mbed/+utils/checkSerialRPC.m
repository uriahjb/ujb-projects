% Do a very simple check of some of the methods over SerialRPC
function checkSerialRPC(port)

if nargin < 1
    port = 'COM5';
end

import mbed.*

m = SerialRPC(port,9600);

fprintf('\n--- AnalogIn ---\n');
ai = AnalogIn(m, p15);
read(ai)
read_u16(ai)

fprintf('\n--- AnalogOut ---\n');
ao = AnalogOut(m, p18);
read(ao)
write(ao, 15.2);
write_u16(ao,44);

fprintf('\n--- DigitalIn ---\n');
di = DigitalIn(m, p14);
read(ai)
options = {'PullUp', 'PullDown', 'PullNone', 'OpenDrain'};
for i=1:numel(options)
   mode(di, options{i});
end

fprintf('\n--- DigitalOut ---\n');
do = DigitalOut(m, p16);
read(do)
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
read(pwm)
write(pwm,17.3);

% LEDs
fprintf('\n--- DigitalOut with LEDs ---\n');
led = DigitalOut(m, LED1);
write(led,1);
write(led,0);

delete(m);



