local tokens = {
    lighttoken = "gkf702rvnq",
    pottoken = "cqdx85joo1"
}

device.on("init" function(msg) {
    local data = [{
        x = [],
        y = [],
        stream = {
            token = tokens.lighttoken,
            maxpoints = 25
        }
    },
    {
        x = [],
        y = [],
        stream = {
            token = tokens.pottoken,
            maxpoints = 25
        }
    }];

    local layout = {
        fileopt = "extend",
        filename = "Electric Imp 8"

    };
    // Set Content-Type header to json
    local headers = { "Content-Type" : "application/json" };

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
    local body = http.urlencode(payload);
    local url = "https://plot.ly/clientresp";
    HttpPostWrapper(url, headers, body, true);

    device.send("initsuccess", "success");
});

device.on("sendlight", function(incoming) {
    local headers = {"plotly-streamtoken" : tokens.lighttoken };
    local body = {
        x = getTime(),
        y = incoming
    }
    local data = http.jsonencode(body);
    local url  = "http://54.201.244.104:9999/"
    //server.log(data);
    HttpPostWrapper(url, headers, data, false);
});

device.on("sendpot", function(incoming) {
    local headers = {"plotly-streamtoken" : tokens.pottoken };
    local body = {
        x = getTime(),
        y = incoming
    }
    local data = http.jsonencode(body);
    local url  = "http://54.201.244.104:9999/"
    //server.log(data);
    HttpPostWrapper(url, headers, data, false);
});


function HttpPostWrapper (url, headers, string, log) {

  local request = http.post(url, headers, string);
  local response = request.sendsync();
  if (log)
    server.log(http.jsonencode(response));
  return response;

}

function getTime() {
    local date = date();
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

