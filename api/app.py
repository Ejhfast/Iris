from aiohttp import web
import json
import os
import sys
import aiohttp_cors
sys.path.insert(0, os.path.abspath('..'))
from demo import iris

PORT = int(os.environ.get("PORT", 8000))

app = web.Application()

cors = aiohttp_cors.setup(app)

def add_cors(route):
    cors.add(route, {"*": aiohttp_cors.ResourceOptions(
                 allow_credentials=True,
                 expose_headers="*",
                 allow_headers="*")})

def parse_args(j_data):
    messages = j_data['messages']
    fail_indexes = [i for i,x in enumerate(messages) if x["origin"] == "iris" and x["kind"] == "ask" ]
    args = {}
    for i in fail_indexes:
        iris_ask = messages[i]["content"]
        var = iris_ask.split()[-1][:-1]
        print(var)
        args[var] = messages[i+1]["content"]
    return args

async def loop(request):
    data = await request.post()
    question = json.loads(data["question"])
    print(question)
    top_level_q = question['messages'][0]['content']
    args = parse_args(question)
    res = iris.loop(top_level_q, args)
    if res[0] == "Success":
        results = {"action":"success", "content":res[1]}
    elif res[0] == "Ask":
        results = {"action":"ask", "content":res[1]}
    else:
        results = {"action":"fail", "content":res[1]}
    print(results)
    return web.json_response(results)

add_cors(app.router.add_route('POST', '/loop', loop))

async def classify_query(request):
    data = await request.post()
    query = data["query"]
    results = iris.best_n(query)
    return web.json_response(results)

add_cors(app.router.add_route('POST', '/classify', classify_query))

async def execute_function(request):
    data = await request.post()
    ex_class = data["class"]
    args = json.loads(data["args"])
    print(ex_class,args)
    execution = iris.call_class(int(ex_class), args)
    return web.json_response({"result": str(execution)})

add_cors(app.router.add_route('POST', '/execute', execute_function))

web.run_app(app,port=PORT)
