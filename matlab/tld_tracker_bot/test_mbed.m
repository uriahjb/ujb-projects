% Connect to mbed through ethernet bridge and send pwm rpc command
import mbed.*
m = mbed.HTTPRPC('192.168.0.11')
speed_pwm = mbed.PwmOut(m, mbed.p21)
pause(0.1)
speed_pwm.period(1/50)
speed_pwm.pulsewidth(0.0011)

steer_pwm = mbed.PwmOut(m, mbed.p22)
pause(0.1)
steer_pwm.period(1/50)
steer_pwm.pulsewidth(0.0016)

m1_pwm = mbed.PwmOut(m, mbed.p23)
pause(0.1)
m1_pwm.period(1/50)
m1_pwm.pulsewidth(0.0016)

m2_pwm = mbed.PwmOut(m, mbed.p24)
pause(0.1)
m2_pwm.period(1/50)
m2_pwm.pulsewidth(0.0016)



