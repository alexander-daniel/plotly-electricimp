local light_sensor = hardware.pin8;
local pot = hardware.pin1;

light_sensor.configure(ANALOG_IN);
pot.configure(ANALOG_IN);


function init() {
    agent.send("init", "hello");
}

function getLight() {
    server.log("getting light");
    local supplyVoltage = hardware.voltage();
    local voltage = supplyVoltage * hardware.pin8.read() / 65535.0;
    return (voltage)*20;
}

function getPot() {
    server.log("getting pot");
    local supplyVoltage = hardware.voltage();
    local voltage = supplyVoltage * hardware.pin1.read() / 65535.0;
    return (voltage)*20;
}

function getSensors() {
    local light = getLight();
    local pot = getPot();
    local sensordata
    agent.send("sendlight", light);
    agent.send("sendpot", pot);
    imp.wakeup(1, getSensors);

}
agent.on("initsuccess" function(msg) {
   getSensors();
});

init();
//getLight();