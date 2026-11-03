import json

with open("../MarcMap/data/StopData.json", "r") as file:
    data = json.loads(file.read())
    for stop in data:
        name = stop["stop_name"].title()
        name = name.replace("Marc", "")
        name = name.replace("W Va", "")
        name = name.replace("Md", "")
        name = name.strip()
        stop["pretty_stop_name"] = name
    with open("../MarcMap/data/StopDataPretty.json", "w") as out:
        out.write(json.dumps(data))
