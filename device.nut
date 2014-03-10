local light_sensor = hardware.pin8;
local temp_sensor = hardware.pin2;

light_sensor.configure(ANALOG_IN);
temp_sensor.configure(ANALOG_IN);


function init() {
    agent.send("init", "hello");
}

function getLight() {
    server.log("getting light");
    local supplyVoltage = hardware.voltage();
    local voltage = supplyVoltage * light_sensor.read() / 65535.0;
    return (voltage)*20;
}

function getTemp() {
    server.log("getting temp");
    local supplyVoltage = hardware.voltage();
    local voltage = supplyVoltage * temp_sensor.read() / 65535.0;
    local c = (voltage - 0.5) * 100 ;
    return c;
}

function getLightSensor() {
    local sensordata = {
        light_sensor_reading = getLight(),
        time_stamp = getTime(),
        }
    agent.send("sendlight", sensordata);
    imp.wakeup(1, getLightSensor);

}

function getTempSensor() {
    local sensordata = {
        temp_sensor_reading = getTemp(),
        time_stamp = getTime(),
        }
    agent.send("sendtemp", sensordata);
    imp.wakeup(1, getTempSensor);
}

function getTime() {
    local date = date(time(), "l");
    local sec = stringTime(date["sec"]);
    local min = stringTime(date["min"]);
    local hour = stringTime(date["hour"]);
    local day = stringTime(date["day"]);
    local month = date["month"];
    local year = date["year"];
    return year+"-"+month+"-"+day+" "+hour+":"+min+":"+sec;

}

function stringTime(num) {
    if (num < 10)
        return "0"+num;
    else
        return ""+num;
}

agent.on("initsuccess" function(msg) {
   getTempSensor();
   getLightSensor();
});

init();
