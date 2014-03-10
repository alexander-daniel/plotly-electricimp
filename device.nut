// initialize  pins
local sensor = hardware.pin1;
sensor.configure(ANALOG_IN);

// When device is started, start Agent Initialization process
function init() {
    agent.send("init", "hello");
}

// Returns sensor voltage
function getSensorVoltage() {
    local supplyVoltage = hardware.voltage();
    local voltage = supplyVoltage * sensor.read() / 65535.0;
    return (voltage);
}

// Sends new reading to the Agent to be Streamed
function readSensor() {
    local sensordata = {
        sensor_reading = getSensorVoltage(),
        time_stamp = getTime(),
        }
    agent.send("new_reading", sensordata);
    imp.wakeup(1, readSensor); // Frequency to Stream data to Plot.ly (min 1)

}

// Get Time String, -14400 is for -4 GMT (Montreal)
// use 3600 and multiply by the hours +/- GMT.
// e.g for +5 GMT local date = date(time()+18000, "u");
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

// Fix Time String
function stringTime(num) {
    if (num < 10)
        return "0"+num;
    else
        return ""+num;
}

// When the Agent is initialized, start Streaming Data!
agent.on("initsuccess" function(msg) {
    readSensor();
});

// Send initialization:start message to Agent
init();
