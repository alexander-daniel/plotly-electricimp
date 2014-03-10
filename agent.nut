local tokens = {
    lighttoken = "gkf702rvnq",
    temptoken = "cqdx85joo1"
}

device.on("init" function(msg) {
    local data = [{
        x = [],
        y = [],
        type = "scatter",
        mode = "markers",
        stream = {
            token = tokens.lighttoken,
            maxpoints = 500
        }
    },
    {
        x = [],
        y = [],
        type = "bar"
        stream = {
            token = tokens.temptoken,
            maxpoints = 500
        }
    }];

    local layout = {
        fileopt = "extend",
        filename = "Sunlight Jams3",

    };


    local payload = {
    un = "electricimp",
    key = "6hpu3v8jaf",
    origin = "plot",
    platform = "rest",
    args = http.jsonencode(data),
    kwargs = http.jsonencode(layout),
    version = "0.0.1"
    };
    // encode data and log
    local headers = { "Content-Type" : "application/json" };
    local body = http.urlencode(payload);
    local url = "https://plot.ly/clientresp";
    HttpPostWrapper(url, headers, body, true);

    device.send("initsuccess", "success");
});

local t = 0

device.on("sendlight", function(incoming) {
    local headers = {"plotly-streamtoken" : tokens.lighttoken };
    local body = {
        x = incoming.time_stamp,
        y = 8,
        marker = {
            size = (incoming.light_sensor_reading)*2,
        },
        text = incoming.light_sensor_reading
    }
    local data = http.jsonencode(body);
    local url  = "http://54.201.244.104:9999/"
    HttpPostWrapper(url, headers, data, false);
});


device.on("sendtemp", function(incoming) {
    local headers = {"plotly-streamtoken" : tokens.temptoken };
    local body = {
        x = incoming.time_stamp,
        y = incoming.temp_sensor_reading,
    }
    local data = http.jsonencode(body);
    local url  = "http://54.201.244.104:9999/"
    HttpPostWrapper(url, headers, data, false);
});

function HttpPostWrapper (url, headers, string, log) {

  local request = http.post(url, headers, string);
  local response = request.sendsync();
  if (log)
    server.log(http.jsonencode(response));
  return response;

}



