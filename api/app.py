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


async def loop(request):
    data = await request.post()
    question = json.loads(data["question"])
    print(question['messages'][0]['content'])
    res = iris.execute(question['messages'][0]['content'])[1]
    results = {"action":"succeed", "content":"{}".format(res)}
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
