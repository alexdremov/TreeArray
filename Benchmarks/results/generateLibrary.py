import json

with open('arrayOspeed.json') as file:
    data = json.load(file)['tasks']
    data = list(map(lambda x : x['title'], data))

output = []

for title in data:
    output += [dict(
            kind="chart",
            title= title[len("Array<Int> "):],
            tasks= [
               title,
               "Tree" + title
            ]
        )]
print(json.dumps(output))
